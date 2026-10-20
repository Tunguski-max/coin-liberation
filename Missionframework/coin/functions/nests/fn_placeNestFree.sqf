/*
    File: fn_placeNestFree.sqf
    Author: COIN Liberation

    Description:
        Free placement of a building nest, for houses without a template (ADR 0019, ticket #44): the core object and
        2-4 props on building positions of the house. Which positions, which props and their direction follow from
        the nest's seed, so the nest looks the same on every visit. A prop takes the next building position where it
        fits, otherwise a free spot next to the core object on the same floor; one without room is left out.
        Everything stands on the floor below its spot, keeps its outline free of walls and other objects and stays
        away from doors. A VBIED garage also gets a civilian vehicle (COIN_fnc_placeNestVehicle). Server only.

    Parameter(s):
        _house     - House of the nest [OBJECT]
        _type      - Nest type [STRING]
        _id        - Nest id [NUMBER]
        _seed      - Seed of the nest [NUMBER]
        _positions - Building positions of the house [ARRAY]
        _order     - Repeatable order of their indices, the core object takes the first one that fits [ARRAY]

    Returns:
        [objects, core object, outlines [position ATL, radius], log text] [ARRAY]
*/

params [
    ["_house", objNull, [objNull]],
    ["_type", "", [""]],
    ["_id", 0, [0]],
    ["_seed", 0, [0]],
    ["_positions", [], [[]]],
    ["_order", [], [[]]]
];

// Independent value streams of the seed (COIN_fnc_seededRandom index), apart from those of COIN_fnc_spawnBuildingNest
private _streamCoreDir = 1000;
private _streamPropCount = 1001;
private _streamProp = 2000;     // + n: class of prop n
private _streamPropDir = 3000;  // + n: direction of prop n
private _streamPropSpot = 4000; // + n: spot next to the core object of prop n

private _seededIndex = {
    params ["_stream", "_count"];
    floor ([_seed, _stream, _count] call COIN_fnc_seededRandom)
};

// Core object and props are no Liberation objects: never saved near a FOB, never doubled after a load.
// Each one is set down on the floor below its spot (ticket #44)
private _createObject = {
    params ["_class"];
    private _object = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _object setVariable ["KP_liberation_preplaced", true];
    _object
};
private _putDown = {
    params ["_object", "_posATL", "_dir"];
    _object setDir _dir;
    _object setPosATL _posATL;
    [_object] call COIN_fnc_snapToFloor;
};

// Taken places: door points stay free, every placed object blocks its outline (only those block guard positions)
private _doorPoints = (_house selectionNames "Memory") select {
    private _name = toLower _x;
    (COIN_doorSelectionNames findIf {(_name find _x) >= 0}) >= 0
};
private _blockers = _doorPoints apply {
    [ASLToATL (AGLToASL (_house modelToWorld (_house selectionPosition [_x, "Memory"]))), COIN_nestDoorClearance]
};
private _placedOutlines = [];
private _block = {
    params ["_object"];
    private _outline = [getPosATL _object, selectMax ([_object] call COIN_fnc_halfSize)];
    _blockers pushBack _outline;
    _placedOutlines pushBack _outline;
};

private _objects = [];
private _usedPositions = [];

// Core object: the first building position in the seed's order where it fits (the first one if none fits)
private _coreClass = COIN_nestValidCores getOrDefault [_type, COIN_nestCoreFallback];
private _core = [_coreClass] call _createObject;
private _coreDir = [_seed, _streamCoreDir, 360] call COIN_fnc_seededRandom;
([_core] call COIN_fnc_halfSize) params ["_coreHalfX", "_coreHalfY"];
private _coreIndex = _order select ((_order findIf {
    [_positions select _x, _coreDir, _coreHalfX, _coreHalfY, [_core], _blockers] call COIN_fnc_isSpotFree
}) max 0);
_usedPositions pushBack _coreIndex;
[_core, _positions select _coreIndex, _coreDir] call _putDown;
_core setVariable ["COIN_nestId", _id];
[_core] call _block;
_objects pushBack _core;
private _corePos = getPosATL _core;
private _coreFloor = [AGLToASL _corePos, _core] call COIN_fnc_getFloorASL;

// VBIED garage: civilian vehicle as a prop, before the other props because it needs the most room
private _vehicleInfo = "";
if (_type isEqualTo "vbiedGarage" && {COIN_enableNestVehicle}) then {
    ([_house, _seed, _blockers] call COIN_fnc_placeNestVehicle) params ["_vehicle", "_inside"];
    if (!isNull _vehicle) then {
        [_vehicle] call _block;
        _objects pushBack _vehicle;
        _vehicleInfo = format [", vehicle %1 %2", typeOf _vehicle, ["next to the house", "inside"] select _inside];
    };
};

// Props: the next free building position where the prop fits, otherwise a free spot next to the core object
// (floor at the core's height, no wall in between). A prop without room is left out.
private _props = COIN_nestValidProps getOrDefault [_type, []];
COIN_nestPropsCount params ["_propsMin", "_propsMax"];
private _propCount = if (_props isEqualTo []) then {0} else {
    _propsMin + ([_streamPropCount, _propsMax - _propsMin + 1] call _seededIndex)
};
COIN_nestPropSpacing params ["_spacingMin", "_spacingMax"];
private _coreCheckASL = (AGLToASL _corePos) vectorAdd [0, 0, COIN_spotCheckHeights select 0];
private _placedProps = 0;
private _propsInHouse = 0;
for "_i" from 1 to _propCount do {
    private _class = _props select ([_streamProp + _i, count _props] call _seededIndex);
    private _dir = [_seed, _streamPropDir + _i, 360] call COIN_fnc_seededRandom;
    private _prop = [_class] call _createObject;
    ([_prop] call COIN_fnc_halfSize) params ["_halfX", "_halfY"];
    private _spot = [];

    {
        private _candidate = _positions select _x;
        if (!(_x in _usedPositions) && {[_candidate, _dir, _halfX, _halfY, [_prop], _blockers] call COIN_fnc_isSpotFree}) exitWith {
            _spot = _candidate;
            _usedPositions pushBack _x;
            _propsInHouse = _propsInHouse + 1;
        };
    } forEach _order;

    if (_spot isEqualTo [] && {!(_coreFloor isEqualTo [])}) then {
        for "_try" from 1 to COIN_nestPropTries do {
            private _ground = _corePos getPos [
                _spacingMin + ([_seed, _streamPropSpot + _i * 100 + _try, _spacingMax - _spacingMin] call COIN_fnc_seededRandom),
                [_seed, _streamPropSpot + 50 + _i * 100 + _try, 360] call COIN_fnc_seededRandom
            ];
            private _candidate = [_ground select 0, _ground select 1, _corePos select 2];
            private _candidateASL = AGLToASL _candidate;
            private _floor = [_candidateASL, _prop, _core] call COIN_fnc_getFloorASL;
            if (
                !(_floor isEqualTo [])
                && {abs ((_floor select 0) - (_coreFloor select 0)) < COIN_spotFloorTolerance}
                && {(lineIntersectsSurfaces [_coreCheckASL, _candidateASL vectorAdd [0, 0, COIN_spotCheckHeights select 0], _core, _prop, true, 1, "GEOM", "VIEW"]) isEqualTo []}
                && {[_candidate, _dir, _halfX, _halfY, [_prop], _blockers] call COIN_fnc_isSpotFree}
            ) exitWith {
                _spot = _candidate;
            };
        };
    };

    if (_spot isEqualTo []) then {
        deleteVehicle _prop;
        if (COIN_debug) then {
            diag_log format ["[COIN] nests: no room for prop %1 of nest %2 (%3), left out", _class, _id, _type];
        };
    } else {
        [_prop, _spot, _dir] call _putDown;
        // Props are decoration, without simulation they do not slide or fall over
        _prop enableSimulationGlobal false;
        [_prop] call _block;
        _objects pushBack _prop;
        _placedProps = _placedProps + 1;
    };
};


[_objects, _core, _placedOutlines, format [", free placement: %1 of %2 props (%3 on building positions)%4", _placedProps, _propCount, _propsInHouse, _vehicleInfo]]
