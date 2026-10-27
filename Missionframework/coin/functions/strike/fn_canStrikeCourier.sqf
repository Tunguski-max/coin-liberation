/*
    File: fn_canStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        Requirement of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2): at least one nest is active, as the documents
        of the courier name its nest. Server only.

    Parameter(s):
        NONE

    Returns:
        The kind can be offered now [BOOL]
*/

(!isNil "COIN_nests") && {(COIN_nests findIf {(_x select 5) isEqualTo "active"}) >= 0}
