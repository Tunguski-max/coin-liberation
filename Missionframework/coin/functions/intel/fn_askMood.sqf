/*
    File: fn_askMood.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter asks a civilian "How do you feel about us?" (ticket 5.3, DESIGN 8). Called by the client
        with remoteExecCall. The same rules as for the question about the militia (COIN_fnc_canQuestion, a little more
        range as the civilian is held), but the civilian may have been questioned before: the mood can be asked as often
        as the interpreter likes. It is no questioning: no mark on the civilian, no cooldown (COIN_fnc_reserveAsking is
        not used), no intel. After a short pause (COIN_questionDelay) the true mood (COIN_fnc_getMood) goes to the
        asking client only. The civilian is held and counts as in a conversation (COIN_talking) until the answer has been read, as
        with the question about the militia, so no second answer overlaps. Switch COIN_enableMood.

    Parameter(s):
        _civ   - Civilian [OBJECT, defaults to objNull]
        _asker - Interpreter [OBJECT, defaults to objNull]

    Returns:
        Question was accepted [BOOL]
*/

params [
    ["_civ", objNull, [objNull]],
    ["_asker", objNull, [objNull]]
];

if (!isServer || {!COIN_enableMood}) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] intel: ERROR - mood question for %1 sent by machine %2, not the owner of %3, refused", _civ, _sender, _asker];
    false
};

if !([_civ, _asker, COIN_talkRange + COIN_talkRangeMargin, true] call COIN_fnc_canQuestion) exitWith {
    diag_log format ["[COIN] intel: mood question of %1 to %2 refused (rules)", name _asker, name _civ];
    false
};

// In a conversation until the answer has been read, like a question about the militia: no second answer overlaps this one
_civ setVariable ["COIN_talking", true, true];
[_civ, _asker, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _civ];

[_civ, _asker] spawn {
    params ["_civ", "_asker"];

    private _minDelay = COIN_questionDelay select 0;
    sleep (_minDelay + random ((COIN_questionDelay select 1) - _minDelay));

    if (alive _civ) then {
        private _mood = [] call COIN_fnc_getMood;
        diag_log format [
            "[COIN] intel: %1 asked %2 (%3) how they feel about us: reputation %4 -> mood %5",
            name _asker, name _civ, typeOf _civ, missionNamespace getVariable ["KP_liberation_civ_rep", 0], _mood
        ];
        [name _civ, _mood] remoteExecCall ["COIN_fnc_showMood", owner _asker];
        sleep COIN_answerReadSeconds;
    };

    [_civ, objNull, 0] remoteExecCall ["COIN_fnc_holdCivilian", _civ];
    _civ setVariable ["COIN_talking", false, true];
};

true
