/*
    File: fn_clientTask.sqf
    Author: COIN Liberation

    Description:
        Client: creates, changes or removes the Arma task of an aid task on this machine (tickets 5.9b and 5.10). The server
        sends it to all machines with remoteExecCall under the id of the task as JIP key, so a late joiner gets the latest
        state. The task is created here and not once on the server, so every player reads it in his own language
        (COIN_aidTaskTexts). It has a marker on the elder's place, or on the village of the site (ticket 5.21, the caller passes its centre and name). With "CREATED" and "SUCCEEDED" / "FAILED" the standard
        message of the game is shown ("Task assigned", "Task completed", "Task failed"), but not for a late joiner (JIP).
        The tasks this machine has are kept in COIN_clientTasks, so init_client.sqf can give them to the unit after a respawn.

    Parameter(s):
        _taskId  - Id of the task [STRING, defaults to ""]
        _state   - "CREATED", "SUCCEEDED", "FAILED" or "REMOVED" (task goes from the list) [STRING, defaults to ""]
        _id      - Kind of task, a key of COIN_aidTaskTexts [STRING, defaults to ""]
        _pos     - Where the elder stands [ARRAY, defaults to [0, 0, 0]]
        _town    - Name of the town [STRING, defaults to ""]
        _minutes - Time limit in minutes, for the text [NUMBER, defaults to 0]
        _notify  - Show the message of the game [BOOL, defaults to true]
        _extra   - For a strike task (tickets 5.13, 5.14): [start, destination, time of day of the beginning, of the end] for the text, for the arms transport (ticket 5.16) four more: the times of day in which the convoy passes point 1 and point 2 [ARRAY, defaults to []]

    Returns:
        NONE
*/

params [
    ["_taskId", "", [""]],
    ["_state", "", [""]],
    ["_id", "", [""]],
    ["_pos", [0, 0, 0], [[]]],
    ["_town", "", [""]],
    ["_minutes", 0, [0]],
    ["_notify", true, [true]],
    ["_extra", [], [[]]]
];

if (!hasInterface || {_taskId isEqualTo ""}) exitWith {};
// The JIP call can come before the unit exists, and the task functions may need to wait. A late joiner gets no message
if (!canSuspend) exitWith {
    if (isRemoteExecutedJIP) then {_this set [6, false]};
    _this spawn COIN_fnc_clientTask
};
waitUntil {!isNull player};

if (isNil "COIN_clientTasks") then {COIN_clientTasks = createHashMap};

if (_state isEqualTo "REMOVED") exitWith {
    COIN_clientTasks deleteAt _taskId;
    if ([_taskId] call BIS_fnc_taskExists) then {
        [_taskId] call BIS_fnc_deleteTask;
    };
};

private _row = [COIN_aidTaskTexts, _id] call COIN_fnc_findByType;
// A strike task has its own texts (ticket 5.13)
private _strike = false;
if (_row isEqualTo []) then {
    _row = [COIN_strikeTaskTexts, _id] call COIN_fnc_findByType;
    _strike = true;
};
if (_row isEqualTo []) exitWith {};

// Kept for the respawn: the task belongs to the unit, the new one gets it again (init_client.sqf), without a message
COIN_clientTasks set [_taskId, [_taskId, _state, _id, _pos, _town, _minutes, false, _extra]];

if !([_taskId] call BIS_fnc_taskExists) then {
    private _title = if (_strike) then {[_row select 1] call COIN_fnc_text} else {format ["%1: %2", [_row select 1] call COIN_fnc_text, _town]};
    private _description = if (_strike) then {
        // A name that is [key, place] (a point on a road) is built in this player's language, any other text goes in as it is
        format ([[_row select 3] call COIN_fnc_text] + (_extra apply {if (_x isEqualType []) then {format [localize (_x select 0), _x select 1]} else {_x}}))
    } else {
        format [[_row select 3] call COIN_fnc_text, _town, _minutes, COIN_aidSupplyDistance, COIN_aidSupplyMinValue, COIN_aidRepairSeconds, COIN_aidRepairRadius select 0]
    };
    [
        player,
        _taskId,
        [_description, _title, ""],
        _pos,
        _state,
        1,
        _notify && {_state isEqualTo "CREATED"},
        [COIN_aidTaskType, COIN_strikeTaskType] select _strike,
        false
    ] call BIS_fnc_taskCreate;
} else {
    if (_state in ["SUCCEEDED", "FAILED"]) then {
        [_taskId, _state, _notify] call BIS_fnc_taskSetState;
    };
};
