/*
    File: fn_findTerrainNestSpots.sqf
    Author: COIN Liberation

    Description:
        Candidate places for a terrain nest (ticket 2.2, DESIGN 5): random positions that pass COIN_fnc_isNestSpotAllowed,
        keep the current distance to the nests placed so far, are at least COIN_nestTerrainMinDistTown from towns and
        the capital, COIN_nestTerrainMinDistRoad from roads, and flat and free of objects (COIN_nestTerrainFlatRadius,
        COIN_nestTerrainMaxGradient). Stops at COIN_nestCandidates places or after COIN_nestPlaceAttempts tries.

    Parameter(s):
        _placed  - Positions of the nests placed so far [ARRAY of positions]
        _minDist - Current minimum distance to them in m [NUMBER]

    Returns:
        Candidate positions in whole metres [ARRAY of positions]
*/

params [
    ["_placed", [], [[]]],
    ["_minDist", COIN_nestMinDistNests, [0]]
];

private _towns = (sectors_capture + sectors_bigtown) apply {markerPos _x};
private _edge = COIN_nestMinDistMapEdge;
private _range = worldSize - 2 * _edge;

private _spots = [];
private _attempt = 0;

while {count _spots < COIN_nestCandidates && {_attempt < COIN_nestPlaceAttempts}} do {
    _attempt = _attempt + 1;
    private _candidate = [round (_edge + random _range), round (_edge + random _range), 0];

    if (
        [_candidate] call COIN_fnc_isNestSpotAllowed
        && {(_placed findIf {(_candidate distance2D _x) < _minDist}) < 0}
        && {(_towns findIf {(_candidate distance2D _x) < COIN_nestTerrainMinDistTown}) < 0}
        && {(_candidate nearRoads COIN_nestTerrainMinDistRoad) isEqualTo []}
        && {!(((AGLToASL _candidate) isFlatEmpty [COIN_nestTerrainFlatRadius, -1, COIN_nestTerrainMaxGradient, COIN_nestTerrainFlatRadius, 0, false]) isEqualTo [])}
    ) then {
        _spots pushBack _candidate;
    };
};

_spots
