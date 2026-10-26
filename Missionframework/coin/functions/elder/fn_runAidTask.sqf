/*
    File: fn_runAidTask.sqf
    Author: COIN Liberation

    Description:
        Server: runs one accepted aid task of a town from start to end (tickets 5.9b, 5.10 and 5.11, DESIGN 8.2). Started by
        COIN_fnc_acceptElderOffer, which has registered the town in COIN_aidActive. Must be spawned.
        Start: a task for the whole side with a marker at the elder's place and the message "New task" (COIN_fnc_clientTask).
        It ends
        - succeeded when the goal of its kind is reached: "supplies" (ticket 5.10) a Liberation supply crate with
          COIN_aidSupplyMinValue supplies stands on the ground at most COIN_aidSupplyDistance m from the elder's place,
          anybody put it there; it is removed and COIN_repAidSupplies reputation is given. "medical" (ticket 5.11) all
          patients, made at the start (COIN_fnc_spawnPatients), are treated; each treatment has given
          COIN_repAidPatient (COIN_fnc_treatPatient), now COIN_repAidMedicalBonus comes on top. "repair" (ticket 5.12)
          all devices, made at the start (COIN_fnc_spawnInfrastructure), are repaired (COIN_fnc_repairInfrastructure):
          COIN_repAidRepair reputation, once, for all together,
        - failed after COIN_aidTaskTimeoutMin minutes, or when the elder of the town dies (the town has no elder
          for a while), or when aid tasks are switched off, or when a patient or device is gone (deleted, e.g. by Zeus).
          Failing because the time is over or the elder died takes back the reputation the task could have given
          (COIN_aidFailurePenaltyFactor times the reward, for "medical" all patients and the bonus, also when some were
          treated and paid already); the other ways to fail cost nothing. The patients and devices go at the end either
          way (COIN_fnc_releasePatients, COIN_fnc_closeInfrastructure).
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

private _patients = [];
private _circles = [];
if (_id isEqualTo "medical") then {
    private _made = [_taskId, _town, _pos] call COIN_fnc_spawnPatients;
    _patients = _made select 0;
    _circles = _made select 1;
};
private _devices = [];
private _smokes = [];
if (_id isEqualTo "repair") then {
    private _made = [_taskId, _town, _pos] call COIN_fnc_spawnInfrastructure;
    _devices = _made select 0;
    _smokes = _made select 1;
};

private _result = "";
while {_result isEqualTo ""} do {
    sleep COIN_aidCheckSeconds;

    if (!COIN_enableAidTasks) exitWith {_result = "aid tasks switched off"};

    // The goal is looked at before the time limit: what was done in time counts, also in the last check
    if (_id isEqualTo "supplies") then {
        // On the ground (not carried, not in a vehicle or hanging below one), a full Liberation supply crate
        private _crates = (nearestObjects [_pos, [KP_liberation_supply_crate], COIN_aidSupplyDistance]) select {
            (typeOf _x) isEqualTo KP_liberation_supply_crate
            && {alive _x}
            && {isNull attachedTo _x}
            && {isNull objectParent _x}
            && {((getPosATL _x) select 2) < COIN_aidSupplyMaxHeight}
            && {(_x getVariable ["KP_liberation_crate_value", 0]) >= COIN_aidSupplyMinValue}
        };
        if (_crates isNotEqualTo []) then {
            private _value = (_crates select 0) getVariable ["KP_liberation_crate_value", 0];
            deleteVehicle (_crates select 0);
            [COIN_repAidSupplies, format ["aid task supplies delivered in %1 (crate of %2)", _town, _value]] call COIN_fnc_changeReputation;
            _result = "succeeded";
        };
    };

    if (_id isEqualTo "medical") then {
        if (_patients isEqualTo [] || {(_patients findIf {isNull _x}) >= 0}) then {
            _result = "a patient is gone";
        } else {
            // Still waiting for treatment: the ones COIN_fnc_treatPatient has not taken from the list
            if ((_patients findIf {_x getVariable ["COIN_patientOpen", false]}) < 0) then {
                [COIN_repAidMedicalBonus, format ["aid task medical aid: all %1 patients treated in %2", count _patients, _town]] call COIN_fnc_changeReputation;
                _result = "succeeded";
            };
        };
    };

    if (_id isEqualTo "repair") then {
        if (_devices isEqualTo []) then {
            _result = "no device could be placed";
        } else {
            if ((_devices findIf {isNull _x}) >= 0) then {
                _result = "a device is gone";
            } else {
                if ((_devices findIf {_x getVariable ["COIN_infraOpen", false]}) < 0) then {
                    [COIN_repAidRepair, format ["aid task repair infrastructure: all %1 devices repaired in %2", count _devices, _town]] call COIN_fnc_changeReputation;
                    _result = "succeeded";
                };
            };
        };
    };

    if (_result isEqualTo "") then {
        if (time >= _endTime) then {
            _result = "time over";
        } else {
            if ((COIN_elderAbsent getOrDefault [_sector, 0]) > time) then {_result = "the elder died"};
        };
    };
};

private _succeeded = _result isEqualTo "succeeded";

// A broken promise: the town takes back what the task could have given (all patients and the bonus for "medical").
// Only when the army let it fail (time over, elder dead), not when it was switched off or a device or patient is lost
if (_result in ["time over", "the elder died"]) then {
    private _reward = switch (_id) do {
        case "supplies": {COIN_repAidSupplies};
        case "medical": {((count _patients) * COIN_repAidPatient) + COIN_repAidMedicalBonus};
        case "repair": {COIN_repAidRepair};
        default {0};
    };
    [
        -(_reward * COIN_aidFailurePenaltyFactor),
        format ["aid task %1 failed in %2 (%3), the reward is taken back", _id, _town, _result]
    ] call COIN_fnc_changeReputation;
};
[_taskId, ["FAILED", "SUCCEEDED"] select _succeeded, _id, _pos, _town, COIN_aidTaskTimeoutMin, true] remoteExecCall ["COIN_fnc_clientTask", 0, _taskId];

if (_id isEqualTo "medical") then {
    [_patients, _circles] spawn COIN_fnc_releasePatients;
};

// The devices not repaired are done with now (no smoke), then all of them go when nobody sees them
{
    if (!isNull _x && {_x getVariable ["COIN_infraOpen", false]}) then {
        [_x] call COIN_fnc_closeInfrastructure;
    };
} forEach _devices;
// The smoke of a device Zeus deleted has no device to be found by
{deleteVehicle _x} forEach _smokes;
if (_devices isNotEqualTo []) then {
    [_devices, "devices"] spawn COIN_fnc_removeWhenUnseen;
};

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
