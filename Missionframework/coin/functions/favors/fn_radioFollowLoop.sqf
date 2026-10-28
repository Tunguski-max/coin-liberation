/*
    File: fn_radioFollowLoop.sqf
    Author: COIN Liberation

    Description:
        Server: the reinforcement follows a player (ticket 5.19, the order "Follow us" of COIN_fnc_radioOrder, DESIGN 8.1). Every
        COIN_radioFollowSeconds the group gets a waypoint COIN_radioFollowDistance behind the player, but only when that point has
        moved COIN_radioFollowMove m or more since the last one (a group that is sent again and again does not walk). The loop ends
        when another order comes (COIN_radioOrderId has moved on) or the reinforcement is over (COIN_reinforcement has another or no
        group). When the player dies or leaves the game the group holds its position (no waypoint, all stop) and the loop ends. Must be spawned.

    Parameter(s):
        _group   - The group of the reinforcement [GROUP, defaults to grpNull]
        _player  - Who gave the order [OBJECT, defaults to objNull]
        _orderId - The number of this order, COIN_radioOrderId at its start [NUMBER, defaults to 0]

    Returns:
        NONE
*/

params [
    ["_group", grpNull, [grpNull]],
    ["_player", objNull, [objNull]],
    ["_orderId", 0, [0]]
];

if (!isServer || {isNull _group}) exitWith {};

// Still this order of this group
private _current = {
    COIN_radioOrderId isEqualTo _orderId
    && {((missionNamespace getVariable ["COIN_reinforcement", []]) param [0, grpNull]) isEqualTo _group}
};

private _lastPoint = [];
private _holding = false;
while {call _current && {!_holding}} do {
    if (!alive _player || {!isPlayer _player}) then {
        // Nobody to follow: hold the position
        while {(count (waypoints _group)) != 0} do {deleteWaypoint ((waypoints _group) select 0)};
        {doStop _x} forEach (units _group);
        _holding = true;
        diag_log format ["[COIN] radio: the reinforcement holds its position, %1 is dead or gone", name _player];
    } else {
        private _point = (getPosATL _player) getPos [COIN_radioFollowDistance, (getDir _player) + 180];
        if (_lastPoint isEqualTo [] || {(_point distance2D _lastPoint) >= COIN_radioFollowMove}) then {
            _lastPoint = _point;
            // Far behind it runs, close it walks
            private _leader = ((units _group) select {alive _x}) param [0, objNull];
            private _speed = ["NORMAL", "FULL"] select (!isNull _leader && {(_leader distance2D _player) > (COIN_radioFollowDistance * 3)});
            [_group, _point, COIN_radioFollowMove, _speed] call COIN_fnc_moveGroup;
        };
        sleep COIN_radioFollowSeconds;
    };
};
