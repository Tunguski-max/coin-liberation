/*
    File: fn_vehicleLimitDeny.sqf
    Author: COIN Liberation

    Description:
        Client: the server denied the purchase (see COIN_fnc_vehicleLimitPurchase). Cancels the running placement
        the same way the player's own cancel does, so Liberation refunds the price. Players read the hint, so it is German.

    Parameter(s):
        _reason - Reason from COIN_fnc_vehicleLimitStatus [STRING]

    Returns:
        The placement was cancelled [BOOL]
*/

params [
    ["_reason", "", [""]]
];

if (!hasInterface) exitWith {false};

hint format ["Kauf nicht möglich\n%1\nDie Kosten werden erstattet.", _reason];

// Only a running placement (1) can be cancelled; the flag keeps the cancel from lifting somebody else's lock
if ((missionNamespace getVariable ["build_confirmed", 0]) != 1) exitWith {
    diag_log format ["[COIN] limits: purchase denied (%1) but no placement is running", _reason];
    false
};

COIN_buildDenied = true;
build_confirmed = 3;

true
