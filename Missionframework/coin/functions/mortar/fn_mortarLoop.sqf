/*
    File: fn_mortarLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (ticket 6.7a, #158, DESIGN 9, ADR 0025): decides when a mortar attack starts. Every
        COIN_mortarCheckSeconds (read on every pass, so a change takes effect within 5 s) it looks at the FOBs in
        random order: one that COIN_fnc_checkMortarFob passes (in a staging area, no cooldown, a player at the FOB)
        gets COIN_mortarChance; the first that wins starts an attack (COIN_fnc_startMortarAttack), then the pass ends.
        Nothing happens while an attack is running. With COIN_debug each pass logs why a FOB was passed over.
        Uses COIN_mortarCooldowns and COIN_mortarActive (not saved, set in init_server.sqf). Waits for Liberation's save and the
        nests, at most COIN_initTimeout (then one ERROR line and the loop ends). Runs as long as
        COIN_enableMortarAttacks is true; no hook in Liberation. Server only.

    Parameter(s):
        NONE

    Returns:
        Loop ended [BOOL]
*/

if (!isServer) exitWith {false};

private _timeout = diag_tickTime + COIN_initTimeout;
private _ready = {
    (missionNamespace getVariable ["save_is_loaded", false])
    && {!isNil "sectors_military"}
    && {!COIN_enableNests || {!isNil "COIN_nests"}}
};
waitUntil {sleep 1; call _ready || {diag_tickTime > _timeout}};
if !(call _ready) exitWith {
    diag_log format ["[COIN] mortar: ERROR - Liberation's save or the nests not ready after %1 s, no mortar attacks", COIN_initTimeout];
    false
};

private _last = time;
while {COIN_enableMortarAttacks} do {
    sleep 5;
    if (time < _last + COIN_mortarCheckSeconds) then {continue};
    _last = time;

    if (COIN_mortarActive) then {
        if (COIN_debug) then {diag_log "[COIN] mortar: check skipped, an attack is running"};
        continue;
    };

    private _started = false;
    {
        private _fob = _x;
        private _name = [_fob] call KPLIB_fnc_getFobName;
        private _reason = [_fob] call COIN_fnc_checkMortarFob;
        if (_reason isNotEqualTo "") then {
            if (COIN_debug) then {diag_log format ["[COIN] mortar: FOB %1: no attack, %2", _name, _reason]};
            continue;
        };
        private _roll = random 1;
        if (COIN_debug) then {diag_log format ["[COIN] mortar: FOB %1: roll %2 against chance %3", _name, _roll toFixed 2, COIN_mortarChance]};
        if (_roll < COIN_mortarChance) exitWith {
            _started = [_fob, "chance"] call COIN_fnc_startMortarAttack;
        };
    } forEach (GRLIB_all_fobs call BIS_fnc_arrayShuffle);

    if (COIN_debug && {!_started} && {GRLIB_all_fobs isEqualTo []}) then {diag_log "[COIN] mortar: check without a FOB"};
};

diag_log "[COIN] mortar: loop ended (COIN_enableMortarAttacks off)";
true
