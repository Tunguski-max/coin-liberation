/*
    File: fn_findTerrainNestSpots.sqf
    Author: COIN Liberation

    Description:
        Candidate places for a terrain nest (ticket 2.2, DESIGN 5): random positions that pass COIN_fnc_isNestSpotAllowed,
        keep the current distance to the nests placed so far, and pass the open-ground rules shared with camps
        (COIN_fnc_checkTerrainSpot: COIN_nestTerrainMinDistTown from towns and the capital, COIN_nestTerrainMinDistRoad
        from roads, flat and free of objects within COIN_nestTerrainFlatRadius and COIN_nestTerrainMaxGradient).
        Stops at COIN_nestCandidates places or after COIN_nestPlaceAttempts tries.

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
        && {([_candidate, COIN_nestTerrainMinDistTown, COIN_nestTerrainMinDistRoad, COIN_nestTerrainFlatRadius, COIN_nestTerrainMaxGradient] call COIN_fnc_checkTerrainSpot) isEqualTo ""}
    ) then {
        _spots pushBack _candidate;
    };
};

_spots
