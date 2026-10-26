/*
    File: fn_addRepairAction.sqf
    Author: COIN Liberation

    Description:
        Client: adds the action "Repair" to a device of an aid task "Repair infrastructure" (ticket 5.12, DESIGN 8.2).
        Sent by COIN_fnc_spawnInfrastructure to all machines with the device as JIP key. The action shows while the device
        waits for a repair (COIN_infraOpen) and the player may repair it (COIN_fnc_canRepairInfrastructure: ACE engineer
        with a tool kit), from COIN_aidRepairRange m. It starts the ACE progress bar for COIN_aidRepairSeconds. The bar
        ends if the player walks away, loses the tool kit, dies or somebody else repairs the device, and he can
        cancel it with Escape: nothing is paid then and he can start again. When it is full the server is told
        (COIN_fnc_repairInfrastructure).

    Parameter(s):
        _device - The device [OBJECT, defaults to objNull]

    Returns:
        The action was added [BOOL]
*/

params [
    ["_device", objNull, [objNull]]
];

if (!hasInterface || {isNull _device}) exitWith {false};

private _index = [1, 0] select (language isEqualTo "German");

_device addAction [
    "<t color='#FFC000'>" + (COIN_aidRepairLabel select _index) + "</t>",
    {
        params ["_target", "_caller"];

        if (isNil "ace_common_fnc_progressBar") exitWith {};
        private _index = [1, 0] select (language isEqualTo "German");

        [
            COIN_aidRepairSeconds,
            [_target],
            {
                params ["_args"];
                _args params ["_target"];
                [_target, name player] remoteExecCall ["COIN_fnc_repairInfrastructure", 2];
            },
            {},
            COIN_aidRepairBarText select _index,
            {
                params ["_args"];
                _args params ["_target"];
                (_target getVariable ["COIN_infraOpen", false])
                && {(player distance _target) <= (COIN_aidRepairRange + 1)}
                && {[player] call COIN_fnc_canRepairInfrastructure}
            }
        ] call ace_common_fnc_progressBar;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "alive _target && {_target getVariable ['COIN_infraOpen', false]} && {[_this] call COIN_fnc_canRepairInfrastructure}",
    COIN_aidRepairRange
];

true
