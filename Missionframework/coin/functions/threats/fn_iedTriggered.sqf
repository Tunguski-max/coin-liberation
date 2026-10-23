/*
    File: fn_iedTriggered.sqf
    Author: COIN Liberation

    Description:
        Does the army set off an IED here? (ticket 4.1a, DESIGN 6) Only BLUFOR (GRLIB_side_friendly) does:
        - a ground vehicle with at least one living BLUFOR crew member within the vehicle radius
          (COIN_iedTriggerVehicleRadius),
        - the foot count or more living BLUFOR soldiers on foot within the foot radius (COIN_iedTriggerFootCount,
          COIN_iedTriggerFootRadius), like Liberation's own IEDs (a lone soldier does not set it off, so he can defuse it).
        Civilians, militia, resistance, aircraft and empty vehicles never do. The remote-triggered IED asks with its
        own values (ticket 4.2b: COIN_iedRemoteRadius, one soldier is enough for the triggerman). Server only (reads
        the units' sides).

    Parameter(s):
        _pos           - Position of the IED [ARRAY]
        _vehicleRadius - Radius for a vehicle in m [NUMBER, defaults to COIN_iedTriggerVehicleRadius]
        _footRadius    - Radius for soldiers on foot in m [NUMBER, defaults to COIN_iedTriggerFootRadius]
        _footCount     - Soldiers on foot needed [NUMBER, defaults to COIN_iedTriggerFootCount]

    Returns:
        true if the army sets it off [BOOL]
*/

params [
    ["_pos", [], [[]]],
    ["_vehicleRadius", COIN_iedTriggerVehicleRadius, [0]],
    ["_footRadius", COIN_iedTriggerFootRadius, [0]],
    ["_footCount", COIN_iedTriggerFootCount, [0]]
];

private _army = {alive _x && {side group _x isEqualTo GRLIB_side_friendly}};

if (((_pos nearEntities ["LandVehicle", _vehicleRadius]) findIf {((crew _x) findIf _army) >= 0}) >= 0) exitWith {true};

(count ((_pos nearEntities ["CAManBase", _footRadius]) select {isNull objectParent _x && _army})) >= _footCount
