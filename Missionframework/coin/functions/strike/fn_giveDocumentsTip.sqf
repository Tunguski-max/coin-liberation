/*
    File: fn_giveDocumentsTip.sqf
    Author: COIN Liberation

    Description:
        Server: what the documents of a search tell (tickets 5.14 and 5.16): a Konkreter Tipp (intel "tip") to a nest, the notification of
        the new intel and the subtitle for the one who searched. The nest is the one of the plan; if it is gone meanwhile, any nest a
        civilian at the fallback position would know of (COIN_fnc_pickIntelNest). Writes a line to the RPT. Must be called where it may
        wait (scheduled).

    Parameter(s):
        _nestId      - Id of the nest the documents name [NUMBER, defaults to -1]
        _fallback    - Position for a nest by chance, if that nest is not active any more [ARRAY, defaults to [0, 0, 0]]
        _searcher    - The player who searched, gets the subtitle [OBJECT, defaults to objNull]
        _speaker     - Key of the name of who speaks in the subtitle [STRING, defaults to ""]
        _text        - Key of what he says [STRING, defaults to ""]
        _taskId      - Id of the Arma task, for the log [STRING, defaults to ""]

    Returns:
        The intel (COIN_fnc_createIntel), [] if none could be made [ARRAY]
*/

params [
    ["_nestId", -1, [0]],
    ["_fallback", [0, 0, 0], [[]]],
    ["_searcher", objNull, [objNull]],
    ["_speaker", "", [""]],
    ["_text", "", [""]],
    ["_taskId", "", [""]]
];

if (!isServer) exitWith {[]};

private _nest = (COIN_nests select {(_x select 0) isEqualTo _nestId && {(_x select 5) isEqualTo "active"}}) param [0, []];
if (_nest isEqualTo []) then {_nest = [_fallback] call COIN_fnc_pickIntelNest};

private _intel = if (_nest isEqualTo []) then {[]} else {[_nest, "tip"] call COIN_fnc_createIntel};
if (_intel isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: %1: the documents name no nest, no intel could be made (nest %2)", _taskId, _nest];
    []
};

diag_log format [
    "[COIN] strike: %1: the documents name nest %2 (%3), circle of %4 m at %5 (intel %6)",
    _taskId, _nest select 0, _nest select 1, _intel select 3, _intel select 2, _intel select 0
];
["intel"] remoteExecCall ["COIN_fnc_showNotification", 0];
if (!isNull _searcher) then {[_speaker, _text] remoteExecCall ["COIN_fnc_showDocumentsFound", owner _searcher]};

_intel
