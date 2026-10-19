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
        [allowed, reason shown to the player, limit entry of COIN_vehicleLimits or [] if the class is not limited] [ARRAY]
*/

params [
    ["_class", "", ["", []]]
];

if (!COIN_enableVehicleLimits || {!(_class isEqualType "")}) exitWith {[true, "", []]};

private _classLower = toLower _class;
private _limit = [];
{
    if ((toLower (_x select 0)) isEqualTo _classLower) exitWith {_limit = _x;};
} forEach COIN_vehicleLimits;

if (_limit isEqualTo []) exitWith {[true, "", []]};

private _max = _limit select 1;
// The placement preview and preplaced vehicles carry KP_liberation_preplaced (as in Liberation's unit_cap.sqf). On a local host the preview of the buyer is a vehicle of the server, too
private _alive = count (vehicles select {alive _x && {(toLower (typeOf _x)) isEqualTo _classLower} && {!(_x getVariable ["KP_liberation_preplaced", false])}});
if (_alive >= _max) exitWith {
    [false, format ["Bereits im Einsatz (höchstens %1 gleichzeitig)", _max], _limit]
};

private _remaining = 0;
{
    if ((_x select 0) isEqualTo _classLower) exitWith {_remaining = (_x select 1) - serverTime;};
} forEach (missionNamespace getVariable ["COIN_vehicleLocks", []]);

if (_remaining > 0) exitWith {
    [false, format ["Gesperrt: noch %1 Min. bis zum nächsten Kauf", ceil (_remaining / 60)], _limit]
};

[true, "", _limit]
