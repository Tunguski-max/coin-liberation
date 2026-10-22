/*
    File: fn_initQuestioning.sqf
    Author: COIN Liberation

    Description:
        Client part of the questioning (ticket 3.1, DESIGN 7). Finds out whether this player started in an interpreter
        slot (role description starts with COIN_interpreterRole, the slot class is the riflemen's class), marks the unit
        again after every respawn and gives it the entry "Ask about the militia" in the normal action menu (mouse wheel
        or space bar, like Liberation's own actions): COIN_fnc_addTalkAction, and COIN_fnc_talkTargetLoop picks the
        civilian the entry is for. Called once at the client start.
        For a test in another slot: player setVariable ["COIN_interpreter", true, true] in the debug console.

    Parameter(s):
        NONE

    Returns:
        Questioning was set up [BOOL]
*/

if (!hasInterface) exitWith {false};

private _role = roleDescription player;
COIN_isInterpreterSlot = (_role find COIN_interpreterRole) isEqualTo 0;
COIN_talkTarget = objNull;
COIN_interrogateTarget = objNull;
[player] call COIN_fnc_applyInterpreter;
[player] call COIN_fnc_addTalkAction;
player addEventHandler ["Respawn", {
    params ["_unit"];
    [_unit] call COIN_fnc_applyInterpreter;
    [_unit] call COIN_fnc_addTalkAction;
}];
diag_log format ["[COIN] interpreter: slot ""%1"" (%2), interpreter=%3", _role, typeOf player, COIN_isInterpreterSlot];

[] spawn COIN_fnc_talkTargetLoop;

true
