/*
    File: fn_acceptElderOffer.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter accepts an offer in the elder's dialog (tickets 5.9b and 5.10, DESIGN 8.2). Called by the
        client with remoteExecCall. Checks everything again: the elder, an interpreter close enough, the offer is
        among those that can be accepted now (COIN_fnc_getAidOffers: one task per town, a wait after its end, a limit
        for all towns). Then the aid task is registered for the town and starts (COIN_fnc_runAidTask): a task for the
        whole side with a marker, and a message to all. The elder answers the interpreter. Switch COIN_enableAidTasks.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]
        _asker - Interpreter [OBJECT, defaults to objNull]
        _id    - Id of the offer, the first column of COIN_aidTaskTexts [STRING, defaults to ""]

    Returns:
        The task was started [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_id", "", [""]]
];

if (!isServer || {!COIN_enableAidTasks}) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] elder: ERROR - offer %1 sent by machine %2, not the owner of %3, refused", _id, _sender, _asker];
    false
};

if (
    !(_elder getVariable ["COIN_elder", false])
    || {!([_elder, _asker, COIN_talkRange + COIN_talkRangeMargin, true] call COIN_fnc_canQuestion)}
) exitWith {
    diag_log format ["[COIN] elder: offer %1 of %2 to %3 refused (rules)", _id, name _asker, name _elder];
    false
};

([_elder] call COIN_fnc_getAidOffers) params ["", "_offers"];
private _offer = _offers select {(_x select 0) isEqualTo _id};
if (_offer isEqualTo [] || {!((_offer select 0) select 2)}) exitWith {
    diag_log format [
        "[COIN] elder: offer %1 of %2 refused: %3",
        _id, name _asker, if (_offer isEqualTo []) then {"unknown offer"} else {(_offer select 0) select 3}
    ];
    [_elder, "refused"] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];
    false
};

private _sector = _elder getVariable ["COIN_sector", ""];
if (_sector isEqualTo "") exitWith {
    diag_log format ["[COIN] elder: offer %1 refused, the elder %2 has no town", _id, name _elder];
    false
};
// Where the elder stands; the town may be removed while the task runs, the place stays
private _pos = (COIN_elderSpots getOrDefault [_sector, [getPosATL _elder]]) select 0;

// Registered before it starts, so a second acceptance in the same moment finds the town busy
COIN_aidNextId = COIN_aidNextId + 1;
private _taskId = format ["COIN_aid_%1", COIN_aidNextId];
private _endTime = time + (COIN_aidTaskTimeoutMin * 60);
COIN_aidActive set [_sector, [_id, _taskId, _endTime]];

[_id, _sector, _pos, _taskId, _endTime, name _asker] spawn COIN_fnc_runAidTask;
[_elder, "accepted"] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];

true
