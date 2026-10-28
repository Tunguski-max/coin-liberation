/*
    File: fn_getLanguageText.sqf
    Author: COIN Liberation

    Description:
        The text of a config table row in the game language, German or else English (tickets 5.6 and 5.19). The table has rows
        [key, [German, English]] like COIN_reinforcementPickTexts and COIN_radioReplyTexts. The texts of the elder and of the aid tasks
        have more columns and are picked where they are used.

    Parameter(s):
        _table - Config table with the key in the first and the texts in the second column [ARRAY of ARRAYs, defaults to []]
        _key   - The row [STRING, defaults to ""]

    Returns:
        The text, "" if the table has no row for the key [STRING]
*/

params [
    ["_table", [], [[]]],
    ["_key", "", [""]]
];

private _row = [_table, _key] call COIN_fnc_findByType;
if (_row isEqualTo []) exitWith {""};

(_row select 1) select ([1, 0] select (language isEqualTo "German"))
