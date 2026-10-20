/*
    File: fn_createNests.sqf
    Author: COIN Liberation

    Description:
        Creates the nests of a new campaign as data, as many of each type as COIN_nestSetup says
        (ticket 2.2, DESIGN 5, ADR 0018).
        - Kind: COIN_nestBuildingShare per type decides whether a nest should be a building or a terrain nest.
        - Building nest: a house at the edge of a town (COIN_fnc_collectNestHouses), any town that still has one,
          with at least the footprint COIN_nestBuildingMinArea asks for this type.
          Only if no house is free even at the smallest distance it becomes a terrain nest (ADR 0018, consequences).
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

// Candidate finders: [placed positions, current distance] -> [[position, town, ...], ...], town "" for terrain nests.
// _findHouses draws from _typeHouses, the houses big enough for the nest type being placed (set in the loop below)
private _findHouses = {
    params ["_placed", "_minDist"];
    private _valid = _typeHouses select {
        private _housePos = _x select 0;
        (_placed findIf {(_housePos distance2D _x) < _minDist}) < 0
    };
    [_valid] call _drawCandidates
};
private _findTerrain = {
    params ["_placed", "_minDist"];
    ([_placed, _minDist] call COIN_fnc_findTerrainNestSpots) apply {[_x, ""]}
};

// Best candidate of a finder, lowering the distance between nests step by step (one log line per step)
private _placeRelaxed = {
    params ["_nestId", "_type", "_kind", "_placed", "_finder"];
    private _minDist = COIN_nestMinDistNests;
    private _best = [];
    while {_best isEqualTo [] && {_minDist >= COIN_nestMinDistNestsMin}} do {
        private _candidates = [_placed, _minDist] call _finder;
        if (_candidates isEqualTo []) then {
            private _next = _minDist - COIN_nestMinDistNestsStep;
            if (_next >= COIN_nestMinDistNestsMin) then {
                diag_log format ["[COIN] nests: no place for nest %1 (%2 %3) with %4 m between nests, trying %5 m", _nestId, _type, _kind, _minDist, _next];
            };
            _minDist = _next;
        } else {
            _best = [_candidates, _placed] call _pickBest;
        };
    };
    _best
};

private _houses = [] call COIN_fnc_collectNestHouses;
diag_log format ["[COIN] nests: %1 houses at the edge of %2 towns can hold a building nest", count _houses, count sectors_capture];
if !(_houses isEqualTo []) then {
    private _areas = _houses apply {_x select 3};
    _areas sort true;
    diag_log format ["[COIN] nests: house footprints min %1 / median %2 / max %3 m2", _areas select 0, _areas select (floor (count _areas / 2)), _areas select (count _areas - 1)];
};

// Debug catalog to choose COIN_nestBuildingClasses from: every house class at the town edges, largest first,
// with its number, footprint and one example to look at in Zeus
if (COIN_debug) then {
    private _catalog = createHashMap;   // class -> [footprint, number, town of the example, position of the example, building positions]
    {
        _x params ["_pos", "_town", "_class", "_area", "_positions"];
        private _entry = _catalog getOrDefault [_class, [_area, 0, _town, _pos, _positions]];
        _entry set [1, (_entry select 1) + 1];
        _catalog set [_class, _entry];
    } forEach _houses;

    // Sorted as [footprint, class] pairs only, sort compares numbers and strings
    private _rows = [];
    {
        _rows pushBack [_y select 0, _x];
    } forEach _catalog;
    _rows sort false;

    diag_log format ["[COIN] nests: catalog of %1 house classes at the town edges (class: number, footprint, building positions, example)", count _rows];
    {
        _x params ["_area", "_class"];
        private _entry = _catalog get _class;
        diag_log format ["[COIN] nests: catalog %1: %2 houses, %3 m2, %4 building positions, e.g. %5 at %6", _class, _entry select 1, _area, _entry select 4, markerText (_entry select 2), _entry select 3];
    } forEach _rows;
};

private _nests = [];
private _picks = [];    // Chosen candidate per nest: [position, town, class, footprint], town "" for terrain nests (log only, not saved)
private _id = 0;

{
    _x params ["_type", "_count"];
    private _share = ([COIN_nestBuildingShare, _type] call COIN_fnc_findByType) param [1, 0];
    private _minArea = ([COIN_nestBuildingMinArea, _type] call COIN_fnc_findByType) param [1, 0];
    private _classes = (([COIN_nestBuildingClasses, _type] call COIN_fnc_findByType) param [1, []]) apply {toLower _x};
    private _minPositions = ([COIN_nestBuildingMinPositions, _type] call COIN_fnc_findByType) param [1, 0];
    private _typeHouses = _houses select {
        (_x select 3) >= _minArea
        && {(_x select 4) >= _minPositions}
        && {_classes isEqualTo [] || {toLower (_x select 2) in _classes}}
    };
    if (_share > 0) then {
        diag_log format [
            "[COIN] nests: %1 houses with at least %2 m2 and %3 building positions for %4 nests%5",
            count _typeHouses, _minArea, _minPositions, _type, ["", format [" (%1 allowed classes)", count _classes]] select (count _classes > 0)
        ];
    };

    for "_i" from 1 to _count do {
        private _nestId = _id + 1;
        private _kind = ["terrain", "building"] select ((random 1) < _share);
        private _placed = _nests apply {_x select 3};
        private _best = [];

        // A building nest tries houses down to the smallest distance first, it becomes a terrain nest only as
        // a last resort ("notfalls", ADR 0018). Any town with a free house will do.
        if (_kind isEqualTo "building") then {
            _best = [_nestId, _type, _kind, _placed, _findHouses] call _placeRelaxed;
            if (_best isEqualTo []) then {
                diag_log format ["[COIN] nests: no house for nest %1 (%2 building, %3 suitable houses) even with %4 m between nests, terrain nest instead", _nestId, _type, count _typeHouses, COIN_nestMinDistNestsMin];
                _kind = "terrain";
            };
        };
        if (_kind isEqualTo "terrain") then {
            _best = [_nestId, _type, _kind, _placed, _findTerrain] call _placeRelaxed;
        };

        if (_best isEqualTo []) then {
            diag_log format ["[COIN] nests: ERROR - no place for nest %1 (%2 %3) even with %4 m between nests, nest left out", _nestId, _type, _kind, COIN_nestMinDistNestsMin];
        } else {
            _id = _nestId;
            _nests pushBack [_id, _type, _kind, _best select 0, floor random _seedRange, "active"];
            _picks pushBack _best;
        };
    };
} forEach COIN_nestSetup;

// Placement log: distances once all nests stand
private _positions = _nests apply {_x select 3};
{
    _x params ["_id", "_type", "_kind", "_pos"];
    private _others = _positions - [_pos];
    private _nearest = if (_others isEqualTo []) then {-1} else {round selectMin (_others apply {_pos distance2D _x})};
    (_picks select _forEachIndex) params ["", ["_town", ""], ["_class", ""], ["_area", 0]];
    private _townInfo = "";
    if !(_town isEqualTo "") then {
        // Largest house in the same town's ring, to compare the size of the chosen one (COIN_nestBuildingMinArea)
        private _largest = [0, ""];
        {
            if ((_x select 1) isEqualTo _town && {(_x select 3) > (_largest select 0)}) then {
                _largest = [_x select 3, _x select 2];
            };
        } forEach _houses;
        _townInfo = format [
            ", town %1 (%2) centre %3 m, house %4 %5 m2, largest in this town %6 %7 m2",
            markerText _town, _town, round (_pos distance2D (markerPos _town)), _class, _area, _largest select 1, _largest select 0
        ];
    };
    diag_log format ["[COIN] nests: placed nest %1 %2 %3 at %4, nearest nest %5 m, start base %6 m%7", _id, _type, _kind, _pos, _nearest, round (_pos distance2D startbase), _townInfo];
} forEach _nests;

diag_log format [
    "[COIN] nests: %1 nests placed, %2 building and %3 terrain",
    count _nests, {(_x select 2) isEqualTo "building"} count _nests, {(_x select 2) isEqualTo "terrain"} count _nests
];

_nests
