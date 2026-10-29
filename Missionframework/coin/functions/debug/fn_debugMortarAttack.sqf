/*
    File: fn_debugMortarAttack.sqf
    Author: COIN Liberation

    Description:
        Debug console, local host (ticket 6.7a, #158): starts a mortar attack now on the FOB nearest to the player, without
        the chance, the cooldown and the player at the FOB. The FOB must still lie in a staging area and no other
        attack may run, otherwise it refuses with a [COIN] line (and a system chat message). On a dedicated server there is no
        player: pass the position of the FOB. Call it with
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
if (!COIN_enableMortarAttacks) exitWith {
    diag_log "[COIN] debug: mortar attack: COIN_enableMortarAttacks is off";
    systemChat "[COIN] mortar attack: COIN_enableMortarAttacks is off";
    false
};

private _say = {
    params ["_text"];
    diag_log format ["[COIN] debug: mortar attack: %1", _text];
    systemChat format ["[COIN] mortar attack: %1", _text];
};

// Without a FOB position the nearest one to the player; a dedicated server has no player and finds none
if (_fob isEqualTo [] && {!isNull player}) then {
    _fob = [getPosATL player] call KPLIB_fnc_getNearestFob;
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
