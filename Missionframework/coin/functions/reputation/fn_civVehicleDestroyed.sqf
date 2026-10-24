/*
    File: fn_civVehicleDestroyed.sqf
    Author: COIN Liberation

    Description:
        Reputation for a civilian vehicle destroyed by the army (ticket 5.1, DESIGN 8, ADR 0023). Called from Liberation's
        kill manager (hook in kill_manager.sqf, with COIN_fnc_captiveKilled) with the killer it has worked out. Liberation
        counts such a vehicle in its statistics only. A civilian vehicle is one Liberation counts as such
        (typeOf in civilian_vehicles), empty or with a crew (a dead crew costs its own reputation, from Liberation).
        Costs COIN_repCivVehicleDestroyed when
        - the killer is the army (side of the killer, like Liberation's own rules): what the militia destroys costs nothing,
        - the vehicle was not made by COIN (COIN_isCoinVehicle: VBIED, vehicle of a garage; the vehicles of later tasks set
          it too): it is militia property and not the people's,
        - the army has not seized it (KPLIB_seized): Liberation took the reputation for that, and a vehicle a player has
          got into is seized (GetInMan).
        Reach: only vehicles with Liberation's kill manager get here. That is the civilian patrol vehicles and those placed
        by Zeus; parked civilian cars never had it (Liberation does not count them in its statistics either), and COIN's own
        vehicles are created without it, so the mark is a second line of defence. Config value 0 switches it off. Server only.

    Parameter(s):
        _vehicle - Object that was destroyed, men are ignored [OBJECT, defaults to objNull]
        _killer  - Its killer as Liberation's kill manager has worked it out [OBJECT, defaults to objNull]

    Returns:
        Reputation was changed [BOOL]
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_killer", objNull, [objNull]]
];

// The kill manager can run before the COIN config is loaded
if (!isServer || {isNil "COIN_repCivVehicleDestroyed"} || {COIN_repCivVehicleDestroyed == 0}) exitWith {false};
if (isNull _vehicle || {_vehicle isKindOf "CAManBase"} || {!(typeOf _vehicle in civilian_vehicles)}) exitWith {false};

private _isCoinVehicle = _vehicle getVariable ["COIN_isCoinVehicle", false];
private _isSeized = _vehicle getVariable ["KPLIB_seized", false];
private _byArmy = !isNull _killer && {(side _killer) isEqualTo GRLIB_side_friendly};

if (COIN_debug) then {
    diag_log format [
        "[COIN] reputation: civilian vehicle check %1, killer %2 (side %3), COIN vehicle %4, seized %5 -> costs reputation %6",
        typeOf _vehicle, typeOf _killer, side _killer, _isCoinVehicle, _isSeized, _byArmy && {!_isCoinVehicle} && {!_isSeized}
    ];
};
if (!_byArmy || _isCoinVehicle || _isSeized) exitWith {false};

[COIN_repCivVehicleDestroyed, format ["civilian vehicle %1 destroyed", typeOf _vehicle]] call COIN_fnc_changeReputation
