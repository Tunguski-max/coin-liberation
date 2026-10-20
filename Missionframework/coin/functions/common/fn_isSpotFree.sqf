/*
    File: fn_isSpotFree.sqf
    Author: COIN Liberation

    Description:
        Is there room for an object of the given size at a spot (ticket #44)? The object is taken as a rectangle
        (half width, half length, facing _dir). Two checks:
        - no blocker (placed object, door point) inside the rectangle grown by the blocker's radius, on the same floor
          (COIN_spotSameFloor),
        - no wall or other fixed geometry between the centre and the four corners and four edge middles, at every
          height of COIN_spotCheckHeights above the spot. Units and vehicles do not count.

    Parameter(s):
        _posATL   - Spot on the floor [ARRAY]
        _dir      - Direction the object would face [NUMBER]
        _halfX    - Half width of the object [NUMBER]
        _halfY    - Half length of the object [NUMBER]
        _ignore   - Up to two objects the rays ignore, e.g. the object itself [ARRAY of OBJECTs]
        _blockers - Taken places [ARRAY of [position ATL, radius]]

    Returns:
        Spot is free [BOOL]
*/

params [
    ["_posATL", [], [[]]],
    ["_dir", 0, [0]],
    ["_halfX", 0, [0]],
    ["_halfY", 0, [0]],
    ["_ignore", [], [[]]],
    ["_blockers", [], [[]]]
];

// Axes of the object on the map: right (model x) and forward (model y)
private _right = [cos _dir, -(sin _dir), 0];
private _forward = [sin _dir, cos _dir, 0];

private _blocked = _blockers findIf {
    _x params ["_blockPos", "_blockRadius"];
    private _offset = _blockPos vectorDiff _posATL;
    abs ((_offset select 2)) < COIN_spotSameFloor
    && {abs (_offset vectorDotProduct _right) < (_halfX + _blockRadius)}
    && {abs (_offset vectorDotProduct _forward) < (_halfY + _blockRadius)}
};
if (_blocked >= 0) exitWith {false};

private _ignore1 = _ignore param [0, objNull];
private _ignore2 = _ignore param [1, objNull];
private _outline = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]];
private _free = true;
{
    private _center = (AGLToASL _posATL) vectorAdd [0, 0, _x];
    {
        _x params ["_sx", "_sy"];
        private _end = _center vectorAdd ((_right vectorMultiply (_sx * _halfX)) vectorAdd (_forward vectorMultiply (_sy * _halfY)));
        private _hits = (lineIntersectsSurfaces [_center, _end, _ignore1, _ignore2, true, -1, "GEOM", "VIEW"]) select {
            private _hitObject = _x select 2;
            isNull _hitObject || {!(_hitObject isKindOf "AllVehicles")}
        };
        if !(_hits isEqualTo []) exitWith {
            _free = false;
        };
    } forEach _outline;
    if (!_free) exitWith {};
} forEach COIN_spotCheckHeights;

_free
