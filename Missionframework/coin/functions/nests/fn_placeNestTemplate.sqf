/*
    File: fn_placeNestTemplate.sqf
    Author: COIN Liberation

    Description:
        Sets up a building nest after a template (ADR 0019, ticket #44): every object of the template is placed at its
        position in the house model and turned with the house, so the layout follows the house's orientation.
        All objects are created first and then set down on the floor below them, at most COIN_templateSnapMax away
        (objects on tables stay on tables). Props have no simulation; the vehicle of a VBIED garage is locked and keeps
        its simulation, so it can be destroyed (decoration, not the core object). Nothing is saved by Liberation.
        Server only.

    Parameter(s):
        _house    - House of the nest [OBJECT]
        _id       - Nest id [NUMBER]
        _template - Valid template [ARRAY: type, house class, objects] (COIN_nestValidTemplates)

    Returns:
        [objects, core object, outlines [position ATL, radius], log text] [ARRAY]
*/

params [
    ["_house", objNull, [objNull]],
    ["_id", 0, [0]],
    ["_template", [], [[]]]
];

_template params ["_type", "", "_entries"];

private _houseDir = getDir _house;
private _objects = [];
private _core = objNull;
private _vehicles = 0;

{
    _x params ["_class", "_offset", "_dirOffset", "_role"];
    if (_role isEqualTo "vehicle" && {!COIN_enableNestVehicle}) then {continue};

    private _object = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    // No physics while it is moved into the house
    _object enableSimulationGlobal false;
    _object setDir (_houseDir + _dirOffset);
    _object setPosASL (AGLToASL (_house modelToWorld _offset));
    _object setVariable ["KP_liberation_preplaced", true];

    switch (_role) do {
        case "core": {
            _core = _object;
            _object setVariable ["COIN_nestId", _id];
        };
        case "vehicle": {
            _object setVehicleLock "LOCKED";
            _vehicles = _vehicles + 1;
        };
    };
    _objects pushBack _object;
} forEach _entries;

// Set down after all objects exist, so something standing on a table finds the table
{
    [_x, COIN_templateSnapMax] call COIN_fnc_snapToFloor;
} forEach _objects;

// Core object and vehicles get their simulation back (they can be destroyed), props stay without
{
    if (_x isEqualTo _core || {_x isKindOf "AllVehicles"}) then {
        _x enableSimulationGlobal true;
    };
} forEach _objects;

private _outlines = _objects apply {[getPosATL _x, selectMax ([_x] call COIN_fnc_halfSize)]};

[_objects, _core, _outlines, format [", template with %1 objects (%2 props, %3 vehicles)", count _objects, count _objects - 1 - _vehicles, _vehicles]]
