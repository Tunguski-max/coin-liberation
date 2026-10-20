/*
    File: fn_snapToFloor.sqf
    Author: COIN Liberation

    Description:
        Sets an object down on the floor below it (ticket #44): finds the floor (COIN_fnc_getFloorASL, the first surface
        below, so a table counts) and moves the object so the lower edge of its bounding box touches it.
        Building positions are meant for soldiers, props without simulation would hover or sink otherwise.
        With a maximum shift, larger gaps are kept: a template object stays where it was placed in Eden and is only
        corrected when houses of the same class stand slightly differently. Template objects are measured at their
        contact point (getPosASL, as Eden placed them) instead of the bounding box, so a correct object does not move.
        Keeps the position if no floor is found.

    Parameter(s):
        _object    - Object [OBJECT]
        _maxShift  - Largest correction in m, -1 for any [NUMBER, defaults to -1]
        _byContact - Measure at the contact point instead of the lower edge of the bounding box [BOOL, defaults to false]

    Returns:
        Object was moved onto the floor [BOOL]
*/

params [
    ["_object", objNull, [objNull]],
    ["_maxShift", -1, [0]],
    ["_byContact", false, [false]]
];

if (isNull _object) exitWith {false};

private _posASL = getPosASL _object;
private _floor = [_posASL, _object] call COIN_fnc_getFloorASL;
if (_floor isEqualTo []) exitWith {false};

private _bottomZ = if (_byContact) then {_posASL select 2} else {
    (_object modelToWorldWorld [0, 0, ((boundingBoxReal _object) select 0) select 2]) select 2
};
private _shift = (_floor select 0) - _bottomZ;
if (_maxShift >= 0 && {abs _shift > _maxShift}) exitWith {false};

_object setPosASL (_posASL vectorAdd [0, 0, _shift]);

true
