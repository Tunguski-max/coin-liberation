/*
    File: fn_searchDocuments.sqf
    Author: COIN Liberation

    Description:
        Server: a player searches the stopped car of the courier for documents (ticket 5.14, DESIGN 8.2). Called by the client
        (the action of COIN_fnc_addCourierAction) with remoteExecCall. Checks everything again: the car is the courier's, it is
        stopped (COIN_courierOpen, set by COIN_fnc_runStrikeCourier), alive and not searched yet, the sender owns the unit,
        and the unit is alive and not further than COIN_courierSearchRange plus COIN_courierSearchRangeMargin from the car. Then the car
        counts as searched, the action goes, and the event of the courier ends in success.

    Parameter(s):
        _vehicle - The car [OBJECT, defaults to objNull]
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
    || {!(_vehicle getVariable ["COIN_courier", false])}
    || {!(_vehicle getVariable ["COIN_courierOpen", false])}
    || {_vehicle getVariable ["COIN_courierSearched", false]}
    || {isNull _by}
    || {!alive _by}
    || {(_by distance _vehicle) > (COIN_courierSearchRange + COIN_courierSearchRangeMargin)}
) exitWith {
    diag_log format ["[COIN] strike: search of a courier car by %1 refused (rules)", name _by];
    false
};

_vehicle setVariable ["COIN_courierSearched", true];
_vehicle setVariable ["COIN_courierSearchedBy", _by];
_vehicle setVariable ["COIN_courierOpen", false, true];
diag_log format ["[COIN] strike: %1 searched the courier car at %2", name _by, getPosATL _vehicle];

true
