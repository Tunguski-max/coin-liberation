/*
    File: fn_showNotification.sqf
    Author: COIN Liberation

    Description:
        Shows a COIN message on this client (ticket 2.14): BIS_fnc_showNotification with the class of
        CfgNotifications (coin\CfgNotifications.hpp), whose texts are keys of the COIN package in stringtable.xml, so
        every client reads it in its own game language (ADR 0026). A nest message names the nest type
        (COIN_nestTypeNames, a key as well). Sent by COIN_fnc_initMessages with remoteExecCall to all machines;
        a dedicated server has no interface and does nothing. With COIN_debug a client logs one line, so the test can see who got it.

    Parameter(s):
        _kind - "nest" (nest destroyed), "camp" (camp cleared), "intel" (new intel, ticket 3.1), "warning" (ticket 3.6) or
                "mortar" (mortar fire on a FOB, ticket 6.7b) [STRING]
        _type - Nest type, for "nest"; name of the FOB, for "mortar" [STRING]

    Returns:
        Message was shown [BOOL]
*/

params [
    ["_kind", "", [""]],
    ["_type", "", [""]]
];

if (!hasInterface) exitWith {false};

private _class = switch (_kind) do {
    case "nest": {"coin_nest_destroyed"};
    case "camp": {"coin_camp_cleared"};
    case "intel": {"coin_intel_new"};
    case "warning": {"coin_intel_warning"};
    case "mortar": {"coin_mortar_attack"};
    default {""};
};
if (_class isEqualTo "") exitWith {false};

private _args = [];
if (_kind isEqualTo "mortar") then {
    _args = [_type];
};
if (_kind isEqualTo "nest") then {
    // The name of the type is a key, localized here on the client; an unknown type shows itself
    private _key = ([COIN_nestTypeNames, _type] call COIN_fnc_findByType) param [1, ""];
    _args = [[_type, localize _key] select (_key isNotEqualTo "")];
};

[_class, _args] call BIS_fnc_showNotification;
if (COIN_debug) then {
    diag_log format ["[COIN] messages: shown %1 message %2", _kind, _args];
};

true
