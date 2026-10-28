/*
    File: fn_showFavors.sqf
    Author: COIN Liberation

    Description:
        Debug display of the favors (ticket 5.4, lobby parameter "COIN Debug"): record "Gefälligkeiten" in the map diary, tab
        "COIN Debug", with the stock, the counter and whether it runs, from the published COIN_favorState
        (COIN_fnc_publishFavors). The text is German, players read it. Diary records belong to the player unit: with _create the
        record is made (start and after every respawn), without it the text of the existing record is replaced. Before the server has
        published, the record says so. Client with interface only.

    Parameter(s):
        _unit   - Player unit [OBJECT, defaults to player]
        _create - Make the record first [BOOL, defaults to false]

    Returns:
        Record was written [BOOL]
*/

params [
    ["_unit", player, [objNull]],
    ["_create", false, [false]]
];

if (!hasInterface || {isNull _unit}) exitWith {false};

if (_create) then {
    _unit createDiarySubject ["COIN_debug", "COIN Debug"];
    _unit setVariable ["COIN_favorRecord", _unit createDiaryRecord ["COIN_debug", ["Gefälligkeiten", ""]]];
};

private _record = _unit getVariable ["COIN_favorRecord", diaryRecordNull];
if (isNull _record) exitWith {false};

private _text = "Noch nicht vom Server berechnet.";
if (!isNil "COIN_favorState") then {
    COIN_favorState params ["_stock", "_counter", "_gain", "_max", "_running"];
    // German decimal comma, one digit
    private _minutes = (_counter toFixed 1) regexReplace ["\.", ","];
    _text = format [
        "<font size='18'>Gefälligkeiten: %1 von %2</font><br/>Zähler: %3 von %4 min, %5<br/><br/>Der Zähler läuft nur mit Ruf ab +%6, mindestens einem Spieler und freiem Platz im Vorrat.",
        _stock, _max, _minutes, _gain, ["steht still", "läuft"] select _running, COIN_favorRepThreshold
    ];
};

_unit setDiaryRecordText [["COIN_debug", _record], ["Gefälligkeiten", _text]];

true
