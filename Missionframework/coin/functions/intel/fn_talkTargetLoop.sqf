/*
    File: fn_talkTargetLoop.sqf
    Author: COIN Liberation

    Description:
        Client loop (ticket 3.1): finds the civilian the interpreter may question, the one he looks at from close by
        (COIN_fnc_canQuestion, COIN_talkRange), and keeps him in COIN_talkTarget, which the action menu entry waits for.
        When the interpreter gets a new civilian in his sights, the civilian is told to stand still and watch him for
        COIN_talkHoldSeconds (COIN_fnc_holdCivilian, run where the civilian is local), so he does not walk away while the
        interpreter reaches for the menu. Looking away keeps the hold, it ends by itself or when the question is asked.
        Runs as long as questioning is switched on. Only a player marked as interpreter does any work.

    Parameter(s):
        NONE

    Returns:
        NONE
*/

while {COIN_enableQuestioning} do {
    private _target = objNull;

    if (alive player && {player getVariable ["COIN_interpreter", false]}) then {
        private _seen = cursorObject;
        if ([_seen, player] call COIN_fnc_canQuestion) then {
            _target = _seen;
        };
    };

    if !(_target isEqualTo COIN_talkTarget) then {
        COIN_talkTarget = _target;
        if (!isNull _target) then {
            [_target, player, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _target];
        };
    };

    sleep COIN_talkScanInterval;
};
