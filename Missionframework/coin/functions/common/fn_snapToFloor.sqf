/*
    File: fn_snapToFloor.sqf
    Author: COIN Liberation

    Description:
        Sets an object down on the floor below it (ticket #44): finds the floor (COIN_fnc_getFloorASL) and moves the
        object so the lower edge of its bounding box touches it. Building positions are meant for soldiers, props
        without simulation would hover or sink otherwise. Keeps the position if no floor is found.

    Parameter(s):
        _object - Object [OBJECT]

    Returns:
        Floor was found [BOOL]
*/

params [
    ["_object", objNull, [objNull]]
];

if (isNull _object) exitWith {false};

private _posASL = getPosASL _object;
private _floor = [_posASL, _object] call COIN_fnc_getFloorASL;
if (_floor isEqualTo []) exitWith {false};

private _bottomZ = (_object modelToWorldWorld [0, 0, ((boundingBoxReal _object) select 0) select 2]) select 2;
_object setPosASL (_posASL vectorAdd [0, 0, (_floor select 0) - _bottomZ]);

true
