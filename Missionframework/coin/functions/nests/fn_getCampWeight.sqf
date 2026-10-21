/*
    File: fn_getCampWeight.sqf
    Author: COIN Liberation

    Description:
        Weight of a nest type for the camps (ticket 2.7, DESIGN 5.1, decision E8): COIN_campsPerNest says how much the
        type adds to the camp capacity and how many camps one nest of it supplies at most. A type without a row weighs 1.

    Parameter(s):
        _type - Nest type, e.g. "command" [STRING]

    Returns:
        Weight [NUMBER]
*/

params [
    ["_type", "", [""]]
];

([COIN_campsPerNest, _type] call COIN_fnc_findByType) param [1, 1]
