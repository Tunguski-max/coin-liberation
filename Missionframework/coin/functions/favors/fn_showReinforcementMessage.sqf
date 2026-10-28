/*
    File: fn_showReinforcementMessage.sqf
    Author: COIN Liberation

    Description:
        Client: shows a message about the reinforcement (ticket 5.6, DESIGN 8.1) as a notification and a line in the chat, German or
        else English by the game language. The texts are COIN_reinforcementTexts. Sent by COIN_fnc_runReinforcement to all machines
        with remoteExecCall (no JIP: a message of a moment).

    Parameter(s):
        _key  - "arrived", "left_time", "left_reputation" or "left_wiped" [STRING, defaults to ""]
        _town - The town of the elder, put in for %1 [STRING, defaults to ""]

    Returns:
        The message was shown [BOOL]
*/

params [
    ["_key", "", [""]],
    ["_town", "", [""]]
];

if (!hasInterface) exitWith {false};

private _index = [1, 0] select (language isEqualTo "German");
private _row = [COIN_reinforcementTexts, _key] call COIN_fnc_findByType;
if (_row isEqualTo []) exitWith {
    diag_log format ["[COIN] favors: ERROR - no message text for %1", _key];
    false
};

private _title = COIN_reinforcementTitle select _index;
private _text = format [(_row select 1) select _index, _town];
["Default", [_title, _text]] call BIS_fnc_showNotification;
systemChat format ["%1: %2", _title, _text];

true
