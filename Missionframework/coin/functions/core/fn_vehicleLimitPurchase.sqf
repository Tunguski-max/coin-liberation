/*
    File: fn_vehicleLimitPurchase.sqf
    Author: COIN Liberation

    Description:
        Server check at every vehicle purchase (hook 12 in build_remote_call.sqf, ticket 1.9, ADR 0007).
        Allowed: starts the lock of the class (minutes from COIN_vehicleLimits, not persisted) and publishes
        the locks, so every build menu shows them.
        Denied (e.g. two players bought at the same time, or the menu was bypassed): tells the buyer's client to
        cancel the placement. Liberation has already charged the price at this point, the cancel refunds it.

    Parameter(s):
        _class - Bought class [STRING]
        _owner - Network ID of the buyer's machine (remoteExecutedOwner) [NUMBER]

    Returns:
        Purchase is allowed [BOOL]
*/

params [
    ["_class", "", [""]],
    ["_owner", 0, [0]]
];

if (!isServer) exitWith {false};

([_class] call COIN_fnc_vehicleLimitStatus) params ["_allowed", "_reason", "_limit"];
if (_limit isEqualTo []) exitWith {true};

// A local host calls itself, remoteExecutedOwner is then 0 and the host's machine is 2
if (_owner <= 0) then {_owner = 2;};

if (!_allowed) exitWith {
    diag_log format ["[COIN] limits: purchase of %1 denied (%2), buyer %3", _class, _reason, _owner];
    [_reason] remoteExecCall ["COIN_fnc_vehicleLimitDeny", _owner];
    false
};

private _classLower = toLower _class;
private _end = serverTime + ((_limit select 2) * 60);

// Drop the lock of this class and expired locks, then add the new one
private _locks = (missionNamespace getVariable ["COIN_vehicleLocks", []]) select {
    !((_x select 0) isEqualTo _classLower) && {(_x select 1) > serverTime}
};
_locks pushBack [_classLower, _end, _owner];
COIN_vehicleLocks = _locks;
publicVariable "COIN_vehicleLocks";

diag_log format ["[COIN] limits: %1 bought by %2, locked for %3 min, max %4 alive", _class, _owner, _limit select 2, _limit select 1];

true
