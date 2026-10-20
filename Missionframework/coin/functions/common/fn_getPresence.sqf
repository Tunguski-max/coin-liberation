/*
    File: fn_getPresence.sqf
    Author: COIN Liberation

    Description:
        Everything that makes COIN content spawn nearby (DESIGN 5, ticket 2.3): living players and the drone (UAV)
        each player is connected to (getConnectedUAV), below COIN_presenceMaxDroneHeight. A player in a manned
        aircraft higher than COIN_presenceMaxAirHeight above ground does not count, so flying over the map spawns nothing.
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

// The drone each player is connected to (whatever its side, e.g. one placed by Zeus), not parked or autonomous ones.
// Like Liberation's sector activation (KPLIB_fnc_getUnitsCount) only below COIN_presenceMaxDroneHeight above ground
{
    private _uav = getConnectedUAV _x;
    if (!isNull _uav && {alive _uav} && {((getPos _uav) select 2) <= COIN_presenceMaxDroneHeight}) then {
        _present pushBackUnique _uav;
    };
} forEach (allPlayers - entities "HeadlessClient_F");

_present
