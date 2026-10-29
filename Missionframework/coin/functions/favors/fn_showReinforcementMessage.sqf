/*
    File: fn_showReinforcementMessage.sqf
    Author: COIN Liberation

    Description:
        Client: shows a message about the reinforcement (ticket 5.6, DESIGN 8.1): BIS_fnc_showNotification with the class
        coin_reinforcement_<key> of CfgNotifications (coin\CfgNotifications.hpp, texts are keys of the COIN package, ADR 0026) in the
        game language, like COIN_fnc_showNotification, and the same line in the chat. Sent by COIN_fnc_runReinforcement to all machines with
        remoteExecCall (no JIP: a message of a moment).

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

private _class = format ["coin_reinforcement_%1", _key];
private _config = missionConfigFile >> "CfgNotifications" >> _class;
if (!isClass _config) exitWith {
    diag_log format ["[COIN] favors: ERROR - no notification class %1", _class];
    false
};

[_class, [_town]] call BIS_fnc_showNotification;
// The chat keeps the line when the notification is gone
systemChat format ["%1: %2", getText (_config >> "title"), format [getText (_config >> "description"), _town]];

true
