/*
    File: fn_reserveAsking.sqf
    Author: COIN Liberation

    Description:
        The interpreter asks (a civilian, ticket 3.1, or a prisoner, ticket 3.8): checks his cooldown (ticket 3.5) and
        reserves his busy time. While the cooldown runs, the one asked puts him off (result "cooldown", shown under the
        name of the one asked) and the caller leaves him unasked. Otherwise the interpreter counts as busy until the answer
        is known, so a second one cannot be asked within the delay; the time only covers a spawn that never gets to
        COIN_fnc_finishAsking. The key is the player (UID), not his unit, so the respawn does not end the cooldown, and a
        second interpreter has his own. Server only.

    Parameter(s):
        _asker     - Interpreter [OBJECT, defaults to objNull]
        _askedName - Name of the one he asks [STRING, defaults to ""]
        _prisoner  - The one asked is a prisoner, so he answers with his own sentences [BOOL, defaults to false]

    Returns:
        [key, end of the reservation] for COIN_fnc_finishAsking, [] if the cooldown runs [ARRAY]
*/

params [
    ["_asker", objNull, [objNull]],
    ["_askedName", "", [""]],
    ["_prisoner", false, [false]]
];

if (!isServer) exitWith {[]};

private _key = getPlayerUID _asker;
private _cooldownEnd = if (COIN_enableCooldown) then {COIN_cooldownEnds getOrDefault [_key, 0]} else {0};
if (_cooldownEnd > time) exitWith {
    diag_log format ["[COIN] intel: %1 may not ask yet, cooldown runs for %2 s more (%3 stays unasked)", name _asker, round (_cooldownEnd - time), _askedName];
    if (_prisoner) then {
        [_askedName, ["cooldown"]] remoteExecCall ["COIN_fnc_showInterrogation", owner _asker];
    } else {
        [_askedName, "cooldown", ""] remoteExecCall ["COIN_fnc_showAnswer", owner _asker];
    };
    []
};

private _pending = time + (COIN_questionDelay select 1) + COIN_answerReadSeconds;
if (COIN_enableCooldown) then {
    COIN_cooldownEnds set [_key, _pending];
};

[_key, _pending]
