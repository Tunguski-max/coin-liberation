/*
    File: fn_pathLength.sqf
    Author: COIN Liberation

    Description:
        The length of a path in m: the sum of the distances between its points (2D). Used by the strike tasks with a route (tickets 5.14
        and 5.16).

    Parameter(s):
        _points - Positions of the path [ARRAY of POSITIONs, defaults to []]

    Returns:
        Length in m [NUMBER]
*/

params [
    ["_points", [], [[]]]
];

private _sum = 0;
for "_i" from 1 to (count _points - 1) do {
    _sum = _sum + ((_points select (_i - 1)) distance2D (_points select _i));
};

_sum
