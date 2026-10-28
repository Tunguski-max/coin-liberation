/*
    File: fn_delayFavor.sqf
    Author: COIN Liberation

    Description:
        Server: throws the counter of the favors back by COIN_favorLossCooldownMin minutes (ticket 5.4, interface for ticket 5.6: the
        next favor comes that much later when the reinforcement was wiped out, DESIGN 8.1). The counter may go below 0. Writes a line
        to the RPT. Server only.

    Parameter(s):
        NONE

    Returns:
        The counter in minutes [NUMBER]
*/

if (!isServer || {!COIN_enableFavors} || {isNil "COIN_favorCounter"}) exitWith {0};

COIN_favorCounter = COIN_favorCounter - COIN_favorLossCooldownMin;
diag_log format ["[COIN] favors: the counter is thrown back by %1 min to %2 min", COIN_favorLossCooldownMin, COIN_favorCounter toFixed 1];
[false] call COIN_fnc_publishFavors;

COIN_favorCounter
