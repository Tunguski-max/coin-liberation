/*
    File: fn_text.sqf
    Author: COIN Liberation

    Description:
        The text of a config entry in the game language (ADR 0026): the key of the COIN package in stringtable.xml, localized on
        this client. A key the stringtable does not know shows itself, so a typo can be seen in the game (COIN_fnc_debugCheckTexts
        looks for them). Used wherever a config table holds a key and the text is read later.

    Parameter(s):
        _key - Key of the stringtable [STRING, defaults to ""]

    Returns:
        The text [STRING], "" for an empty key
*/

params [
    ["_key", "", [""]]
];

private _text = localize _key;
[_text, _key] select (_text isEqualTo "")
