/*
    File: fn_publishFavors.sqf
    Author: COIN Liberation

    Description:
        Server: publishes (with COIN_debug only) the stock and the counter of the favors for the debug record (ticket 5.4):
        COIN_favorState = [stock, counter in minutes, minutes per favor, most in stock, the counter runs]. A local host updates its
        own record directly (it gets no published value from itself). Server only.

    Parameter(s):
        _running - The counter runs now [BOOL, defaults to false]

    Returns:
        Nothing
*/

params [
    ["_running", false, [false]]
];

if (!isServer) exitWith {};

COIN_favorState = [COIN_favorStock, COIN_favorCounter, COIN_favorGainMinutes, COIN_favorMaxStored, _running];
// Only the debug record of the players reads it: nothing is sent without COIN_debug
if (COIN_debug) then {publicVariable "COIN_favorState"};

if (hasInterface && {COIN_debug}) then {
    [player] call COIN_fnc_showFavors;
};
