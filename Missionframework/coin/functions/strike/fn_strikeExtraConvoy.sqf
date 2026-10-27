/*
    File: fn_strikeExtraConvoy.sqf
    Author: COIN Liberation

    Description:
        The times of day in the text of the strike task "Intercept arms transport" (ticket 5.16), called by COIN_fnc_runStrikeTask
        when the task is made: the time windows of the plan (seconds after the beginning) as times of day on the game clock
        (COIN_fnc_clockText), added after the four texts every strike task has. Server only.

    Parameter(s):
        _plan      - Plan from COIN_fnc_planStrikeConvoy [ARRAY, defaults to []]
        _startTime - Time (server time) of the beginning [NUMBER, defaults to 0]

    Returns:
        [point 1 from, point 1 to, point 2 from, point 2 to] as "HH:MM" [ARRAY of STRING]
*/

params [
    ["_plan", [], [[]]],
    ["_startTime", 0, [0]]
];

private _clocks = [];
{
    _x params ["_from", "_to"];
    _clocks pushBack ([_startTime - time + _from] call COIN_fnc_clockText);
    _clocks pushBack ([_startTime - time + _to] call COIN_fnc_clockText);
} forEach (_plan param [8, []]);

_clocks
