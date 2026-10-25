/*
    File: fn_clientTask.sqf
    Author: COIN Liberation

    Description:
        Client: creates, changes or removes the Arma task of an aid task on this machine (tickets 5.9b and 5.10). The server
        sends it to all machines with remoteExecCall under the id of the task as JIP key, so a late joiner gets the latest
        state. The task is created here and not once on the server, so every player reads it in his own language
        (COIN_aidTaskTexts). It has a marker on the elder's place. With "CREATED" and "SUCCEEDED" / "FAILED" the standard
        message of the game is shown ("Task assigned", "Task completed", "Task failed"), unless the task is created late.

    Parameter(s):
        _taskId  - Id of the task [STRING, defaults to ""]
        _state   - "CREATED", "SUCCEEDED", "FAILED" or "REMOVED" (task goes from the list) [STRING, defaults to ""]
        _id      - Kind of task, a key of COIN_aidTaskTexts [STRING, defaults to ""]
        _pos     - Where the elder stands [ARRAY, defaults to [0, 0, 0]]
        _town    - Name of the town [STRING, defaults to ""]
        _minutes - Time limit in minutes, for the text [NUMBER, defaults to 0]
        _notify  - Show the message of the game [BOOL, defaults to true]

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
    ["_notify", true, [true]]
];

if (!hasInterface || {_taskId isEqualTo ""}) exitWith {};
// The JIP call can come before the unit exists, and the task functions may need to wait
if (!canSuspend) exitWith {_this spawn COIN_fnc_clientTask};
waitUntil {!isNull player};

if (_state isEqualTo "REMOVED") exitWith {
    if ([_taskId] call BIS_fnc_taskExists) then {
        [_taskId] call BIS_fnc_deleteTask;
    };
};

private _index = [1, 0] select (language isEqualTo "German");
private _row = [COIN_aidTaskTexts, _id] call COIN_fnc_findByType;
if (_row isEqualTo []) exitWith {};

if !([_taskId] call BIS_fnc_taskExists) then {
    private _title = format ["%1: %2", (_row select 1) select _index, _town];
    private _description = format [((_row select 3) select _index), _town, _minutes, COIN_aidSupplyDistance];
    [
        player,
        _taskId,
        [_description, _title, ""],
        _pos,
        _state,
        1,
        _notify && {_state isEqualTo "CREATED"},
        COIN_aidTaskType,
        false
    ] call BIS_fnc_taskCreate;
};

if (_state in ["SUCCEEDED", "FAILED"]) then {
    [_taskId, _state, _notify] call BIS_fnc_taskSetState;
};
