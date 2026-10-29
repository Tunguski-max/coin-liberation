/*
    File: fn_mortarFobExists.sqf
    Author: COIN Liberation

    Description:
        Is there still a FOB at this position (ticket 6.7a, #158)? A FOB can be dismantled while a mortar attack on it
        runs. A FOB within COIN_mortarFobRadius of the position counts as the same one. Server only.

    Parameter(s):
        _fob - Position of the FOB [ARRAY]

    Returns:
        The FOB exists [BOOL]
*/

params [
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer) exitWith {false};

((missionNamespace getVariable ["GRLIB_all_fobs", []]) findIf {(_x distance2D _fob) < COIN_mortarFobRadius}) >= 0
