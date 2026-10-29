/*
    File: fn_spawnMortarSquad.sqf
    Author: COIN Liberation

    Description:
        Spawns the mortar squad of a mortar attack (ticket 6.7a, #158, DESIGN 9): a light mortar (the first class of
        COIN_mortarClasses that exists, Project OPFOR has none for the Afghan Militia) facing the FOB, and
        COIN_mortarCrew militia fighters, one of them its gunner. The fighters hold their place (no path). They are
        managed by Liberation's kill manager, marked as COIN units for the AI budget (the squad always spawns, the budget
        is not asked) and all of it goes to Zeus. In the area of a command post the fighters get COIN_origin
        ["camp", nest id, -1], so a prisoner names that nest in the interrogation; in the area of a military post only they
        have none and the interrogation follows the rule "Welches Nest" (DESIGN 7). Server only.

    Parameter(s):
        _spot - Position of the mortar [ARRAY]
        _fob  - Position of the FOB it faces [ARRAY]

    Returns:
        [group, fighters, mortar] or [] if no class of COIN_mortarClasses exists [ARRAY]
*/

params [
    ["_spot", [], [[]], [2, 3]],
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer) exitWith {[]};

private _classes = COIN_mortarClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_classes isEqualTo []) exitWith {
    diag_log format ["[COIN] mortar: ERROR - no class of COIN_mortarClasses exists, no squad: %1", COIN_mortarClasses];
    []
};

private _dir = _spot getDir _fob;
private _mortar = createVehicle [_classes select 0, _spot, [], 0, "CAN_COLLIDE"];
_mortar setDir _dir;
_mortar setVectorUp (surfaceNormal (getPosATL _mortar));
_mortar setVehicleAmmo 1;

private _group = createGroup [GRLIB_side_enemy, true];
private _fighters = [];
for "_i" from 0 to (COIN_mortarCrew - 1) do {
    private _unit = [selectRandom militia_squad, _spot, _group] call KPLIB_fnc_createManagedUnit;
    if (_i isEqualTo 0) then {
        _unit moveInGunner _mortar;
    } else {
        _unit setPosATL (_spot getPos [2.5, _dir + 120 * _i]);
        _unit setDir _dir;
    };
    _unit disableAI "PATH";
    _fighters pushBack _unit;
};
// A prisoner names the command post of the staging area the squad stands in (ticket 6.7b, #159), the convention of the other
// COIN units: origin "camp" with the nest id. In the area of a military post only: no origin, he follows the rule "Which nest"
private _commandAreas = ([_spot] call COIN_fnc_getStagingAreasAt) select {((_x select 2) select 0) isEqualTo "nest"};
if (_commandAreas isNotEqualTo []) then {
    private _nestId = (((([_commandAreas, [], {_spot distance2D (_x select 0)}, "ASCEND"] call BIS_fnc_sortBy) select 0) select 2) select 1);
    {_x setVariable ["COIN_origin", ["camp", _nestId, -1]]} forEach _fighters;
    diag_log format ["[COIN] mortar: the squad at %1 comes from the command post of nest %2, a prisoner names that nest", _spot apply {round _x}, _nestId];
} else {
    diag_log format ["[COIN] mortar: the squad at %1 is in no command post area, a prisoner follows the rule 'Which nest'", _spot apply {round _x}];
};
_group setBehaviour "AWARE";
[_fighters] call COIN_fnc_markCoinUnits;
[[_mortar] + _fighters] call COIN_fnc_addToCurators;

[_group, _fighters, _mortar]
