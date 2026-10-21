/*
    File: fn_describeCampSpot.sqf
    Author: COIN Liberation

    Description:
        Text for the RPT line of a camp (ticket 2.8): distances to the nearest road, town, FOB, captured sector and
        the start base, and the cover around it. Roads are searched within COIN_campExclusionRadius.
        Server only.

    Parameter(s):
        _pos - Camp position [ARRAY]

    Returns:
        E.g. "road 312 m, town Kamino 1204 m, FOB none, captured sector none, start base 8174 m, cover 14" [STRING]
*/

params [
    ["_pos", [], [[]]]
];

private _roads = (_pos nearRoads COIN_campExclusionRadius) apply {_pos distance2D _x};
private _road = if (_roads isEqualTo []) then {format ["none within %1 m", COIN_campExclusionRadius]} else {format ["%1 m", round selectMin _roads]};

private _towns = [sectors_capture + sectors_bigtown, [], {_pos distance2D (markerPos _x)}, "ASCEND"] call BIS_fnc_sortBy;
private _town = format ["%1 %2 m", markerText (_towns select 0), round (_pos distance2D (markerPos (_towns select 0)))];

private _fobs = (missionNamespace getVariable ["GRLIB_all_fobs", []]) apply {_pos distance2D _x};
private _fob = if (_fobs isEqualTo []) then {"none"} else {format ["%1 m", round selectMin _fobs]};

private _captured = (missionNamespace getVariable ["blufor_sectors", []]) apply {_pos distance2D (markerPos _x)};
private _sector = if (_captured isEqualTo []) then {"none"} else {format ["%1 m", round selectMin _captured]};

format [
    "road %1, town %2, FOB %3, captured sector %4, start base %5 m, cover %6",
    _road, _town, _fob, _sector, round (_pos distance2D startbase), [_pos] call COIN_fnc_getCampCover
]
