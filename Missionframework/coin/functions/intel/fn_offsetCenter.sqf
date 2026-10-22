/*
    File: fn_offsetCenter.sqf
    Author: COIN Liberation

    Description:
        Middle of an intel circle around a point (ticket 3.1, DESIGN 7): moved away from the point by a share of the
        radius (COIN_intelCenterOffset) in a random direction, so the point lies in the circle but not in its middle and
        the circle does not give it away. The point is a nest, or the fake point of a lie.

    Parameter(s):
        _pos    - Nest or fake point [ARRAY]
        _radius - Radius of the circle in m [NUMBER]

    Returns:
        Middle of the circle [ARRAY]
*/

params [
    ["_pos", [], [[]]],
    ["_radius", 0, [0]]
];

private _minShare = COIN_intelCenterOffset select 0;
private _maxShare = COIN_intelCenterOffset select 1;

_pos getPos [_radius * (_minShare + random (_maxShare - _minShare)), random 360]
