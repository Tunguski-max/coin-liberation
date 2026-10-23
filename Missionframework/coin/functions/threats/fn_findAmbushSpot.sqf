/*
    File: fn_findAmbushSpot.sqf
    Author: COIN Liberation

    Description:
        Place for the ambush of a camp (ticket 4.5, DESIGN 6): beside the nearest road whose segment lies
        COIN_ambushDistance (200-800 m) from the camp. The road segments around the camp are taken in the order of
        their distance to the camp; the first one with a usable place beside it wins. A road is no pedestrian path and no
        bridge. A place beside the road (the edge plus COIN_ambushRoadOffset, either side, tried in random order) is
        rejected when it is
        - in water, steeper than COIN_ambushMaxSlope or on a road itself,
        - closer than COIN_ambushMinDistSector to a sector centre (not in the town core),
        - closer than COIN_ambushMinDistBase to the start base or a FOB,
        - closer than COIN_ambushMinDistAmbush to the ambush of another camp.
        The ambush faces the road. Server only.

    Parameter(s):
        _campPos - Position of the camp [ARRAY]

    Returns:
        [[position, direction facing the road, position on the road] or [] if none was found, rejected road segments and
        places per rule (HASHMAP rule -> number)] [ARRAY]
*/

params [
    ["_campPos", [], [[]]]
];

if (!isServer) exitWith {[[], createHashMap]};

COIN_ambushDistance params ["_distMin", "_distMax"];
COIN_ambushRoadOffset params ["_offsetMin", "_offsetMax"];

private _bases = [startbase] + (missionNamespace getVariable ["GRLIB_all_fobs", []]);
private _others = ((missionNamespace getVariable ["COIN_camps", []]) select {(_x param [8, []]) isNotEqualTo []}) apply {(_x select 8) select 0};

// The rule a place breaks, "" if none
private _fault = {
    params ["_place"];
    switch (true) do {
        case (surfaceIsWater _place): {"water"};
        case (((surfaceNormal _place) select 2) < COIN_ambushMaxSlope): {"slope"};
        case (isOnRoad _place): {"onRoad"};
        case ((sectors_allSectors findIf {(_place distance2D (markerPos _x)) < COIN_ambushMinDistSector}) >= 0): {"sector"};
        case ((_bases findIf {(_place distance2D _x) < COIN_ambushMinDistBase}) >= 0): {"base"};
        case ((_others findIf {(_place distance2D _x) < COIN_ambushMinDistAmbush}) >= 0): {"otherAmbush"};
        default {""};
    }
};

private _roads = [_campPos nearRoads _distMax, [], {_x distance2D _campPos}, "ASCEND"] call BIS_fnc_sortBy;
private _spot = [];
private _rejected = createHashMap;
private _reject = {
    params ["_rule"];
    _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
};

{
    private _road = _x;
    if ((_road distance2D _campPos) < _distMin) then {
        ["tooNear"] call _reject;
        continue;
    };
    private _info = getRoadInfo _road;
    if (_info isEqualTo [] || {_info select 2} || {_info select 8}) then {
        ["roadKind"] call _reject;
        continue;
    };
    _info params ["", "_width", "", "", "", "", "_begin", "_end"];
    private _roadPos = getPosATL _road;
    private _roadDir = if (_begin isEqualTo _end) then {getDir _road} else {_begin getDir _end};

    {
        private _distance = _width / 2 + _offsetMin + random (_offsetMax - _offsetMin);
        private _place = _roadPos getPos [_distance, _roadDir + _x];
        private _rule = [_place] call _fault;
        if (_rule isEqualTo "") exitWith {
            _spot = [[round (_place select 0), round (_place select 1), 0], _place getDir _roadPos, _roadPos];
        };
        [_rule] call _reject;
    } forEach (selectRandom [[90, -90], [-90, 90]]);

    if (_spot isNotEqualTo []) exitWith {};
} forEach _roads;

[_spot, _rejected]
