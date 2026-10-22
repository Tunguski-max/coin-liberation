/*
    File: fn_spawnNestGuards.sqf
    Author: COIN Liberation

    Description:
        Guards of a nest or camp, complete on every spawn (ticket 2.3, ADR 0019, ADR 0020):
        - stationary guards stand at the given spots and stay there until there is shooting nearby, then they fight
          as normal AI,
        - the others patrol around the nest as one group. The patrol keeps outside Liberation's capture radius of the
          nearest sector, so it never blocks a capture (ADR 0018).
        Guards are militia (preset militia_squad), managed by Liberation's kill manager and marked as COIN units for
        the AI budget. The caller hands them to Zeus together with the nest's objects. Server only.

    Parameter(s):
        _pos    - Nest or camp position, centre of the patrol [POSITION]
        _count  - Number of guards [NUMBER]
        _spots  - Spots for stationary guards, best first [ARRAY of [position ATL, direction]]
        _share  - Share of the guards that stand at the spots, at most one per spot [NUMBER]
        _origin - Where the guards belong, [kind "nest" or "camp", nest id, camp id] (the camp id only for "camp"); the prisoner they may become tells it (ticket 3.8) [ARRAY, defaults to []]

    Returns:
        [guards, number stationary, number patrolling, patrol radius in m] [ARRAY]
*/

params [
    ["_pos", [0, 0, 0], [[]]],
    ["_count", 0, [0]],
    ["_spots", [], [[]]],
    ["_share", 0, [0]],
    ["_origin", [], [[]]]
];

private _stationary = (round (_count * _share)) min (count _spots);
private _patrolling = _count - _stationary;
private _guards = [];

if (_stationary > 0) then {
    private _group = createGroup [GRLIB_side_enemy, true];
    for "_i" from 0 to (_stationary - 1) do {
        (_spots select _i) params ["_spotPos", "_spotDir"];
        private _unit = [selectRandom militia_squad, _spotPos, _group] call KPLIB_fnc_createManagedUnit;
        _unit setPosATL _spotPos;
        _unit setDir _spotDir;
        _unit setUnitPos "UP";
        // Stays at its spot until there is shooting nearby, then it fights as normal AI
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
    // Free spot next to the nest, the nest position itself if there is none
    private _start = [_pos, _startMin, _startMin max (_startMax min _patrolRadius), 2, 0, 0.5, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
    for "_i" from 1 to _patrolling do {
        _guards pushBack ([selectRandom militia_squad, _start, _group, "PRIVATE", _startMin] call KPLIB_fnc_createManagedUnit);
    };
    [_group, _pos, _patrolRadius] call BIS_fnc_taskPatrol;
};

[_guards] call COIN_fnc_markCoinUnits;
// A guard who surrenders keeps this, so an interrogation can tell where he comes from (COIN_fnc_pickInterrogationNest)
{_x setVariable ["COIN_origin", _origin]} forEach _guards;

[_guards, _stationary, _patrolling, _patrolRadius]
