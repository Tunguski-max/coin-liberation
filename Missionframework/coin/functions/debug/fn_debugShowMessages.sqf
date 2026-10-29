/*
    File: fn_debugShowMessages.sqf
    Author: COIN Liberation

    Description:
        Debug console, on the machine of a player (ticket 7.0a, #177, ADR 0026): shows every COIN message once, one after the
        other, in the game language of this machine, so the texts of the stringtable can be read without playing the
        event. Nest messages for all nest types, camp, intel, warning, mortar fire (FOB "Test") and the four reinforcement
        messages. A system chat line and a [COIN] line say what is shown. Must be called from a script that can
        sleep (spawn it): [] spawn COIN_fnc_debugShowMessages.

    Parameter(s):
        _pause - Seconds between two messages [NUMBER, defaults to 4]

    Returns:
        Number of messages shown [NUMBER]
*/

params [
    ["_pause", 4, [0]]
];

if (!hasInterface || {!canSuspend}) exitWith {
    diag_log "[COIN] debug: show messages: needs a player and a scheduled call, use [] spawn COIN_fnc_debugShowMessages";
    0
};

private _shown = 0;
private _say = {
    params ["_label"];
    diag_log format ["[COIN] debug: show messages: %1", _label];
    systemChat format ["[COIN] message: %1", _label];
    _shown = _shown + 1;
    sleep _pause;
};

{
    ["nest", _x select 0] call COIN_fnc_showNotification;
    [format ["nest %1", _x select 0]] call _say;
} forEach COIN_nestTypeNames;

{
    [_x select 0, _x select 1] call COIN_fnc_showNotification;
    [format ["%1", _x select 0]] call _say;
} forEach [["camp", ""], ["intel", ""], ["warning", ""], ["mortar", "Test"]];

{
    [_x, "Test town"] call COIN_fnc_showReinforcementMessage;
    [format ["reinforcement %1", _x]] call _say;
} forEach ["arrived", "left_time", "left_reputation", "left_wiped"];

_shown
