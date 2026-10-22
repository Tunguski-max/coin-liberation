/*
    File: fn_spawnCamp.sqf
    Author: COIN Liberation

    Description:
        Spawns the content of a camp when players come near (ticket 2.9, DESIGN 5.1, ADR 0015, ADR 0020), after the
        plan of COIN_fnc_planCamp:
        - the objects of a camp template around the camp position, turned and tilted with the terrain
          (COIN_fnc_placeNestTemplate, a camp template has no core object),
        - the guards: about COIN_nestTerrainGuardShare of them stand in a ring around the camp, the others patrol
          (COIN_fnc_findGuardRingSpots, COIN_fnc_spawnNestGuards),
        - perhaps a technical with militia crew (KPLIB_fnc_spawnVehicle), unlocked so players can capture it.
        Everything goes to Zeus, the fighters are marked as COIN units. The technical carries COIN_campTechnical, so
        COIN_fnc_removeCamp can tell whether a player took it. The budget is asked by the caller. Server only,
        must run scheduled (the vehicle spawn waits).

    Parameter(s):
        _camp     - Camp [ARRAY, layout in COIN_fnc_createCamp]
        _plan     - Result of COIN_fnc_planCamp [ARRAY]
        _distance - Distance of the nearest player, for the log [NUMBER]

    Returns:
        Spawned objects and units [ARRAY of OBJECTs]
*/

params [
    ["_camp", [], [[]]],
    ["_plan", [], [[]]],
    ["_distance", 0, [0]]
];

if (!isServer) exitWith {[]};

_camp params ["_id", "_nestId", "_pos"];
_plan params ["_guardCount", "_templateIndex", "_dir", "_technicalClass"];

private _templates = COIN_validTerrainTemplates select {(_x select 0) isEqualTo "camp"};
([[_pos, _dir], _id, (_templates select _templateIndex) select 1] call COIN_fnc_placeNestTemplate)
    params ["_objects", "", "_placedOutlines", "_layout"];

private _spots = [_pos, _guardCount, _placedOutlines] call COIN_fnc_findGuardRingSpots;
([_pos, _guardCount, _spots, 1] call COIN_fnc_spawnNestGuards)
    params ["_guards", "_inRing", "_patrolling", "_patrolRadius"];
_objects append _guards;

// Technical: on a free spot next to the camp, looking away from it, not locked
private _technical = objNull;
if !(_technicalClass isEqualTo "") then {
    COIN_campTechnicalDist params ["_distMin", "_distMax"];
    private _spot = [_pos, _distMin, _distMax, COIN_campTechnicalClearance, 0, 0.3, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
    _technical = [_spot, _technicalClass, true, false] call KPLIB_fnc_spawnVehicle;
    if (isNull _technical) then {
        diag_log format ["[COIN] camps: camp %1 got no technical, %2 could not be spawned", _id, _technicalClass];
    } else {
        _technical setDir (_pos getDir _spot);
        _technical setVectorUp surfaceNormal (position _technical);
        _technical setVariable ["COIN_campTechnical", true];
        [crew _technical] call COIN_fnc_markCoinUnits;
        _objects pushBack _technical;
        _objects append (crew _technical);
    };
};

[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] camps: camp %1 (nest %2) spawned at %3, player %4 m away: camp template %5 of %6 turned to %7 degrees%8, %9 guards (%10 around the camp, %11 patrolling within %12 m), technical %13",
    _id, _nestId, _pos, round _distance, _templateIndex + 1, count _templates, _dir, _layout,
    _guardCount, _inRing, _patrolling, round _patrolRadius,
    ["none", format ["%1 with %2 crew", _technicalClass, count crew _technical]] select (!isNull _technical)
];

_objects
