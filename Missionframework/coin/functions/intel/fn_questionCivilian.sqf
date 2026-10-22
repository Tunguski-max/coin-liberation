/*
    File: fn_questionCivilian.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter asks a civilian about the militia (ticket 3.1, DESIGN 7). Called by the client with
        remoteExecCall. Checks the rules again (COIN_fnc_canQuestion, a little more range as the civilian is held but may
        have drifted), marks the civilian as questioned for good and holds him. After a short pause (COIN_questionDelay)
        the answer is chosen: a nest as COIN_fnc_pickIntelNest says, a true level (rumor, hint, tip) by the weights of
        COIN_intelWeightsMid; lies and the reputation weights come with ticket 3.4. Without an active nest the civilian
        knows nothing. The answer goes to the asking client only, a new intel is announced to everybody
        (COIN_fnc_showNotification, "Neue Intel"). The civilian is released after the answer has been read.

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

if (!isServer) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] intel: ERROR - question for %1 sent by machine %2, not the owner of %3, refused", _civ, _sender, _asker];
    false
};

if !([_civ, _asker, COIN_talkRange + COIN_talkRangeMargin] call COIN_fnc_canQuestion) exitWith {
    diag_log format ["[COIN] intel: question of %1 to %2 refused (rules)", name _asker, name _civ];
    false
};

// Once per civilian, also when he knows nothing
_civ setVariable ["COIN_questioned", true, true];
_civ setVariable ["COIN_talking", true, true];
[_civ, _asker, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _civ];

[_civ, _asker] spawn {
    params ["_civ", "_asker"];

    private _minDelay = COIN_questionDelay select 0;
    sleep (_minDelay + random ((COIN_questionDelay select 1) - _minDelay));

    if (alive _civ) then {
        private _name = name _civ;
        private _level = "nothing";
        private _type = "";
        private _nest = [getPosATL _civ] call COIN_fnc_pickIntelNest;

        if !(_nest isEqualTo []) then {
            private _weights = COIN_intelWeightsMid;
            _level = ["rumor", "hint", "tip"] selectRandomWeighted [_weights select 1, _weights select 2, _weights select 3];
            private _intel = [_nest, _level] call COIN_fnc_createIntel;
            if !(_intel isEqualTo []) then {
                _type = _intel select 5;
                diag_log format [
                    "[COIN] intel: %1 asked %2 (%3): %4 about nest %5 (%6), %7 m away, circle of %8 m at %9 (intel %10)",
                    name _asker, _name, typeOf _civ, _level, _nest select 0, _nest select 1,
                    round ((_nest select 3) distance2D _civ), _intel select 3, _intel select 2, _intel select 0
                ];
                ["intel"] remoteExecCall ["COIN_fnc_showNotification", 0];
            } else {
                _level = "nothing";
            };
        } else {
            diag_log format ["[COIN] intel: %1 asked %2 (%3): no active nest, he knows nothing", name _asker, _name, typeOf _civ];
        };

        [_name, _level, _type] remoteExecCall ["COIN_fnc_showAnswer", owner _asker];
        sleep COIN_answerReadSeconds;
    };

    [_civ, objNull, 0] remoteExecCall ["COIN_fnc_holdCivilian", _civ];
    _civ setVariable ["COIN_talking", false, true];
};

true
