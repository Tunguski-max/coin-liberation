/*
    File: fn_planStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        Plan of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2), made when it is offered (a kind without a plan is
        not offered). The courier starts on the road at a town the militia holds (sectors_capture, not liberated), one of the
        COIN_courierStartCandidates nearest to the given origin (the one who told of it), so the task is near the players. The
        destination is a point on the road COIN_courierDistance m along the road from the start: the roads connected to the
        start are followed piece by piece (no path, COIN_courierSearchNodes pieces at most) and one piece in that range is taken
        at random. It has no town of its own, so it is named after the nearest town (COIN_courierDestinationName). The nest the
        documents will name is the one a civilian of the start town would know of (COIN_fnc_pickIntelNest). Server only.

    Parameter(s):
        _origin - Where the one stands who told of it [ARRAY, defaults to [0, 0, 0]]

    Returns:
        [start position, start town, destination position, destination name [German, English], id of the nest, direction of the car],
        [] if there is no such start and destination [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]]]
];

if (!isServer || {isNil "sectors_capture"}) exitWith {[]};

COIN_courierDistance params ["_distMin", "_distMax"];

// A road piece a car can use: no path
private _usable = {
    params ["_road"];
    private _info = getRoadInfo _road;
    _info isNotEqualTo [] && {!(_info select 2)}
};

// The road nearest to the centre of a town: the piece, objNull if there is none
private _roadAt = {
    params ["_town"];
    private _centre = markerPos _town;
    private _roads = (_centre nearRoads COIN_courierRoadSearch) select {[_x] call _usable};
    if (_roads isEqualTo []) exitWith {objNull};
    _roads = [_roads, [], {_x distance2D _centre}, "ASCEND"] call BIS_fnc_sortBy;
    _roads select 0
};

// A road has no front: the end of the direction that points towards a position
private _faceTowards = {
    params ["_from", "_roadDir", "_towards"];
    if (abs ((((_roadDir - (_from getDir _towards)) + 540) mod 360) - 180) > 90) then {_roadDir + 180} else {_roadDir}
};

// The road pieces COIN_courierDistance m along the road from a piece: [[piece, metres along the road], ...]
private _along = {
    params ["_start"];
    private _found = [];
    private _seen = createHashMap;
    _seen set [str _start, true];
    private _queue = [[_start, 0]];
    private _looked = 0;
    while {_queue isNotEqualTo [] && {_looked < COIN_courierSearchNodes}} do {
        (_queue deleteAt 0) params ["_road", "_metres"];
        _looked = _looked + 1;
        {
            private _next = _x;
            if (!(_seen getOrDefault [str _next, false]) && {[_next] call _usable}) then {
                _seen set [str _next, true];
                private _total = _metres + (_road distance2D _next);
                if (_total <= _distMax) then {
                    if (_total >= _distMin) then {_found pushBack [_next, _total]};
                    _queue pushBack [_next, _total];
                };
            };
        } forEach (roadsConnectedTo _road);
    };
    _found
};

// The towns the militia holds, the nearest to the origin first; one of the nearest at random, then the next ones
private _held = sectors_capture select {!(_x in (missionNamespace getVariable ["blufor_sectors", []]))};
private _sorted = [_held, [], {(markerPos _x) distance2D _origin}, "ASCEND"] call BIS_fnc_sortBy;
private _candidates = _sorted select [0, COIN_courierStartCandidates];
private _rest = _sorted select [COIN_courierStartCandidates, count _sorted];
_candidates = (_candidates call BIS_fnc_arrayShuffle) + _rest;

private _plan = [];
{
    private _town = _x;
    private _startRoad = [_town] call _roadAt;
    if (!isNull _startRoad) then {
        private _ends = [_startRoad] call _along;
        if (_ends isNotEqualTo []) then {
            private _end = selectRandom _ends;
            private _endRoad = _end select 0;
            private _startPos = getPosATL _startRoad;
            private _endPos = getPosATL _endRoad;
            private _nest = [markerPos _town] call COIN_fnc_pickIntelNest;
            if (_nest isNotEqualTo []) then {
                // The destination is named after the nearest town of the map
                private _near = [sectors_capture, [], {(markerPos _x) distance2D _endPos}, "ASCEND"] call BIS_fnc_sortBy;
                private _nearName = markerText (_near select 0);
                private _dir = [_startPos, getDir _startRoad, _endPos] call _faceTowards;
                _plan = [
                    [_startPos select 0, _startPos select 1, 0], markerText _town,
                    [_endPos select 0, _endPos select 1, 0], COIN_courierDestinationName apply {format [_x, _nearName]},
                    _nest select 0, _dir
                ];
                diag_log format [
                    "[COIN] strike: courier plan: %1 to %2, %3 m along the road (%4 m by air), nest %5, start town %6 m from the origin (%7 towns of the militia)",
                    markerText _town, _nearName, round (_end select 1), round (_startPos distance2D _endPos), _nest select 0,
                    round ((markerPos _town) distance2D _origin), count _held
                ];
            };
        };
    };
    if (_plan isNotEqualTo []) exitWith {};
} forEach _candidates;

if (_plan isEqualTo []) then {
    diag_log format ["[COIN] strike: courier: no start and no destination %1 to %2 m along a road, %3 towns of the militia", _distMin, _distMax, count _held];
};

_plan
