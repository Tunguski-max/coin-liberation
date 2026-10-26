/*
    File: fn_interrogatePrisoner.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter interrogates a prisoner (ticket 3.8, DESIGN 7, ADR 0011). Called by the client with
        remoteExecCall. Checks the rules again (COIN_fnc_canInterrogate), marks the prisoner as interrogated for good and
        keeps him in the conversation until the answer has been read. After a short pause (COIN_questionDelay) there are
        one or two results (the second with the chance COIN_interrogationSecondChance), each rolled by its own weights
        (COIN_interrogationWeights, they do not depend on the reputation). The first result is never "I know nothing" as
        long as there is a nest to tell of. The nest the results are about: COIN_fnc_pickInterrogationNest, one for both
        results. Each result is made as for a civilian (COIN_fnc_resolveOutcome), a second true hit on the same nest makes
        its circle smaller. The
        answer goes to the asking client only, new intel is announced to everybody once. The cooldown (ticket 3.5) is
        checked before and started by a marker, as for a civilian (COIN_fnc_reserveAsking, COIN_fnc_finishAsking).
        Liberation's intel points for handing him in at the FOB stay as they are.

    Parameter(s):
        _prisoner - Prisoner [OBJECT, defaults to objNull]
        _asker    - Interpreter [OBJECT, defaults to objNull]

    Returns:
        Interrogation was accepted [BOOL]
*/

params [
    ["_prisoner", objNull, [objNull]],
    ["_asker", objNull, [objNull]]
];

if (!isServer) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] intel: ERROR - interrogation of %1 sent by machine %2, not the owner of %3, refused", _prisoner, _sender, _asker];
    false
};

if !([_prisoner, _asker, COIN_talkRange + COIN_talkRangeMargin] call COIN_fnc_canInterrogate) exitWith {
    diag_log format ["[COIN] intel: interrogation of %1 by %2 refused (rules)", name _prisoner, name _asker];
    false
};

private _reservation = [_asker, name _prisoner, true] call COIN_fnc_reserveAsking;
if (_reservation isEqualTo []) exitWith {false};

// Once per prisoner, also when he says nothing
_prisoner setVariable ["COIN_interrogated", true, true];
_prisoner setVariable ["COIN_talking", true, true];

[_prisoner, _asker, _reservation] spawn {
    params ["_prisoner", "_asker", "_reservation"];

    private _minDelay = COIN_questionDelay select 0;
    sleep (_minDelay + random ((COIN_questionDelay select 1) - _minDelay));

    if (alive _prisoner) then {
        private _name = name _prisoner;
        private _count = [1, 2] select (random 1 < COIN_interrogationSecondChance);
        diag_log format [
            "[COIN] intel: %1 interrogates %2 (%3), origin %4: %5 result(s)",
            name _asker, _name, typeOf _prisoner, _prisoner getVariable ["COIN_origin", []], _count
        ];

        // One nest for all results: a second true result only shrinks its circle, a prisoner never names two nests
        private _nest = [_prisoner] call COIN_fnc_pickInterrogationNest;
        private _levels = [];
        private _notifications = [];
        for "_i" from 0 to (_count - 1) do {
            private _weights = COIN_interrogationWeights select _i;
            private _outcome = [_weights, _nest] call COIN_fnc_rollOutcome;
            diag_log format ["[COIN] intel: interrogation result %1: weights %2 -> %3", _i + 1, _weights, _outcome];

            private _result = [_outcome, _nest, _prisoner] call COIN_fnc_resolveOutcome;
            // The first result is never "nothing": a lie or a warning that could not be made becomes a true level
            if (_i isEqualTo 0 && {(_result select 0) isEqualTo "nothing"} && {!(_nest isEqualTo [])}) then {
                _outcome = [[0] + (_weights select [1, 3]) + [0, 0], _nest] call COIN_fnc_rollOutcome;
                diag_log format ["[COIN] intel: first result made nothing, a true level is taken instead -> %1", _outcome];
                _result = [_outcome, _nest, _prisoner] call COIN_fnc_resolveOutcome;
            };

            _result params ["_level", "", "_notify"];
            if !(_notify isEqualTo "") then {
                _levels pushBack _level;
                _notifications pushBackUnique _notify;
            };
        };

        {[_x] remoteExecCall ["COIN_fnc_showNotification", 0]} forEach _notifications;
        if (_levels isEqualTo []) then {
            diag_log format ["[COIN] intel: %1 had nothing to tell", _name];
            _levels = ["nothing"];
        };

        // A marker (also a lie or a warning) starts the cooldown, "I know nothing" does not
        [_asker, _reservation, !(_notifications isEqualTo [])] call COIN_fnc_finishAsking;

        [_name, _levels] remoteExecCall ["COIN_fnc_showInterrogation", owner _asker];
        sleep COIN_answerReadSeconds;

        // Every interrogation: a strike task may arise besides the results (ticket 5.13, DESIGN 8.2)
        private _strike = [_prisoner, _asker] call COIN_fnc_decideStrikeTask;
        if (_strike isNotEqualTo "") then {
            [_prisoner, _asker, _strike] spawn COIN_fnc_offerStrikeTask;
        };
    } else {
        [_asker, _reservation, false] call COIN_fnc_finishAsking;
    };

    _prisoner setVariable ["COIN_talking", false, true];
};

true
