/*
    File: fn_runReinforcement.sqf
    Author: COIN Liberation

    Description:
        Server: watches the reinforcement that COIN_fnc_requestReinforcement sent (ticket 5.6, DESIGN 8.1) every COIN_reinforcementCheckSeconds,
        until it ends:
        - "time": COIN_reinforcementMaxMin minutes since the fighters appeared,
        - "reputation": the reputation is below COIN_favorMinRep (the resistance is no longer on our side),
        - "wiped": no fighter is alive any more (killed, or deleted in Zeus). The next favor comes later (COIN_fnc_delayFavor).
        Everybody gets a message when the group reaches the point (one fighter within COIN_reinforcementArriveRadius) and when it leaves
        (COIN_fnc_showReinforcementMessage). After "time" and "reputation" the survivors walk back to the elder's place, then go when
        nobody sees them (COIN_fnc_removeWhenUnseen), at the latest COIN_reinforcementReturnSeconds after the order. From that moment
        COIN_reinforcement is empty again, so another reinforcement may be sent. Must be spawned. Server only.

    Parameter(s):
        _group - The group of the local fighters, the state is COIN_reinforcement [GROUP, defaults to grpNull]

    Returns:
        How it ended: "time", "reputation" or "wiped" [STRING]
*/

params [
    ["_group", grpNull, [grpNull]]
];

if (!isServer) exitWith {""};

COIN_reinforcement params ["", "_home", "_target", "_endTime", "_town"];
private _started = time;
private _size = count (units _group);

private _arrived = false;
private _result = "";
while {_result isEqualTo ""} do {
    sleep COIN_reinforcementCheckSeconds;
    private _alive = (units _group) select {alive _x};
    if (_alive isEqualTo []) then {
        _result = "wiped";
    } else {
        if ((missionNamespace getVariable ["KP_liberation_civ_rep", 0]) < COIN_favorMinRep) then {
            _result = "reputation";
        } else {
            if (time >= _endTime) then {
                _result = "time";
            } else {
                if (!_arrived && {_alive findIf {(_x distance2D _target) <= COIN_reinforcementArriveRadius} >= 0}) then {
                    _arrived = true;
                    ["arrived", _town] remoteExecCall ["COIN_fnc_showReinforcementMessage", 0];
                    diag_log format [
                        "[COIN] favors: reinforcement from %1 reached the point after %2 min, %3 of %4 fighters alive",
                        _town, ((time - _started) / 60) toFixed 1, count _alive, _size
                    ];
                };
            };
        };
    };
};

private _survivors = (units _group) select {alive _x};
diag_log format [
    "[COIN] favors: reinforcement from %1 ends (%2) after %3 min, %4 of %5 fighters alive",
    _town, _result, ((time - _started) / 60) toFixed 1, count _survivors, _size
];
// None on its way any more: the group is not led by the radio from here on, and the next one may come
COIN_reinforcement = [];
["left_" + _result, _town] remoteExecCall ["COIN_fnc_showReinforcementMessage", 0];

if (_result isEqualTo "wiped") exitWith {
    // Wiped out: the next favor comes later (ticket 5.4). Their death costs no reputation
    [] call COIN_fnc_delayFavor;
    _result
};

// They walk home and go when nobody sees them
while {(count (waypoints _group)) != 0} do {deleteWaypoint ((waypoints _group) select 0)};
_group setBehaviour "AWARE";
_group setSpeedMode "NORMAL";
private _waypoint = _group addWaypoint [_home, 0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointCompletionRadius COIN_reinforcementHomeRadius;

private _giveUp = time + COIN_reinforcementReturnSeconds;
waitUntil {
    sleep COIN_reinforcementCheckSeconds;
    time >= _giveUp || {((units _group) select {alive _x && {(_x distance2D _home) > COIN_reinforcementHomeRadius}}) isEqualTo []}
};

[(units _group) select {!isNull _x}, "local fighters"] spawn COIN_fnc_removeWhenUnseen;

_result
