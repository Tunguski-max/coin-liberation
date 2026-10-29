/*
    File: fn_text.sqf
    Author: COIN Liberation

    Description:
        The text of a config entry in the game language (ADR 0026, tickets 7.0b to 7.0d). The entry is either a key of the
        COIN package in stringtable.xml (localized on this client) or, until the module is converted, the old pair
        [German, English] (German if the game language is German, else English). A key the stringtable does not know shows
        itself, so a typo can be seen in the game. The pair branch goes with ticket 7.0d, when no pair is left.

    Parameter(s):
        _text - A key [STRING] or a pair [German, English] [ARRAY]

    Returns:
        The text [STRING]
*/

params [
    ["_text", "", ["", []]]
];

if (_text isEqualType "") exitWith {
    private _localized = localize _text;
    [_localized, _text] select (_localized isEqualTo "")
};

_text select ([1, 0] select (language isEqualTo "German"))
