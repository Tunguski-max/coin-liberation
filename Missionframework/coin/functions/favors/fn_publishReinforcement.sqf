/*
    File: fn_publishReinforcement.sqf
    Author: COIN Liberation

    Description:
        Server: tells all machines whether a reinforcement is on its way (ticket 5.19): COIN_reinforcementOn, a small public variable
        that the radio menu of the players follows (COIN_fnc_updateRadio, also for a late joiner). Called when the reinforcement
        comes (COIN_fnc_requestReinforcement) and when it ends (COIN_fnc_runReinforcement). A local host updates its own menu
        directly (it gets no published value from itself). Server only.

    Parameter(s):
        _on - A reinforcement is on its way [BOOL, defaults to false]

    Returns:
        Nothing
*/

params [
    ["_on", false, [false]]
];

if (!isServer) exitWith {};

COIN_reinforcementOn = _on;
publicVariable "COIN_reinforcementOn";

if (hasInterface) then {
    [] call COIN_fnc_updateRadio;
};
