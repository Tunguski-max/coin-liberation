/*
    File: fn_moveGroup.sqf
    Author: COIN Liberation

    Description:
        Server: sends a group of the reinforcement to a point (tickets 5.6 and 5.19): takes all its waypoints away, lets every unit
        follow its leader again (a unit that was stopped by "doStop" obeys the waypoint then, Liberation does the same before its
        waypoints) and gives the group one move waypoint, with its speed, behaviour and combat mode. The group walks there and stays; the caller may add more
        waypoints to the one that is returned.

    Parameter(s):
        _group     - The group [GROUP, defaults to grpNull]
        _pos       - Where it goes [POSITION, defaults to [0, 0, 0]]
        _radius    - Completion radius of the waypoint in m [NUMBER, defaults to 30]
        _speed     - Speed mode: "LIMITED", "NORMAL" or "FULL" [STRING, defaults to "NORMAL"]
        _behaviour - Behaviour: "SAFE", "AWARE", "COMBAT" [STRING, defaults to "AWARE"]
        _combat    - Combat mode: "YELLOW" (open fire when fired upon or seen), "RED" (open fire at will), "" = not changed
                     [STRING, defaults to "YELLOW"]

    Returns:
        The move waypoint [ARRAY]
*/

params [
    ["_group", grpNull, [grpNull]],
    ["_pos", [0, 0, 0], [[]]],
    ["_radius", 30, [0]],
    ["_speed", "NORMAL", [""]],
    ["_behaviour", "AWARE", [""]],
    ["_combat", "YELLOW", [""]]
];

if (!isServer || {isNull _group}) exitWith {[]};

[_group] call COIN_fnc_clearWaypoints;
{_x doFollow (leader _group)} forEach (units _group);
_group setBehaviour _behaviour;
_group setSpeedMode _speed;
if (_combat isNotEqualTo "") then {_group setCombatMode _combat};

private _waypoint = _group addWaypoint [_pos, 0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointCompletionRadius _radius;
// The group may have had a waypoint that was current: it must go to the new one, not wait for the one that is gone
_group setCurrentWaypoint _waypoint;

_waypoint
