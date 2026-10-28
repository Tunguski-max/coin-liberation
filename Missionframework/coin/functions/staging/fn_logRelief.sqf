/*
    File: fn_logRelief.sqf
    Author: COIN Liberation
    Description:
        Log line for the end of a relief that was waiting for its time (ticket 6.1c, #156, hook 33): called (Liberation's
        report goes out, the patrols turn to the sector) or lapsed (source gone, sector captured or no longer
        attacked). Nothing for a relief from a radio tower (switch off). Server only.

    Parameter(s):
        _sector - Marker of the sector under attack [STRING]
        _relief - Result of COIN_fnc_getRelief [ARRAY]
        _called - The relief was called [BOOL]

    Returns:
        Log line was written [BOOL]
*/

params [
    ["_sector", "", [""]],
    ["_relief", [], [[]], 3],
    ["_called", false, [false]]
];

if (!isServer || {((_relief select 1) select 0) isEqualTo "tower"}) exitWith {false};

diag_log format [
    "[COIN] staging: relief for %1 (%2) %3 (source %4)",
    _sector, markerText _sector,
    ["lapsed: source gone, sector captured or no longer attacked", "called, patrols turn to the sector, no paratroopers"] select _called,
    _relief select 1
];
true
