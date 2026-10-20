/*
    File: fn_initNests.sqf
    Author: COIN Liberation

    Description:
        Server start of the militia network (tickets 2.1 and 2.5, ADR 0005, ADR 0018). Waits until Liberation has
        loaded its save, then takes the nests from entry 22. A new campaign, a save without entry 22 (e.g. from
        phase 1) or a block with an unknown save version gets new nests (COIN_fnc_createNests), which are saved
        right away. Sets COIN_nests, logs every nest and draws the debug map when COIN_debug is on.
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

private _block = missionNamespace getVariable ["COIN_loadedSaveBlock", []];
private _nests = [];

if (_block isEqualTo []) then {
    diag_log "[COIN] nests: no COIN block in the save (new campaign or save without nests), creating nests";
} else {
    if (_block isEqualTypeParams [0, []] && {(_block select 0) isEqualTo COIN_saveVersion}) then {
        {
            if (_x isEqualTypeParams [0, "", "", [], 0, ""]) then {
                _nests pushBack _x;
            } else {
                diag_log format ["[COIN] nests: ERROR - invalid nest in the save left out: %1", _x];
            };
        } forEach (_block select 1);
        diag_log format ["[COIN] nests: %1 nests loaded from the save (save version %2)", count _nests, _block select 0];
    } else {
        diag_log format ["[COIN] nests: ERROR - COIN block with unknown format or save version %1 (expected %2), creating new nests", _block select 0, COIN_saveVersion];
    };
};

private _created = _nests isEqualTo [];
if (_created) then {
    _nests = [] call COIN_fnc_createNests;
};

COIN_nests = _nests;

{
    _x params ["_id", "_type", "_kind", "_pos", "_seed", "_state"];
    diag_log format ["[COIN] nests: nest %1 %2 %3 at %4 seed %5 %6, radius %7", _id, _type, _kind, _pos, _seed, _state, [_type] call COIN_fnc_getNestRadius];
} forEach COIN_nests;

if (_created) then {
    [] call KPLIB_fnc_doSave;
    diag_log format ["[COIN] nests: %1 new nests created and saved", count COIN_nests];
};

if (COIN_debug) then {
    [] call COIN_fnc_drawNestMarkers;
};

count COIN_nests
