/*
    File: fn_addTalkAction.sqf
    Author: COIN Liberation

    Description:
        Adds the entry "Ask about the militia" to the normal action menu of a player unit (ticket 3.1), in Liberation's
        yellow. It shows while COIN_talkTarget is a civilian the interpreter may question (COIN_fnc_talkTargetLoop);
        choosing it sends the question to the server (COIN_fnc_questionCivilian). Actions belong to the unit, so this runs
        at start and after every respawn.

    Parameter(s):
        _unit - Player unit [OBJECT, defaults to objNull]

    Returns:
        Action id [NUMBER], -1 if there was no unit [NUMBER]
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {-1};

private _text = COIN_askMilitiaLabel select ([1, 0] select (language isEqualTo "German"));

_unit addAction [
    format ["<t color='#FFFF00'>%1</t>", _text],
    {
        private _civ = COIN_talkTarget;
        COIN_talkTarget = objNull;
        if (!isNull _civ) then {
            [_civ, player] remoteExecCall ["COIN_fnc_questionCivilian", 2];
        };
    },
    nil, COIN_talkActionPriority, true, true, "",
    "!isNull COIN_talkTarget",
    COIN_talkRange + COIN_talkRangeMargin
]
