/*
    File: fn_showAnswer.sqf
    Author: COIN Liberation

    Description:
        Shows the answer of a civilian to the interpreter as a subtitle (ticket 3.1): his name and a sentence, German or
        else English by the game language. The sentences come from COIN_questionAnswers by the result; a hint or a tip
        has them by nest type (COIN_questionAnswersByType), but the civilian never says the type itself. A result without
        sentences gets the rumor sentences. While the cooldown of the interpreter runs (ticket 3.5) the result is "cooldown"
        and the civilian puts the interpreter off (COIN_cooldownAnswers). Sent by
        COIN_fnc_questionCivilian to the asking client only.

    Parameter(s):
        _name  - Name of the civilian [STRING, defaults to ""]
        _level - "nothing", "unsafe", "cooldown", "rumor", "hint", "tip" or "warning" [STRING, defaults to "nothing"]
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

// [German sentences, English sentences] of this result, [] if there are none
private _texts = switch (true) do {
    case (_level isEqualTo "cooldown"): {COIN_cooldownAnswers};
    case (_level in ["hint", "tip"]): {
        private _byType = ([COIN_questionAnswersByType, _level] call COIN_fnc_findByType) param [1, []];
        ([_byType, _type] call COIN_fnc_findByType) param [1, []]
    };
    default {([COIN_questionAnswers, _level] call COIN_fnc_findByType) param [1, []]};
};
// The interpreter must never speak a civilian's rumor sentence in his own name
if (_texts isEqualTo [] && {_level isEqualTo "cooldown"}) exitWith {
    diag_log "[COIN] intel: ERROR - no cooldown texts in COIN_cooldownAnswers";
    false
};
if (_texts isEqualTo []) then {
    diag_log format ["[COIN] intel: ERROR - no answer texts for result %1 (type %2), rumor texts used", _level, _type];
    _texts = ([COIN_questionAnswers, "rumor"] call COIN_fnc_findByType) param [1, []];
};
if (_texts isEqualTo []) exitWith {false};

"COIN_subtitle" cutText [
    format ["<t size='1.1' color='#e0c070'>%1</t><br/>%2", _name, selectRandom (_texts select _index)],
    "PLAIN DOWN", 0.3, true, true
];

// A newer answer must not be faded out by the timer of an older one
if (!isNil "COIN_subtitleTimer") then {terminate COIN_subtitleTimer};
COIN_subtitleTimer = [] spawn {
    sleep COIN_answerShowSeconds;
    "COIN_subtitle" cutFadeOut 1;
};

true
