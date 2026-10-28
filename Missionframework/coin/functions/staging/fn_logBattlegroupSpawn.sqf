/*
    File: fn_logBattlegroupSpawn.sqf
    Author: COIN Liberation

    Description:
        Log line for a counterattack that had to start in a staging area (ticket 6.1b, #155, hook 32): which spawn point
        was chosen and which staging area contains it, or that the counterattack is skipped because Liberation found no
        valid spawn point inside a staging area (also logged when it found none for another reason, e.g. all too near
        to or too far from the army's sectors and FOBs, or used by a secondary mission). Nothing is logged for a
        counterattack without the condition (switch off, or the capital as target). Server only.

    Parameter(s):
        _target      - Sector marker the counterattack aims at, "" for a random battlegroup [STRING]
        _spawnPoint  - Spawn point marker Liberation chose, "" if none [STRING]
        _stagingOnly - The condition applied (COIN_fnc_isStagingOnly) [BOOL]

    Returns:
        Log line was written [BOOL]
*/

params [
    ["_target", "", [""]],
    ["_spawnPoint", "", [""]],
    ["_stagingOnly", false, [false]]
];

if (!isServer || {!_stagingOnly}) exitWith {false};

private _what = if (_target isEqualTo "") then {"random battlegroup"} else {format ["counterattack on %1 (%2)", _target, markerText _target]};

if (_spawnPoint isEqualTo "") exitWith {
    diag_log format [
        "[COIN] staging: %1 skipped, no valid spawn point inside a staging area (%2 staging area(s))",
        _what, count ([] call COIN_fnc_getStagingAreas)
    ];
    true
};

diag_log format [
    "[COIN] staging: %1 starts at %2, in %3",
    _what, _spawnPoint,
    (([markerPos _spawnPoint] call COIN_fnc_getStagingAreasAt) apply {[_x] call COIN_fnc_describeStagingArea}) joinString "; "
];
true
