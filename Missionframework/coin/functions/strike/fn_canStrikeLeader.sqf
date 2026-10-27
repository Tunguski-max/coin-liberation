/*
    File: fn_canStrikeLeader.sqf
    Author: COIN Liberation

    Description:
        Requirement of the strike task "Arrest leader" (ticket 5.15, DESIGN 8.2): at least one command post is active, as the leader
        belongs to one. Server only.

    Parameter(s):
        NONE

    Returns:
        The kind can be offered now [BOOL]
*/

(!isNil "COIN_nests") && {(COIN_nests findIf {(_x select 1) isEqualTo "command" && {(_x select 5) isEqualTo "active"}}) >= 0}
