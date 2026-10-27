/*
    File: fn_calcRoute.sqf
    Author: COIN Liberation

    Description:
        The route a car finds between two positions (calculatePath, "car", "safe"), for the strike tasks that send a car along a road
        (tickets 5.14 and 5.16). The route may come in several parts (the event can fire more than once): all of them are kept, the
        longest is taken, COIN_strikePathWait s after the first one. The agent of calculatePath deletes itself soon after the route
        is made, so the parts are kept in an array of ours and not read from the agent afterwards. The route counts when it ends
        within COIN_strikePathEndTolerance of the destination. The search takes at most COIN_strikePathTimeout s. Writes a line to
        the RPT with the number of parts, the length, the distance at which it ends and how long the first part took.
        Must be called where it may wait (scheduled). Server only.

    Parameter(s):
        _from - Start position [ARRAY, defaults to [0, 0, 0]]
        _to   - Destination position [ARRAY, defaults to [0, 0, 0]]

    Returns:
        The points of the route, [] if there is none (or it ends too far from the destination, or the search takes too long) [ARRAY of POSITIONs]
*/

params [
    ["_from", [0, 0, 0], [[]]],
    ["_to", [0, 0, 0], [[]]]
];

if (!isServer) exitWith {[]};

private _started = diag_tickTime;
private _agent = calculatePath ["car", "safe", _from, _to];
private _agentMissing = isNull _agent;
private _parts = [];
_agent setVariable ["COIN_paths", _parts];
_agent addEventHandler ["PathCalculated", {
    params ["_agent", "_path"];
    (_agent getVariable "COIN_paths") pushBack _path;
}];
private _timeout = diag_tickTime + COIN_strikePathTimeout;
waitUntil {sleep 0.05; (count _parts) > 0 || {diag_tickTime > _timeout}};
private _waited = diag_tickTime - _started;
sleep COIN_strikePathWait;
if (!isNull _agent) then {deleteVehicle _agent};

private _best = [];
{
    if ((count _x) >= 2 && {([_x] call COIN_fnc_pathLength) > ([_best] call COIN_fnc_pathLength)}) then {_best = _x};
} forEach _parts;

private _gap = if (_best isEqualTo []) then {-1} else {round ((_best select (count _best - 1)) distance2D _to)};
diag_log format [
    "[COIN] strike: route: %1 event(s), longest %2 points, %3 m, ends %4 m from the destination (%5 m by air), first part after %6 s, agent missing: %7",
    count _parts, count _best, round ([_best] call COIN_fnc_pathLength), _gap, round (_from distance2D _to),
    _waited toFixed 1, _agentMissing
];

if (_best isEqualTo [] || {_gap > COIN_strikePathEndTolerance}) exitWith {[]};
_best
