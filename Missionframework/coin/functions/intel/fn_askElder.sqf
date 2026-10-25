/*
    File: fn_askElder.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter asks a civilian "Where do I find the elder?" (ticket 5.9a, for large towns). Called by the
        client with remoteExecCall. The same rules as for the question about the mood (COIN_fnc_canQuestion with _mood, a
        civilian questioned before may be asked), but not the elder himself. It is no questioning: no mark on the
        civilian, no cooldown, no intel. After a short pause (COIN_questionDelay) the civilian answers the asking client
        only, and if an elder lives within COIN_elderLocateRange of him, the elder is marked on the map for everybody for
        COIN_elderMarkerSeconds (COIN_fnc_markElder). Without one (the town has none for now, or the civilian is
        elsewhere) he says so. The civilian is held and counts as in a conversation (COIN_talking) until the answer has
        been read. Switch COIN_enableElderLocate.

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

if (!isServer || {!COIN_enableElderLocate}) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] intel: ERROR - elder question for %1 sent by machine %2, not the owner of %3, refused", _civ, _sender, _asker];
    false
};

if (
    !([_civ, _asker, COIN_talkRange + COIN_talkRangeMargin, true] call COIN_fnc_canQuestion)
    || {_civ getVariable ["COIN_elder", false]}
) exitWith {
    diag_log format ["[COIN] intel: elder question of %1 to %2 refused (rules)", name _asker, name _civ];
    false
};

// In a conversation until the answer has been read, like the other questions: no second answer overlaps this one
_civ setVariable ["COIN_talking", true, true];
[_civ, _asker, COIN_talkHoldSeconds] remoteExecCall ["COIN_fnc_holdCivilian", _civ];

[_civ, _asker] spawn {
    params ["_civ", "_asker"];

    private _minDelay = COIN_questionDelay select 0;
    sleep (_minDelay + random ((COIN_questionDelay select 1) - _minDelay));

    if (alive _civ) then {
        // The nearest elder who lives and is not too far away from the civilian
        private _elder = objNull;
        {
            if ((_x distance2D _civ) <= COIN_elderLocateRange && {isNull _elder || {(_x distance2D _civ) < (_elder distance2D _civ)}}) then {
                _elder = _x;
            };
        } forEach (allUnits select {alive _x && {_x getVariable ["COIN_elder", false]}});

        private _result = if (isNull _elder) then {
            format ["no elder within %1 m", COIN_elderLocateRange]
        } else {
            [_elder] call COIN_fnc_markElder;
            format ["%1 (%2 m away), marked for %3 s", name _elder, round (_civ distance2D _elder), COIN_elderMarkerSeconds]
        };
        diag_log format ["[COIN] intel: %1 asked %2 where the elder is: %3", name _asker, name _civ, _result];
        [name _civ, !isNull _elder] remoteExecCall ["COIN_fnc_showElderLocation", owner _asker];
        sleep COIN_answerReadSeconds;
    };

    [_civ, objNull, 0] remoteExecCall ["COIN_fnc_holdCivilian", _civ];
    _civ setVariable ["COIN_talking", false, true];
};

true
