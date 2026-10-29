/*
    File: fn_debugMortarAttack.sqf
    Author: COIN Liberation

    Description:
        Debug console, server (ticket 6.7a, #158): starts a mortar attack now on the FOB nearest to the player, without
        the chance, the cooldown and the player at the FOB. The FOB must still lie in a staging area and no other
        attack may run, otherwise it refuses with a [COIN] line (and a system chat message). Call it with
        [] call COIN_fnc_debugMortarAttack, or with a FOB position to name the FOB.

    Parameter(s):
        _fob - Position of the FOB, none = the nearest to the player [ARRAY, defaults to []]

    Returns:
        The attack started [BOOL]
*/

params [
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer) exitWith {false};

private _say = {
    params ["_text"];
    diag_log format ["[COIN] debug: mortar attack: %1", _text];
    systemChat format ["[COIN] mortar attack: %1", _text];
};

if (_fob isEqualTo []) then {
    private _pos = if (isNull player) then {[0, 0, 0]} else {getPosATL player};
    _fob = [_pos] call KPLIB_fnc_getNearestFob;
};
if (_fob isEqualTo [] || {_fob isEqualTo [0, 0, 0]}) exitWith {
    ["no FOB found"] call _say;
    false
};

private _name = [_fob] call KPLIB_fnc_getFobName;
private _reason = [_fob, false, true] call COIN_fnc_checkMortarFob;
if (_reason isNotEqualTo "") exitWith {
    [format ["FOB %1: no attack, %2", _name, _reason]] call _say;
    false
};

private _started = [_fob, "debug"] call COIN_fnc_startMortarAttack;
[format ["FOB %1: %2", _name, ["not started, see the log above", "started"] select _started]] call _say;
_started
