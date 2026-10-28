/*
    File: fn_initReadinessEvents.sqf
    Author: COIN Liberation

    Description:
        Registers the readiness changes that follow a COIN event (ticket 6.6b, #153, ADR 0013), like
        COIN_fnc_initReputationEvents does for the reputation.
        - Nest destroyed (server event COIN_nestDestroyed, raised once per nest by COIN_fnc_destroyNest): combat_readiness
          falls at once by the value of the nest type in COIN_nestReadinessDrop. Zeus
          deleting the core object is no destruction and raises no event. A type without a row, or with 0, drops nothing.
        Registered only while COIN_enableNestReadinessDrop is true, decided once at the server start (no effect at
        runtime, unlike the cap loop). Called before COIN_fnc_initNests is spawned. Server only.

    Parameter(s):
        NONE

    Returns:
        Number of handlers registered [NUMBER]
*/

if (!isServer) exitWith {0};

if (!COIN_enableNestReadinessDrop) exitWith {
    diag_log "[COIN] readiness: drop for a destroyed nest off, Liberation's readiness stays";
    0
};

["COIN_nestDestroyed", {
    params ["_id", "_type"];
    private _drop = (([COIN_nestReadinessDrop, _type] call COIN_fnc_findByType) param [1, 0]);
    if (_drop > 0) then {
        [_drop, format ["nest %1 (%2) destroyed", _id, _type]] call COIN_fnc_lowerReadiness;
    };
}] call CBA_fnc_addEventHandler;

diag_log "[COIN] readiness: 1 event handler registered (nest destroyed)";

1
