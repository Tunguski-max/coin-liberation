/*
    File: fn_countCoinUnits.sqf
    Author: COIN Liberation

    Description:
        Counts the living COIN units (marked by COIN_fnc_markCoinUnits) that Liberation counts as well:
        Liberation's KPLIB_fnc_getOpforCap counts every unit on the enemy side. A captured COIN unit has left
        that side and drops out of both counts (ADR 0015, ticket 2.13).

    Parameter(s):
        NONE

    Returns:
        Number of COIN units on the enemy side [NUMBER]
*/

{(side _x) isEqualTo GRLIB_side_enemy && {_x getVariable ["COIN_isCoinUnit", false]}} count allUnits
