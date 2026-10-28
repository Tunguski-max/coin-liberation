/*
    File: fn_limitOldVehicles.sqf
    Author: COIN Liberation

    Description:
        At most COIN_battlegroupOldVehicleMax (1) old vehicles per counterattack (ticket 6.2, #157, ADR 0014, E10, hook 34).
        Takes the vehicle classes spawn_battlegroup.sqf has drawn from the preset list; every old vehicle beyond the
        limit is replaced by a random technical from the same list, so the number of vehicles stays the same.
        Old vehicles are the classes of COIN_battlegroupOldVehicleClasses, technicals are the entries of the list
        that are neither an old vehicle nor a troop transport (opfor_troup_transports, they carry a squad).
        Without such a technical in the list nothing is replaced (one log line). One log line per replacement.
        Server only.

    Parameter(s):
        _selection - Vehicle classes drawn for the counterattack [ARRAY of STRING]
        _pool      - The preset list they were drawn from [ARRAY of STRING]

    Returns:
        Vehicle classes with at most COIN_battlegroupOldVehicleMax old vehicles [ARRAY of STRING]
*/

params [
    ["_selection", [], [[]]],
    ["_pool", [], [[]]]
];

if (!isServer || {!COIN_enableOldVehicleLimit}) exitWith {_selection};

private _oldClasses = COIN_battlegroupOldVehicleClasses apply {toLower _x};
private _transports = opfor_troup_transports apply {toLower _x};

private _oldIndexes = [];
{
    if ((toLower _x) in _oldClasses) then {_oldIndexes pushBack _forEachIndex};
} forEach _selection;

private _excess = _oldIndexes select [COIN_battlegroupOldVehicleMax, count _oldIndexes];
if (_excess isEqualTo []) exitWith {_selection};

private _technicals = _pool select {!((toLower _x) in _oldClasses) && {!((toLower _x) in _transports)}};
if (_technicals isEqualTo []) exitWith {
    diag_log format ["[COIN] battlegroup: %1 old vehicle(s) over the limit of %2 stay, the list has no technical to replace them", count _excess, COIN_battlegroupOldVehicleMax];
    _selection
};

private _result = +_selection;
{
    private _technical = selectRandom _technicals;
    diag_log format ["[COIN] battlegroup: old vehicle %1 over the limit of %2 replaced by technical %3", _selection select _x, COIN_battlegroupOldVehicleMax, _technical];
    _result set [_x, _technical];
} forEach _excess;

_result
