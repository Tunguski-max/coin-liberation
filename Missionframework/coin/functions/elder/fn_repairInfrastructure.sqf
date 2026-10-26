/*
    File: fn_repairInfrastructure.sqf
    Author: COIN Liberation

    Description:
        Server: a player repaired a device of an aid task "Repair infrastructure" (ticket 5.12, DESIGN 8.2). Called with
        remoteExecCall by the action of COIN_fnc_addRepairAction when its progress bar was full. Only a device still
        waiting for a repair counts (COIN_infraOpen), so two players at once repair it once. The device is closed
        (smoke off, COIN_fnc_closeInfrastructure). The reputation is given by the task
        (COIN_fnc_runAidTask) when all devices are repaired.

    Parameter(s):
        _device - The device [OBJECT, defaults to objNull]
        _by     - Name of the player, for the log [STRING, defaults to ""]

    Returns:
        The device was repaired [BOOL]
*/

params [
    ["_device", objNull, [objNull]],
    ["_by", "", [""]]
];

if (!isServer || {isNull _device} || {!(_device getVariable ["COIN_infraOpen", false])}) exitWith {false};

[_device] call COIN_fnc_closeInfrastructure;
diag_log format ["[COIN] aid: a %1 in %2 was repaired by %3", typeOf _device, _device getVariable ["COIN_infraTown", ""], _by];

true
