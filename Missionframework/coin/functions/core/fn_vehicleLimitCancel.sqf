/*
    File: fn_vehicleLimitCancel.sqf
    Author: COIN Liberation

    Description:
        Client: the placement of a bought vehicle was cancelled (hook 13 in do_build.sqf, ticket 1.9).
        Liberation refunds the price, so the lock of this purchase is lifted on the server.
        Skipped when the cancel was caused by a denied purchase: that lock belongs to the earlier buyer.

    Parameter(s):
        _class - Class whose placement was cancelled [STRING]

    Returns:
        The server was asked to lift the lock [BOOL]
*/

params [
    ["_class", "", [""]]
];

if (!COIN_enableVehicleLimits) exitWith {false};

if (missionNamespace getVariable ["COIN_buildDenied", false]) exitWith {
    COIN_buildDenied = false;
    false
};

[_class] remoteExecCall ["COIN_fnc_vehicleLimitRelease", 2];

true
