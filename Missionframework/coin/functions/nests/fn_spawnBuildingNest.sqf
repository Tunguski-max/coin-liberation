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
          around the nest as one group. The patrol keeps outside Liberation's capture radius of the nearest sector,
          so it never blocks a capture (ADR 0018). A house without free positions keeps all guards outside.
          On contact they fight as normal AI.
        Guards are militia (preset militia_squad), managed by Liberation's kill manager, marked as COIN units for the
        AI budget. Objects are excluded from Liberation's save near FOBs. Everything goes to Zeus.
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
    [_house, _id, _templates select ([_streamTemplate, count _templates] call _seededIndex)] call COIN_fnc_placeNestTemplate
};
_placement params ["_objects", "_core", "_placedOutlines", "_layout"];
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
    "[COIN] nests: nest %1 (%2) spawned in %3 at %4, player %5 m away: core %6%7, %8 guards (%9 in the house, %10 patrolling within %11 m)",
    _id, _type, typeOf _house, _pos, round _distance, typeOf _core, _layout, _guardCount, _inHouse, _patrolling, round _patrolRadius
];

_objects
