/*
    File: fn_useFavor.sqf
    Author: COIN Liberation

    Description:
        Server: uses one favor from the stock (ticket 5.4, interface for ticket 5.6 "Reinforcement"). The counter is not changed
        (COIN_fnc_delayFavor throws it back when the group is lost). Writes a line to the RPT. Server only.

    Parameter(s):
        NONE

    Returns:
        A favor was in stock and is used [BOOL]
*/

if (!isServer || {!COIN_enableFavors} || {isNil "COIN_favorStock"}) exitWith {false};

if (COIN_favorStock <= 0) exitWith {
    diag_log "[COIN] favors: no favor in stock, nothing used";
    false
};

COIN_favorStock = COIN_favorStock - 1;
diag_log format ["[COIN] favors: a favor is used, stock %1 of %2, counter %3 min", COIN_favorStock, COIN_favorMaxStored, COIN_favorCounter toFixed 1];
[false] call COIN_fnc_publishFavors;

true
