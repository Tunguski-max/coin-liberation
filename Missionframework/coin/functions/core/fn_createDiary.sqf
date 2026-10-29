/*
    File: fn_createDiary.sqf
    Author: COIN Liberation

    Description:
        Adds the COIN information to the player's map diary (map screen, tab "COIN Liberation").
        The texts are keys of the COIN package (ADR 0026), so every player reads them in his language. Diary records belong to the player unit,
        so this is called again after every respawn.

    Parameter(s):
        _unit - Player unit to add the diary to [OBJECT, defaults to player]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_unit", player, [objNull]]
];

if (isNull _unit) exitWith {false};

// Text colors of the headings, matching the shemag colors
private _red = "#ff4d4d";
private _green = "#66cc66";
private _blue = "#4da6ff";

_unit createDiarySubject ["COIN_info", "COIN Liberation"];

_unit createDiaryRecord ["COIN_info", [localize "STR_COIN_diary_idTitle", format [localize "STR_COIN_diary_idText", _red, _green, _blue]]];

true
