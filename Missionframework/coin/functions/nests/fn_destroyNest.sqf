/*
    File: fn_destroyNest.sqf
    Author: COIN Liberation

    Description:
        Marks a nest as destroyed (ticket 2.4, #33, ADR 0018): state "destroyed", saved right away with Liberation's
        save function, one log line, grey debug marker and the server event "COIN_nestDestroyed" [id, type, position]
        (CBA local event). Reputation (Phase 5) and readiness drop (Phase 6) attach to that event.
        Only once per nest: a nest that is already destroyed, or an id that is no saved nest (debug nest), does nothing.
        A destroyed nest never spawns again; guards still alive fight on until the nest is removed.
        Server only.

    Parameter(s):
        _id     - Nest id [NUMBER]
        _reason - Why, for the log, e.g. "core object destroyed" [STRING]

    Returns:
        Nest was destroyed by this call [BOOL]
*/

params [
    ["_id", -1, [0]],
    ["_reason", "", [""]]
];

if (!isServer || {!COIN_enableNestDestruction}) exitWith {false};

private _index = COIN_nests findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {
    if (COIN_debug) then {
        diag_log format ["[COIN] nests: nest %1 is no saved nest (%2), ignored", _id, _reason];
    };
    false
};

private _nest = COIN_nests select _index;
_nest params ["", "_type", "_kind", "_pos"];

// Check and set in one unscheduled step, so the Killed handler and the spawn loop cannot both get through
private _first = false;
isNil {
    if !((_nest select 5) isEqualTo "destroyed") then {
        _nest set [5, "destroyed"];     // state
        _first = true;
    };
};
if (!_first) exitWith {false};

diag_log format ["[COIN] nests: nest %1 (%2, %3) at %4 destroyed (%5)", _id, _type, _kind, _pos, _reason];

// Saved right away, outside the event handler; Liberation skips a save while another one runs, then once more later
[_id] spawn {
    params ["_id"];
    private _saved = [] call KPLIB_fnc_doSave;
    if (!_saved) then {
        sleep COIN_nestSaveRetryDelay;
        _saved = [] call KPLIB_fnc_doSave;
    };
    diag_log format [
        "[COIN] nests: destroyed nest %1 %2",
        _id, ["not saved yet (Liberation was saving twice), goes into Liberation's next save", "saved"] select _saved
    ];
};

if (COIN_debug) then {
    [] call COIN_fnc_drawNestMarkers;
};

["COIN_nestDestroyed", [_id, _type, _pos]] call CBA_fnc_localEvent;

true
