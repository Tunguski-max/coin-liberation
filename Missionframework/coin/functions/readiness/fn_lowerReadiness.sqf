/*
    File: fn_lowerReadiness.sqf
    Author: COIN Liberation

    Description:
        The one way COIN lowers Liberation's combat_readiness (ticket 6.6b, #153, ADR 0013): a destroyed nest and the
        strike tasks (leader, arms transport, export) go through it. Never below 0. Liberation saves and syncs the value
        itself. One [COIN] line with the reason, the old and the new value and the amount. Server only.

    Parameter(s):
        _amount - Points to take off [NUMBER]
        _reason - Why, for the log, e.g. "nest 3 (command) destroyed" [STRING]

    Returns:
        Points really taken off, less than _amount near 0 [NUMBER]
*/

params [
    ["_amount", 0, [0]],
    ["_reason", "", [""]]
];

if (!isServer || {_amount <= 0} || {isNil "combat_readiness"}) exitWith {0};

private _before = combat_readiness;
combat_readiness = (combat_readiness - _amount) max 0;

diag_log format [
    "[COIN] readiness: %1: %2 -> %3 (-%4)",
    _reason, _before toFixed 1, combat_readiness toFixed 1, _amount
];

_before - combat_readiness
