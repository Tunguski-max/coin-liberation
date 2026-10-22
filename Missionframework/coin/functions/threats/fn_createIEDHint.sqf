/*
    File: fn_createIEDHint.sqf
    Author: COIN Liberation

    Description:
        Hint object next to an IED (ticket 4.1b, DESIGN 6): with chance COIN_iedHintChance a conspicuous object from
        COIN_iedHintClasses (dirt mound, litter, tyres, rubble) lies COIN_iedHintMinDist to COIN_iedHintMaxDist m from
        the IED. The players can see it, an ACE mine detector does not react to it. Added to Zeus. COIN_fnc_removeIED
        deletes it with its IED. Classes the game does not know are left out once, with a log line. Server only.

    Parameter(s):
        _pos - Position of the IED [ARRAY]

    Returns:
        The hint object, objNull if there is none (chance, switch, no class, no dry spot) [OBJECT]
*/

params [
    ["_pos", [], [[]]]
];

if (!isServer || {!COIN_enableIEDHints} || {random 1 >= COIN_iedHintChance}) exitWith {objNull};

if (isNil "COIN_iedHintValid") then {
    COIN_iedHintValid = COIN_iedHintClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
    private _missing = COIN_iedHintClasses - COIN_iedHintValid;
    if (_missing isNotEqualTo []) then {
        diag_log format ["[COIN] ieds: hint classes not in this game, left out: %1", _missing joinString ", "];
    };
};
if (COIN_iedHintValid isEqualTo []) exitWith {objNull};

private _spot = [];
for "_i" from 1 to COIN_iedHintAttempts do {
    private _candidate = _pos getPos [COIN_iedHintMinDist + random (COIN_iedHintMaxDist - COIN_iedHintMinDist), random 360];
    if (!surfaceIsWater _candidate) exitWith {_spot = [_candidate select 0, _candidate select 1, 0]};
};
if (_spot isEqualTo []) exitWith {objNull};

private _hint = createVehicle [selectRandom COIN_iedHintValid, _spot, [], 0, "CAN_COLLIDE"];
_hint setPosATL _spot;
_hint setDir random 360;
_hint setVectorUp surfaceNormal _spot;
[[_hint]] call COIN_fnc_addToCurators;

_hint
