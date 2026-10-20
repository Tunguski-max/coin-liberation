/*
    File: fn_spawnBuildingNest.sqf
    Author: COIN Liberation

    Description:
        Spawns the content of a building nest when players come near (ticket 2.3, DESIGN 5, ADR 0018):
        - the core object and 2-4 props on building positions of the house. Which positions, which props and their
          direction follow from the nest's seed, so the nest looks the same on every visit.
        - guards, complete on every spawn (number from the seed, COIN_nestGuardsMin to Max): about half of them stay
          at free building positions inside the house, the others patrol around the nest as one group.
          A house without free positions (e.g. a small garage) keeps all of them outside.
        Guards are militia (preset militia_squad), managed by Liberation's kill manager, marked as COIN units for the
        AI budget. Everything goes to Zeus. The core object carries COIN_nestId for the destruction check (ticket 2.4).
        Server only.

    Parameter(s):
        _nest     - Nest [ARRAY: id, type, kind, pos, seed, state]
        _distance - Distance of the nearest player, for the log [NUMBER]

    Returns:
        [objects and units, groups], or [] if the house is gone [ARRAY]
*/

params [
    ["_nest", [], [[]]],
    ["_distance", 0, [0]]
];

_nest params ["_id", "_type", "_kind", "_pos", "_seed"];

// The saved position is the house position in whole metres, so the house is the building right there (5 m tolerance)
private _house = nearestBuilding _pos;
if (isNull _house || {(_house distance2D _pos) > 5} || {!alive _house}) exitWith {
    diag_log format ["[COIN] nests: ERROR - house of nest %1 (%2) not found at %3, nothing spawned", _id, _type, _pos];
    []
};

private _positions = _house buildingPos -1;
if (_positions isEqualTo []) exitWith {
    diag_log format ["[COIN] nests: ERROR - house %1 of nest %2 (%3) has no building positions, nothing spawned", typeOf _house, _id, _type];
    []
};

// Repeatable order of the building positions: the first one gets the core object, then the props, then the guards
private _pool = [];
for "_i" from 0 to (count _positions - 1) do {
    _pool pushBack _i;
};
private _order = [];
private _draw = 0;
while {!(_pool isEqualTo [])} do {
    _order pushBack (_pool deleteAt (floor ([_seed, _draw, count _pool] call COIN_fnc_seededRandom)));
    _draw = _draw + 1;
};

private _objects = [];

// Core object
private _coreClass = COIN_nestValidCores getOrDefault [_type, COIN_nestCoreFallback];
private _core = createVehicle [_coreClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_core setPosATL (_positions select (_order select 0));
_core setDir ([_seed, 100, 360] call COIN_fnc_seededRandom);
_core setVariable ["COIN_nestId", _id, true];
_objects pushBack _core;

// Props: as many as the seed says, at most one per free position
private _props = COIN_nestValidProps getOrDefault [_type, []];
COIN_nestPropsCount params ["_propsMin", "_propsMax"];
private _propCount = _propsMin + floor ([_seed, 101, _propsMax - _propsMin + 1] call COIN_fnc_seededRandom);
_propCount = _propCount min ((count _order) - 1);
if (_props isEqualTo []) then {
    _propCount = 0;
};
for "_i" from 1 to _propCount do {
    private _class = _props select (floor ([_seed, 200 + _i, count _props] call COIN_fnc_seededRandom));
    private _prop = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _prop setPosATL (_positions select (_order select _i));
    _prop setDir ([_seed, 300 + _i, 360] call COIN_fnc_seededRandom);
    // Props are decoration, without simulation they do not slide or fall over
    _prop enableSimulationGlobal false;
    _objects pushBack _prop;
};

// Guards: complete on every spawn
private _guardCount = COIN_nestGuardsMin + floor ([_seed, 400, COIN_nestGuardsMax - COIN_nestGuardsMin + 1] call COIN_fnc_seededRandom);
private _free = _order select [1 + _propCount];
private _inHouse = (round (_guardCount * COIN_nestGuardsInHouseShare)) min (count _free);
private _patrolling = _guardCount - _inHouse;
private _groups = [];
private _guards = [];

if (_inHouse > 0) then {
    private _group = createGroup [GRLIB_side_enemy, true];
    for "_i" from 0 to (_inHouse - 1) do {
        private _guardPos = _positions select (_free select _i);
        private _unit = [selectRandom militia_squad, _guardPos, _group] call KPLIB_fnc_createManagedUnit;
        _unit setPosATL _guardPos;
        _unit setDir (random 360);
        _unit setUnitPos "UP";
        // Stays at its position in the house, fights from there
        _unit disableAI "PATH";
        _guards pushBack _unit;
    };
    _groups pushBack _group;
};

if (_patrolling > 0) then {
    private _group = createGroup [GRLIB_side_enemy, true];
    // Free spot next to the house (10-40 m), the house position itself if there is none
    private _start = [_pos, 10, 40, 2, 0, 0.5, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
    for "_i" from 1 to _patrolling do {
        _guards pushBack ([selectRandom militia_squad, _start, _group, "PRIVATE", 5] call KPLIB_fnc_createManagedUnit);
    };
    [_group, _pos, COIN_nestPatrolRadius] call BIS_fnc_taskPatrol;
    _groups pushBack _group;
};

[_guards] call COIN_fnc_markCoinUnits;
_objects append _guards;
[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] nests: nest %1 (%2) spawned in %3 at %4, player %5 m away: core %6, %7 props, %8 guards (%9 in the house, %10 patrolling)",
    _id, _type, typeOf _house, _pos, round _distance, _coreClass, _propCount, _guardCount, _inHouse, _patrolling
];

[_objects, _groups]
