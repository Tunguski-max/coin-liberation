/*
    File: fn_showDocumentsFound.sqf
    Author: COIN Liberation

    Description:
        Client: shows what the search of the courier's car found (ticket 5.14) as a subtitle, in the game
        language (keys of the COIN package, ADR 0026). Sent by COIN_fnc_runStrikeCourier to the player who searched.

    Parameter(s):
        _speaker - Key of the name of who speaks [STRING, defaults to ""]
        _text    - Key of what he says [STRING, defaults to ""]

    Returns:
        The subtitle was shown [BOOL]
*/

params [
    ["_speaker", "", [""]],
    ["_text", "", [""]]
];

if (!hasInterface) exitWith {false};

[[_speaker] call COIN_fnc_text, [[_text] call COIN_fnc_text]] call COIN_fnc_showSubtitle
