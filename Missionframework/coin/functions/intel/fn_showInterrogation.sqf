/*
    File: fn_showInterrogation.sqf
    Author: COIN Liberation

    Description:
        Shows what a prisoner says to the interpreter as a subtitle (ticket 3.8): his name and one sentence per result,
        German or else English by the game language. The sentences come from COIN_interrogationAnswers by the level of
        the result, a prisoner never says the nest type. While the cooldown of the interpreter runs (ticket 3.5) the
        result is "cooldown" and the prisoner puts him off (COIN_interrogationCooldownAnswers). Sent by
        COIN_fnc_interrogatePrisoner to the asking client only.

    Parameter(s):
        _name   - Name of the prisoner [STRING, defaults to ""]
        _levels - Level of each result: "nothing", "cooldown", "rumor", "hint", "tip" or a warning key of COIN_warningKinds ("warning", "warningIED", "warningAmbush") [ARRAY of STRINGs, defaults to []]

    Returns:
        Answer was shown [BOOL]
*/

params [
    ["_name", "", [""]],
    ["_levels", [], [[]]]
];

if (!hasInterface) exitWith {false};

private _index = [1, 0] select (language isEqualTo "German");

private _sentences = [];
{
    // [German sentences, English sentences] of this result
    private _texts = if (_x isEqualTo "cooldown") then {
        COIN_interrogationCooldownAnswers
    } else {
        ([COIN_interrogationAnswers, _x] call COIN_fnc_findByType) param [1, []]
    };
    if (_texts isEqualTo []) then {
        diag_log format ["[COIN] intel: ERROR - no interrogation texts for result %1", _x];
    } else {
        _sentences pushBack selectRandom (_texts select _index);
    };
} forEach _levels;

[_name, _sentences] call COIN_fnc_showSubtitle
