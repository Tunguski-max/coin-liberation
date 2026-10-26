/*
    File: fn_spawnSiteAmbush.sqf
    Author: COIN Liberation

    Description:
        Spawns the ambush at the site of an aid task (ticket 5.22, ADR 0024, DESIGN 8.2), after the plan of
        COIN_fnc_planSiteAmbush. Built like the ambush of a camp (COIN_fnc_spawnAmbush), but at the place of the plan without a
        camp: militia fighters in a row (COIN_ambushSpacing apart, kneeling, facing the way the plan says, not moving), cover objects of
        COIN_ambushCoverClasses in front of some of them, and in houses of the village (map houses within COIN_siteHouseRadius
        of its centre that have building positions) the fighters of the plan, standing in a room. Both groups hold fire
        (COIN_ambushHoldFire) until COIN_fnc_runSiteAmbush lets them open fire. The fighters are managed by Liberation's kill
        manager, marked as COIN units for the AI budget (the caller asked it) and come from the nest of the plan
        (COIN_origin "camp", nest id, no camp), so a prisoner names that nest in the interrogation. Everything goes to Zeus.
        Server only.

    Parameter(s):
        _plan     - Result of COIN_fnc_planSiteAmbush [ARRAY]
        _centre   - Centre of the village [ARRAY]
        _place    - Name of the village, for the log [STRING]
        _distance - Distance of the nearest player, for the log [NUMBER]

    Returns:
        [spawned objects and units, fighters] [ARRAY]
*/

params [
    ["_plan", [], [[]]],
    ["_centre", [], [[]]],
    ["_place", "", [""]],
    ["_distance", 0, [0]]
];

if (!isServer || {_plan isEqualTo []}) exitWith {[[], []]};

_plan params ["_nestId", "_pos", "_dir", "", "_fighterCount", "_coverCount", "_houseCount"];

// A fighter of the militia, from the nest of the plan
private _createFighter = {
    params ["_spot", "_group"];
    private _unit = [selectRandom militia_squad, _spot, _group] call KPLIB_fnc_createManagedUnit;
    _unit disableAI "PATH";
    _unit setVariable ["COIN_origin", ["camp", _nestId, -1]];
    _unit
};

private _group = createGroup [GRLIB_side_enemy, true];
private _fighters = [];
private _spots = [];

for "_i" from 0 to (_fighterCount - 1) do {
    // In a row across the direction he faces, a little nearer to or farther from the line
    private _along = (_i - (_fighterCount - 1) / 2) * COIN_ambushSpacing;
    private _spot = (_pos getPos [_along, _dir + 90]) getPos [(random (2 * COIN_ambushDepthJitter)) - COIN_ambushDepthJitter, _dir];
    if (surfaceIsWater _spot || {isOnRoad _spot}) then {
        _spot = _pos;
    };
    _spot = [_spot select 0, _spot select 1, 0];

    private _unit = [_spot, _group] call _createFighter;
    _unit setPosATL _spot;
    _unit setDir _dir;
    _unit setUnitPos COIN_ambushHideStance;
    _fighters pushBack _unit;
    _spots pushBack _spot;
};
_group setBehaviour COIN_ambushHideBehaviour;
_group setCombatMode COIN_ambushHoldFire;

// Cover in front of some of the fighters
private _classes = COIN_ambushCoverClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
if (count _classes < count COIN_ambushCoverClasses) then {
    diag_log format ["[COIN] danger: the ambush at %1 leaves out cover classes that do not exist: %2", _place, COIN_ambushCoverClasses - _classes];
};
private _objects = +_fighters;
if (_classes isNotEqualTo []) then {
    // At most one per fighter (after a visit fewer fighters may be left)
    for "_i" from 0 to ((_coverCount min _fighterCount) - 1) do {
        private _spot = (_spots deleteAt (floor random count _spots)) getPos [COIN_ambushCoverDistance, _dir];
        private _cover = createVehicle [selectRandom _classes, [_spot select 0, _spot select 1, 0], [], 0, "CAN_COLLIDE"];
        _cover setDir _dir;
        _cover setVectorUp (surfaceNormal (getPosATL _cover));
        _objects pushBack _cover;
    };
};

// Fighters in houses of the village, one house each, a room position at random
private _houses = (nearestTerrainObjects [_centre, COIN_siteHouseTypes, COIN_siteHouseRadius, false, true]) select {
    (_x buildingPos -1) isNotEqualTo []
};
private _houseFighters = [];
if (_houses isNotEqualTo [] && {_houseCount > 0}) then {
    private _houseGroup = createGroup [GRLIB_side_enemy, true];
    for "_i" from 1 to (_houseCount min count _houses) do {
        private _house = _houses deleteAt (floor random count _houses);
        private _spot = selectRandom (_house buildingPos -1);
        private _unit = [_spot, _houseGroup] call _createFighter;
        _unit setPos _spot;
        _unit setDir (random 360);
        _unit setUnitPos COIN_aidAmbushHouseStance;
        _houseFighters pushBack _unit;
    };
    _houseGroup setBehaviour COIN_ambushHideBehaviour;
    _houseGroup setCombatMode COIN_ambushHoldFire;
};
_fighters append _houseFighters;
_objects append _houseFighters;

[_fighters] call COIN_fnc_markCoinUnits;
[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] danger: ambush at %1 (nest %2) spawned at %3, player %4 m away: %5 fighters, %6 cover objects, %7 in houses (%8 asked for)",
    _place, _nestId, _pos, round _distance, _fighterCount, count _objects - count _fighters, count _houseFighters, _houseCount
];

[_objects, _fighters]
