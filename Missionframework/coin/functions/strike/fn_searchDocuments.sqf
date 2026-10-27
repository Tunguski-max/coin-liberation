/*
    File: fn_searchDocuments.sqf
    Author: COIN Liberation

    Description:
        Server: a player searches a stopped vehicle for documents: the car of the courier (ticket 5.14, DESIGN 8.2) or a truck of the
        arms transport (ticket 5.16). Called by the client (the action of COIN_fnc_addCourierAction) with remoteExecCall. Checks
        everything again: the vehicle is searchable (COIN_searchable), it is open to a search (COIN_searchOpen, set by the event that made
        it: COIN_fnc_runStrikeCourier, COIN_fnc_runStrikeConvoy), alive and not searched yet, the sender owns the unit, and the unit is
        alive and not further than COIN_courierSearchRange plus COIN_courierSearchRangeMargin from the vehicle. Then the vehicle counts as
        searched (COIN_searched, COIN_searchedBy), the action goes, and the event looks at it and goes on.

    Parameter(s):
        _vehicle - The car or truck [OBJECT, defaults to objNull]
        _by      - The player who searches [OBJECT, defaults to objNull]

    Returns:
        The search was accepted [BOOL]
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_by", objNull, [objNull]]
];

if (!isServer || {!COIN_enableStrikeTasks}) exitWith {false};

// The player must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _by != _sender}) exitWith {
    diag_log format ["[COIN] strike: ERROR - search sent by machine %1, not the owner of %2, refused", _sender, _by];
    false
};

if (
    isNull _vehicle
    || {!alive _vehicle}
    || {!(_vehicle getVariable ["COIN_searchable", false])}
    || {!(_vehicle getVariable ["COIN_searchOpen", false])}
    || {_vehicle getVariable ["COIN_searched", false]}
    || {isNull _by}
    || {!alive _by}
    || {(_by distance _vehicle) > (COIN_courierSearchRange + COIN_courierSearchRangeMargin)}
) exitWith {
    diag_log format ["[COIN] strike: search of a vehicle by %1 refused (rules)", name _by];
    false
};

_vehicle setVariable ["COIN_searched", true];
_vehicle setVariable ["COIN_searchedBy", _by];
_vehicle setVariable ["COIN_searchOpen", false, true];
diag_log format ["[COIN] strike: %1 searched the vehicle (%3) at %2", name _by, getPosATL _vehicle, typeOf _vehicle];

true
