/*
    File: fn_initNests.sqf
    Author: COIN Liberation

    Description:
        Server start of the militia network (tickets 2.1 and 2.5, ADR 0005, ADR 0018). Waits until Liberation has
        loaded its save, then takes the nests from entry 22. A new campaign or a save without entry 22 (e.g. from
        phase 1) gets new nests (COIN_fnc_createNests), which are saved right away. A block with an unknown save
        version is kept unchanged and no nests are active. Sets COIN_nests, logs every nest (state of the campaign,
        once per start) and draws the debug map when COIN_debug is on. Calculates the network strength
        (COIN_fnc_updateNetworkStrength, ticket 2.6). Then creates the camps (COIN_fnc_initCamps,
        ticket 2.7, while COIN_enableCamps is true) and starts the spawn loop.
        Must be spawned (waits for save_is_loaded).

    Parameter(s):
        NONE

    Returns:
        Number of nests [NUMBER]
*/

if (!isServer) exitWith {0};

private _timeout = diag_tickTime + COIN_initTimeout;
waitUntil {
    sleep 1;
    (missionNamespace getVariable ["save_is_loaded", false]) || {diag_tickTime > _timeout}
};

if !(missionNamespace getVariable ["save_is_loaded", false]) exitWith {
    diag_log format ["[COIN] nests: ERROR - Liberation's save not loaded after %1 s, no nests", COIN_initTimeout];
    0
};

// Core objects, props and building templates are checked first, the placement of new nests needs the templates
[] call COIN_fnc_validateNestContent;

private _block = missionNamespace getVariable ["COIN_loadedSaveBlock", []];

// Unknown format or save version: keep the block untouched (COIN_fnc_getSaveBlock writes it back) instead of
// replacing it, a conversion has to be written first (ADR 0018)
if !(_block isEqualTo [] || {_block isEqualTypeParams [0, []] && {(_block select 0) isEqualTo COIN_saveVersion}}) exitWith {
    diag_log format ["[COIN] nests: ERROR - COIN block with unknown format or save version %1 (expected %2), no nests, the block is kept unchanged", _block select 0, COIN_saveVersion];
    0
};

private _nests = [];
private _created = _block isEqualTo [];

if (_created) then {
    diag_log "[COIN] nests: no COIN block in the save (new campaign or save without nests), creating nests";
    _nests = [] call COIN_fnc_createNests;
} else {
    {
        if (_x isEqualTypeParams [0, "", "", [], 0, ""]) then {
            _nests pushBack _x;
        } else {
            diag_log format ["[COIN] nests: ERROR - invalid nest in the save left out: %1", _x];
        };
    } forEach (_block select 1);
    diag_log format ["[COIN] nests: %1 nests loaded from the save (save version %2)", count _nests, _block select 0];
};

COIN_nests = _nests;

{
    _x params ["_id", "_type", "_kind", "_pos", "_seed", "_state"];
    diag_log format ["[COIN] nests: nest %1 %2 %3 at %4 seed %5 %6, radius %7", _id, _type, _kind, _pos, _seed, _state, [_type] call COIN_fnc_getNestRadius];
} forEach COIN_nests;

// Saved right away, so a restart within Liberation's save interval keeps the same nests
if (_created) then {
    if ([] call KPLIB_fnc_doSave) then {
        diag_log format ["[COIN] nests: %1 new nests created and saved", count COIN_nests];
    } else {
        diag_log format ["[COIN] nests: %1 new nests created, saved with Liberation's next save", count COIN_nests];
    };
};

if (COIN_debug) then {
    [] call COIN_fnc_drawNestMarkers;
    // One line per event, so the test can see it comes exactly once per nest
    ["COIN_nestDestroyed", {
        params ["_id", "_type", "_pos"];
        diag_log format ["[COIN] nests: event COIN_nestDestroyed for nest %1 (%2) at %3", _id, _type, _pos];
    }] call CBA_fnc_addEventHandler;
};

// Network strength (ticket 2.6): from the nests now and again after every destruction
if (COIN_enableNetworkStrength) then {
    [] call COIN_fnc_updateNetworkStrength;
    ["COIN_nestDestroyed", {
        [] call COIN_fnc_updateNetworkStrength;
    }] call CBA_fnc_addEventHandler;
} else {
    diag_log "[COIN] network: network strength off, not calculated";
};

// Camps as data (ticket 2.7), not saved: new places on every start
if (COIN_enableCamps) then {
    [] call COIN_fnc_initCamps;
} else {
    diag_log "[COIN] camps: camps off, none are created";
};

// Content near players (ticket 2.3)
if (COIN_enableNestSpawn) then {
    [] spawn COIN_fnc_nestSpawnLoop;
} else {
    diag_log "[COIN] nests: spawning off, nests stay data only";
};

count COIN_nests
