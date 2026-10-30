/*
    File: fn_findCampSpot.sqf
    Author: COIN Liberation

    Description:
        Place for a camp (ticket 2.8, DESIGN 5.1): a random position on land that
        - is farther from the active camps than the best place found so far (spacing, "farthest candidate" as for the nests:
          of up to COIN_campCandidates valid places the one farthest from the other camps wins, so camps spread over the map),
        - is at least COIN_campMinDistMapEdge from the map edge, COIN_campMinDistStartBase from the start base and
          COIN_campMinDistSector from every sector centre (Liberation's 175 m evaluation),
        - is at least COIN_campExclusionRadius from every captured sector (blufor_sectors) and every FOB,
        - keeps the open-ground rules of COIN_fnc_checkTerrainSpot (towns, roads, flat and free, shared with terrain nests),
        - has at least COIN_campCoverMin cover objects within COIN_campCoverRadius (COIN_fnc_getCampCover).
        Tries COIN_campPlaceAttempts times, cheap rules first, and stops early after COIN_campCandidates valid places.
        The rules apply once, when the camp is placed.
        Server only.

    Parameter(s):
        NONE

    Returns:
        [position in whole metres or [] if none was found, rejected positions per rule (HASHMAP rule -> number, "spacing" =
        not farther from the other camps than the best place so far), distance of the place to the nearest other camp in m (-1 without one)] [ARRAY]
*/

if (!isServer) exitWith {[[], createHashMap, -1]};

private _edge = COIN_campMinDistMapEdge;
private _range = worldSize - 2 * _edge;

// Positions that keep camps away: captured sectors and FOBs
private _exclusion = [] call COIN_fnc_getCampExclusion;

// Positions of the camps that count; the place must keep away from them as far as possible
private _others = ([] call COIN_fnc_getActiveCamps) apply {_x select 2};
private _spot = [];
private _spotScore = -1;
private _found = 0;
private _rejected = createHashMap;

for "_i" from 1 to COIN_campPlaceAttempts do {
    private _candidate = [round (_edge + random _range), round (_edge + random _range), 0];

    // Cheap spacing score first, so the expensive rules are only checked for a place that would win
    private _score = if (_others isEqualTo []) then {1e9} else {selectMin (_others apply {_candidate distance2D _x})};

    private _fault = switch (true) do {
        case (surfaceIsWater _candidate): {"water"};
        case ((_candidate distance2D startbase) < COIN_campMinDistStartBase): {"startBase"};
        case ((sectors_allSectors findIf {(_candidate distance2D (markerPos _x)) < COIN_campMinDistSector}) >= 0): {"sector"};
        case ((_exclusion findIf {(_candidate distance2D _x) < COIN_campExclusionRadius}) >= 0): {"exclusionZone"};
        case (_found > 0 && {_score <= _spotScore}): {"spacing"};
        default {[_candidate, COIN_campMinDistTown, COIN_campMinDistRoad, COIN_campFlatRadius, COIN_campMaxGradient] call COIN_fnc_checkTerrainSpot};
    };
    if (_fault isEqualTo "" && {([_candidate] call COIN_fnc_getCampCover) < COIN_campCoverMin}) then {
        _fault = "cover";
    };

    if (_fault isEqualTo "") then {
        _spot = _candidate;
        _spotScore = _score;
        _found = _found + 1;
    } else {
        _rejected set [_fault, (_rejected getOrDefault [_fault, 0]) + 1];
    };
    if (_found >= COIN_campCandidates) exitWith {};
};

[_spot, _rejected, [-1, _spotScore] select (_spotScore < 1e9 && {_spotScore >= 0})]
