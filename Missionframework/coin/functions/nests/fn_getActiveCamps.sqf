/*
    File: fn_getActiveCamps.sqf
    Author: COIN Liberation

    Description:
        The camps that count against the capacity and the weight of their nest (ticket 2.10): state "active" and
        "moving" (will be replaced where it stands now). A "cleared" camp is replaced after a delay, a "retired" one
        is not, neither counts. States are set by COIN_fnc_manageCamps and COIN_fnc_checkCampCleared.

    Parameter(s):
        NONE

    Returns:
        Camps [ARRAY of camps]
*/

if (isNil "COIN_camps") exitWith {[]};

COIN_camps select {(_x select 6) in ["active", "moving"]}
