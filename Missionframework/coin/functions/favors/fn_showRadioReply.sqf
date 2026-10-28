/*
    File: fn_showRadioReply.sqf
    Author: COIN Liberation

    Description:
        Client: the radio answers a player who gave an order to the reinforcement (ticket 5.19, DESIGN 8.1): a line in the chat that starts
        with the call sign COIN_radioCallsign, German or else English by the game language. The texts are COIN_radioReplyTexts. Sent by
        COIN_fnc_radioOrder to the machine of the one who gave the order only.

    Parameter(s):
        _key  - The answer, the first column of COIN_radioReplyTexts [STRING, defaults to ""]
        _args - What is put in for %1, %2 of the text [ARRAY, defaults to []]

    Returns:
        The answer was shown [BOOL]
*/

params [
    ["_key", "", [""]],
    ["_args", [], [[]]]
];

if (!hasInterface) exitWith {false};

private _text = [COIN_radioReplyTexts, _key] call COIN_fnc_getLanguageText;
if (_text isEqualTo "") exitWith {
    diag_log format ["[COIN] radio: ERROR - no answer text for %1", _key];
    false
};

private _index = [1, 0] select (language isEqualTo "German");
systemChat format ["%1: %2", COIN_radioCallsign select _index, format ([_text] + _args)];

true
