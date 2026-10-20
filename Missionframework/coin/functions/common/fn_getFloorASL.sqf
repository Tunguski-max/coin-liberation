/*
    File: fn_getFloorASL.sqf
    Author: COIN Liberation

    Description:
        Height of the floor below a spot (ticket #44): building floor or terrain, searched from COIN_floorProbe above
        to below the spot. Uses the geometry LOD, the view LOD where a model has none. Units and vehicles are no floor.

    Parameter(s):
        _posASL  - Spot [ARRAY]
        _ignore1 - Object the search ignores, e.g. the object to set down [OBJECT]
        _ignore2 - Second object to ignore [OBJECT]

    Returns:
        [floor height ASL], or [] if there is no floor within reach [ARRAY]
*/

params [
    ["_posASL", [], [[]]],
    ["_ignore1", objNull, [objNull]],
    ["_ignore2", objNull, [objNull]]
];

COIN_floorProbe params ["_up", "_down"];
private _hits = (lineIntersectsSurfaces [
    _posASL vectorAdd [0, 0, _up], _posASL vectorAdd [0, 0, -_down], _ignore1, _ignore2, true, -1, "GEOM", "VIEW"
]) select {
    private _hitObject = _x select 2;
    isNull _hitObject || {!(_hitObject isKindOf "AllVehicles")}
};

if (_hits isEqualTo []) exitWith {[]};
[((_hits select 0) select 0) select 2]
