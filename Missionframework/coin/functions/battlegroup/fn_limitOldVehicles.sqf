/*
    File: fn_limitOldVehicles.sqf
    Author: COIN Liberation

    Description:
        At most one old vehicle (BTR-60, M113) per counterattack (ticket 6.2, #157, ADR 0014, E10, hook 34).
        Takes the vehicle classes spawn_battlegroup.sqf has drawn from the preset list; every old vehicle after
        the first is replaced by a random technical from the same list, so the number of vehicles stays the same.
        Old vehicles are the classes of COIN_battlegroupOldVehicleClasses, technicals are the entries of the list
        that are neither an old vehicle nor a troop transport (opfor_troup_transports, they carry a squad).
        Without such a technical in the list nothing is replaced. One log line per replacement. Server only.

    Parameter(s):
        _selection - Vehicle classes drawn for the counterattack [ARRAY of STRING]
        _pool      - The preset list they were drawn from [ARRAY of STRING]

    Returns:
        Vehicle classes with at most one old vehicle [ARRAY of STRING]
*/

params [
    ["_selection", [], [[]]],
    ["_pool", [], [[]]]
];

if (!isServer || {!COIN_enableOldVehicleLimit}) exitWith {_selection};

private _oldClasses = COIN_battlegroupOldVehicleClasses apply {toLower _x};
private _isOld = {(toLower _this) in _oldClasses};

private _technicals = _pool select {!(_x call _isOld) && {!(_x in opfor_troup_transports)}};
private _result = +_selection;
private _kept = false;

{
    if (_x call _isOld) then {
        if (!_kept) then {
            _kept = true;
        } else {
            if (_technicals isEqualTo []) exitWith {
                diag_log format ["[COIN] battlegroup: second old vehicle %1 stays, the list has no technical to replace it", _x];
            };
            private _technical = selectRandom _technicals;
            _result set [_forEachIndex, _technical];
            diag_log format ["[COIN] battlegroup: second old vehicle %1 in the counterattack replaced by technical %2", _x, _technical];
        };
    };
} forEach _selection;

_result
