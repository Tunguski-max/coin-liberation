/*
    File: fn_runAidTask.sqf
    Author: COIN Liberation

    Description:
        Server: runs one accepted aid task of a town from start to end (tickets 5.9b and 5.10, DESIGN 8.2). Started by
        COIN_fnc_acceptElderOffer, which has registered the town in COIN_aidActive. Must be spawned.
        Start: a task for the whole side with a marker at the elder's place and the message "New task" (COIN_fnc_clientTask).
        It ends
        - succeeded when the goal of its kind is reached: "supplies" (ticket 5.10) a Liberation supply crate with
          COIN_aidSupplyMinValue supplies stands on the ground at most COIN_aidSupplyDistance m from the elder's place,
          anybody put it there; it is removed and COIN_repAidSupplies reputation is given,
        - failed after COIN_aidTaskTimeoutMin minutes, or when the elder of the town dies (the town has no elder
          for a while), or when aid tasks are switched off. Failing costs nothing.
        Then the town waits COIN_aidTaskCooldownMin minutes before it has a new aid task, and the finished task stays in
        the task list for COIN_aidTaskEndShowSeconds. Nothing is saved. The things a task makes stay until its end, also
        when the population of the town is removed: the place is the one of the elder, not the elder himself.

    Parameter(s):
        _id      - Kind of task, a key of COIN_aidTaskTexts [STRING, defaults to ""]
        _sector  - Sector marker of the town [STRING, defaults to ""]
        _pos     - Where the elder stands [ARRAY]
        _taskId  - Id of the Arma task [STRING]
        _endTime - Time (server time) at which the task fails [NUMBER]
        _by      - Name of the interpreter who accepted it, for the log [STRING, defaults to ""]

    Returns:
        The task succeeded [BOOL]
*/

params [
    ["_id", "", [""]],
    ["_sector", "", [""]],
    ["_pos", [0, 0, 0], [[]]],
    ["_taskId", "", [""]],
    ["_endTime", 0, [0]],
    ["_by", "", [""]]
];

if (!isServer || {_id isEqualTo ""} || {_sector isEqualTo ""}) exitWith {false};

private _town = markerText _sector;
diag_log format [
    "[COIN] aid: task %1 accepted by %2 in %3 (%4), at %5, %6 of %7 tasks now, limit %8 min",
    _id, _by, _town, _sector, _pos apply {round _x}, count COIN_aidActive, COIN_aidTaskMaxActive, COIN_aidTaskTimeoutMin
];
[_taskId, "CREATED", _id, _pos, _town, COIN_aidTaskTimeoutMin, true] remoteExecCall ["COIN_fnc_clientTask", 0, _taskId];

private _result = "";
while {_result isEqualTo ""} do {
    sleep COIN_aidCheckSeconds;

    if (!COIN_enableAidTasks) exitWith {_result = "aid tasks switched off"};
    if (time >= _endTime) exitWith {_result = "time over"};
    if ((COIN_elderAbsent getOrDefault [_sector, 0]) > time) exitWith {_result = "the elder died"};

    if (_id isEqualTo "supplies") then {
        // On the ground (not carried, not in a vehicle or hanging below one), a full Liberation supply crate
        private _crates = (nearestObjects [_pos, [KP_liberation_supply_crate], COIN_aidSupplyDistance]) select {
            (typeOf _x) isEqualTo KP_liberation_supply_crate
            && {alive _x}
            && {isNull attachedTo _x}
            && {isNull objectParent _x}
            && {((getPosATL _x) select 2) < 1.5}
            && {(_x getVariable ["KP_liberation_crate_value", 0]) >= COIN_aidSupplyMinValue}
        };
        if (_crates isNotEqualTo []) then {
            private _value = (_crates select 0) getVariable ["KP_liberation_crate_value", 0];
            deleteVehicle (_crates select 0);
            [COIN_repAidSupplies, format ["aid task supplies delivered in %1 (crate of %2)", _town, _value]] call COIN_fnc_changeReputation;
            _result = "succeeded";
        };
    };
};

private _succeeded = _result isEqualTo "succeeded";
[_taskId, ["FAILED", "SUCCEEDED"] select _succeeded, _id, _pos, _town, COIN_aidTaskTimeoutMin, true] remoteExecCall ["COIN_fnc_clientTask", 0, _taskId];

COIN_aidActive deleteAt _sector;
COIN_aidCooldown set [_sector, time + (COIN_aidTaskCooldownMin * 60)];
diag_log format [
    "[COIN] aid: task %1 in %2 (%3) ended: %4, the town waits %5 min, %6 of %7 tasks now",
    _id, _town, _sector, _result, COIN_aidTaskCooldownMin, count COIN_aidActive, COIN_aidTaskMaxActive
];

// Stays in the task list for a while, then goes; late joiners get nothing of it any more
sleep COIN_aidTaskEndShowSeconds;
[_taskId, "REMOVED", _id, _pos, _town, COIN_aidTaskTimeoutMin, false] remoteExecCall ["COIN_fnc_clientTask", 0];
[] remoteExecCall ["", _taskId];

_succeeded
