/*
    File: fn_stagingLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (ticket 6.1a, #154, ADR 0025): watches the staging areas and reacts when the set changes, because a
        command post was destroyed or a military post was captured or lost. On every change one [COIN] line with the
        number of staging areas and each one's source, and with COIN_debug the debug map is drawn again
        (COIN_fnc_drawStagingMarkers). The first pass after the save is loaded counts as a change.
        Waits for Liberation's save (blufor_sectors is empty until then, every military post would count as held) and
        for the nests, at most COIN_initTimeout (then one ERROR line and the loop ends). Checks every
        COIN_stagingCheckSeconds; no hook in Liberation. Runs as long as COIN_enableStagingAreas is true. Server only.

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
    diag_log format ["[COIN] staging: ERROR - Liberation's save or the nests not ready after %1 s, no staging areas", COIN_initTimeout];
    false
};

private _lastSources = [];
private _first = true;

while {COIN_enableStagingAreas} do {
    private _areas = [] call COIN_fnc_getStagingAreas;
    private _sources = _areas apply {_x select 2};

    if (_first || {!(_sources isEqualTo _lastSources)}) then {
        _first = false;
        _lastSources = _sources;
        diag_log format [
            "[COIN] staging: %1 staging area(s)%2",
            count _areas,
            if (_areas isEqualTo []) then {""} else {": " + ((_areas apply {[_x] call COIN_fnc_describeStagingArea}) joinString "; ")}
        ];
        [] call COIN_fnc_drawStagingMarkers;
    };

    sleep COIN_stagingCheckSeconds;
};

diag_log "[COIN] staging: loop ended (COIN_enableStagingAreas off)";

true
