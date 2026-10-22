/*
    File: fn_spawnPopulation.sqf
    Author: COIN Liberation

    Description:
        Spawns the own civilians of a liberated town (ticket 3.7, ADR 0011): COIN_populationRadius around the centre of
        the sector, each at a free spot (BIS_fnc_findSafePos, so not inside a building), each in a group of his own
        like Liberation's civilians and walking around the town (Liberation's add_civ_waypoints). They are made like
        Liberation's civilians (preset list civilians, KPLIB_fnc_createManagedUnit), so killing one costs reputation
        through Liberation's kill manager. Handed to Zeus. Without a free spot a civilian stands in the centre.
        Server only.

    Parameter(s):
        _sector - Sector marker of the town [STRING, defaults to ""]
        _count  - Number of civilians [NUMBER, defaults to 0]

    Returns:
        The spawned civilians [ARRAY of OBJECTs]
*/

params [
    ["_sector", "", [""]],
    ["_count", 0, [0]]
];

if (!isServer || {_sector isEqualTo ""} || {_count <= 0}) exitWith {[]};

private _center = markerPos _sector;
private _civs = [];

for "_i" from 1 to _count do {
    private _pos = [_center, 0, COIN_populationRadius, COIN_populationSpotClearance, 0, COIN_populationMaxGradient, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
    private _group = createGroup [GRLIB_side_civilian, true];
    private _civ = [selectRandom civilians, _pos, _group] call KPLIB_fnc_createManagedUnit;
    if (isNil "add_civ_waypoints") then {
        diag_log "[COIN] population: ERROR - Liberation's add_civ_waypoints is missing, the civilians stand still";
    } else {
        [_group] call add_civ_waypoints;
    };
    _civs pushBack _civ;
};

[_civs] call COIN_fnc_addToCurators;

_civs
