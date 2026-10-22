/*
    File: fn_iedTriggered.sqf
    Author: COIN Liberation

    Description:
        Does the army set off an IED here? (ticket 4.1a, DESIGN 6) Only BLUFOR (GRLIB_side_friendly) does:
        - a ground vehicle with at least one living BLUFOR crew member within COIN_iedTriggerVehicleRadius,
        - a living BLUFOR soldier on foot within COIN_iedTriggerFootRadius.
        Civilians, militia, resistance, aircraft and empty vehicles never do. Server only (reads the units' sides).

    Parameter(s):
        _pos - Position of the IED [ARRAY]

    Returns:
        true if the army sets it off [BOOL]
*/

params [
    ["_pos", [], [[]]]
];

private _army = {alive _x && {side group _x isEqualTo GRLIB_side_friendly}};

if (((_pos nearEntities ["LandVehicle", COIN_iedTriggerVehicleRadius]) findIf {((crew _x) findIf _army) >= 0}) >= 0) exitWith {true};

((_pos nearEntities ["CAManBase", COIN_iedTriggerFootRadius]) findIf {isNull objectParent _x && _army}) >= 0
