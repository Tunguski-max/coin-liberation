/*
    File: fn_canStrikeConvoy.sqf
    Author: COIN Liberation

    Description:
        Requirement of the strike task "Intercept arms transport" (ticket 5.16, DESIGN 8.2): at least one weapons cache is active, as the
        convoy drives to one. Server only.

    Parameter(s):
        NONE

    Returns:
        The kind can be offered now [BOOL]
*/

(!isNil "COIN_nests") && {(COIN_nests findIf {(_x select 1) isEqualTo "cache" && {(_x select 5) isEqualTo "active"}}) >= 0}
