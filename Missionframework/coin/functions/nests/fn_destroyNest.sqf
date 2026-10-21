/*
    File: fn_destroyNest.sqf
    Author: COIN Liberation

    Description:
        Marks a nest as destroyed (ticket 2.4, #33, ADR 0018): state "destroyed", saved right away with Liberation's
        save function, one log line, grey debug marker and the server event "COIN_nestDestroyed" [id, type, position]
        (CBA local event). Reputation (Phase 5), readiness drop (Phase 6) and documents (Phase 3) attach to that event.
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
_nest params ["", "_type", "_kind", "_pos", "", "_state"];
if (_state isEqualTo "destroyed") exitWith {false};

_nest set [5, "destroyed"];

// Saved right away; Liberation skips a save while another one runs, then the nest is saved a moment later
private _saved = [] call KPLIB_fnc_doSave;
diag_log format [
    "[COIN] nests: nest %1 (%2, %3) at %4 destroyed (%5), %6",
    _id, _type, _kind, _pos, _reason,
    ["save busy, saving again in a moment", "saved"] select _saved
];
if (!_saved) then {
    [_id] spawn {
        params ["_id"];
        sleep COIN_nestSaveRetryDelay;
        diag_log format [
            "[COIN] nests: destroyed nest %1 %2",
            _id, ["saved with Liberation's next save", "saved"] select ([] call KPLIB_fnc_doSave)
        ];
    };
};

if (COIN_debug) then {
    [] call COIN_fnc_drawNestMarkers;
};

["COIN_nestDestroyed", [_id, _type, _pos]] call CBA_fnc_localEvent;

true
