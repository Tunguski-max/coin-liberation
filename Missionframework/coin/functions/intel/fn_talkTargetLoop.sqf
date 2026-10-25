/*
    File: fn_talkTargetLoop.sqf
    Author: COIN Liberation

    Description:
        Client loop (ticket 3.1): finds the civilian the interpreter may question, the one he looks at from close by
        (COIN_fnc_canQuestion, COIN_talkRange), and keeps him in COIN_talkTarget, which the action menu entry waits for.
        When the interpreter gets a new civilian in his sights, the civilian is told to stand still and watch him for
        COIN_talkHoldSeconds (COIN_fnc_holdCivilian, run where the civilian is local), so he does not walk away while the
        interpreter reaches for the menu. Looking away keeps the hold, it ends by itself or when the question is asked.
        The civilian of "How do you feel about us?" (ticket 5.3, may have been questioned before) is kept in COIN_moodTarget,
        the same civilian unless he is the elder of a town in COIN_locateTarget ("Where do I find the elder?", ticket 5.9a);
        the elder himself is kept in COIN_helpTarget ("Can we help?", ticket 5.9b).
        The same for a prisoner (ticket 3.8, COIN_fnc_canInterrogate) in COIN_interrogateTarget; a prisoner is bound,
        so he is not held. Runs as long as questioning is switched on. Only a player marked as interpreter does any work.

    Parameter(s):
        NONE

    Returns:
        NONE
*/

private _lastHeld = objNull;

while {COIN_enableQuestioning} do {
    private _target = objNull;
    private _moodTarget = objNull;
    private _locateTarget = objNull;
    private _helpTarget = objNull;
    private _prisoner = objNull;

    if (alive player && {player getVariable ["COIN_interpreter", false]}) then {
        private _seen = cursorObject;
        if ([_seen, player] call COIN_fnc_canQuestion) then {
            _target = _seen;
        };
        // The questions that may be asked of a civilian who was questioned before: the mood (ticket 5.3), where the
        // elder is (ticket 5.9a, not of the elder himself) and whether they can help (ticket 5.9b, only of the elder).
        // Each has its own switch
        if ([_seen, player, COIN_talkRange, true] call COIN_fnc_canQuestion) then {
            private _isElder = _seen getVariable ["COIN_elder", false];
            if (COIN_enableMood) then {
                _moodTarget = _seen;
            };
            if (COIN_enableElderLocate && {!_isElder}) then {
                _locateTarget = _seen;
            };
            if (COIN_enableAidTasks && {_isElder}) then {
                _helpTarget = _seen;
            };
        };
        if ([_seen, player] call COIN_fnc_canInterrogate) then {
            _prisoner = _seen;
        };
    };
    COIN_interrogateTarget = _prisoner;
    COIN_talkTarget = _target;
    COIN_moodTarget = _moodTarget;
    COIN_locateTarget = _locateTarget;
    COIN_helpTarget = _helpTarget;

    // Whoever may be asked something stops and watches him once he is in the sights
    private _held = _target;
    {
        if (!isNull _x) exitWith {_held = _x};
    } forEach [_moodTarget, _locateTarget, _helpTarget];
    if !(_held isEqualTo _lastHeld) then {
        _lastHeld = _held;
        if (!isNull _held) then {
            [_held, player, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _held];
        };
    };

    sleep COIN_talkScanInterval;
};
