/*
    File: fn_showMood.sqf
    Author: COIN Liberation

    Description:
        Shows the mood of the population to the interpreter as a subtitle (ticket 5.3): the name of the civilian and a
        sentence of COIN_moodAnswers for this mood, German or else English by the game language. Sent by
        COIN_fnc_askMood to the asking client only.

    Parameter(s):
        _name - Name of the civilian [STRING, defaults to ""]
        _mood - Mood key, the first column of COIN_moodAnswers [STRING, defaults to ""]

    Returns:
        Answer was shown [BOOL]
*/

params [
    ["_name", "", [""]],
    ["_mood", "", [""]]
];

if (!hasInterface) exitWith {false};

private _texts = ([COIN_moodAnswers, _mood] call COIN_fnc_findByType) param [1, []];

if (_texts isEqualTo []) exitWith {
    diag_log format ["[COIN] intel: ERROR - no mood texts for mood %1", _mood];
    false
};

[_name, [[selectRandom _texts] call COIN_fnc_text]] call COIN_fnc_showSubtitle
