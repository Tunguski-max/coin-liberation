/*
    File: fn_getRelief.sqf
    Author: COIN Liberation
    Description:
        Where does the relief for a militia sector under attack come from? (ticket 6.1c, #156, ADR 0025, hook 33)
        Asked by reinforcements_manager.sqf instead of Liberation's search for the nearest radio tower. With
        COIN_enableStagingAreas and COIN_enableStagingRelief it is the nearest staging area (distance from its
        centre) that contains the sector, and the relief calls no paratroopers (the militia has no helicopters,
        ADR 0014). A sector in no staging area gets no relief. With one of the two switches off it is Liberation's
        radio tower search, paratroopers as before (without towers on the map: no relief). Logs the result.
        Server only.

    Parameter(s):
        _sector - Marker of the sector under attack [STRING]

    Returns:
        [] if there is no relief, otherwise [distance of the source to the sector in m, source, paratroopers allowed],
        source is ["nest", id] or ["sector", marker] (see COIN_fnc_getStagingAreas), or ["tower", marker] [ARRAY]
*/

params [
    ["_sector", "", [""]]
];

if (!isServer) exitWith {[]};

private _name = format ["%1 (%2)", _sector, markerText _sector];

if !(COIN_enableStagingAreas && {COIN_enableStagingRelief}) exitWith {
    private _tower = [markerPos _sector, GRLIB_side_enemy, GRLIB_radiotower_size * 1.4] call KPLIB_fnc_getNearestTower;
    if (isNil "_tower") exitWith {[]};
    [(markerPos _tower) distance (markerPos _sector), ["tower", _tower], true]
};

private _areas = [markerPos _sector] call COIN_fnc_getStagingAreasAt;
if (_areas isEqualTo []) exitWith {
    diag_log format ["[COIN] staging: relief for %1: no staging area contains the sector, no relief", _name];
    []
};

// The nearest staging area by its centre
private _distances = _areas apply {[(markerPos _sector) distance2D (_x select 0), _x select 2]};
_distances sort true;
(_distances select 0) params ["_distance", "_source"];

diag_log format [
    "[COIN] staging: relief for %1 comes from %2, %3 m away",
    _name, [_areas select (_areas findIf {(_x select 2) isEqualTo _source})] call COIN_fnc_describeStagingArea, round _distance
];

[_distance, _source, false]
