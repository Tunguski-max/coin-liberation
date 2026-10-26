/*
    File: fn_startSecondary.sqf
    Author: COIN Liberation

    Description:
        Server: starts one of Liberation's secondary missions for an interpreter who accepted it in the dialog of the elder
        (ticket 5.17, ADR 0023). Called by COIN_fnc_acceptElderOffer after it has checked the rules and that the offer can be
        accepted (COIN_fnc_getAidOffers: enough intel points, no other secondary mission). The start is Liberation's own server
        call (start_secondary_remote_call): it takes the cost from resources_intel and starts the mission, nothing of that is
        changed here. Liberation's dialog only starts a mission while enemy territory is left for it, its server call does not
        look, so this does (KPLIB_fnc_getOpforSpawnPoint). The elder answers the interpreter. A secondary mission does not
        belong to a town: it does not count as an aid task and the town does not wait afterwards.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]
        _asker - Interpreter [OBJECT, defaults to objNull]
        _offer - Row of COIN_secondaryOffers [ARRAY, defaults to []]

    Returns:
        The mission was started [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_offer", [], [[]]]
];

if (!isServer || {_offer isEqualTo []}) exitWith {false};

_offer params ["_id", "_index"];

if (([2000, 999999, false] call KPLIB_fnc_getOpforSpawnPoint) isEqualTo "") exitWith {
    diag_log format ["[COIN] secondary: %1 refused for %2, not enough enemy territory left for a mission", _id, name _asker];
    [_elder, "refused"] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];
    false
};

private _intelBefore = missionNamespace getVariable ["resources_intel", 0];
private _started = ([_index] call start_secondary_remote_call) isEqualTo true;

diag_log format [
    "[COIN] secondary: %1 %2 for %3 at the elder of %4, cost %5, intel points %6 -> %7",
    _id, ["not started", "started"] select _started, name _asker, markerText (_elder getVariable ["COIN_sector", ""]),
    GRLIB_secondary_missions_costs select _index, _intelBefore, missionNamespace getVariable ["resources_intel", 0]
];

[_elder, ["refused", "accepted"] select _started] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];

_started
