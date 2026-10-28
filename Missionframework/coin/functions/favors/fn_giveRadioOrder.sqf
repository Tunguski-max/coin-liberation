/*
    File: fn_giveRadioOrder.sqf
    Author: COIN Liberation

    Description:
        Client: the player chose a radio order for the reinforcement in the communication menu (ticket 5.19, DESIGN 8.1; the expression of
        CfgCommunicationMenu.hpp). "follow" and "attack" go to the server as they are. "goto" asks for the point on the map first
        (COIN_fnc_pickMapPoint, no circle, Esc cancels and nothing is sent). The server checks the player and the order again
        (COIN_fnc_radioOrder) and answers with a radio message. Must be spawned.

    Parameter(s):
        _caller - The player [OBJECT, defaults to objNull]
        _order  - "follow", "goto" or "attack" [STRING, defaults to ""]

    Returns:
        The order was sent to the server [BOOL]
*/

params [
    ["_caller", objNull, [objNull]],
    ["_order", "", [""]]
];

if (COIN_debug) then {diag_log format ["[COIN] radio: menu item %1 chosen by %2", _order, name _caller]};
if (!hasInterface || {_caller isNotEqualTo player}) exitWith {false};
if (!canSuspend) exitWith {_this spawn COIN_fnc_giveRadioOrder; true};

// The menu may be a moment behind the server
if (!(missionNamespace getVariable ["COIN_reinforcementOn", false]) || {!([_caller] call COIN_fnc_canGiveRadioOrder)}) exitWith {
    if (COIN_debug) then {diag_log format ["[COIN] radio: order %1 of %2 not sent, no reinforcement on its way or not allowed", _order, name _caller]};
    false
};

private _pos = [];
if (_order isEqualTo "goto") then {
    // The map is open once: a second click on the menu item while it picks does nothing (the position stays empty)
    if !(missionNamespace getVariable ["COIN_radioPicking", false]) then {
        COIN_radioPicking = true;
        _pos = [getPosATL _caller, 0, objNull, "start_radio"] call COIN_fnc_pickMapPoint;
        COIN_radioPicking = false;
    };
};
if (_order isEqualTo "goto" && {_pos isEqualTo []}) exitWith {false};

[_caller, _order, _pos] remoteExecCall ["COIN_fnc_radioOrder", 2];

true
