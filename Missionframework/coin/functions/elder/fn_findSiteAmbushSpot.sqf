/*
    File: fn_findSiteAmbushSpot.sqf
    Author: COIN Liberation

    Description:
        Place for the ambush at the site of an aid task (ticket 5.22, ADR 0024, DESIGN 8.2): COIN_aidAmbushDistance (100-250 m)
        from the village centre, on the side of the elder's town (COIN_aidAmbushArc degrees to either side of the direction to
        it). Beside a road if one gives a usable place (the edge plus COIN_ambushRoadOffset, either side), the roads nearest to the
        direction of the town first; the ambush then faces the road. Else on free ground, facing the town. A place is rejected when it is
        - in water, steeper than COIN_ambushMaxSlope or on a road itself,
        - closer than COIN_ambushMinDistSector to a sector centre or COIN_ambushMinDistBase to the start base or a FOB,
        - on free ground: closer than COIN_aidAmbushHouseClearance to a house.
        A place that terrain hides from COIN_aidAmbushViewDistance m out towards the town is preferred to one that is in plain
        view (the first usable one is taken if none is hidden). Server only.

    Parameter(s):
        _centre - Centre of the village [ARRAY]
        _toward - Where the army comes from, the elder's place [ARRAY]

    Returns:
        [position, direction the fighters face, position on the road or [] on free ground], [] if there is no place [ARRAY]
*/

params [
    ["_centre", [], [[]]],
    ["_toward", [], [[]]]
];

if (!isServer || {_centre isEqualTo []} || {_toward isEqualTo []}) exitWith {[]};

COIN_aidAmbushDistance params ["_distMin", "_distMax"];
COIN_ambushRoadOffset params ["_offsetMin", "_offsetMax"];

private _base = _centre getDir _toward;
private _bases = [startbase] + (missionNamespace getVariable ["GRLIB_all_fobs", []]);

// Degrees between the direction of a position from the village and the direction of the town (0-180)
private _angle = {
    params ["_pos"];
    abs ((((_centre getDir _pos) - _base) + 540) mod 360 - 180)
};

// The rule a place breaks, "" if none
private _fault = {
    params ["_place"];
    switch (true) do {
        case (surfaceIsWater _place): {"water"};
        case (((surfaceNormal _place) select 2) < COIN_ambushMaxSlope): {"slope"};
        case (isOnRoad _place): {"onRoad"};
        case ((sectors_allSectors findIf {(_place distance2D (markerPos _x)) < COIN_ambushMinDistSector}) >= 0): {"sector"};
        case ((_bases findIf {(_place distance2D _x) < COIN_ambushMinDistBase}) >= 0): {"base"};
        default {""};
    }
};

// Terrain between a man out on the way of the army and the place
private _lookout = _centre getPos [COIN_aidAmbushViewDistance, _base];
private _lookoutASL = [_lookout select 0, _lookout select 1, (getTerrainHeightASL _lookout) + 2];
private _hidden = {
    params ["_place"];
    terrainIntersectASL [_lookoutASL, [_place select 0, _place select 1, (getTerrainHeightASL _place) + 1.5]]
};

private _spot = [];
private _fallback = [];
// One candidate: the first hidden one wins, the first usable one is kept in case none is hidden
private _consider = {
    params ["_place", "_dir", "_roadPos"];
    private _entry = [[round (_place select 0), round (_place select 1), 0], _dir, _roadPos];
    if ([_place] call _hidden) then {
        _spot = _entry;
    } else {
        if (_fallback isEqualTo []) then {_fallback = _entry};
    };
};

// Beside a road, the roads in the direction of the town first
private _roads = (_centre nearRoads _distMax) select {
    private _distance = _x distance2D _centre;
    _distance >= _distMin && {([getPosATL _x] call _angle) <= COIN_aidAmbushArc}
};
_roads = [_roads, [], {[getPosATL _x] call _angle}, "ASCEND"] call BIS_fnc_sortBy;

{
    private _road = _x;
    private _info = getRoadInfo _road;
    // No pedestrian path, no bridge
    if (_info isEqualTo [] || {_info select 2} || {_info select 8}) then {continue};
    _info params ["", "_width", "", "", "", "", "_begin", "_end"];
    private _roadPos = getPosATL _road;
    private _roadDir = if (_begin isEqualTo _end) then {getDir _road} else {_begin getDir _end};

    {
        private _place = _roadPos getPos [_width / 2 + _offsetMin + random (_offsetMax - _offsetMin), _roadDir + _x];
        if (([_place] call _fault) isEqualTo "" && {([_place] call _angle) <= COIN_aidAmbushArc}) then {
            [_place, _place getDir _roadPos, _roadPos] call _consider;
        };
        if (_spot isNotEqualTo []) exitWith {};
    } forEach (selectRandom [[90, -90], [-90, 90]]);

    if (_spot isNotEqualTo []) exitWith {};
} forEach _roads;

// No road gave a place: free ground, the fighters face the town
if (_spot isEqualTo [] && {_fallback isEqualTo []}) then {
    for "_try" from 1 to COIN_aidAmbushSpotTries do {
        private _place = _centre getPos [_distMin + random (_distMax - _distMin), _base + (random (2 * COIN_aidAmbushArc)) - COIN_aidAmbushArc];
        if (
            ([_place] call _fault) isEqualTo ""
            && {(nearestTerrainObjects [_place, COIN_siteHouseTypes, COIN_aidAmbushHouseClearance, false, true]) isEqualTo []}
        ) then {
            [_place, _base, []] call _consider;
        };
        if (_spot isNotEqualTo []) exitWith {};
    };
};

if (_spot isEqualTo []) then {_spot = _fallback};
_spot
