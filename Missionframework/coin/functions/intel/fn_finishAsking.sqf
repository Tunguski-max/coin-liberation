/*
    File: fn_finishAsking.sqf
    Author: COIN Liberation

    Description:
        The answer to the interpreter is known (ticket 3.5): a marker (also a lie or a warning) starts his cooldown,
        "I know nothing", a refusal and a civilian who died end the busy time reserved by COIN_fnc_reserveAsking without
        a cooldown. The busy time is ended only if it is still the one set then (a later question may have set its own).
        Server only.

    Parameter(s):
        _asker       - Interpreter [OBJECT, defaults to objNull]
        _reservation - Result of COIN_fnc_reserveAsking [ARRAY, defaults to []]
        _madeMarker  - The answer made a marker [BOOL, defaults to false]

    Returns:
        NONE
*/

params [
    ["_asker", objNull, [objNull]],
    ["_reservation", [], [[]], 2],
    ["_madeMarker", false, [false]]
];

if (!isServer || {!COIN_enableCooldown}) exitWith {};

_reservation params ["_key", "_pending"];

if (_madeMarker) then {
    COIN_cooldownEnds set [_key, time + COIN_questionCooldown];
    diag_log format ["[COIN] intel: cooldown of %1 started for %2 s", name _asker, COIN_questionCooldown];
} else {
    if ((COIN_cooldownEnds getOrDefault [_key, 0]) isEqualTo _pending) then {
        COIN_cooldownEnds deleteAt _key;
    };
};
