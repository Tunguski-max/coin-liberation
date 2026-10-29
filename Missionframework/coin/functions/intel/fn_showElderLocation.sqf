/*
    File: fn_showElderLocation.sqf
    Author: COIN Liberation

    Description:
        Shows the answer to "Where do I find the elder?" to the interpreter as a subtitle (ticket 5.9a): the name of the
        civilian and a sentence of COIN_elderLocateAnswers, in the game language (keys of the COIN package, ADR 0026). Sent by
        COIN_fnc_askElder to the asking client only.

    Parameter(s):
        _name  - Name of the civilian [STRING, defaults to ""]
        _found - An elder was marked [BOOL, defaults to false]

    Returns:
        Answer was shown [BOOL]
*/

params [
    ["_name", "", [""]],
    ["_found", false, [false]]
];

if (!hasInterface) exitWith {false};

private _key = ["none", "found"] select _found;
private _texts = ([COIN_elderLocateAnswers, _key] call COIN_fnc_findByType) param [1, []];

if (_texts isEqualTo []) exitWith {
    diag_log format ["[COIN] intel: ERROR - no elder location texts for %1", _key];
    false
};

[_name, [[selectRandom _texts] call COIN_fnc_text]] call COIN_fnc_showSubtitle
