/*
    File: fn_createNests.sqf
    Author: COIN Liberation

    Description:
        Creates the nests of a new campaign as data, as many of each type as COIN_nestSetup says
        (ticket 2.2, DESIGN 5, ADR 0018).
        - Kind: COIN_nestBuildingShare per type decides whether a nest should be a building or a terrain nest.
        - Building nest: a house at the edge of a town (COIN_fnc_collectNestHouses), any town that still has one.
          Without a house it becomes a terrain nest (ADR 0018, consequences).
        - Terrain nest: a flat, free place away from towns and roads (COIN_fnc_findTerrainNestSpots).
        - Evenly spread ("best candidate"): of up to COIN_nestCandidates valid places, the one farthest from the nests
          placed so far wins.
        - If no place keeps COIN_nestMinDistNests to the other nests, the distance is lowered by
          COIN_nestMinDistNestsStep (one log line per step) down to COIN_nestMinDistNestsMin; below that the nest is
          left out with an error line. Start base, capital, sectors and map edge are never relaxed.
        Logs every nest with its kind and its distances to the nearest nest, the start base and, for building nests,
        the centre of its town.

    Parameter(s):
        NONE

    Returns:
        Nests [ARRAY of [id, type, kind, pos, seed, state]]
*/

// Seeds stay below 1e6, so str in Liberation's save writes them as whole numbers
private _seedRange = 1e6;

// Of [position, town] candidates, the one farthest from the placed nests (any one for the first nest)
private _pickBest = {
    params ["_candidates", "_placed"];
    if (_placed isEqualTo []) exitWith {selectRandom _candidates};
    private _best = [];
    private _bestDist = -1;
    {
        private _pos = _x select 0;
        private _dist = selectMin (_placed apply {_pos distance2D _x});
        if (_dist > _bestDist) then {
            _bestDist = _dist;
            _best = _x;
        };
    } forEach _candidates;
    _best
};

// Random subset of at most COIN_nestCandidates elements
private _drawCandidates = {
    params ["_pool"];
    _pool = +_pool;
    private _drawn = [];
    while {count _drawn < COIN_nestCandidates && {!(_pool isEqualTo [])}} do {
        _drawn pushBack (_pool deleteAt (floor random count _pool));
    };
    _drawn
};

private _houses = [] call COIN_fnc_collectNestHouses;
diag_log format ["[COIN] nests: %1 houses at the edge of %2 towns can hold a building nest", count _houses, count sectors_capture];

private _nests = [];
private _towns = [];    // Town marker per nest, "" for terrain nests (log only, not saved)
private _id = 0;

{
    _x params ["_type", "_count"];
    private _share = ([COIN_nestBuildingShare, _type] call COIN_fnc_findByType) param [1, 0];

    for "_i" from 1 to _count do {
        private _wantBuilding = (random 1) < _share;
        private _placed = _nests apply {_x select 3};
        private _minDist = COIN_nestMinDistNests;
        private _result = [];   // [position, kind, town]

        while {_result isEqualTo [] && {_minDist >= COIN_nestMinDistNestsMin}} do {
            if (_wantBuilding) then {
                private _valid = _houses select {
                    private _housePos = _x select 0;
                    (_placed findIf {(_housePos distance2D _x) < _minDist}) < 0
                };
                if !(_valid isEqualTo []) then {
                    private _best = [[_valid] call _drawCandidates, _placed] call _pickBest;
                    _result = [_best select 0, "building", _best select 1];
                };
            };

            if (_result isEqualTo []) then {
                private _spots = [_placed, _minDist] call COIN_fnc_findTerrainNestSpots;
                if !(_spots isEqualTo []) then {
                    if (_wantBuilding) then {
                        diag_log format ["[COIN] nests: no house for a building %1 nest with %2 m between nests, terrain nest instead", _type, _minDist];
                    };
                    private _best = [_spots apply {[_x, ""]}, _placed] call _pickBest;
                    _result = [_best select 0, "terrain", ""];
                };
            };

            if (_result isEqualTo []) then {
                diag_log format ["[COIN] nests: no place for a %1 nest with %2 m between nests, trying %3 m", _type, _minDist, _minDist - COIN_nestMinDistNestsStep];
                _minDist = _minDist - COIN_nestMinDistNestsStep;
            };
        };

        if (_result isEqualTo []) then {
            diag_log format ["[COIN] nests: ERROR - no place for a %1 nest even with %2 m between nests, nest left out", _type, COIN_nestMinDistNestsMin];
        } else {
            _result params ["_pos", "_kind", "_town"];
            _id = _id + 1;
            _nests pushBack [_id, _type, _kind, _pos, floor random _seedRange, "active"];
            _towns pushBack _town;
        };
    };
} forEach COIN_nestSetup;

// Placement log: distances once all nests stand
private _positions = _nests apply {_x select 3};
{
    _x params ["_id", "_type", "_kind", "_pos"];
    private _others = _positions - [_pos];
    private _nearest = if (_others isEqualTo []) then {-1} else {round selectMin (_others apply {_pos distance2D _x})};
    private _town = _towns select _forEachIndex;
    private _townInfo = if (_town isEqualTo "") then {""} else {
        format [", town %1 (%2) centre %3 m", markerText _town, _town, round (_pos distance2D (markerPos _town))]
    };
    diag_log format ["[COIN] nests: placed nest %1 %2 %3 at %4, nearest nest %5 m, start base %6 m%7", _id, _type, _kind, _pos, _nearest, round (_pos distance2D startbase), _townInfo];
} forEach _nests;

diag_log format [
    "[COIN] nests: %1 nests placed, %2 building and %3 terrain",
    count _nests, {(_x select 2) isEqualTo "building"} count _nests, {(_x select 2) isEqualTo "terrain"} count _nests
];

_nests
