/*
    File: fn_createDiary.sqf
    Author: COIN Liberation

    Description:
        Adds the COIN information to the player's map diary (map screen, tab "COIN Liberation").
        Players read it in game, so the text is German. Diary records belong to the player unit,
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

_unit createDiaryRecord ["COIN_info", ["Erkennungszeichen", format [
    "<font size='18'>Wer ist wer? Das Kopftuch (Shemag)</font><br/><br/>" +
    "Miliz und Widerstand sehen sich ähnlich. Deshalb tragen alle ihre bewaffneten Kämpfer ein Kopftuch in fester Farbe:<br/><br/>" +
    "<font color='%1' size='16'>ROT: Miliz</font><br/>" +
    "Der Gegner. Immer feindlich. Miliz-Kämpfer mit Helm tragen statt des Tuchs ihren Helm: Wer einen Helm trägt, gehört zur Miliz.<br/><br/>" +
    "<font color='%2' size='16'>GRÜN: Widerstand, feindlich</font><br/>" +
    "Der Ruf bei der Bevölkerung ist schlecht. Der Widerstand kämpft gegen uns und an der Seite der Miliz.<br/><br/>" +
    "<font color='%3' size='16'>BLAU: Widerstand, neutral oder freundlich</font><br/>" +
    "Der Ruf ist nicht schlecht. Blau schießt nicht auf uns. Bei gutem Ruf kämpft der Widerstand an unserer Seite gegen die Miliz, bei mittlerem Ruf hält er sich heraus.<br/><br/>" +
    "<font size='14'>Hinweise</font><br/>" +
    "- Die Farbe wechselt, sobald sich der Ruf ändert. Auch bereits lebende Widerstandskämpfer färben um (nach wenigen Sekunden).<br/>" +
    "- Sinkt der Ruf, kann ein eben noch blauer Kämpfer grün werden. Beim Näherkommen zuerst auf die Farbe achten, dann schießen.",
    _red, _green, _blue
]]];

true
