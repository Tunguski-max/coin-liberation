/*
    File: fn_findMortarSpot.sqf
    Author: COIN Liberation

    Description:
        Position for the mortar squad of a mortar attack (ticket 6.7a, #158, DESIGN 9): COIN_mortarDistance
        (1500-2500 m) from the FOB, out of sight of the players, preferably inside a staging area, on flat ground.
        Tries COIN_mortarSpotTries random points in two passes: first only inside a staging area, then anywhere.
        A point is rejected when it is
        - in water, steeper than COIN_mortarMinNormalZ, on or beside a road, under a roof or a tree,
        - too close to a wall, house, fence or tree: a ray in 8 directions at each of COIN_mortarClearHeights hits
          something within COIN_mortarClearRadius (a shell must not hit it, the squad must not be hurt),
        - in a blocked firing arc: a ray of COIN_mortarClearArc m towards the FOB at each of COIN_mortarClearElevations
          (degrees above the horizon, the mortar fires steeply) hits something,
        - closer than COIN_mortarMinDistSector to a sector centre, closer than COIN_mortarMinDistBase to the start base
          or a FOB,
        - closer than COIN_mortarMinDistPlayer to a player, or seen by a player within COIN_mortarSightDistance
          (line of sight from his eyes to a point 1.5 m above the ground).
        Server only.

    Parameter(s):
        _fob - Position of the FOB that is shelled [ARRAY]

    Returns:
        [position or [] if none was found, the spot is inside a staging area, rejected points per rule (HASHMAP rule -> number)] [ARRAY]
*/

params [
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer) exitWith {[[], false, createHashMap]};

COIN_mortarDistance params ["_distMin", "_distMax"];

private _players = (allPlayers - entities "HeadlessClient_F") select {alive _x};
private _bases = [startbase] + (missionNamespace getVariable ["GRLIB_all_fobs", []]);
private _rejected = createHashMap;

// Directions of the wall check, evenly around the mortar
private _angles = [];
for "_i" from 0 to (COIN_mortarClearDirections - 1) do {
    _angles pushBack (_i * 360 / COIN_mortarClearDirections);
};

// The rule a point breaks, "" if none. The cheap rules come first, the rays last
private _fault = {
    params ["_point"];
    private _ground = ATLToASL _point;
    switch (true) do {
        case (surfaceIsWater _point): {"water"};
        case (((surfaceNormal _point) select 2) < COIN_mortarMinNormalZ): {"slope"};
        case (isOnRoad _point || {(_point nearRoads 15) isNotEqualTo []}): {"road"};
        case ((sectors_allSectors findIf {(_point distance2D (markerPos _x)) < COIN_mortarMinDistSector}) >= 0): {"sector"};
        case ((_bases findIf {(_point distance2D _x) < COIN_mortarMinDistBase}) >= 0): {"base"};
        case ((_players findIf {(_x distance2D _point) < COIN_mortarMinDistPlayer}) >= 0): {"playerNear"};
        case (lineIntersects [_ground vectorAdd [0, 0, 0.5], _ground vectorAdd [0, 0, 8]]): {"covered"};
        case ((COIN_mortarClearHeights findIf {
            private _height = _x;
            // Objects only: terrain hits (a slope) are no wall
            (_angles findIf {
                ((lineIntersectsSurfaces [
                    _ground vectorAdd [0, 0, _height],
                    _ground vectorAdd [(sin _x) * COIN_mortarClearRadius, (cos _x) * COIN_mortarClearRadius, _height],
                    objNull, objNull, true, COIN_mortarClearMaxHits, "GEOM", "NONE"
                ]) findIf {!isNull (_x select 2)}) >= 0
            }) >= 0
        }) >= 0): {"wall"};
        case ((COIN_mortarClearElevations findIf {
            private _toFob = _point getDir _fob;
            private _start = _ground vectorAdd [0, 0, COIN_mortarClearArcStart];
            lineIntersects [_start, _start vectorAdd [(sin _toFob) * (cos _x) * COIN_mortarClearArc, (cos _toFob) * (cos _x) * COIN_mortarClearArc, (sin _x) * COIN_mortarClearArc]]
        }) >= 0): {"arc"};
        case ((_players findIf {
            (_x distance2D _point) < COIN_mortarSightDistance
            && {(lineIntersectsSurfaces [eyePos _x, _ground vectorAdd [0, 0, 1.5], _x, objNull, true, 1, "VIEW", "FIRE"]) isEqualTo []}
        }) >= 0): {"seen"};
        default {""};
    }
};

private _spot = [];
private _inArea = false;
{
    private _needArea = _x;
    for "_i" from 1 to COIN_mortarSpotTries do {
        private _point = _fob getPos [_distMin + random (_distMax - _distMin), random 360];
        _point = [_point select 0, _point select 1, 0];

        if (_needArea && {([_point] call COIN_fnc_getStagingAreasAt) isEqualTo []}) then {
            _rejected set ["outsideArea", (_rejected getOrDefault ["outsideArea", 0]) + 1];
            continue;
        };
        private _rule = [_point] call _fault;
        if (_rule isNotEqualTo "") then {
            _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
            continue;
        };
        _spot = _point;
        break;
    };
    if (_spot isNotEqualTo []) exitWith {};
} forEach [true, false];

if (_spot isNotEqualTo []) then {
    _inArea = ([_spot] call COIN_fnc_getStagingAreasAt) isNotEqualTo [];
};

[_spot, _inArea, _rejected]
