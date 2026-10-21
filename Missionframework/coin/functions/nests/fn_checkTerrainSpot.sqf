/*
    File: fn_checkTerrainSpot.sqf
    Author: COIN Liberation

    Description:
        The open-ground rules terrain nests and camps share (ticket 2.8, DESIGN 5 and 5.1): a spot must be away from
        towns and the capital, away from roads, and flat and free of objects. Cheap checks first. Everything else
        (map edge, start base, sectors, exclusion zone, cover) stays with the caller, because nests and camps differ there.

    Parameter(s):
        _pos         - Position [ARRAY]
        _minDistTown - Minimum distance to the centre of a town or the capital in m [NUMBER]
        _minDistRoad - Minimum distance to a road in m [NUMBER]
        _flatRadius  - Radius around the spot that must be flat and free in m [NUMBER]
        _maxGradient - Largest terrain gradient inside that radius (isFlatEmpty) [NUMBER]

    Returns:
        "" if the spot is allowed, otherwise the rule it breaks: "town", "road" or "flat" [STRING]
*/

params [
    ["_pos", [], [[]]],
    ["_minDistTown", 0, [0]],
    ["_minDistRoad", 0, [0]],
    ["_flatRadius", 0, [0]],
    ["_maxGradient", 0, [0]]
];

if (((sectors_capture + sectors_bigtown) findIf {(_pos distance2D (markerPos _x)) < _minDistTown}) >= 0) exitWith {"town"};
if !((_pos nearRoads _minDistRoad) isEqualTo []) exitWith {"road"};
if (((AGLToASL _pos) isFlatEmpty [_flatRadius, -1, _maxGradient, _flatRadius, 0, false]) isEqualTo []) exitWith {"flat"};

""
