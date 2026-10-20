/*
    File: fn_halfSize.sqf
    Author: COIN Liberation

    Description:
        Half width (model x) and half length (model y) of an object from its bounding box (ticket #44).

    Parameter(s):
        _object - Object [OBJECT]

    Returns:
        [half width, half length] in m [ARRAY]
*/

params [
    ["_object", objNull, [objNull]]
];

(boundingBoxReal _object) params ["_corner1", "_corner2"];
[abs ((_corner2 select 0) - (_corner1 select 0)) / 2, abs ((_corner2 select 1) - (_corner1 select 1)) / 2]
