/*
    File: fn_askElderHelp.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter asks the elder "Can we help?" (ticket 5.9b, DESIGN 8). Called by the client with
        remoteExecCall. Checks the rules again (the elder, an interpreter close enough, COIN_fnc_canQuestion with the
        rules of the mood question), collects what the elder offers now (COIN_fnc_getAidOffers) and sends it to the
        asking client, which opens the dialog (COIN_fnc_openElderDialog). Switch COIN_enableAidTasks.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]
        _asker - Interpreter [OBJECT, defaults to objNull]

    Returns:
        The dialog was sent [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_asker", objNull, [objNull]]
];

if (!isServer || {!COIN_enableAidTasks}) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] elder: ERROR - help question for %1 sent by machine %2, not the owner of %3, refused", _elder, _sender, _asker];
    false
};

if (
    !(_elder getVariable ["COIN_elder", false])
    || {!([_elder, _asker, COIN_talkRange + COIN_talkRangeMargin, true] call COIN_fnc_canQuestion)}
) exitWith {
    diag_log format ["[COIN] elder: help question of %1 to %2 refused (rules)", name _asker, name _elder];
    false
};

([_elder] call COIN_fnc_getAidOffers) params ["_busy", "_offers", "_active"];
diag_log format [
    "[COIN] elder: %1 asked %2 if they can help: %3 tasks running, %4 offered, town %5",
    name _asker, name _elder, _active, count (_offers select {_x select 2}), ["is free", "is busy"] select (_busy isNotEqualTo "")
];

[_elder, _busy, _offers, _active] remoteExecCall ["COIN_fnc_openElderDialog", owner _asker];

true
