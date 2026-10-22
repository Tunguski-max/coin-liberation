/*
    File: fn_questionCivilian.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter asks a civilian about the militia (ticket 3.1, DESIGN 7). Called by the client with
        remoteExecCall. Checks the rules again (COIN_fnc_canQuestion, a little more range as the civilian is held but may
        have drifted), marks the civilian as questioned for good and holds him. After a short pause (COIN_questionDelay)
        the answer is chosen by the weights of the reputation band (COIN_fnc_getReputationBand, COIN_intelWeightsByBand,
        ticket 3.4): nothing, a true level (rumor, hint, tip) about a nest as COIN_fnc_pickIntelNest says, or a lie
        (COIN_fnc_createLie), which the player cannot tell from a true answer, or a warning of an active camp close by
        (COIN_fnc_createWarning, ticket 3.6; no camp in range = he knows nothing). Without an active nest the civilian
        knows nothing. With armed enemies close
        (COIN_fnc_isUnsafe) he refuses instead, gives no intel and can be asked again later. The answer goes to the
        asking client only, a new intel is announced to everybody (COIN_fnc_showNotification, "Neue Intel"). The
        civilian is released after the answer has been read.
        Cooldown (ticket 3.5): a marker (also a lie) makes the interpreter wait COIN_questionCooldown s. If he asks before
        that, the civilian puts him off (result "cooldown") and stays unquestioned. "I know nothing" and a refusal
        start no cooldown. Kept per player UID in COIN_cooldownEnds, not saved.

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

// Cooldown (ticket 3.5): the civilian puts the interpreter off and stays unquestioned
private _reservation = [_asker, name _civ] call COIN_fnc_reserveAsking;
if (_reservation isEqualTo []) exitWith {false};

// Once per civilian, also when he knows nothing
_civ setVariable ["COIN_questioned", true, true];
_civ setVariable ["COIN_talking", true, true];
[_civ, _asker, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _civ];

[_civ, _asker, _reservation] spawn {
    params ["_civ", "_asker", "_reservation"];

    private _minDelay = COIN_questionDelay select 0;
    sleep (_minDelay + random ((COIN_questionDelay select 1) - _minDelay));

    if (alive _civ) then {
        private _name = name _civ;
        private _nest = [getPosATL _civ] call COIN_fnc_pickIntelNest;

        private _band = [] call COIN_fnc_getReputationBand;
        private _weights = ([COIN_intelWeightsByBand, _band] call COIN_fnc_findByType) param [1, COIN_intelWeightsMid];
        // Weights: [nothing, rumor, hint, tip, warning, lie]
        private _outcome = [_weights, _nest] call COIN_fnc_rollOutcome;
        // Armed enemies close: he refuses before any result counts. He is not used up, the interpreter may ask again later
        if ([_civ] call COIN_fnc_isUnsafe) then {
            _outcome = "unsafe";
            _civ setVariable ["COIN_questioned", false, true];
        };
        diag_log format [
            "[COIN] intel: %1 asked %2 (%3): reputation %4, band %5, weights %6 -> %7",
            name _asker, _name, typeOf _civ, missionNamespace getVariable ["KP_liberation_civ_rep", 0], _band, _weights, _outcome
        ];

        ([_outcome, _nest, _civ] call COIN_fnc_resolveOutcome) params ["_level", "_type", "_notify"];
        if (_outcome isEqualTo "unsafe") then {_level = "unsafe"};
        if !(_notify isEqualTo "") then {
            [_notify] remoteExecCall ["COIN_fnc_showNotification", 0];
        };

        // A marker (also a lie or a warning) starts the cooldown, "I know nothing" and a refusal do not
        [_asker, _reservation, !(_notify isEqualTo "")] call COIN_fnc_finishAsking;

        [_name, _level, _type] remoteExecCall ["COIN_fnc_showAnswer", owner _asker];
        sleep COIN_answerReadSeconds;
    } else {
        [_asker, _reservation, false] call COIN_fnc_finishAsking;
    };

    [_civ, objNull, 0] remoteExecCall ["COIN_fnc_holdCivilian", _civ];
    _civ setVariable ["COIN_talking", false, true];
};

true
