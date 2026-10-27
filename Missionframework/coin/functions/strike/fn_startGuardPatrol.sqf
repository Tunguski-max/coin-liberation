/*
    File: fn_startGuardPatrol.sqf
    Author: COIN Liberation

    Description:
        Sends a group of guards of a strike task on a patrol round a centre (tickets 5.15 and 5.18): a loop of waypoints at free spots,
        each in its own sector of the circle, so the loop goes round the centre, walking. (Liberation's BIS_fnc_taskPatrol did not make
        the guards move, so the waypoints are our own.) Server only.

    Parameter(s):
        _group     - The patrolling group [GROUP, defaults to grpNull]
        _centre    - What the patrol goes round [ARRAY, defaults to [0, 0, 0]]
        _radius    - m round the centre within which the patrol walks [NUMBER, defaults to 0]
        _points    - Waypoints of the loop [NUMBER, defaults to 0]
        _arrive    - m from a waypoint at which the group goes on to the next [NUMBER, defaults to 0]
        _behaviour - Behaviour of the group on the patrol [STRING, defaults to "AWARE"]

    Returns:
        Number of waypoints of the group [NUMBER]
*/

params [
    ["_group", grpNull, [grpNull]],
    ["_centre", [0, 0, 0], [[]]],
    ["_radius", 0, [0]],
    ["_points", 0, [0]],
    ["_arrive", 0, [0]],
    ["_behaviour", "AWARE", [""]]
];

if (!isServer || {isNull _group} || {_points < 1}) exitWith {0};

private _spots = [];
for "_i" from 0 to (_points - 1) do {
    // Each point in its own sector of the circle, so the loop goes round the centre
    private _angle = _i * 360 / _points;
    private _point = _centre getPos [(_radius * 0.5) + random (_radius * 0.5), _angle + random (360 / _points)];
    private _safe = [_point, 0, 8, COIN_strikeGuardClearance, 0, COIN_strikeGuardGradient, 0, [], [_point, _point]] call BIS_fnc_findSafePos;
    if (_safe isEqualType [] && {count _safe >= 2} && {(_safe select 0) isEqualType 0}) then {_point = _safe};
    _spots pushBack [_point select 0, _point select 1, 0];
};
{
    private _waypoint = _group addWaypoint [_x, 0];
    _waypoint setWaypointType "MOVE";
    _waypoint setWaypointSpeed "LIMITED";
    _waypoint setWaypointBehaviour _behaviour;
    _waypoint setWaypointCompletionRadius _arrive;
} forEach _spots;
(_group addWaypoint [_spots select 0, 0]) setWaypointType "CYCLE";

count waypoints _group
