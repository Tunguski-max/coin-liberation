/*
    File: fn_planStrikeConvoy.sqf
    Author: COIN Liberation

    Description:
        Plan of the strike task "Intercept arms transport" (ticket 5.16, DESIGN 8.2), made when it is offered (a kind without a plan is
        not offered). The convoy drives to a weapons cache (an active nest of type "cache", at random) on the road. The start is a town
        (sectors_capture, one the militia holds if there is such a pair) COIN_convoyDistance m from the road end next to the cache
        (COIN_convoyCacheRoadSearch) in a straight line; the route a car finds (COIN_fnc_calcRoute) must be COIN_convoyRouteLength long
        and no longer than COIN_convoyMaxDetour times the straight line. At most COIN_convoyPathTries routes are tried, each for
        COIN_strikePathTimeout s. Two points on the route are named, the task shows nothing else of it (the cache stays secret): near the
        fractions COIN_convoyPointFractions of the route, a bridge before a junction before any road piece within COIN_convoyPointSearch
        of the route; the second at least COIN_convoyPointMinCache m (straight line) from the cache, the points at least
        COIN_convoyPointMinGap m apart. For each point the time window in which the convoy passes it, as seconds after the beginning
        (the average speed is COIN_convoyAverageKmh, the window is COIN_convoyWindowShare of the time on both sides, at least
        COIN_convoyWindowMin s). Also the places and directions of the vehicles at the start (COIN_convoyOrder, COIN_convoySpacing m
        apart along the route, the first in the order is in front) and the waypoints along the route (COIN_convoyWaypointSpacing m apart,
        the two points of the task are always among them).
        Must be called where it may wait (scheduled). Server only.

    Parameter(s):
        _origin - Where the one stands who told of it, for the log [ARRAY, defaults to [0, 0, 0]]

    Returns:
        [position of point 1, name of point 1, position of point 2, name of point 2, id of the cache, vehicles at the start
        [[position, direction], ...] in the order of the convoy, waypoints [position, ...], position at the end of the route,
        time windows [[from, to], [from, to]] in s after the beginning, name of the start town, length of the route in m],
        [] if there is no such route [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]]]
];

if (!isServer || {isNil "sectors_capture"} || {isNil "COIN_nests"}) exitWith {[]};

private _caches = COIN_nests select {(_x select 1) isEqualTo "cache" && {(_x select 5) isEqualTo "active"}};
if (_caches isEqualTo []) exitWith {[]};
_caches = _caches call BIS_fnc_arrayShuffle;

COIN_convoyDistance params ["_distMin", "_distMax"];
COIN_convoyRouteLength params ["_lengthMin", "_lengthMax"];

// Position and direction on the route a given distance from its start (path = positions, cum = distance from the start of each)
private _placeAt = {
    params ["_path", "_cum", "_distance"];
    private _i = (_cum findIf {_x >= _distance}) max 1;
    private _from = _path select (_i - 1);
    private _to = _path select _i;
    private _span = (_cum select _i) - (_cum select (_i - 1));
    private _share = if (_span > 0) then {(((_distance - (_cum select (_i - 1))) / _span) min 1) max 0} else {0};
    private _pos = [(_from select 0) + ((_to select 0) - (_from select 0)) * _share, (_from select 1) + ((_to select 1) - (_from select 1)) * _share, 0];
    // The height of the road piece there (a bridge is higher than the ground); the place itself stays on the line between the route points
    private _road = roadAt _pos;
    if (!isNull _road) then {_pos set [2, (getPosATL _road) select 2]};
    [_pos, _from getDir _to]
};

// The name of a point: the kind of road and the nearest place, German and English
private _nameOf = {
    params ["_pos", "_kind"];
    private _places = nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], COIN_convoyNameRadius];
    private _place = if (_places isEqualTo []) then {mapGridPosition _pos} else {text (_places select 0)};
    (COIN_convoyPointNames select _kind) apply {format [_x, _place]}
};

// The point on the route near a fraction of its length: [index, kind 0 road / 1 junction / 2 bridge]
private _pointNear = {
    params ["_path", "_cum", "_total", "_fraction", "_avoid"];
    private _best = [-1, 0];
    private _bestScore = 0;
    {
        private _along = _cum select _forEachIndex;
        // Near the fraction, and not within COIN_convoyPointMinCache of the cache (a point that close gives the cache away)
        if (abs (_along - (_fraction * _total)) <= COIN_convoyPointSearch * _total && {(_x distance2D _avoid) >= COIN_convoyPointMinCache}) then {
            private _road = roadAt _x;
            private _kind = 0;
            if (!isNull _road) then {
                if (((getRoadInfo _road) param [8, false])) then {
                    _kind = 2;
                } else {
                    if (count (roadsConnectedTo _road) >= 3) then {_kind = 1};
                };
            };
            // A bridge before a junction before a road piece (the kind outweighs any distance: the search reaches COIN_convoyPointSearch of the
            // route round the fraction, less than the whole route); within a kind the nearest to the fraction
            private _score = (_kind * _total) - abs (_along - (_fraction * _total));
            if ((_best select 0) < 0 || {_score > _bestScore}) then {
                _bestScore = _score;
                _best = [_forEachIndex, _kind];
            };
        };
    } forEach _path;
    _best
};

// The plan for a route, [] if its points do not fit
private _makePlan = {
    params ["_path", "_nest", "_startName", "_endPos"];
    private _cum = [0];
    for "_i" from 1 to (count _path - 1) do {
        _cum pushBack ((_cum select (_i - 1)) + ((_path select (_i - 1)) distance2D (_path select _i)));
    };
    private _total = _cum select (count _cum - 1);

    COIN_convoyPointFractions params ["_f1", "_f2"];
    private _p1 = [_path, _cum, _total, _f1, _nest select 3] call _pointNear;
    private _p2 = [_path, _cum, _total, _f2, _nest select 3] call _pointNear;
    if ((_p1 select 0) < 0 || {(_p2 select 0) < 0}) exitWith {[]};

    private _pos1 = _path select (_p1 select 0);
    private _pos2 = _path select (_p2 select 0);
    private _along1 = _cum select (_p1 select 0);
    private _along2 = _cum select (_p2 select 0);
    if (
        (_pos2 distance2D (_nest select 3)) < COIN_convoyPointMinCache
        || {(_along2 - _along1) < COIN_convoyPointMinGap}
    ) exitWith {
        diag_log format ["[COIN] strike: convoy: points do not fit (point 2 %1 m from the cache, %2 m between the points)", round (_pos2 distance2D (_nest select 3)), round (_along2 - _along1)];
        []
    };

    // The vehicles at the start: the first of the order in front, the others behind it along the route
    private _count = count COIN_convoyOrder;
    private _spawn = [];
    for "_k" from 0 to (_count - 1) do {
        _spawn pushBack ([_path, _cum, (_count - 1 - _k) * COIN_convoySpacing] call _placeAt);
    };
    private _lead = (_count - 1) * COIN_convoySpacing;

    // Time windows: the convoy drives at an average speed, the way of the first vehicle from the start
    private _speed = COIN_convoyAverageKmh / 3.6;
    private _windows = [_along1, _along2] apply {
        private _seconds = ((_x - _lead) max 0) / _speed;
        private _half = COIN_convoyWindowMin max (_seconds * COIN_convoyWindowShare);
        [round ((_seconds - _half) max 0), round (_seconds + _half)]
    };

    // Waypoints along the route, from beyond the vehicles at the start to the end
    private _waypoints = [];
    private _next = _lead + COIN_convoyWaypointSpacing;
    {
        // The two points of the task are always waypoints, so the convoy certainly passes them
        if ((_cum select _forEachIndex) >= _next || {_forEachIndex isEqualTo (_p1 select 0)} || {_forEachIndex isEqualTo (_p2 select 0)}) then {
            _waypoints pushBack [_x select 0, _x select 1, 0];
            _next = (_cum select _forEachIndex) + COIN_convoyWaypointSpacing;
        };
    } forEach _path;
    _waypoints pushBack [_endPos select 0, _endPos select 1, 0];

    [
        [_pos1 select 0, _pos1 select 1, 0], [_pos1, _p1 select 1] call _nameOf,
        [_pos2 select 0, _pos2 select 1, 0], [_pos2, _p2 select 1] call _nameOf,
        _nest select 0, _spawn, _waypoints, [_endPos select 0, _endPos select 1, 0], _windows, _startName, round _total
    ]
};

private _plan = [];
private _tries = 0;
while {_plan isEqualTo [] && {_caches isNotEqualTo []} && {_tries < COIN_convoyPathTries}} do {
    private _nest = _caches deleteAt 0;
    private _endRoad = [_nest select 3, COIN_convoyCacheRoadSearch] call COIN_fnc_findRoadNear;
    if (!isNull _endRoad) then {
        private _endPos = getPosATL _endRoad;

        // Towns the right distance from the road end next to the cache; those the militia holds first
        private _held = sectors_capture select {!(_x in (missionNamespace getVariable ["blufor_sectors", []]))};
        private _towns = sectors_capture select {
            private _d = (markerPos _x) distance2D _endPos;
            _d >= _distMin && {_d <= _distMax}
        };
        private _fromHeld = _towns select {_x in _held};
        _towns = +([_towns, _fromHeld] select (_fromHeld isNotEqualTo []));

        while {_plan isEqualTo [] && {_towns isNotEqualTo []} && {_tries < COIN_convoyPathTries}} do {
            private _town = _towns deleteAt (floor random count _towns);
            private _startRoad = [markerPos _town, COIN_strikeRoadSearch] call COIN_fnc_findRoadNear;
            if (!isNull _startRoad) then {
                _tries = _tries + 1;
                private _startPos = getPosATL _startRoad;
                private _straight = _startPos distance2D _endPos;
                private _path = [_startPos, _endPos] call COIN_fnc_calcRoute;
                private _length = [_path] call COIN_fnc_pathLength;
                if (_path isNotEqualTo [] && {_length >= _lengthMin} && {_length <= _lengthMax} && {_length <= _straight * COIN_convoyMaxDetour}) then {
                    _plan = [_path, _nest, markerText _town, _endPos] call _makePlan;
                    if (_plan isNotEqualTo []) then {
                        diag_log format [
                            "[COIN] strike: convoy plan: from %1 to cache %2 (%3 m by road, %4 m by air), point 1 %5 at %6 s, point 2 %7 at %8 s after the beginning, start %9 m from the origin",
                            _plan select 9, _nest select 0, _plan select 10, round _straight, (_plan select 1) select 0, (_plan select 8) select 0,
                            (_plan select 3) select 0, (_plan select 8) select 1, round (_startPos distance2D _origin)
                        ];
                    };
                } else {
                    diag_log format ["[COIN] strike: convoy: %1 to cache %2 rejected, %3 m by air, route %4 m", markerText _town, _nest select 0, round _straight, round _length];
                };
            };
        };
    } else {
        diag_log format ["[COIN] strike: convoy: no road within %1 m of cache %2", COIN_convoyCacheRoadSearch, _nest select 0];
    };
};

if (_plan isEqualTo []) then {
    diag_log format ["[COIN] strike: convoy: no cache with a route of %1 to %2 m for a car (%3 tried)", _lengthMin, _lengthMax, _tries];
};

_plan
