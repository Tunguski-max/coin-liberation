/*
    File: fn_readinessCapLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (ticket 6.6a, #152, ADR 0013, ADR 0025): the network caps Liberation's combat_readiness. Every
        COIN_readinessCapSeconds the readiness is set to at most COIN_fnc_getReadinessCap. No hook: Liberation keeps
        raising the readiness (captures, readiness_increase.sqf), the loop pulls it back within one interval.
        Liberation saves and syncs combat_readiness itself.
        A cap of 100 (full network) never acts: on a difficulty of 2 and more Liberation lets the readiness go above 100,
        and a full network must not change that. Without a cap (-1, see COIN_fnc_getReadinessCap) nothing happens.
        Log: one line when the cap changes; one line with old value, new value and cap when the readiness is lowered by
        at least COIN_readinessCapLogDrop, smaller pull-backs (Liberation's 0.25 steps) only with COIN_debug.
        Runs as long as COIN_capReadinessByNetwork is true (off: Liberation's readiness stays). Server only.

    Parameter(s):
        NONE

    Returns:
        Loop ended [BOOL]
*/

if (!isServer) exitWith {false};

// Liberation sets combat_readiness when its save is loaded
waitUntil {sleep 1; !isNil "combat_readiness"};

private _lastCap = -1;

while {COIN_capReadinessByNetwork} do {
    private _cap = [] call COIN_fnc_getReadinessCap;

    if (_cap >= 0 && {_cap < 100}) then {
        if (_cap != _lastCap) then {
            _lastCap = _cap;
            diag_log format [
                "[COIN] readiness: cap %1 at network strength %2 (floor %3), readiness now %4",
                _cap toFixed 1, COIN_networkStrength toFixed 2, COIN_readinessCapFloor, combat_readiness toFixed 1
            ];
        };

        if (combat_readiness > _cap) then {
            private _before = combat_readiness;
            combat_readiness = _cap;
            if (COIN_debug || {(_before - _cap) >= COIN_readinessCapLogDrop}) then {
                diag_log format [
                    "[COIN] readiness: %1 -> %2, capped by the network (cap %3)",
                    _before toFixed 1, combat_readiness toFixed 1, _cap toFixed 1
                ];
            };
        };
    };

    sleep COIN_readinessCapSeconds;
};

diag_log "[COIN] readiness: cap loop ended (COIN_capReadinessByNetwork off), Liberation's readiness stays";

true
