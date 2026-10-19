/*
    File: fn_vehicleLimitRelease.sqf
    Author: COIN Liberation

    Description:
        Server: the buyer cancelled the placement (and got the price back), so the lock of this purchase is
        lifted again (ticket 1.9). Only the machine that started the lock can lift it.

    Parameter(s):
        _class - Class whose placement was cancelled [STRING]

    Returns:
        A lock was lifted [BOOL]
*/

params [
    ["_class", "", [""]]
];

if (!isServer) exitWith {false};

private _owner = remoteExecutedOwner;
if (_owner <= 0) then {_owner = 2;};

private _classLower = toLower _class;
private _locks = missionNamespace getVariable ["COIN_vehicleLocks", []];
private _remaining = _locks select {!((_x select 0) isEqualTo _classLower && {(_x select 2) isEqualTo _owner})};

if (count _remaining == count _locks) exitWith {false};

COIN_vehicleLocks = _remaining;
publicVariable "COIN_vehicleLocks";
diag_log format ["[COIN] limits: placement of %1 cancelled by %2, lock lifted", _class, _owner];

true
