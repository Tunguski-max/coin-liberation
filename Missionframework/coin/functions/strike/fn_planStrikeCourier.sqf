/*
    File: fn_planStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        Plan of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2), made when it is offered (a kind without a plan is
        not offered). Like the convoy of Liberation's secondary mission the courier starts anywhere on the map and does not care for
        the players: the start is a town (sectors_capture) the militia holds if there is such a pair, the destination any other town,
        held or not, COIN_courierDistance m away in a straight line. Each has a road piece near its centre (COIN_fnc_findRoadNear,
        COIN_strikeRoadSearch, no path). A pair is only taken when a car finds a route (COIN_fnc_calcRoute): the route has to end
        within COIN_strikePathEndTolerance of the destination and be no longer than COIN_courierMaxDetour times the straight line. At most
        COIN_courierPathTries pairs are tried, each for COIN_strikePathTimeout s. The nest the documents will name is the one a
        civilian of the start town would know of (COIN_fnc_pickIntelNest). Must be called where it may wait (scheduled). Server only.

    Parameter(s):
        _origin - Where the one stands who told of it, for the log [ARRAY, defaults to [0, 0, 0]]

    Returns:
        [start position, start town, destination position, destination town, id of the nest, direction of the car],
        [] if there is no such pair of towns [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]]]
];

if (!isServer || {isNil "sectors_capture"}) exitWith {[]};

COIN_courierDistance params ["_distMin", "_distMax"];

// The road nearest to the centre of a town: the piece, objNull if there is none
private _roadAt = {
    params ["_town"];
    [markerPos _town, COIN_strikeRoadSearch] call COIN_fnc_findRoadNear
};

// A road has no front: the end of the direction that points towards a position
private _faceTowards = {
    params ["_from", "_roadDir", "_towards"];
    if (abs ((((_roadDir - (_from getDir _towards)) + 540) mod 360) - 180) > 90) then {_roadDir + 180} else {_roadDir}
};

// The length of the route a car finds between two positions, -1 if there is none (or it takes too long to find)
private _routeLength = {
    params ["_from", "_to"];
    private _route = [_from, _to] call COIN_fnc_calcRoute;
    if (_route isEqualTo []) exitWith {-1};
    [_route] call COIN_fnc_pathLength
};

// Pairs of towns the right distance apart (start, destination); those with a start the militia holds first
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

private _fromHeld = _pairs select {(_x select 0) in _held};
private _candidates = +([_pairs, _fromHeld] select (_fromHeld isNotEqualTo []));

private _plan = [];
private _tries = 0;
while {_plan isEqualTo [] && {_candidates isNotEqualTo []} && {_tries < COIN_courierPathTries}} do {
    private _pair = _candidates deleteAt (floor random count _candidates);
    _pair params ["_a", "_b"];
    private _startRoad = [_a] call _roadAt;
    private _endRoad = [_b] call _roadAt;
    if (!isNull _startRoad && {!isNull _endRoad}) then {
        _tries = _tries + 1;
        private _startPos = getPosATL _startRoad;
        private _endPos = getPosATL _endRoad;
        private _straight = _startPos distance2D _endPos;
        private _length = [_startPos, _endPos] call _routeLength;
        if (_length > 0 && {_length <= _straight * COIN_courierMaxDetour}) then {
            private _nest = [markerPos _a] call COIN_fnc_pickIntelNest;
            if (_nest isNotEqualTo []) then {
                _plan = [
                    [_startPos select 0, _startPos select 1, 0], markerText _a,
                    [_endPos select 0, _endPos select 1, 0], markerText _b,
                    _nest select 0, [_startPos, getDir _startRoad, _endPos] call _faceTowards
                ];
                diag_log format [
                    "[COIN] strike: courier plan: %1 to %2, %3 m by air, %4 m by road, nest %5, start %6 m from the origin (%7 pairs, %8 tried)",
                    markerText _a, markerText _b, round _straight, round _length, _nest select 0,
                    round (_startPos distance2D _origin), count _pairs, _tries
                ];
            };
        } else {
            diag_log format ["[COIN] strike: courier: %1 to %2 rejected, %3 m by air, route %4 m", markerText _a, markerText _b, round _straight, round _length];
        };
    };
};

if (_plan isEqualTo []) then {
    diag_log format ["[COIN] strike: courier: no pair of towns %1 to %2 m apart with a route for a car (%3 pairs, %4 tried)", _distMin, _distMax, count _pairs, _tries];
};

_plan
