/*
    File: fn_showAnswer.sqf
    Author: COIN Liberation

    Description:
        Shows the answer of a civilian to the interpreter as a subtitle (ticket 3.1): his name and a sentence, German or
        else English by the game language, picked from COIN_questionAnswers by the result. A hint or a tip names the
        nest type (%1 in the sentence). Sent by COIN_fnc_questionCivilian to the asking client only.

    Parameter(s):
        _name  - Name of the civilian [STRING, defaults to ""]
        _level - "nothing", "rumor", "hint" or "tip" [STRING, defaults to "nothing"]
        _type  - Nest type, for "hint" and "tip" [STRING, defaults to ""]

    Returns:
        Answer was shown [BOOL]
*/

params [
    ["_name", "", [""]],
    ["_level", "nothing", [""]],
    ["_type", "", [""]]
];

if (!hasInterface) exitWith {false};

private _index = [1, 0] select (language isEqualTo "German");
private _row = [COIN_questionAnswers, _level] call COIN_fnc_findByType;
if (_row isEqualTo []) exitWith {
    diag_log format ["[COIN] intel: ERROR - no answer texts for result %1", _level];
    false
};

private _typeName = ([COIN_nestTypeNames, _type] call COIN_fnc_findByType) param [1, [_type, _type]];
private _sentence = selectRandom ((_row select 1) select _index);
_sentence = format [_sentence, _typeName select _index];

"COIN_subtitle" cutText [
    format ["<t size='1.1' color='#e0c070'>%1</t><br/>%2", _name, _sentence],
    "PLAIN DOWN", 0.3, true, true
];

// A newer answer must not be faded out by the timer of an older one
if (!isNil "COIN_subtitleTimer") then {terminate COIN_subtitleTimer};
COIN_subtitleTimer = [] spawn {
    sleep COIN_answerShowSeconds;
    "COIN_subtitle" cutFadeOut 1;
};

true
