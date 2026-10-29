/*
    File: fn_startMortarAttack.sqf
    Author: COIN Liberation

    Description:
        Starts a mortar attack on a FOB (ticket 6.7a, #158, DESIGN 9): only if none is running (at most one on the
        map) and a spot for the squad was found (COIN_fnc_findMortarSpot). Puts the FOB in its cooldown
        (COIN_mortarCooldownSeconds) and spawns COIN_fnc_runMortarAttack. The caller has checked the FOB
        (COIN_fnc_checkMortarFob) and rolled the chance, the debug function skips both. Server only.

    Parameter(s):
        _fob    - Position of the FOB [ARRAY]
        _reason - Why the attack starts, for the log: "chance" or "debug" [STRING]

    Returns:
        The attack started [BOOL]
*/

params [
    ["_fob", [], [[]], [2, 3]],
    ["_reason", "chance", [""]]
];

if (!isServer || {!COIN_enableMortarAttacks}) exitWith {false};

private _fobName = [_fob] call KPLIB_fnc_getFobName;
if (COIN_mortarActive) exitWith {
    diag_log format ["[COIN] mortar: no attack on FOB %1 (%2): another one is running", _fobName, _reason];
    false
};

([_fob] call COIN_fnc_findMortarSpot) params ["_spot", "_inArea", "_rejected"];
if (_spot isEqualTo []) exitWith {
    diag_log format [
        "[COIN] mortar: no attack on FOB %1 (%2): no spot for the squad %3-%4 m away, rejected points %5",
        _fobName, _reason, COIN_mortarDistance select 0, COIN_mortarDistance select 1, _rejected
    ];
    false
};

COIN_mortarActive = true;
COIN_mortarCooldowns set [[_fob] call COIN_fnc_mortarFobKey, time + COIN_mortarCooldownSeconds];
[_fob, _spot, _reason] spawn COIN_fnc_runMortarAttack;
true
