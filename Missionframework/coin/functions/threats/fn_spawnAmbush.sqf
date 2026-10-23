/*
    File: fn_spawnAmbush.sqf
    Author: COIN Liberation

    Description:
        Spawns an ambush when players come near (ticket 4.5, DESIGN 6, ADR 0015), after the plan of COIN_fnc_planAmbush:
        militia fighters in a row beside the road (COIN_ambushSpacing apart, kneeling, facing the road, not moving) and
        a few cover objects of COIN_ambushCoverClasses in front of some of them. The group holds fire
        (COIN_ambushHoldFire) until COIN_fnc_ambushWatch lets it open fire. The fighters are managed by Liberation's kill
        manager, marked as COIN units for the AI budget and come from the camp ("camp", nest, camp id) for a
        later interrogation. Everything goes to Zeus. The budget is asked by the caller. Server only.

    Parameter(s):
        _camp     - Camp with an ambush [ARRAY, layout in COIN_fnc_createCamp]
        _plan     - Result of COIN_fnc_planAmbush [ARRAY]
        _distance - Distance of the nearest player, for the log [NUMBER]

    Returns:
        [spawned objects and units, fighters] [ARRAY]
*/

params [
    ["_camp", [], [[]]],
    ["_plan", [], [[]]],
    ["_distance", 0, [0]]
];

if (!isServer) exitWith {[[], []]};

_camp params ["_id", "_nestId", "_campPos"];
(_camp select 8) params ["_pos", "_dir"];
_plan params ["_fighterCount", "_coverCount"];

private _group = createGroup [GRLIB_side_enemy, true];
private _fighters = [];
private _spots = [];

for "_i" from 0 to (_fighterCount - 1) do {
    // In a row across the direction he faces, a little nearer to or farther from the road
    private _along = (_i - (_fighterCount - 1) / 2) * COIN_ambushSpacing;
    private _spot = (_pos getPos [_along, _dir + 90]) getPos [(random (2 * COIN_ambushDepthJitter)) - COIN_ambushDepthJitter, _dir];
    if (surfaceIsWater _spot || {isOnRoad _spot}) then {
        _spot = _pos;
    };
    _spot = [_spot select 0, _spot select 1, 0];

    private _unit = [selectRandom militia_squad, _spot, _group] call KPLIB_fnc_createManagedUnit;
    _unit setPosATL _spot;
    _unit setDir _dir;
    _unit setUnitPos COIN_ambushHideStance;
    _unit disableAI "PATH";
    _unit setVariable ["COIN_origin", ["camp", _nestId, _id]];
    _fighters pushBack _unit;
    _spots pushBack _spot;
};
_group setBehaviour COIN_ambushHideBehaviour;
_group setCombatMode COIN_ambushHoldFire;
[_fighters] call COIN_fnc_markCoinUnits;

// Cover in front of some of the fighters, on the side of the road
private _classes = COIN_ambushCoverClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
if (count _classes < count COIN_ambushCoverClasses) then {
    diag_log format ["[COIN] ambushes: ambush of camp %1 leaves out cover classes that do not exist: %2", _id, COIN_ambushCoverClasses - _classes];
};
private _objects = +_fighters;
if (_classes isNotEqualTo []) then {
    for "_i" from 0 to (_coverCount - 1) do {
        private _spot = (_spots deleteAt (floor random count _spots)) getPos [COIN_ambushCoverDistance, _dir];
        private _cover = createVehicle [selectRandom _classes, [_spot select 0, _spot select 1, 0], [], 0, "CAN_COLLIDE"];
        _cover setDir _dir;
        _cover setVectorUp (surfaceNormal (getPosATL _cover));
        _objects pushBack _cover;
    };
};

[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] ambushes: ambush of camp %1 (nest %2) spawned at %3, %4 m from its camp, player %5 m away: %6 fighters, %7 cover objects, facing %8 degrees",
    _id, _nestId, _pos, round (_pos distance2D _campPos), round _distance, _fighterCount, count _objects - _fighterCount, round _dir
];

[_objects, _fighters]
