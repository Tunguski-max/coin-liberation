/*
    File: fn_planStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        Plan of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2), made when it is accepted: two towns
        (sectors_capture, those the militia still holds if there are two such towns the right distance apart) COIN_courierDistance
        apart, with a road near each (COIN_courierRoadSearch around the centre, no path, no bridge). The courier starts on the
        road at the first and drives to the road at the second. The nest the documents will name is the one a civilian of the first
        town would know of (COIN_fnc_pickIntelNest). Server only.

    Parameter(s):
        NONE

    Returns:
        [start position, start town, destination position, destination town, id of the nest, direction of the car at the start],
        [] if there is no such pair of towns [ARRAY]
*/

if (!isServer || {isNil "sectors_capture"}) exitWith {[]};

COIN_courierDistance params ["_distMin", "_distMax"];

// The road nearest to the centre of a town: [position, direction], [] if there is none
private _roadAt = {
    params ["_town"];
    private _centre = markerPos _town;
    private _roads = (_centre nearRoads COIN_courierRoadSearch) select {
        private _info = getRoadInfo _x;
        _info isNotEqualTo [] && {!(_info select 2)} && {!(_info select 8)}
    };
    if (_roads isEqualTo []) exitWith {[]};
    _roads = [_roads, [], {_x distance2D _centre}, "ASCEND"] call BIS_fnc_sortBy;
    private _road = _roads select 0;
    private _pos = getPosATL _road;
    [[_pos select 0, _pos select 1, 0], getDir _road]
};

// Pairs of towns the right distance apart; those the militia still holds both are preferred
private _held = sectors_capture select {!(_x in (missionNamespace getVariable ["blufor_sectors", []]))};
private _pairs = [];
{
    private _a = _x;
    {
        private _distance = (markerPos _a) distance2D (markerPos _x);
        if (_x != _a && {_distance >= _distMin} && {_distance <= _distMax}) then {
            _pairs pushBack [_a, _x];
        };
    } forEach sectors_capture;
} forEach sectors_capture;

private _bothHeld = _pairs select {(_x select 0) in _held && {(_x select 1) in _held}};
private _candidates = [_pairs, _bothHeld] select (_bothHeld isNotEqualTo []);

private _plan = [];
while {_plan isEqualTo [] && {_candidates isNotEqualTo []}} do {
    private _pair = _candidates deleteAt (floor random count _candidates);
    _pair params ["_a", "_b"];
    private _start = [_a] call _roadAt;
    private _end = [_b] call _roadAt;
    if (_start isNotEqualTo [] && {_end isNotEqualTo []}) then {
        private _nest = [markerPos _a] call COIN_fnc_pickIntelNest;
        if (_nest isNotEqualTo []) then {
            // The car faces the way to the destination (a road has no front)
            private _dir = (_start select 0) getDir (_end select 0);
            _plan = [_start select 0, markerText _a, _end select 0, markerText _b, _nest select 0, _dir];
        };
    };
};

if (_plan isEqualTo []) then {
    diag_log format ["[COIN] strike: courier: no pair of towns %1 to %2 m apart with a road at both, %3 pairs", _distMin, _distMax, count _pairs];
} else {
    diag_log format [
        "[COIN] strike: courier plan: %1 to %2, %3 m, nest %4 (%5 pairs of towns, %6 with both held by the militia)",
        _plan select 1, _plan select 3, round ((_plan select 0) distance2D (_plan select 2)), _plan select 4, count _pairs, count _bothHeld
    ];
};

_plan
