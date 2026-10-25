/*
    File: fn_initReputationEvents.sqf
    Author: COIN Liberation

    Description:
        Registers the reputation changes that follow a COIN event (ticket 5.1, ADR 0009, DESIGN 8), like
        COIN_fnc_initMessages does for the messages. Each change goes through COIN_fnc_changeReputation, a config
        value of 0 switches it off (no handler is registered).
        - Nest destroyed (server event COIN_nestDestroyed, raised once per nest by COIN_fnc_destroyNest, any nest type):
          COIN_repNestDestroyed.
        - Prisoner (ACE: handcuffed or surrendered): remembers the state of a living unit in COIN_prisonerState, because ACE
          clears isHandcuffed when the unit dies and COIN_fnc_captiveKilled needs it then. Only while COIN_repCaptiveKilled
          is not 0.
        Further events of block 5A (tickets 5.1 to 5.3) are added here. Called once at the server start, before
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

if (COIN_repCaptiveKilled != 0) then {
    // Global event of ACE after every change, [unit, state, reason, caller]; only the server needs the memory
    ["ace_captiveStatusChanged", {
        params ["_unit"];
        if (alive _unit) then {
            _unit setVariable ["COIN_prisonerState", (_unit getVariable ["ace_captives_isHandcuffed", false]) || {_unit getVariable ["ace_captives_isSurrendering", false]}];
        };
    }] call CBA_fnc_addEventHandler;
    _on = _on + 1;
};

diag_log format ["[COIN] reputation: %1 event handler(s) registered (nest destroyed %2, prisoner killed %3)", _on, COIN_repNestDestroyed, COIN_repCaptiveKilled];

_on
