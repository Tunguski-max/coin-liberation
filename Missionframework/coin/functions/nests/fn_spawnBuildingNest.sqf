/*
    File: fn_spawnBuildingNest.sqf
    Author: COIN Liberation

    Description:
        Spawns the content of a building nest when players come near (ticket 2.3, DESIGN 5, ADR 0018, ADR 0019):
        - core object, props and, for a VBIED garage, a vehicle: after a template of the house class and nest type
          (COIN_fnc_placeNestTemplate, the seed picks one if there are several), otherwise with the free placement
          (COIN_fnc_placeNestFree).
        - guards, complete on every spawn (number from the seed, COIN_nestGuardsMin to Max): about half of them stay
          at the free building positions closest to the core object (none under a placed object), the others patrol
          around the nest (COIN_fnc_spawnNestGuards). A house without free positions keeps all guards outside.
        - a weapons cache also gets its old vehicles (COIN_fnc_spawnOldVehicles).
        Objects are excluded from Liberation's save near FOBs. Everything goes to Zeus.
        The core object carries COIN_nestId and COIN_nestHouse for the destruction check (ticket 2.4). Server only.

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

// Value streams of the seed (COIN_fnc_seededRandom index), apart from those of the placement functions
private _streamOrder = 0;       // + n: order of the building positions
private _streamGuards = 5000;
private _streamTemplate = 7000;

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

// Repeatable order of the building positions (free placement: core object first, then props; then the guards)
private _pool = [];
for "_i" from 0 to (count _positions - 1) do {
    _pool pushBack _i;
};
private _order = [];
while {!(_pool isEqualTo [])} do {
    _order pushBack (_pool deleteAt ([_streamOrder + count _order, count _pool] call _seededIndex));
};

// Template of this house class and type, otherwise free placement
private _houseClass = toLower (typeOf _house);
private _templates = COIN_nestValidTemplates select {(_x select 0) isEqualTo _type && {(_x select 1) isEqualTo _houseClass}};
private _placement = if (_templates isEqualTo []) then {
    [_house, _type, _id, _seed, _positions, _order] call COIN_fnc_placeNestFree
} else {
    [_house, _id, (_templates select ([_streamTemplate, count _templates] call _seededIndex)) select 2] call COIN_fnc_placeNestTemplate
};
_placement params ["_objects", "_core", "_placedOutlines", "_layout"];
// For the destruction check: a collapsing house destroys the nest (ticket 2.4)
_core setVariable ["COIN_nestHouse", _house];
private _corePos = getPosATL _core;

// Guards: complete on every spawn
private _guardCount = COIN_nestGuardsMin + ([_streamGuards, COIN_nestGuardsMax - COIN_nestGuardsMin + 1] call _seededIndex);
// Free building positions not covered by a placed object, closest to the core object first
private _free = (_order apply {_positions select _x}) select {
    private _guardPos = _x;
    (_placedOutlines findIf {
        _x params ["_outlinePos", "_outlineRadius"];
        (_guardPos distance2D _outlinePos) < _outlineRadius
        && {abs ((_guardPos select 2) - (_outlinePos select 2)) < COIN_spotSameFloor}
    }) < 0
};
_free = [_free, [], {_x distance _corePos}, "ASCEND"] call BIS_fnc_sortBy;
([_pos, _guardCount, _free apply {[_x, random 360]}, COIN_nestGuardsInHouseShare] call COIN_fnc_spawnNestGuards)
    params ["_guards", "_inHouse", "_patrolling", "_patrolRadius"];
_objects append _guards;
// A weapons cache also guards old vehicles (ticket 2.9a)
if (_type isEqualTo "cache") then {
    _objects append ([_nest] call COIN_fnc_spawnOldVehicles);
};
[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] nests: nest %1 (%2) spawned in %3 at %4, player %5 m away: core %6%7, %8 guards (%9 in the house, %10 patrolling within %11 m)",
    _id, _type, typeOf _house, _pos, round _distance, typeOf _core, _layout, _guardCount, _inHouse, _patrolling, round _patrolRadius
];

_objects
