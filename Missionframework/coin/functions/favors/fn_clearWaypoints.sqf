/*
    File: fn_clearWaypoints.sqf
    Author: COIN Liberation

    Description:
        Takes all the waypoints of a group away (tickets 5.6 and 5.19), like Liberation's guerilla scripts do before they give new ones.

    Parameter(s):
        _group - The group [GROUP, defaults to grpNull]

    Returns:
        Nothing
*/

params [
    ["_group", grpNull, [grpNull]]
];

while {(count (waypoints _group)) != 0} do {deleteWaypoint ((waypoints _group) select 0)};
