/*
    File: fn_getPresence.sqf
    Author: COIN Liberation

    Description:
        Everything that makes COIN content spawn nearby (DESIGN 5, ticket 2.3): living players and drones (UAVs) of the
        player side that a player is connected to. A player in a manned aircraft higher than
        COIN_presenceMaxAirHeight above ground does not count, so flying over the map spawns nothing.
        Headless clients never count.
        Called once per check by the spawn loops, which then measure the distance to each nest or camp.

    Parameter(s):
        NONE

    Returns:
        Players and drones that count [ARRAY of OBJECTs]
*/

private _present = (allPlayers - entities "HeadlessClient_F") select {
    private _vehicle = vehicle _x;
    alive _x
    && {!(_vehicle isKindOf "Air") || {((getPosATL _vehicle) select 2) <= COIN_presenceMaxAirHeight}}
};

// Only drones a player is flying (connected to a terminal), not parked or autonomous ones
_present append (allUnitsUAV select {alive _x && {(side _x) isEqualTo GRLIB_side_friendly} && {isUAVConnected _x}});

_present
