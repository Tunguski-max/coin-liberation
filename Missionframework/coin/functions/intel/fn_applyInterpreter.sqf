/*
    File: fn_applyInterpreter.sqf
    Author: COIN Liberation

    Description:
        Marks a player unit as interpreter, or not, from the slot this player started in (COIN_isInterpreterSlot, set by
        COIN_fnc_initQuestioning). Variables of a unit are lost when the player respawns, the slot is not, so this runs
        at start and after each respawn. The variable is public: the server checks it before it answers.
        The slot class (B_Soldier_F) is the same as the riflemen's, so the role cannot be told by class.

    Parameter(s):
        _unit - Player unit [OBJECT, defaults to objNull]

    Returns:
        Unit is an interpreter [BOOL]
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {false};

private _isInterpreter = missionNamespace getVariable ["COIN_isInterpreterSlot", false];
_unit setVariable ["COIN_interpreter", _isInterpreter, true];

_isInterpreter
