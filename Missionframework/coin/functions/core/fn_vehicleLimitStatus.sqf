/*
    File: fn_vehicleLimitStatus.sqf
    Author: COIN Liberation

    Description:
        Tells whether a vehicle class may be bought right now under the equipment limits (ticket 1.9, ADR 0007).
        A limited class is blocked while its maximum number of alive vehicles exists, and during the lock
        that starts with each purchase (COIN_vehicleLimits, COIN_vehicleLocks). Runs on the server (check at the
        purchase) and on clients (build menu), both read the same published locks. Without COIN_enableVehicleLimits
        everything is allowed.

    Parameter(s):
        _class - Vehicle class from the build list [STRING] (other types, e.g. squads, are always allowed)

    Returns:
        [allowed, key of the reason (stringtable, ADR 0026) or "", limit entry of COIN_vehicleLimits or [] if the class is not limited, value for %1 of the reason] [ARRAY]
*/

params [
    ["_class", "", ["", []]]
];

if (!COIN_enableVehicleLimits || {!(_class isEqualType "")}) exitWith {[true, "", [], 0]};

private _classLower = toLower _class;
private _limit = [];
{
    if ((toLower (_x select 0)) isEqualTo _classLower) exitWith {_limit = _x;};
} forEach COIN_vehicleLimits;

if (_limit isEqualTo []) exitWith {[true, "", [], 0]};

private _max = _limit select 1;
// The placement preview and preplaced vehicles carry KP_liberation_preplaced (as in Liberation's unit_cap.sqf). On a local host the preview of the buyer is a vehicle of the server, too
private _alive = count (vehicles select {alive _x && {(toLower (typeOf _x)) isEqualTo _classLower} && {!(_x getVariable ["KP_liberation_preplaced", false])}});
if (_alive >= _max) exitWith {
    [false, "STR_COIN_limits_alive", _limit, _max]
};

private _remaining = 0;
{
    if ((_x select 0) isEqualTo _classLower) exitWith {_remaining = (_x select 1) - serverTime;};
} forEach (missionNamespace getVariable ["COIN_vehicleLocks", []]);

if (_remaining > 0) exitWith {
    [false, "STR_COIN_limits_locked", _limit, ceil (_remaining / 60)]
};

[true, "", _limit, 0]
