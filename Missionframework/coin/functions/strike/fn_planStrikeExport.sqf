/*
    File: fn_planStrikeExport.sqf
    Author: COIN Liberation

    Description:
        Plan of the strike task "Export" (ticket 5.18, DESIGN 8.2), made when it is offered (a kind without a plan is not offered).
        One of the airfields that can be taken (COIN_fnc_findExportAirfields; the requirement has written the reasons for the others to
        the RPT), at random: the civilian plane stands on its runway at the position and in the direction of the list
        COIN_exportAirfields. The guards come
        from a nest a civilian there would know of (COIN_fnc_pickIntelNest), so a prisoner names that nest. The units do not care for
        the players: they appear at the beginning, wherever the players are. Server only.

    Parameter(s):
        _origin - Where the one stands who told of it, for the log [ARRAY, defaults to [0, 0, 0]]

    Returns:
        [position of the runway, name of the airfield, [] (no destination), "", id of the nest of the guards (-1: none), position of the
        plane, direction of the plane, name of the town of the militia], [] if there is no airfield [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]]]
];

if (!isServer) exitWith {[]};

private _airfields = [] call COIN_fnc_findExportAirfields;
if (_airfields isEqualTo []) exitWith {[]};

(selectRandom _airfields) params ["_name", "_pos", "_dir", "_town"];
private _nest = [_pos] call COIN_fnc_pickIntelNest;
private _nestId = if (_nest isEqualTo []) then {-1} else {_nest select 0};

diag_log format [
    "[COIN] strike: export plan: plane at %1 (%2 of %3 airfields), town %4 of the militia, guards of nest %5, %6 m from the origin",
    _name, count _airfields, count COIN_exportAirfields, _town, _nestId, round (_pos distance2D _origin)
];

[[_pos select 0, _pos select 1, 0], _name, [], "", _nestId, _pos, _dir, _town]
