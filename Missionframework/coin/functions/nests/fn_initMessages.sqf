/*
    File: fn_initMessages.sqf
    Author: COIN Liberation

    Description:
        Messages to all players when the militia network loses something (ticket 2.14, DESIGN 5 and 5.1), like
        Liberation's message for a lost FOB: a notification on every client (COIN_fnc_showNotification).
        - Nest destroyed (server event COIN_nestDestroyed, once per nest): the nest type, no position.
          Switch COIN_enableNestMessage.
        - Camp cleared (server event COIN_campCleared, once per camp): no position and no hint to its nest, because
          the trail from camp to nest is intel (Phase 3). Switch COIN_enableCampMessage.
        A camp that moves, is replaced or retired raises no event, a core object deleted by Zeus no destruction, so
        none of these send a message. Players who join later get nothing (no JIP). With COIN_debug each camp event is
        also written to the RPT, and each client logs the message it shows. Called once at the server start. Server only.

    Parameter(s):
        NONE

    Returns:
        Number of messages switched on [NUMBER]
*/

if (!isServer) exitWith {0};

private _on = 0;

if (COIN_enableNestMessage) then {
    ["COIN_nestDestroyed", {
        params ["", "_type"];
        ["nest", _type] remoteExecCall ["COIN_fnc_showNotification", 0];
    }] call CBA_fnc_addEventHandler;
    _on = _on + 1;
};

// One line per event, independent of the message switch, so the test can see it comes exactly once per camp
// (the nest event has its line in COIN_fnc_initNests)
if (COIN_debug) then {
    ["COIN_campCleared", {
        params ["_id", "_nestId", "_pos"];
        diag_log format ["[COIN] camps: event COIN_campCleared for camp %1 (nest %2) at %3", _id, _nestId, _pos];
    }] call CBA_fnc_addEventHandler;
};

if (COIN_enableCampMessage) then {
    ["COIN_campCleared", {
        ["camp"] remoteExecCall ["COIN_fnc_showNotification", 0];
    }] call CBA_fnc_addEventHandler;
    _on = _on + 1;
};

diag_log format ["[COIN] messages: nest message %1, camp message %2", COIN_enableNestMessage, COIN_enableCampMessage];

_on
