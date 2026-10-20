/*
    File: fn_snapToFloor.sqf
    Author: COIN Liberation

    Description:
        Sets an object down on the floor below it (ticket #44): searches the floor from COIN_floorProbe above to below
        the object (building floor or terrain) and moves the object so the lower edge of its bounding box touches it.
        Building positions are meant for soldiers, props without simulation would hover or sink otherwise.
        Keeps the position if no floor is found.

    Parameter(s):
        _object - Object [OBJECT]

    Returns:
        Floor was found [BOOL]
*/

params [
    ["_object", objNull, [objNull]]
];

if (isNull _object) exitWith {false};

COIN_floorProbe params ["_up", "_down"];
private _posASL = getPosASL _object;
private _hits = lineIntersectsSurfaces [
    _posASL vectorAdd [0, 0, _up], _posASL vectorAdd [0, 0, -_down], _object, objNull, true, 1, "GEOM", "NONE"
];
if (_hits isEqualTo []) exitWith {false};

private _floorZ = ((_hits select 0) select 0) select 2;
private _bottomZ = (_object modelToWorldWorld [0, 0, ((boundingBoxReal _object) select 0) select 2]) select 2;
_object setPosASL (_posASL vectorAdd [0, 0, _floorZ - _bottomZ]);

true
