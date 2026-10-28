/*
    File: fn_getReadinessCap.sqf
    Author: COIN Liberation

    Description:
        Highest combat_readiness the militia may have (ticket 6.6a, #152, ADR 0013, ADR 0025):
        COIN_readinessCapFloor + (100 - COIN_readinessCapFloor) x network strength. At full strength 100 (no effect),
        with no active nest left the floor. Reads the published COIN_networkStrength and COIN_networkCounts, so it works
        on the server (COIN_fnc_readinessCapLoop) and on clients (debug diary, COIN_fnc_showNetworkStrength).
        No cap (-1) as long as the strength is not known (nests not loaded yet, nests or network strength off) and in a
        campaign without any nest (placement failed): its strength 0 would otherwise pull the readiness to the floor.

    Parameter(s):
        NONE

    Returns:
        Cap from COIN_readinessCapFloor to 100, or -1 for no cap [NUMBER]
*/

if (isNil "COIN_networkStrength" || {isNil "COIN_networkCounts"}) exitWith {-1};
if ((COIN_networkCounts select 1) isEqualTo 0) exitWith {-1};

// 100 is the top of Liberation's readiness scale, not a balancing value
COIN_readinessCapFloor + (100 - COIN_readinessCapFloor) * COIN_networkStrength
