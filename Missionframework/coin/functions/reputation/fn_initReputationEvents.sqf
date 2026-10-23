/*
    File: fn_initReputationEvents.sqf
    Author: COIN Liberation

    Description:
        Registers the reputation changes that follow a COIN event (ticket 5.1, ADR 0009, DESIGN 8), like
        COIN_fnc_initMessages does for the messages. Each change goes through COIN_fnc_changeReputation, a config
        value of 0 switches it off (no handler is registered).
        - Nest destroyed (server event COIN_nestDestroyed, raised once per nest by COIN_fnc_destroyNest, any nest type):
          COIN_repNestDestroyed.
        Further events of block 5A (tickets 5.1 to 5.8) are added here. Called once at the server start, before
        any nest can be destroyed. Server only.

    Parameter(s):
        NONE

    Returns:
        Number of handlers registered [NUMBER]
*/

if (!isServer) exitWith {0};

private _on = 0;

if (COIN_repNestDestroyed != 0) then {
    ["COIN_nestDestroyed", {
        params ["_id", "_type"];
        [COIN_repNestDestroyed, format ["nest %1 (%2) destroyed", _id, _type]] call COIN_fnc_changeReputation;
    }] call CBA_fnc_addEventHandler;
    _on = _on + 1;
};

diag_log format ["[COIN] reputation: %1 event handler(s) registered (nest destroyed %2)", _on, COIN_repNestDestroyed];

_on
