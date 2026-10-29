/*
    File: fn_vehicleLimitDeny.sqf
    Author: COIN Liberation

    Description:
        Client: the server denied the purchase (see COIN_fnc_vehicleLimitPurchase). Cancels the running placement
        of that class the same way the player's own cancel does, so Liberation refunds the price (if the
        FOB storage has room for the crates, otherwise Liberation says so itself).
        The hint is built here in the language of the buyer: the server sends only the key of the reason and its number (ADR 0026).

    Parameter(s):
        _reason - Key of the reason from COIN_fnc_vehicleLimitStatus [STRING]
        _value  - Number put in for %1 of the reason [NUMBER, defaults to 0]
        _class  - Class whose purchase was denied [STRING]

    Returns:
        The placement was cancelled [BOOL]
*/

params [
    ["_reason", "", [""]],
    ["_value", 0, [0]],
    ["_class", "", [""]]
];

if (!hasInterface) exitWith {false};

// Only a running placement (1) of the denied class can be cancelled. Otherwise the vehicle may already be placed
private _placing = "";
if (!isNil "buildtype" && {!isNil "buildindex"} && {buildtype in [2, 3, 4, 5, 7]} && {buildindex >= 0}) then {
    _placing = (((KPLIB_buildList select buildtype) select buildindex) select 0);
};
if ((missionNamespace getVariable ["build_confirmed", 0]) != 1 || {!((toLower _placing) isEqualTo (toLower _class))}) exitWith {
    diag_log format ["[COIN] limits: purchase of %1 denied (%2) but its placement is not running", _class, _reason];
    false
};

hint format ["%1\n%2", localize "STR_COIN_limits_denied", format [localize _reason, _value]];

// The flag keeps the cancel from lifting the lock of the earlier buyer (COIN_fnc_vehicleLimitCancel)
COIN_buildDenied = true;
build_confirmed = 3;

true
