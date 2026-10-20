/*
    File: fn_spawnBuildingNest.sqf
    Author: COIN Liberation

    Description:
        Spawns the content of a building nest when players come near (ticket 2.3, DESIGN 5, ADR 0018):
        - the core object and 2-4 props on building positions of the house. Which positions, which props and their
          direction follow from the nest's seed, so the nest looks the same on every visit. A prop takes the next
          building position where it fits, otherwise a free spot next to the core object on the same floor; one
          without room is left out. Everything stands on the floor below its spot, keeps its outline free of walls
          and other objects and stays away from doors (ticket #44).
        - a VBIED garage also gets a civilian vehicle as a prop (COIN_fnc_placeNestVehicle).
        - guards, complete on every spawn (number from the seed, COIN_nestGuardsMin to Max): about half of them stay
          at the free building positions closest to the core object, the others patrol around the nest as one group.
          The patrol keeps outside Liberation's capture radius of the nearest sector, so it never blocks a capture
          (ADR 0018). A house without free positions keeps all guards outside. On contact they fight as normal AI.
        Guards are militia (preset militia_squad), managed by Liberation's kill manager, marked as COIN units for the
        AI budget. Core object and props are excluded from Liberation's save near FOBs. Everything goes to Zeus.
        The core object carries COIN_nestId for the destruction check (ticket 2.4). Server only.

    Parameter(s):
        _nest     - Nest [ARRAY: id, type, kind, pos, seed, state]
        _distance - Distance of the nearest player, for the log [NUMBER]

    Returns:
        Spawned objects and units, [] if the house is gone [ARRAY of OBJECTs]
*/

params [
    ["_nest", [], [[]]],
    ["_distance", 0, [0]]
];

if (!isServer) exitWith {[]};

_nest params ["_id", "_type", "_kind", "_pos", "_seed"];

// Independent value streams of the seed (COIN_fnc_seededRandom index): far apart, so a house with many building
// positions never reaches the next stream
private _streamOrder = 0;       // + n: order of the building positions
private _streamCoreDir = 1000;
private _streamPropCount = 1001;
private _streamProp = 2000;     // + n: class of prop n
private _streamPropDir = 3000;  // + n: direction of prop n
private _streamPropSpot = 4000; // + n: spot next to the core object of prop n
private _streamGuards = 5000;

private _seededIndex = {
    params ["_stream", "_count"];
    floor ([_seed, _stream, _count] call COIN_fnc_seededRandom)
};

// The saved position is the house position in whole metres, found the same way COIN_fnc_collectNestHouses found it
private _house = ((nearestObjects [_pos, ["House"], COIN_nestHouseTolerance]) select {
    alive _x && {!((_x buildingPos -1) isEqualTo [])}
}) param [0, objNull];
if (isNull _house) exitWith {
    diag_log format ["[COIN] nests: ERROR - house of nest %1 (%2) not found at %3, nothing spawned", _id, _type, _pos];
    []
};

private _positions = _house buildingPos -1;

// Repeatable order of the building positions: the first one gets the core object, then the props, then the guards
private _pool = [];
for "_i" from 0 to (count _positions - 1) do {
    _pool pushBack _i;
};
private _order = [];
while {!(_pool isEqualTo [])} do {
    _order pushBack (_pool deleteAt ([_streamOrder + count _order, count _pool] call _seededIndex));
};

// Half width and half length of an object (bounding box)
private _halfSize = {
    params ["_object"];
    (boundingBoxReal _object) params ["_c1", "_c2"];
    [abs ((_c2 select 0) - (_c1 select 0)) / 2, abs ((_c2 select 1) - (_c1 select 1)) / 2]
};

// Core object and props are no Liberation objects: never saved near a FOB, never doubled after a load.
// Each one is set down on the floor below its spot (ticket #44)
private _create = {
    params ["_class"];
    private _object = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _object setVariable ["KP_liberation_preplaced", true];
    _object
};
private _put = {
    params ["_object", "_posATL", "_dir"];
    _object setDir _dir;
    _object setPosATL _posATL;
    [_object] call COIN_fnc_snapToFloor;
};

// Taken places: doors stay free, every placed object blocks its own outline
private _blockers = ((_house selectionNames "Memory") select {((toLower _x) find "door") >= 0}) apply {
    [ASLToATL (AGLToASL (_house modelToWorld (_house selectionPosition [_x, "Memory"]))), COIN_nestDoorClearance]
};
private _block = {
    params ["_object"];
    _blockers pushBack [getPosATL _object, selectMax ([_object] call _halfSize)];
};

private _objects = [];
private _usedPositions = [_order select 0];

// Core object
private _corePos = _positions select (_order select 0);
private _coreClass = COIN_nestValidCores getOrDefault [_type, COIN_nestCoreFallback];
private _core = [_coreClass] call _create;
[_core, _corePos, [_seed, _streamCoreDir, 360] call COIN_fnc_seededRandom] call _put;
_core setVariable ["COIN_nestId", _id];
[_core] call _block;
_objects pushBack _core;

// VBIED garage: civilian vehicle as a prop, before the other props because it needs the most room
private _vehicleInfo = "";
if (_type isEqualTo "vbiedGarage") then {
    private _vehicle = [_house, _seed, _blockers] call COIN_fnc_placeNestVehicle;
    if (!isNull _vehicle) then {
        [_vehicle] call _block;
        _objects pushBack _vehicle;
        _vehicleInfo = format [", vehicle %1 %2", typeOf _vehicle, ["next to the house", "inside"] select (_vehicle getVariable ["COIN_nestVehicleInside", false])];
    };
};

// Props: the next free building position where the prop fits, otherwise a free spot next to the core object
// (same floor, no wall in between). A prop without room is left out.
private _props = COIN_nestValidProps getOrDefault [_type, []];
COIN_nestPropsCount params ["_propsMin", "_propsMax"];
private _propCount = if (_props isEqualTo []) then {0} else {
    _propsMin + ([_streamPropCount, _propsMax - _propsMin + 1] call _seededIndex)
};
COIN_nestPropSpacing params ["_spacingMin", "_spacingMax"];
private _coreCheckASL = (AGLToASL (getPosATL _core)) vectorAdd [0, 0, COIN_spotCheckHeight];
private _placedProps = 0;
private _propsInHouse = 0;
for "_i" from 1 to _propCount do {
    private _class = _props select ([_streamProp + _i, count _props] call _seededIndex);
    private _dir = [_seed, _streamPropDir + _i, 360] call COIN_fnc_seededRandom;
    private _prop = [_class] call _create;
    ([_prop] call _halfSize) params ["_halfX", "_halfY"];
    private _spot = [];

    {
        private _candidate = _positions select _x;
        if (!(_x in _usedPositions) && {[_candidate, _dir, _halfX, _halfY, [_prop], _blockers] call COIN_fnc_isSpotFree}) exitWith {
            _spot = _candidate;
            _usedPositions pushBack _x;
            _propsInHouse = _propsInHouse + 1;
        };
    } forEach _order;

    if (_spot isEqualTo []) then {
        for "_try" from 1 to COIN_nestPropTries do {
            private _ground = (getPosATL _core) getPos [
                _spacingMin + ([_seed, _streamPropSpot + _i * 100 + _try, _spacingMax - _spacingMin] call COIN_fnc_seededRandom),
                [_seed, _streamPropSpot + 50 + _i * 100 + _try, 360] call COIN_fnc_seededRandom
            ];
            private _candidate = [_ground select 0, _ground select 1, (getPosATL _core) select 2];
            private _candidateASL = (AGLToASL _candidate) vectorAdd [0, 0, COIN_spotCheckHeight];
            if (
                (lineIntersectsSurfaces [_coreCheckASL, _candidateASL, _core, _prop, true, 1, "GEOM", "NONE"]) isEqualTo []
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
        [_prop, _spot, _dir] call _put;
        // Props are decoration, without simulation they do not slide or fall over
        _prop enableSimulationGlobal false;
        [_prop] call _block;
        _objects pushBack _prop;
        _placedProps = _placedProps + 1;
    };
};

// Guards: complete on every spawn
private _guardCount = COIN_nestGuardsMin + ([_streamGuards, COIN_nestGuardsMax - COIN_nestGuardsMin + 1] call _seededIndex);
// Free building positions, closest to the core object first
private _free = (_order select {!(_x in _usedPositions)}) apply {_positions select _x};
_free = [_free, [], {_x distance _corePos}, "ASCEND"] call BIS_fnc_sortBy;
private _inHouse = (round (_guardCount * COIN_nestGuardsInHouseShare)) min (count _free);
private _patrolling = _guardCount - _inHouse;
private _guards = [];

if (_inHouse > 0) then {
    private _group = createGroup [GRLIB_side_enemy, true];
    for "_i" from 0 to (_inHouse - 1) do {
        private _guardPos = _free select _i;
        private _unit = [selectRandom militia_squad, _guardPos, _group] call KPLIB_fnc_createManagedUnit;
        _unit setPosATL _guardPos;
        _unit setDir (random 360);
        _unit setUnitPos "UP";
        // Stays at its position until there is shooting nearby, then it fights as normal AI
        _unit disableAI "PATH";
        _unit addEventHandler ["FiredNear", {
            params ["_unit"];
            _unit enableAI "PATH";
            _unit removeEventHandler [_thisEvent, _thisEventHandler];
        }];
        _guards pushBack _unit;
    };
};

private _patrolRadius = 0;
if (_patrolling > 0) then {
    // Keep the patrol outside the capture radius of the nearest sector (the capital's radius is larger)
    private _sector = [sectors_allSectors, _pos] call BIS_fnc_nearestPosition;
    private _captureSize = GRLIB_capture_size * ([1, COIN_capitalCaptureFactor] select (_sector in sectors_bigtown));
    _patrolRadius = COIN_nestPatrolRadius min ((_pos distance2D (markerPos _sector)) - _captureSize - COIN_nestPatrolSectorMargin);
    _patrolRadius = _patrolRadius max 0;

    private _group = createGroup [GRLIB_side_enemy, true];
    COIN_nestPatrolStart params ["_startMin", "_startMax"];
    // Free spot next to the house, the house position itself if there is none
    private _start = [_pos, _startMin, _startMin max (_startMax min _patrolRadius), 2, 0, 0.5, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
    for "_i" from 1 to _patrolling do {
        _guards pushBack ([selectRandom militia_squad, _start, _group, "PRIVATE", _startMin] call KPLIB_fnc_createManagedUnit);
    };
    [_group, _pos, _patrolRadius] call BIS_fnc_taskPatrol;
};

[_guards] call COIN_fnc_markCoinUnits;
_objects append _guards;
[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] nests: nest %1 (%2) spawned in %3 at %4, player %5 m away: core %6, %7 of %8 props (%9 on building positions)%10, %11 guards (%12 in the house, %13 patrolling within %14 m)",
    _id, _type, typeOf _house, _pos, round _distance, _coreClass, _placedProps, _propCount, _propsInHouse, _vehicleInfo, _guardCount, _inHouse, _patrolling, round _patrolRadius
];

_objects
