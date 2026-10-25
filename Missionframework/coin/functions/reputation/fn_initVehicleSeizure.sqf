/*
    File: fn_initVehicleSeizure.sqf
    Author: COIN Liberation

    Description:
        Client: a player who gets into a civilian vehicle seizes it, and that costs COIN_repCivVehicleSeized reputation
        (ticket 5.1, DESIGN 8). Liberation means it that way (KPLIB_fnc_setVehicleSeized, penalty
        KP_liberation_cr_vehicle_penalty = 2), but its GetInMan handler in init_client.sqf calls KPLIB_fnc_setVehiclesSeized,
        a name that does not exist, so nothing is ever seized (the same typo is in the upstream repository). Here the
        handler is made again with the right name, on the player and again after every respawn, and Liberation's
        penalty is set from the COIN config (0: seizing is free). Calling Liberation's function keeps its message to
        everybody, the log line, the statistics and the flag KPLIB_seized, which the save, Zeus and
        COIN_fnc_civVehicleDestroyed (a seized vehicle is ours, destroying it costs nothing) rely on. A second call for the
        same vehicle changes nothing, so a fixed upstream handler does no harm. Switch COIN_enableVehicleSeizure. Runs on
        every machine with an interface, once at the start.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!hasInterface) exitWith {false};

// Liberation takes this much (a positive number) when it seizes, the COIN value is a change of the reputation
KP_liberation_cr_vehicle_penalty = 0 max (-COIN_repCivVehicleSeized);

// The handler on the player, and again after every respawn like the other player handlers of COIN. A second handler on
// the same unit does no harm, KPLIB_fnc_setVehicleSeized seizes a vehicle only once
COIN_seizeOnGetIn = {
    params ["", "", "_vehicle"];
    [_vehicle] call KPLIB_fnc_setVehicleSeized;
};
player addEventHandler ["GetInMan", COIN_seizeOnGetIn];
player addEventHandler ["Respawn", {params ["_unit"]; _unit addEventHandler ["GetInMan", COIN_seizeOnGetIn];}];

diag_log format ["[COIN] reputation: vehicle seizure on, getting into a civilian vehicle seizes it, reputation %1", COIN_repCivVehicleSeized];

true
