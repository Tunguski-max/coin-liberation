/*
    File: fn_spawnMortarSquad.sqf
    Author: COIN Liberation

    Description:
        Spawns the mortar squad of a mortar attack (ticket 6.7a, #158, DESIGN 9): a light mortar (the first class of
        COIN_mortarClasses that exists, Project OPFOR has none for the Afghan Militia) facing the FOB, and
        COIN_mortarCrew militia fighters, one of them its gunner. The fighters hold their place (no path). They are
        managed by Liberation's kill manager, marked as COIN units for the AI budget (the squad always spawns, the budget
        is not asked) and all of it goes to Zeus. Server only.

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
_group setBehaviour "AWARE";
[_fighters] call COIN_fnc_markCoinUnits;
[[_mortar] + _fighters] call COIN_fnc_addToCurators;

[_group, _fighters, _mortar]
