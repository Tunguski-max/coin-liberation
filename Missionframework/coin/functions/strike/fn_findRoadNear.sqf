/*
    File: fn_findRoadNear.sqf
    Author: COIN Liberation

    Description:
        The road piece a car of a strike task starts or ends on (tickets 5.14 and 5.16): of the roads within the radius around a
        position the ones a car can use (no path, no other vehicle, a parked car, within COIN_strikeRoadClearance, or the car would stand
        wedged), a main road before a road before a track (COIN_strikeRoadTypes), within a type the nearest to the position.
        Server only.

    Parameter(s):
        _centre - Position, 2D or 3D [ARRAY, defaults to [0, 0, 0]]
        _radius - Radius in m the road is looked for [NUMBER, defaults to 300]

    Returns:
        The road piece, objNull if there is none [OBJECT]
*/

params [
    ["_centre", [0, 0, 0], [[]]],
    ["_radius", 300, [0]]
];

if (!isServer) exitWith {objNull};

private _roads = (_centre nearRoads _radius) select {
    private _info = getRoadInfo _x;
    _info isNotEqualTo [] && {!(_info select 2)} && {(nearestObjects [getPosATL _x, ["LandVehicle"], COIN_strikeRoadClearance]) isEqualTo []}
};
if (_roads isEqualTo []) exitWith {objNull};

_roads = [_roads, [], {
    private _rank = COIN_strikeRoadTypes find ((getRoadInfo _x) select 0);
    if (_rank < 0) then {_rank = count COIN_strikeRoadTypes};
    (_rank * 100000) + (_x distance2D _centre)
}, "ASCEND"] call BIS_fnc_sortBy;

_roads select 0
