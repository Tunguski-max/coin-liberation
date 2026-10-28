/*
    File: fn_requestReinforcement.sqf
    Author: COIN Liberation

    Description:
        Server: an interpreter asks the elder for a reinforcement and has picked its target point (ticket 5.6, DESIGN 8.1, ADR 0012 and 0023).
        Called by COIN_fnc_pickReinforcementPoint with remoteExecCall. Checks everything again: the machine, the elder, an interpreter
        close enough, the offer is one that can be accepted now (COIN_fnc_getAidOffers: none on its way, the reputation, a favor in stock, the
        intel points), the point (no water, within COIN_reinforcementMaxDistance of the elder). Then it takes one favor (COIN_fnc_useFavor) and
        COIN_favorIntelCost intel points, and COIN_reinforcementSize local fighters appear at the elder's place: Liberation's resistance in
        a group of their own (KPLIB_fnc_spawnGuerillaGroup: equipment of the current tier of the resistance), no part of any enemy
        budget, given to Zeus. They walk to the point; COIN_fnc_runReinforcement watches the group, COIN_fnc_watchReinforcement reports to the radio. The group is kept in
        COIN_reinforcement = [group, place of the elder, target point, end time, town] (empty while none is on its way), for the radio of
        ticket 5.19 (the radio orders, COIN_fnc_radioOrder); COIN_fnc_publishReinforcement tells the players. Not saved. Switches COIN_enableFavors, COIN_enableReinforcement and COIN_enableAidTasks.

    Parameter(s):
        _elder  - The elder [OBJECT, defaults to objNull]
        _asker  - Interpreter [OBJECT, defaults to objNull]
        _target - Target point [ARRAY, defaults to []]

    Returns:
        The reinforcement was sent [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_target", [], [[]]]
];

if (!isServer || {!COIN_enableFavors} || {!COIN_enableReinforcement} || {!COIN_enableAidTasks}) exitWith {false};

// The asker must be the unit of the machine that sent this
private _sender = remoteExecutedOwner;
if (_sender > 0 && {owner _asker != _sender}) exitWith {
    diag_log format ["[COIN] favors: ERROR - reinforcement request sent by machine %1, not the owner of %2, refused", _sender, _asker];
    false
};

if (
    !(_elder getVariable ["COIN_elder", false])
    || {!([_elder, _asker, COIN_talkRange + COIN_talkRangeMargin, true] call COIN_fnc_canQuestion)}
) exitWith {
    diag_log format ["[COIN] favors: reinforcement request of %1 to %2 refused (rules)", name _asker, name _elder];
    false
};

// Refused: the elder says so, the log says why
private _refuse = {
    params ["_why"];
    diag_log format ["[COIN] favors: reinforcement request of %1 at the elder of %2 refused: %3", name _asker, markerText (_elder getVariable ["COIN_sector", ""]), _why];
    [_elder, "refused"] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];
    false
};

([_elder] call COIN_fnc_getAidOffers) params ["", "_offers"];
private _offer = _offers select {(_x select 0) isEqualTo "reinforcement"};
if (_offer isEqualTo [] || {!((_offer select 0) select 2)}) exitWith {
    [if (_offer isEqualTo []) then {"no such offer"} else {(_offer select 0) select 3}] call _refuse
};

// The point: the client judged it already, the server does not trust that. The elder may have drifted a few metres since
if (count _target < 2 || {!(_target isEqualTypeAll 0)}) exitWith {["no point"] call _refuse};
if (surfaceIsWater _target) exitWith {["the point is in water"] call _refuse};
private _distance = _target distance2D _elder;
if (_distance > COIN_reinforcementMaxDistance + COIN_talkRangeMargin) exitWith {
    [format ["the point is %1 m from the elder, %2 at most", round _distance, COIN_reinforcementMaxDistance]] call _refuse
};

private _sector = _elder getVariable ["COIN_sector", ""];
private _town = markerText _sector;
// Where the elder stands: the fighters appear there and walk home to it (the elder may be gone by then, the place stays)
private _home = (COIN_elderSpots getOrDefault [_sector, [getPosATL _elder]]) select 0;

// The favor first: it is the one that can be gone by now (a second interpreter in the same moment)
if !([] call COIN_fnc_useFavor) exitWith {["no favor in stock"] call _refuse};
private _intelBefore = missionNamespace getVariable ["resources_intel", 0];
resources_intel = (_intelBefore - COIN_favorIntelCost) max 0;

private _group = [_home, COIN_reinforcementSize] call KPLIB_fnc_spawnGuerillaGroup;
_group setVariable ["COIN_reinforcement", true, true];
[units _group] call COIN_fnc_addToCurators;

[_group, _target, COIN_reinforcementArriveRadius] call COIN_fnc_moveGroup;

private _endTime = time + (COIN_reinforcementMaxMin * 60);
COIN_reinforcement = [_group, _home, _target, _endTime, _town];
[true] call COIN_fnc_publishReinforcement;

diag_log format [
    "[COIN] favors: reinforcement for %1 from the elder of %2: %3 fighters (tier %4) walk %5 m to %6, intel points %7 -> %8, favors left %9, leave after %10 min",
    name _asker, _town, count (units _group), [] call KPLIB_fnc_getResistanceTier, round (_home distance2D _target), mapGridPosition _target,
    _intelBefore, resources_intel, COIN_favorStock, COIN_reinforcementMaxMin
];

[_elder, "reinforcement"] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];
[_group] spawn COIN_fnc_runReinforcement;
[_group] spawn COIN_fnc_watchReinforcement;

true
