/*
    File: fn_findCampSpot.sqf
    Author: COIN Liberation

    Description:
        Place for a camp (ticket 2.8, DESIGN 5.1): a random position on land that
        - is at least COIN_campMinDistMapEdge from the map edge, COIN_campMinDistStartBase from the start base and
          COIN_campMinDistSector from every sector centre (Liberation's 175 m evaluation),
        - is at least COIN_campExclusionRadius from every captured sector (blufor_sectors) and every FOB,
        - keeps the open-ground rules of COIN_fnc_checkTerrainSpot (towns, roads, flat and free, shared with terrain nests),
        - has at least COIN_campCoverMin cover objects within COIN_campCoverRadius (COIN_fnc_getCampCover).
        Tries COIN_campPlaceAttempts times, cheap rules first. The rules apply once, when the camp is placed.
        Server only.

    Parameter(s):
        NONE

    Returns:
        [position in whole metres or [] if none was found, rejected positions per rule (HASHMAP rule -> number)] [ARRAY]
*/

if (!isServer) exitWith {[[], createHashMap]};

private _edge = COIN_campMinDistMapEdge;
private _range = worldSize - 2 * _edge;

// Positions that keep camps away: captured sectors and FOBs
private _exclusion = [] call COIN_fnc_getCampExclusion;

private _spot = [];
private _rejected = createHashMap;

for "_i" from 1 to COIN_campPlaceAttempts do {
    private _candidate = [round (_edge + random _range), round (_edge + random _range), 0];

    private _fault = switch (true) do {
        case (surfaceIsWater _candidate): {"water"};
        case ((_candidate distance2D startbase) < COIN_campMinDistStartBase): {"startBase"};
        case ((sectors_allSectors findIf {(_candidate distance2D (markerPos _x)) < COIN_campMinDistSector}) >= 0): {"sector"};
        case ((_exclusion findIf {(_candidate distance2D _x) < COIN_campExclusionRadius}) >= 0): {"exclusionZone"};
        default {[_candidate, COIN_campMinDistTown, COIN_campMinDistRoad, COIN_campFlatRadius, COIN_campMaxGradient] call COIN_fnc_checkTerrainSpot};
    };
    if (_fault isEqualTo "" && {([_candidate] call COIN_fnc_getCampCover) < COIN_campCoverMin}) then {
        _fault = "cover";
    };

    if (_fault isEqualTo "") exitWith {
        _spot = _candidate;
    };
    _rejected set [_fault, (_rejected getOrDefault [_fault, 0]) + 1];
};

[_spot, _rejected]
