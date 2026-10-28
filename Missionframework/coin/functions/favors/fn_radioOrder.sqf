/*
    File: fn_radioOrder.sqf
    Author: COIN Liberation

    Description:
        Server: a player gives the reinforcement a radio order (ticket 5.19, DESIGN 8.1, ADR 0023). Called by COIN_fnc_giveRadioOrder with
        remoteExecCall. Checks the machine, that a reinforcement is on its way with a fighter alive, and that the player may give
        orders (COIN_fnc_canGiveRadioOrder). The last order counts: a new one ends a following group's loop. The orders:
        - "follow": the group follows the player (COIN_fnc_radioFollowLoop),
        - "goto": the group walks to the point and stays (not in water); the player gets a message when it has arrived (COIN_radioGoto,
          COIN_fnc_runReinforcement),
        - "attack": the group goes to the middle of the militia's town nearest to it (the capital counts, military posts do not) in
          combat mode and searches and destroys there in COIN_radioAttackRadius; none left: "no target", the old order stays. Liberation
          activates a town only when players are near, without them the town is empty (no hook in Liberation).
        The player gets a radio message (COIN_fnc_showRadioReply) and the RPT a line. An order does not change the time of the
        reinforcement or its message of arrival (the first point). Switch COIN_enableRadio.

    Parameter(s):
        _caller - The player [OBJECT, defaults to objNull]
        _order  - "follow", "goto" or "attack" [STRING, defaults to ""]
        _pos    - The point of "goto" [ARRAY, defaults to []]

    Returns:
        The order was carried out [BOOL]
*/

params [
    ["_caller", objNull, [objNull]],
    ["_order", "", [""]],
    ["_pos", [], [[]]]
];

// owner of a null unit is 0, and a message to 0 goes to everybody
if (!isServer || {!COIN_enableRadio} || {isNull _caller}) exitWith {false};

// The player must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _caller != _sender}) exitWith {
    diag_log format ["[COIN] radio: ERROR - order %1 sent by machine %2, not the owner of %3, refused", _order, _sender, _caller];
    false
};

private _reply = {
    params ["_key", ["_args", []]];
    [_key, _args] remoteExecCall ["COIN_fnc_showRadioReply", owner _caller];
};

private _state = missionNamespace getVariable ["COIN_reinforcement", []];
private _group = _state param [0, grpNull];
private _here = ((units _group) select {alive _x}) param [0, objNull];
if (_state isEqualTo [] || {isNull _here} || {!([_caller] call COIN_fnc_canGiveRadioOrder)}) exitWith {
    diag_log format ["[COIN] radio: order %1 of %2 refused (no reinforcement, or the rules)", _order, name _caller];
    ["refused"] call _reply;
    false
};

private _town = _state select 4;
private _done = false;
// A new order ends the loop of a group that follows and the wait of the group for its point of "go there"
private _nextOrder = {
    COIN_radioGoto = [];
    COIN_radioOrderId = (missionNamespace getVariable ["COIN_radioOrderId", 0]) + 1;
    COIN_radioOrderId
};

switch (_order) do {
    case "follow": {
        // It starts calm, but a group that is fighting keeps its modes; the loop leaves them alone, so a fight is not broken off
        if ((time - (_group getVariable ["COIN_lastCombat", -1e6])) > COIN_radioFightSeconds) then {
            _group setBehaviour "AWARE";
            _group setCombatMode "YELLOW";
        };
        [_group, _caller, call _nextOrder] spawn COIN_fnc_radioFollowLoop;
        ["follow"] call _reply;
        diag_log format ["[COIN] radio: %1 orders the reinforcement from %2: follow", name _caller, _town];
        _done = true;
    };
    case "goto": {
        if (count _pos < 2 || {!(_pos isEqualTypeAll 0)} || {surfaceIsWater _pos}) then {
            diag_log format ["[COIN] radio: order goto of %1 refused, no usable point %2", name _caller, _pos];
            ["refused"] call _reply;
        } else {
            call _nextOrder;
            [_group, _pos, COIN_reinforcementArriveRadius] call COIN_fnc_moveGroup;
            // COIN_fnc_runReinforcement tells the player when a fighter is there
            COIN_radioGoto = [_pos, _caller];
            ["goto", [mapGridPosition _pos]] call _reply;
            diag_log format ["[COIN] radio: %1 orders the reinforcement from %2: go to %3, %4 m", name _caller, _town, mapGridPosition _pos, round (_here distance2D _pos)];
            _done = true;
        };
    };
    case "attack": {
        private _targets = ([true, false] call COIN_fnc_getMilitiaTowns) apply {[(markerPos _x) distance2D _here, _x]};
        if (_targets isEqualTo []) then {
            ["no_target"] call _reply;
            diag_log format ["[COIN] radio: %1 orders the reinforcement from %2: attack, no town of the militia left", name _caller, _town];
        } else {
            _targets sort true;
            (_targets select 0) params ["_distance", "_marker"];
            call _nextOrder;
            // On the way ready to fire at will, there searching and destroying like Liberation's own guerilla
            COIN_radioAttackModes params ["_speed", "_wayBehaviour", "_combat", "_searchBehaviour"];
            private _waypoint = [_group, markerPos _marker, COIN_reinforcementArriveRadius, _speed, _wayBehaviour, _combat] call COIN_fnc_moveGroup;
            _waypoint = _group addWaypoint [markerPos _marker, COIN_radioAttackRadius];
            _waypoint setWaypointType "SAD";
            _waypoint setWaypointBehaviour _searchBehaviour;
            _waypoint = _group addWaypoint [markerPos _marker, COIN_radioAttackRadius];
            _waypoint setWaypointType "CYCLE";
            ["attack", [markerText _marker, round _distance]] call _reply;
            diag_log format ["[COIN] radio: %1 orders the reinforcement from %2: attack %3, %4 m", name _caller, _town, markerText _marker, round _distance];
            _done = true;
        };
    };
    default {
        diag_log format ["[COIN] radio: ERROR - unknown order %1 of %2", _order, name _caller];
        ["refused"] call _reply;
    };
};

_done
