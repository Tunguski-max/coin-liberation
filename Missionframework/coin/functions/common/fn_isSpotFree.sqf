/*
    File: fn_isSpotFree.sqf
    Author: COIN Liberation

    Description:
        Is there room for an object of the given size at a spot (ticket #44)? Two checks:
        - no blocker (already placed object, door) closer than both radii on the same floor (COIN_spotSameFloor),
        - no wall or other geometry within the object's outline: eight rays from the centre, COIN_spotCheckHeight above
          the spot, each as long as the outline (ellipse of the half sizes) in its direction.

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

private _radius = _halfX max _halfY;
private _blocked = _blockers findIf {
    _x params ["_blockPos", "_blockRadius"];
    (_posATL distance2D _blockPos) < (_radius + _blockRadius)
    && {abs ((_posATL select 2) - (_blockPos select 2)) < COIN_spotSameFloor}
};
if (_blocked >= 0) exitWith {false};

private _center = (AGLToASL _posATL) vectorAdd [0, 0, COIN_spotCheckHeight];
private _free = true;
for "_angle" from 0 to 315 step 45 do {
    private _length = sqrt (((_halfX * sin _angle) ^ 2) + ((_halfY * cos _angle) ^ 2));
    private _end = _center vectorAdd [(sin (_dir + _angle)) * _length, (cos (_dir + _angle)) * _length, 0];
    if !((lineIntersectsSurfaces [_center, _end, _ignore param [0, objNull], _ignore param [1, objNull], true, 1, "GEOM", "NONE"]) isEqualTo []) exitWith {
        _free = false;
    };
};

_free
