/*
    File: fn_getIntelRadius.sqf
    Author: COIN Liberation

    Description:
        Start radius of an intel circle by its level (ticket 3.1, DESIGN 7): COIN_intelRadiusRumor, COIN_intelRadiusHint
        or COIN_intelRadiusTip.

    Parameter(s):
        _level - "rumor", "hint" or "tip" [STRING, defaults to "rumor"]

    Returns:
        Radius in m, 0 for an unknown level [NUMBER]
*/

params [
    ["_level", "rumor", [""]]
];

switch (_level) do {
    case "rumor": {COIN_intelRadiusRumor};
    case "hint": {COIN_intelRadiusHint};
    case "tip": {COIN_intelRadiusTip};
    default {0};
}
