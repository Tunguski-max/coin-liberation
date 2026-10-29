/*
    File: fn_startMortarAttack.sqf
    Author: COIN Liberation

    Description:
        Starts a mortar attack on a FOB (ticket 6.7a, #158, DESIGN 9): only if none is running (at most one on the
        map) and a spot for the squad was found (COIN_fnc_findMortarSpot). Takes COIN_mortarActive before the search. The FOB goes into its cooldown
        at the end of the attack (COIN_fnc_runMortarAttack, spawned here). The caller has checked the FOB
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

// Taken before the search, which can be suspended: a second start in the meantime is refused
COIN_mortarActive = true;
([_fob] call COIN_fnc_findMortarSpot) params ["_spot", "_inArea", "_rejected"];
if (_spot isEqualTo []) exitWith {
    COIN_mortarActive = false;
    diag_log format [
        "[COIN] mortar: no attack on FOB %1 (%2): no spot for the squad %3-%4 m away, rejected points %5",
        _fobName, _reason, COIN_mortarDistance select 0, COIN_mortarDistance select 1, _rejected
    ];
    false
};

[_fob, _spot, _reason] spawn COIN_fnc_runMortarAttack;
true
