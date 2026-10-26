/*
    File: fn_closeInfrastructure.sqf
    Author: COIN Liberation

    Description:
        Server: a device of an aid task "Repair infrastructure" is done with (ticket 5.12, DESIGN 8.2), repaired
        (COIN_fnc_repairInfrastructure) or left over at the end of the task (COIN_fnc_runAidTask): it no longer waits
        for a repair (COIN_infraOpen is public, so the action goes) and the smoke is removed. The device itself stays until
        the task ends, then it goes when nobody sees it (COIN_fnc_runAidTask, COIN_fnc_removeWhenUnseen).

    Parameter(s):
        _device - The device [OBJECT, defaults to objNull]

    Returns:
        The device was closed [BOOL]
*/

params [
    ["_device", objNull, [objNull]]
];

if (!isServer || {isNull _device}) exitWith {false};

_device setVariable ["COIN_infraOpen", false, true];
deleteVehicle (_device getVariable ["COIN_infraSmoke", objNull]);

true
