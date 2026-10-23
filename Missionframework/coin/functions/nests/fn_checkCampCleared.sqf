/*
    File: fn_checkCampCleared.sqf
    Author: COIN Liberation

    Description:
        Has a spawned camp been cleared ("ausgehoben", ticket 2.10, DESIGN 5.1)? It is when none of its fighters, the
        crew of the technical included, can still fight: dead, captive (vanilla or ACE handcuffed or surrendering),
        no longer on the enemy side, or farther than COIN_campFleeDistance from the camp. An unconscious fighter still
        counts, it may wake up. Then the camp is set to
        "cleared" (it stays in COIN_camps until it is removed, COIN_fnc_manageCamps drops it then), one log line is
        written, the server event "COIN_campCleared" [camp id, nest id, position] is raised (CBA local event, once per
        camp; the message to the players hangs on it) and a replacement is planned after
        COIN_campReplaceMinutes. Called by the spawn loop on every check
        of a spawned camp. Server only.

    Parameter(s):
        _camp  - Camp [ARRAY, layout in COIN_fnc_createCamp]
        _entry - What the spawn loop kept: [spawned objects and units, last time a player was near, technical] [ARRAY]

    Returns:
        Camp was cleared by this call [BOOL]
*/

params [
    ["_camp", [], [[]]],
    ["_entry", [], [[]]]
];

_camp params ["_id", "_nestId", "_pos", "", "", "", "_state"];
_entry params ["_objects"];

// A cleared or retired camp is already on its way out
if !(_state in ["active", "moving"]) exitWith {false};

if !(([_objects, _pos] call COIN_fnc_getCapableFighters) isEqualTo []) exitWith {false};

_camp set [6, "cleared"];
COIN_campReplaceMinutes params ["_replaceMin", "_replaceMax"];
private _delay = (_replaceMin + random (_replaceMax - _replaceMin)) * 60;
COIN_campReplacements pushBack (time + _delay);

diag_log format [
    "[COIN] camps: camp %1 (nest %2) at %3 cleared (ausgehoben), a replacement follows in %4 min",
    _id, _nestId, _pos, (round (_delay / 6)) / 10
];
if (COIN_debug) then {
    [] call COIN_fnc_drawCampMarkers;
};

// Once per camp: only a camp that was active or moving gets here and is cleared by this call
["COIN_campCleared", [_id, _nestId, _pos]] call CBA_fnc_localEvent;

true
