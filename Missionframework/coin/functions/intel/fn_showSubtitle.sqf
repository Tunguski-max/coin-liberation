/*
    File: fn_showSubtitle.sqf
    Author: COIN Liberation

    Description:
        Shows what a civilian or a prisoner says as a subtitle (tickets 3.1 and 3.8): his name and one line per sentence.
        The subtitle stays COIN_answerShowSeconds and fades out; a newer one is not faded out by the timer of an older one.
        Client only.

    Parameter(s):
        _name      - Name of the one who speaks [STRING, defaults to ""]
        _sentences - Sentences, one line each [ARRAY of STRINGs, defaults to []]

    Returns:
        Subtitle was shown [BOOL]
*/

params [
    ["_name", "", [""]],
    ["_sentences", [], [[]]]
];

if (!hasInterface || {_sentences isEqualTo []}) exitWith {false};

"COIN_subtitle" cutText [
    format ["<t size='1.1' color='#e0c070'>%1</t><br/>%2", _name, _sentences joinString "<br/>"],
    "PLAIN DOWN", 0.3, true, true
];

if (!isNil "COIN_subtitleTimer") then {terminate COIN_subtitleTimer};
COIN_subtitleTimer = [] spawn {
    sleep COIN_answerShowSeconds;
    "COIN_subtitle" cutFadeOut 1;
};

true
