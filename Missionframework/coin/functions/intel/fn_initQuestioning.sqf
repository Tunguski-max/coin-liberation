/*
    File: fn_initQuestioning.sqf
    Author: COIN Liberation

    Description:
        Client part of the questioning (ticket 3.1, DESIGN 7). Finds out whether this player started in an interpreter
        slot (role description starts with COIN_interpreterRole, the slot class is the riflemen's class), marks the unit
        again after every respawn and adds the ACE interaction at civilians:
        "Talk" (ACE_MainActions) with the question "Ask about the militia" below it. Only an interpreter sees them
        (COIN_fnc_canQuestion). Hovering "Talk" stops the civilian (runOnHover), choosing the question sends it to the
        server (COIN_fnc_questionCivilian). Called once at the client start.
        For a test in another slot: player setVariable ["COIN_interpreter", true, true] in the debug console.

    Parameter(s):
        NONE

    Returns:
        Interaction was added [BOOL]
*/

if (!hasInterface) exitWith {false};

if (!KP_liberation_ace) exitWith {
    diag_log "[COIN] interpreter: ACE not loaded, no interaction added";
    false
};

private _role = roleDescription player;
COIN_isInterpreterSlot = (_role find COIN_interpreterRole) isEqualTo 0;
[player] call COIN_fnc_applyInterpreter;
player addEventHandler ["Respawn", {params ["_unit"]; [_unit] call COIN_fnc_applyInterpreter;}];
diag_log format ["[COIN] interpreter: slot ""%1"" (%2), interpreter=%3", _role, typeOf player, COIN_isInterpreterSlot];

private _german = (language isEqualTo "German");
private _talkText = (COIN_talkLabels select 0) select ([1, 0] select _german);
private _askText = (COIN_talkLabels select 1) select ([1, 0] select _german);

// Hovering the entry (the player is about to ask) stops the civilian. It runs on the civilian's machine, so the
// order is sent there; resent only every few seconds while the entry stays hovered or is clicked again
private _talk = [
    "COIN_talk", _talkText, "",
    {
        params ["_target", "_player"];
        if (time < (_target getVariable ["COIN_holdSent", -1000]) + COIN_talkHoldResend) exitWith {};
        _target setVariable ["COIN_holdSent", time];
        [_target, _player, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _target];
    },
    {
        params ["_target", "_player"];
        [_target, _player] call COIN_fnc_canQuestion
    },
    {}, [], {[0, 0, 0]}, COIN_talkRange, [false, false, false, true, false]
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, ["ACE_MainActions"], _talk, true] call ace_interact_menu_fnc_addActionToClass;

private _ask = [
    "COIN_askMilitia", _askText, "",
    {
        params ["_target", "_player"];
        [_target, _player] remoteExecCall ["COIN_fnc_questionCivilian", 2];
    },
    {
        params ["_target", "_player"];
        [_target, _player] call COIN_fnc_canQuestion
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, ["ACE_MainActions", "COIN_talk"], _ask, true] call ace_interact_menu_fnc_addActionToClass;

true
