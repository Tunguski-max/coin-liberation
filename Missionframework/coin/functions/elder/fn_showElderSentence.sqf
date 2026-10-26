/*
    File: fn_showElderSentence.sqf
    Author: COIN Liberation

    Description:
        Client: the elder says a sentence to the interpreter as a subtitle (tickets 5.9b and 5.10): a random sentence of
        COIN_elderSentences for the key, German or else English by the game language, under his name. Keys: "busy" (the town
        runs or waits for an aid task, on opening the dialog), "accepted" (the interpreter accepted a task), "refused"
        (the server refused the offer), "site" (ticket 5.21: where the aid task plays, %1 is the name of the village). Sent by the
        server with remoteExecCall, or called by the dialog.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]
        _key   - Which sentence, the first column of COIN_elderSentences [STRING, defaults to ""]
        _place - Name of the village, put in for %1 of the sentence [STRING, defaults to ""]
        _extraKey - Key of a second sentence, a second line under the first (ticket 5.22: "danger", the vague warning) [STRING, defaults to ""]

    Returns:
        The sentence was shown [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_key", "", [""]],
    ["_place", "", [""]],
    ["_extraKey", "", [""]]
];

if (!hasInterface) exitWith {false};

private _index = [1, 0] select (language isEqualTo "German");
private _texts = ([COIN_elderSentences, _key] call COIN_fnc_findByType) param [1, []];

if (_texts isEqualTo []) exitWith {
    diag_log format ["[COIN] elder: ERROR - no elder sentences for %1", _key];
    false
};

private _lines = [format [selectRandom (_texts select _index), _place]];

// A second line under the first, e.g. the vague warning of an ambush at the site
if (_extraKey isNotEqualTo "") then {
    private _extra = ([COIN_elderSentences, _extraKey] call COIN_fnc_findByType) param [1, []];
    if (_extra isNotEqualTo []) then {
        _lines pushBack (selectRandom (_extra select _index));
    };
};

[name _elder, _lines] call COIN_fnc_showSubtitle
