/*
    File: fn_showCourierFound.sqf
    Author: COIN Liberation

    Description:
        Client: shows what the search of the courier's car found (ticket 5.14) as a subtitle, German or else English by the game
        language. Sent by COIN_fnc_runStrikeCourier to the player who searched.

    Parameter(s):
        _speaker - Who speaks, [German, English] [ARRAY, defaults to ["", ""]]
        _text    - What he says, [German, English] [ARRAY, defaults to ["", ""]]

    Returns:
        The subtitle was shown [BOOL]
*/

params [
    ["_speaker", ["", ""], [[]]],
    ["_text", ["", ""], [[]]]
];

if (!hasInterface) exitWith {false};

private _index = [1, 0] select (language isEqualTo "German");

[_speaker select _index, [_text select _index]] call COIN_fnc_showSubtitle
