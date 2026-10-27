/*
    File: fn_acceptStrikeTask.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter accepts the strike task that was offered to him (tickets 5.13 and 5.14, DESIGN 8.2). Called
        by the client with remoteExecCall from the dialog. Checks everything again: the offer exists for this player (it is
        used up now), is the one named, has not run out (COIN_strikeOfferSeconds) and fewer than COIN_strikeTaskMaxActive
        run. The plan of the kind (start and destination, COIN_strikeKinds) was made with the offer (COIN_fnc_decideStrikeTask), the beginning is rolled in
        COIN_strikeTaskDelayMin minutes from now and the end in COIN_strikeTaskWindowMin minutes from now (the end is later
        than the beginning). The task goes into COIN_strikeActive and runs (COIN_fnc_runStrikeTask); the one who told of it
        answers. Nothing is saved. Switch COIN_enableStrikeTasks.

    Parameter(s):
        _speaker - Civilian or prisoner who told of it [OBJECT, defaults to objNull]
        _asker   - Interpreter [OBJECT, defaults to objNull]
        _id      - Kind of strike task, a key of COIN_strikeKinds [STRING, defaults to ""]

    Returns:
        The task was started [BOOL]
*/

params [
    ["_speaker", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_id", "", [""]]
];

if (!isServer || {!COIN_enableStrikeTasks}) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] strike: ERROR - strike task %1 accepted by machine %2, not the owner of %3, refused", _id, _sender, _asker];
    false
};

private _uid = getPlayerUID _asker;
private _offer = COIN_strikeOffers getOrDefault [_uid, []];
COIN_strikeOffers deleteAt _uid;
if (_offer isEqualTo [] || {(_offer select 0) != _id} || {time > (_offer select 1)}) exitWith {
    diag_log format ["[COIN] strike: %1 accepted %2 without a valid offer (%3), refused", name _asker, _id, _offer];
    false
};

// A task that should have ended long ago (its run broke off) does not block the limit for ever
COIN_strikeActive = COIN_strikeActive select {time <= (_x select 2) + COIN_aidTaskEndShowSeconds};
if (count COIN_strikeActive >= COIN_strikeTaskMaxActive) exitWith {
    diag_log format ["[COIN] strike: %1 accepted %2, but %3 strike task(s) run already, refused", name _asker, _id, count COIN_strikeActive];
    false
};

private _row = [COIN_strikeKinds, _id] call COIN_fnc_findByType;
if (_row isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: ERROR - unknown kind %1, refused", _id];
    false
};

// The plan was made when the strike task was offered
private _plan = _offer param [2, []];
if (_plan isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: ERROR - the offer of %1 for %2 has no plan, refused", _id, name _asker];
    false
};

// A strike task that took the place of the intel of a questioning begins sooner
([COIN_strikeTaskDelayMin, COIN_strikeTaskDelayMinFast] select (_offer param [3, false])) params ["_delayMin", "_delayMax"];
COIN_strikeTaskWindowMin params ["_windowMin", "_windowMax"];
private _delay = _delayMin + random (_delayMax - _delayMin);
// The window is at least a little longer than the wait for the beginning
private _window = (_windowMin + random (_windowMax - _windowMin)) max (_delay + 1);

COIN_strikeNextId = COIN_strikeNextId + 1;
private _taskId = format ["COIN_strike_%1", COIN_strikeNextId];
// Registered before it starts, so a second acceptance in the same moment finds the limit reached
private _endTime = time + (_window * 60);
COIN_strikeActive pushBack [_taskId, _id, _endTime];

[_row, _plan, _taskId, time + (_delay * 60), _endTime, name _asker] spawn COIN_fnc_runStrikeTask;
[_speaker, "strike_accepted"] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];

true
