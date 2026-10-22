/*
    File: fn_showNotification.sqf
    Author: COIN Liberation

    Description:
        Shows a COIN message on this client (ticket 2.14): BIS_fnc_showNotification with the class of
        CfgNotifications (coin\CfgNotifications.hpp) in the game language, German or else English. A nest message
        names the nest type (COIN_nestTypeNames). Sent by COIN_fnc_initMessages with remoteExecCall to all machines;
        a dedicated server has no interface and does nothing. With COIN_debug a client logs one line, so the test can see who got it.

    Parameter(s):
        _kind - "nest" (nest destroyed), "camp" (camp cleared) or "intel" (new intel, ticket 3.1) [STRING]
        _type - Nest type, for "nest" [STRING]

    Returns:
        Message was shown [BOOL]
*/

params [
    ["_kind", "", [""]],
    ["_type", "", [""]]
];

if (!hasInterface) exitWith {false};

private _german = (language isEqualTo "German");
private _class = switch (_kind) do {
    case "nest": {"coin_nest_destroyed"};
    case "camp": {"coin_camp_cleared"};
    case "intel": {"coin_intel_new"};
    default {""};
};
if (_class isEqualTo "") exitWith {false};

private _args = [];
if (_kind isEqualTo "nest") then {
    // Unknown type: the type itself
    private _names = ([COIN_nestTypeNames, _type] call COIN_fnc_findByType) param [1, [_type, _type]];
    _args = [_names select ([1, 0] select _german)];
};

[format ["%1_%2", _class, ["en", "de"] select _german], _args] call BIS_fnc_showNotification;
if (COIN_debug) then {
    diag_log format ["[COIN] messages: shown %1 message %2", _kind, _args];
};

true
