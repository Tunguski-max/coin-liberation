/*
    File: fn_spawnTerrainNest.sqf
    Author: COIN Liberation

    Description:
        Spawns the content of a terrain nest when players come near (ticket #31, DESIGN 5, ADR 0018, ADR 0020):
        - core object and props after a terrain template of the nest type: the seed picks the template and turns it
          around the nest position, every object stands at its height above the terrain and tilts with the slope
          (COIN_fnc_placeNestTemplate).
        - guards, complete on every spawn (number from the seed, COIN_nestGuardsMin to Max): about
          COIN_nestTerrainGuardShare of them stand in a ring around the camp (COIN_nestTerrainGuardRing, not on a
          placed object) and look outwards, the others patrol around the nest (COIN_fnc_spawnNestGuards).
        Objects are excluded from Liberation's save near FOBs. Everything goes to Zeus.
        The core object carries COIN_nestId for the destruction check (ticket 2.4). Server only.

    Parameter(s):
        _nest     - Nest [ARRAY: id, type, kind, pos, seed, state]
        _distance - Distance of the nearest player, for the log [NUMBER]

    Returns:
        Spawned objects and units, [] if the type has no usable terrain template [ARRAY of OBJECTs]
*/

params [
    ["_nest", [], [[]]],
    ["_distance", 0, [0]]
];

if (!isServer) exitWith {[]};

_nest params ["_id", "_type", "", "_pos", "_seed"];

// Value streams of the seed (COIN_fnc_seededRandom index), the same as building nests use where they mean the same
private _streamGuards = 5000;
private _streamTemplate = 7000;
private _streamDir = 7100;

private _templates = COIN_validTerrainTemplates select {(_x select 0) isEqualTo _type};
if (_templates isEqualTo []) exitWith {
    diag_log format ["[COIN] nests: ERROR - no usable terrain template for %1, nest %2 not spawned", _type, _id];
    []
};
private _templateIndex = floor ([_seed, _streamTemplate, count _templates] call COIN_fnc_seededRandom);
private _dir = round ([_seed, _streamDir, 360] call COIN_fnc_seededRandom);

([[_pos, _dir], _id, (_templates select _templateIndex) select 1] call COIN_fnc_placeNestTemplate)
    params ["_objects", "_core", "_placedOutlines", "_layout"];

// Guards: complete on every spawn, the stationary ones spread evenly around the ring and looking outwards.
// Their spots are not from the seed on purpose, guards are dynamic (ADR 0020)
private _guardCount = COIN_nestGuardsMin + floor ([_seed, _streamGuards, COIN_nestGuardsMax - COIN_nestGuardsMin + 1] call COIN_fnc_seededRandom);
private _ringCount = round (_guardCount * COIN_nestTerrainGuardShare);
COIN_nestTerrainGuardRing params ["_ringMin", "_ringMax"];
private _spots = [];
private _startAngle = random 360;
for "_i" from 0 to (_ringCount - 1) do {
    for "_try" from 1 to COIN_nestTerrainGuardTries do {
        // Within its own share of the ring, so the guards do not bunch up
        private _angle = _startAngle + (_i + random 1) * 360 / _ringCount;
        private _spot = _pos getPos [_ringMin + random (_ringMax - _ringMin), _angle];
        if (
            !surfaceIsWater _spot
            && {(_placedOutlines findIf {(_spot distance2D (_x select 0)) < (_x select 1) + COIN_nestTerrainGuardClearance}) < 0}
        ) exitWith {
            _spots pushBack [[_spot select 0, _spot select 1, 0], _angle];
        };
    };
};
([_pos, _guardCount, _spots, 1] call COIN_fnc_spawnNestGuards)
    params ["_guards", "_inRing", "_patrolling", "_patrolRadius"];
_objects append _guards;
[_objects] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] nests: nest %1 (%2) spawned in the terrain at %3, player %4 m away: core %5, terrain template %6 of %7 turned to %8 degrees%9, %10 guards (%11 around the camp, %12 patrolling within %13 m)",
    _id, _type, _pos, round _distance, typeOf _core, _templateIndex + 1, count _templates, _dir, _layout,
    _guardCount, _inRing, _patrolling, round _patrolRadius
];

_objects
