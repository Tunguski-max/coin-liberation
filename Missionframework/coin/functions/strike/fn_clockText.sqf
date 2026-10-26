/*
    File: fn_clockText.sqf
    Author: COIN Liberation

    Description:
        The time of day on the game clock a number of seconds from now, as "HH:MM" (ticket 5.13): a strike task names the
        beginning and the end in game time, which is what the players read on their watches. The clock runs faster than
        real time when the time multiplier is above 1. Server or client.

    Parameter(s):
        _seconds - Seconds from now (server time) [NUMBER, defaults to 0]

    Returns:
        "HH:MM" [STRING]
*/

params [
    ["_seconds", 0, [0]]
];

private _hours = (daytime + (_seconds / 3600) * timeMultiplier) mod 24;
private _h = floor _hours;
private _m = floor ((_hours - _h) * 60);

private _pad = {
    params ["_n"];
    (["", "0"] select (_n < 10)) + str _n
};

format ["%1:%2", [_h] call _pad, [_m] call _pad]
