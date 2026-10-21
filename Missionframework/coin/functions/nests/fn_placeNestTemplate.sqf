/*
    File: fn_placeNestTemplate.sqf
    Author: COIN Liberation

    Description:
        Sets up the objects of a template (ADR 0019, ADR 0020, tickets #44 and #31):
        - building template: every object is placed at its position in the house model and turned with the house,
          so the layout follows the house's orientation. Props stand exactly as placed in Eden (COIN_templateSnapMax,
          default never corrected); vehicles are set down on the floor within COIN_templateVehicleSnapMax.
        - terrain template: every object is placed at its offset from the centre, turned with the template's direction,
          at its height above the terrain below it, and tilted with the slope there (surface normal).
        Vehicles cannot be damaged for COIN_spawnVehicleProtection seconds while their physics starts.
        Props have no simulation; the vehicle of a VBIED garage is locked and keeps its simulation, so it can be
        destroyed (decoration, not the core object). Mines are live (createMine), players can defuse them with ACE.
        Everything except the mines is excluded from Liberation's save: Liberation saves every mine near a FOB, so a
        FOB within about 150 m of such a nest doubles them after a restart (known limitation).
        Server only.

    Parameter(s):
        _anchor  - House of a building template, or [centre position, direction] of a terrain template [OBJECT or ARRAY]
        _id      - Nest id, set on the core object [NUMBER]
        _entries - Objects of a valid template [ARRAY of [class, offset, direction, role]]

    Returns:
        [objects, core object (objNull if the template has none), outlines [position ATL, radius], log text] [ARRAY]
*/

params [
    ["_anchor", objNull, [objNull, []]],
    ["_id", 0, [0]],
    ["_entries", [], [[]]]
];

private _inHouse = _anchor isEqualType objNull;
private _anchorDir = if (_inHouse) then {getDir _anchor} else {_anchor param [1, 0]};
private _objects = [];
private _core = objNull;
private _vehicles = [];

{
    _x params ["_class", "_offset", "_dirOffset", "_role"];
    if (_role isEqualTo "vehicle" && {!COIN_enableNestVehicle}) then {continue};
    if (_role isEqualTo "mine" && {!COIN_enableNestMines}) then {continue};

    private _posASL = if (_inHouse) then {
        AGLToASL (_anchor modelToWorld _offset)
    } else {
        // Offset turned with the template (x to the right, y to the front), height above the terrain below the object
        (_anchor select 0) params ["_centreX", "_centreY"];
        _offset params ["_offsetX", "_offsetY", "_height"];
        ATLToASL [
            _centreX + _offsetX * cos _anchorDir + _offsetY * sin _anchorDir,
            _centreY - _offsetX * sin _anchorDir + _offsetY * cos _anchorDir,
            _height
        ]
    };
    private _object = if (_role isEqualTo "mine") then {
        // Live mine (decided 2026-10-20): players can defuse it with ACE, a shot can set it off
        createMine [_class, ASLToATL _posASL, [], 0]
    } else {
        private _created = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
        // No physics while it is moved into place
        _created enableSimulationGlobal false;
        _created
    };
    private _dir = _anchorDir + _dirOffset;
    _object setDir _dir;
    if (!_inHouse) then {
        // Tilted with the slope below it, still facing its direction
        private _up = surfaceNormal _posASL;
        private _forward = [sin _dir, cos _dir, 0];
        _object setVectorDirAndUp [vectorNormalized (_forward vectorDiff (_up vectorMultiply (_forward vectorDotProduct _up))), _up];
    };
    _object setPosASL _posASL;
    _object setVariable ["KP_liberation_preplaced", true];

    switch (_role) do {
        case "core": {
            _core = _object;
            _object setVariable ["COIN_nestId", _id];
        };
        case "vehicle": {
            _object setVehicleLock "LOCKED";
            _vehicles pushBack _object;
        };
    };
    _objects pushBack _object;
} forEach _entries;

// Building templates: set down after all objects exist, measured at the contact point as Eden placed them. Props only
// if COIN_templateSnapMax allows it (default never, they stand exactly as in Eden), vehicles always within
// COIN_templateVehicleSnapMax, so their wheels are on the floor when their physics starts.
// Terrain templates already stand at their height above the terrain
if (_inHouse) then {
    {
        private _maxShift = [COIN_templateSnapMax, COIN_templateVehicleSnapMax] select (_x in _vehicles);
        if (_maxShift > 0) then {
            [_x, _maxShift, true] call COIN_fnc_snapToFloor;
        };
    } forEach _objects;
};

// Core object and vehicles get their simulation back (they can be destroyed), props stay without.
// Vehicles cannot be damaged for the first seconds, a jolt when their physics starts must not wreck them
{
    _x enableSimulationGlobal true;
} forEach (([_core] select {!isNull _x}) + _vehicles);
{
    _x allowDamage false;
} forEach _vehicles;
if !(_vehicles isEqualTo []) then {
    _vehicles spawn {
        sleep COIN_spawnVehicleProtection;
        {
            if (!isNull _x) then {_x allowDamage true};
        } forEach _this;
    };
};

private _outlines = _objects apply {[getPosATL _x, selectMax ([_x] call COIN_fnc_halfSize)]};

[
    _objects,
    _core,
    _outlines,
    format [
        ", template with %1 objects (%2 props, %3 vehicles)",
        count _objects, count _objects - ([1, 0] select (isNull _core)) - count _vehicles, count _vehicles
    ]
]
