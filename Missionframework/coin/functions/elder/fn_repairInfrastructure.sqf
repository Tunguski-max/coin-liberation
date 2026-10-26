/*
    File: fn_repairInfrastructure.sqf
    Author: COIN Liberation

    Description:
        Server: a player repaired a device of an aid task "Repair infrastructure" (ticket 5.12, DESIGN 8.2). Called with
        remoteExecCall by the action of COIN_fnc_addRepairAction when its progress bar was full. The server checks it
        again: the sender is the owner of the unit, the unit may repair (COIN_fnc_canRepairInfrastructure: ACE engineer
        with a tool kit) and is close enough, and the device still waits for a repair (COIN_infraOpen), so two players
        at once repair it once. The device is closed (smoke off, COIN_fnc_closeInfrastructure). The reputation is given by
        the task (COIN_fnc_runAidTask) when all devices are repaired.

    Parameter(s):
        _device - The device [OBJECT, defaults to objNull]
        _by     - The player who repaired it [OBJECT, defaults to objNull]

    Returns:
        The device was repaired [BOOL]
*/

params [
    ["_device", objNull, [objNull]],
    ["_by", objNull, [objNull]]
];

if (!isServer || {isNull _device} || {isNull _by} || {!(_device getVariable ["COIN_infraOpen", false])}) exitWith {false};

// The player must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _by != _sender}) exitWith {
    diag_log format ["[COIN] aid: ERROR - repair sent by machine %1, not the owner of %2, refused", _sender, _by];
    false
};

if (
    !([_by] call COIN_fnc_canRepairInfrastructure)
    || {(_by distance _device) > (COIN_aidRepairRange + COIN_aidRepairRangeMargin)}
) exitWith {
    diag_log format ["[COIN] aid: repair of a %1 by %2 refused (rules)", typeOf _device, name _by];
    false
};

[_device] call COIN_fnc_closeInfrastructure;
diag_log format ["[COIN] aid: a %1 in %2 was repaired by %3", typeOf _device, _device getVariable ["COIN_infraTown", ""], name _by];

true
