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
        that, he answers himself (result "cooldown") and the civilian stays unquestioned. "I know nothing" and a refusal
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

// Cooldown (ticket 3.5): the interpreter answers himself and the civilian stays unquestioned. The key is the player, not
// his unit, so the respawn does not end it, and a second interpreter has his own
private _key = getPlayerUID _asker;
private _cooldownEnd = if (COIN_enableCooldown) then {COIN_cooldownEnds getOrDefault [_key, 0]} else {0};
if (_cooldownEnd > time) exitWith {
    diag_log format ["[COIN] intel: %1 may not ask yet, cooldown runs for %2 s more (%3 stays unquestioned)", name _asker, round (_cooldownEnd - time), name _civ];
    [name _civ, "cooldown", ""] remoteExecCall ["COIN_fnc_showAnswer", owner _asker];
    false
};
// Until the answer is known the interpreter counts as busy, so a second civilian cannot be asked within the delay.
// The spawn below ends this at once; the time only covers a spawn that never gets there
private _pending = time + (COIN_questionDelay select 1) + COIN_answerReadSeconds;
if (COIN_enableCooldown) then {
    COIN_cooldownEnds set [_key, _pending];
};

// Once per civilian, also when he knows nothing
_civ setVariable ["COIN_questioned", true, true];
_civ setVariable ["COIN_talking", true, true];
[_civ, _asker, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _civ];

[_civ, _asker, _key, _pending] spawn {
    params ["_civ", "_asker", "_key", "_pending"];

    // Ends the busy time again, but only if it is still the one set above (a later question may have set its own)
    private _endPending = {
        if (COIN_enableCooldown && {(COIN_cooldownEnds getOrDefault [_key, 0]) isEqualTo _pending}) then {
            COIN_cooldownEnds deleteAt _key;
        };
    };

    private _minDelay = COIN_questionDelay select 0;
    sleep (_minDelay + random ((COIN_questionDelay select 1) - _minDelay));

    if (alive _civ) then {
        private _name = name _civ;
        private _level = "nothing";
        private _type = "";
        private _nest = [getPosATL _civ] call COIN_fnc_pickIntelNest;

        private _band = [] call COIN_fnc_getReputationBand;
        private _weights = ([COIN_intelWeightsByBand, _band] call COIN_fnc_findByType) param [1, COIN_intelWeightsMid];
        // Weights: [nothing, rumor, hint, tip, warning, lie]
        private _outcome = ["nothing", "rumor", "hint", "tip", "warning", "lie"] selectRandomWeighted _weights;
        // Without an active nest there is nothing to tell and nothing to lie about
        if (
            _nest isEqualTo []
            || {_outcome isEqualTo "lie" && {!COIN_enableLies}}
            || {_outcome isEqualTo "warning" && {!COIN_enableWarnings}}
        ) then {_outcome = "nothing"};
        // Armed enemies close: he refuses before any result counts. He is not used up, the interpreter may ask again later
        if ([_civ] call COIN_fnc_isUnsafe) then {
            _outcome = "unsafe";
            _civ setVariable ["COIN_questioned", false, true];
        };
        diag_log format [
            "[COIN] intel: %1 asked %2 (%3): reputation %4, band %5, weights %6 -> %7",
            name _asker, _name, typeOf _civ, missionNamespace getVariable ["KP_liberation_civ_rep", 0], _band, _weights, _outcome
        ];

        private _intel = [];
        if (_outcome isEqualTo "unsafe") then {_level = "unsafe"};
        switch (_outcome) do {
            case "lie": {_intel = [getPosATL _civ] call COIN_fnc_createLie;};
            case "warning": {_intel = [getPosATL _civ] call COIN_fnc_createWarning;};
            case "rumor";
            case "hint";
            case "tip": {_intel = [_nest, _outcome] call COIN_fnc_createIntel;};
        };

        if !(_intel isEqualTo []) then {
            if (_outcome isEqualTo "warning") then {
                // [id, campId, center, radius]: no level, no type, no cooldown difference
                _level = "warning";
                diag_log format [
                    "[COIN] intel: warning about camp %1, circle of %2 m at %3 (warning %4)",
                    _intel select 1, _intel select 3, _intel select 2, _intel select 0
                ];
                ["warning"] remoteExecCall ["COIN_fnc_showNotification", 0];
            } else {
                // A lie is shown with the level and type it was made with, so it reads like a true answer
                _level = [_outcome, _intel select 4] select (_outcome isEqualTo "lie");
                _type = _intel select 5;
                if (_outcome isEqualTo "lie") then {
                    diag_log format [
                        "[COIN] intel: LIE shown as %1 %2, circle of %3 m at %4, fake point %5 (intel %6)",
                        _level, _type, _intel select 3, _intel select 2, _intel select 6, _intel select 0
                    ];
                } else {
                    diag_log format [
                        "[COIN] intel: %1 about nest %2 (%3), %4 m away, circle of %5 m at %6 (intel %7)",
                        _level, _nest select 0, _nest select 1,
                        round ((_nest select 3) distance2D _civ), _intel select 3, _intel select 2, _intel select 0
                    ];
                };
                ["intel"] remoteExecCall ["COIN_fnc_showNotification", 0];
            };
        } else {
            if (_outcome isEqualTo "warning") then {
                diag_log format ["[COIN] intel: %1 knows of no camp within %2 m, he knows nothing", _name, COIN_warningRange];
            };
        };

        // A marker (also a lie or a warning) starts the cooldown, "I know nothing" and a refusal do not
        if (COIN_enableCooldown && {!(_intel isEqualTo [])}) then {
            COIN_cooldownEnds set [_key, time + COIN_questionCooldown];
            diag_log format ["[COIN] intel: cooldown of %1 started for %2 s", name _asker, COIN_questionCooldown];
        } else {
            call _endPending;
        };

        [_name, _level, _type] remoteExecCall ["COIN_fnc_showAnswer", owner _asker];
        sleep COIN_answerReadSeconds;
    } else {
        call _endPending;
    };

    [_civ, objNull, 0] remoteExecCall ["COIN_fnc_holdCivilian", _civ];
    _civ setVariable ["COIN_talking", false, true];
};

true
