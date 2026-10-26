/*
    File: fn_runStrikeTask.sqf
    Author: COIN Liberation

    Description:
        Server: runs one accepted strike task from start to end (tickets 5.13 and 5.14, DESIGN 8.2). Started by
        COIN_fnc_acceptStrikeTask, which has put the task into COIN_strikeActive. Must be spawned.
        At the start: a task for the whole side with the times of day of the beginning and the end (game clock,
        COIN_fnc_clockText) and the name of the start and the destination, markers at both (COIN_strikeMarkerStart, COIN_strikeMarkerEnd)
        and the message "New task" (COIN_fnc_clientTask). It waits for the beginning, then the run of the kind
        (COIN_strikeKinds, fourth entry) takes over and returns "succeeded" or the reason it failed, at the latest when the end time
        is reached. A strike task that fails or runs out costs nothing. The markers go, the task stays in the task list for
        COIN_aidTaskEndShowSeconds. Nothing is saved.

    Parameter(s):
        _row       - Entry of COIN_strikeKinds [ARRAY, defaults to []]
        _plan      - Result of the plan of the kind [start position, start name, destination position, destination name, ...] [ARRAY, defaults to []]
        _taskId    - Id of the Arma task [STRING, defaults to ""]
        _startTime - Time (server time) of the beginning [NUMBER, defaults to 0]
        _endTime   - Time (server time) at which the task fails [NUMBER, defaults to 0]
        _by        - Name of the interpreter who accepted it, for the log [STRING, defaults to ""]

    Returns:
        The task succeeded [BOOL]
*/

params [
    ["_row", [], [[]]],
    ["_plan", [], [[]]],
    ["_taskId", "", [""]],
    ["_startTime", 0, [0]],
    ["_endTime", 0, [0]],
    ["_by", "", [""]]
];

if (!isServer || {_row isEqualTo []} || {_plan isEqualTo []}) exitWith {false};

_row params ["_kind", "", "", "_runFunction"];
_plan params ["_startPos", "_startName", "_endPos", "_endName"];

private _startClock = [_startTime - time] call COIN_fnc_clockText;
private _endClock = [_endTime - time] call COIN_fnc_clockText;
private _minutes = round ((_endTime - time) / 60);
private _extra = [_startName, _endName, _startClock, _endClock];

private _markers = [];
{
    _x params ["_suffix", "_pos", "_name", "_look"];
    private _marker = createMarker [format ["%1_%2", _taskId, _suffix], _pos];
    _marker setMarkerType (_look select 0);
    _marker setMarkerColor (_look select 1);
    _marker setMarkerText _name;
    _markers pushBack _marker;
} forEach [
    ["start", _startPos, _startName, COIN_strikeMarkerStart],
    ["end", _endPos, _endName, COIN_strikeMarkerEnd]
];

diag_log format [
    "[COIN] strike: task %1 (%2) accepted by %3: %4 to %5, begins at %6 (in %7 min), ends at %8 (in %9 min)",
    _kind, _taskId, _by, _startName, _endName, _startClock, round ((_startTime - time) / 60), _endClock, _minutes
];
[_taskId, "CREATED", _kind, _startPos, "", _minutes, true, _extra] remoteExecCall ["COIN_fnc_clientTask", 0, _taskId];

// Wait for the beginning; the task can be switched off meanwhile
private _result = "";
while {_result isEqualTo "" && {time < _startTime}} do {
    sleep COIN_strikeCheckSeconds;
    if (GRLIB_endgame != 0 || {!COIN_enableStrikeTasks}) then {_result = "strike tasks switched off"};
};

if (_result isEqualTo "") then {
    diag_log format ["[COIN] strike: task %1 (%2) begins", _kind, _taskId];
    _result = [_plan, _endTime, _taskId, _by] call (missionNamespace getVariable [_runFunction, {"no run function"}]);
};

private _succeeded = _result isEqualTo "succeeded";
[_taskId, ["FAILED", "SUCCEEDED"] select _succeeded, _kind, _startPos, "", _minutes, true, _extra] remoteExecCall ["COIN_fnc_clientTask", 0, _taskId];

{deleteMarker _x} forEach _markers;
COIN_strikeActive = COIN_strikeActive select {(_x select 0) != _taskId};
diag_log format ["[COIN] strike: task %1 (%2) ended: %3, %4 strike task(s) now", _kind, _taskId, _result, count COIN_strikeActive];

// Stays in the task list for a while, then goes
sleep COIN_aidTaskEndShowSeconds;
[_taskId, "REMOVED", _kind, _startPos, "", _minutes, false, _extra] remoteExecCall ["COIN_fnc_clientTask", 0];
[] remoteExecCall ["", _taskId];

_succeeded
