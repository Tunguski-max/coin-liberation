/*
    File: fn_findExportAirfields.sqf
    Author: COIN Liberation

    Description:
        The airfields from which the strike task "Export" can be taken (ticket 5.18, DESIGN 8.2): those of COIN_exportAirfields that
        have a runway position, and a place that the militia holds within COIN_exportTownRange m: a town, the capital or a military post
        (COIN_fnc_getMilitiaTowns). An airfield without a position in the list, or without such a place, is left out (with a line in the RPT if asked to log).
        Server only.

    Parameter(s):
        _log - Write the reasons for leaving an airfield out to the RPT [BOOL, defaults to false]

    Returns:
        [[name, position of the runway, direction, name of the nearest place of the militia], ...] [ARRAY]
*/

params [
    ["_log", false, [false]]
];

if (!isServer || {isNil "sectors_capture"}) exitWith {[]};

private _held = [true, true] call COIN_fnc_getMilitiaTowns;
private _found = [];
{
    _x params ["_name", "_pos", "_dir"];
    if (_pos isEqualTo []) then {
        if (_log) then {diag_log format ["[COIN] strike: export: airfield %1 has no runway position in COIN_exportAirfields", _name]};
    } else {
        private _near = _held select {(markerPos _x) distance2D _pos <= COIN_exportTownRange};
        if (_near isEqualTo []) then {
            if (_log) then {diag_log format ["[COIN] strike: export: airfield %1 has no town, capital or military post the militia holds within %2 m, no export", _name, COIN_exportTownRange]};
        } else {
            private _sorted = [_near, [], {(markerPos _x) distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;
            _found pushBack [_name, _pos, _dir, markerText (_sorted select 0)];
        };
    };
} forEach COIN_exportAirfields;

_found
