/*
    File: fn_addTalkAction.sqf
    Author: COIN Liberation

    Description:
        Adds the entries "Ask about the militia" (ticket 3.1), "Interrogate" (ticket 3.8), "Where do I find the elder?" (ticket
        5.9a, COIN_locateTarget, COIN_fnc_askElder) and "How do you feel about us?"
        (ticket 5.3, COIN_moodTarget, COIN_fnc_askMood) to the normal action menu of
        a player unit. They look like Liberation's own entries (fn_addActionsPlayer): plain yellow text built the same
        way, no size tag, no on-screen action window, hidden after use. "Ask about the militia" shows while
        COIN_talkTarget is a civilian the interpreter may question, "Interrogate" while COIN_interrogateTarget is a
        prisoner he may interrogate (COIN_fnc_talkTargetLoop); choosing one sends the question to the server
        (COIN_fnc_questionCivilian, COIN_fnc_interrogatePrisoner). Actions belong to the unit, so this runs at start and
        after every respawn.

    Parameter(s):
        _unit - Player unit [OBJECT, defaults to objNull]

    Returns:
        Action ids of the entries [ARRAY of NUMBERs], [] if there was no unit [ARRAY]
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {[]};

private _index = [1, 0] select (language isEqualTo "German");

// [label, variable that holds the target, function on the server]
[
    [COIN_askMilitiaLabel, "COIN_talkTarget", "COIN_fnc_questionCivilian"],
    [COIN_interrogateLabel, "COIN_interrogateTarget", "COIN_fnc_interrogatePrisoner"],
    [COIN_moodLabel, "COIN_moodTarget", "COIN_fnc_askMood"],
    [COIN_elderLocateLabel, "COIN_locateTarget", "COIN_fnc_askElder"]
] apply {
    _x params ["_label", "_targetVar", "_serverFunction"];
    _unit addAction [
        ["<t color='#FFFF00'>", _label select _index, "</t>"] joinString "",
        {
            (_this select 3) params ["_targetVar", "_serverFunction"];
            private _target = missionNamespace getVariable [_targetVar, objNull];
            missionNamespace setVariable [_targetVar, objNull];
            if (!isNull _target) then {
                [_target, player] remoteExecCall [_serverFunction, 2];
            };
        },
        [_targetVar, _serverFunction],
        COIN_talkActionPriority,
        false,
        true,
        "",
        format ["!isNull %1", _targetVar],
        COIN_talkRange + COIN_talkRangeMargin
    ]
}
