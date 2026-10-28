/*
    File: fn_runStrikeLeader.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Arrest leader" (ticket 5.15, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the beginning
        (it may sleep). The leader stands beside a house of a village in civilian clothes and unarmed (COIN_fnc_createCivilianFighter,
        COIN_role "leader", a class of COIN_leaderClasses or any civilian of Liberation), COIN_leaderGuards militia fighters in uniform
        stand in a ring around him, looking outwards, COIN_leaderPatrolShare of them walk a patrol round him instead (a loop of waypoints). They are made with Liberation's kill manager, marked as COIN units, handed to Zeus, and come from the command
        post of the plan, so a prisoner names that post. At least COIN_leaderGuardArmorShare of them (more at a high readiness, as in the
        field squads, ADR 0014) are Islamic State twins in vest and helmet. The ring guards stay where they are and take up the fight (they
        may move, the patrol leaves its route) as soon as a group is in combat. Units spawn whatever the distance of the players is. Every COIN_strikeCheckSeconds:
        - succeeded: the leader is alive and captive (handcuffed or surrendering, ACE) and COIN_leaderFobRange m or nearer to a FOB:
          combat_readiness falls by COIN_strikeReadinessLoss once, he stays (COIN_leaderKeepSeconds) so the interpreter can interrogate
          him: the first result is always a concrete tip about his command post (COIN_leaderNest, COIN_fnc_interrogatePrisoner),
        - failed: he is dead (no change of readiness), or the end time is reached.
        What is left goes when nobody sees it (COIN_fnc_removeWhenUnseen), a captive leader who is still alive after COIN_leaderKeepSeconds,
        at once if the strike tasks are switched off. Server only.

    Parameter(s):
        _plan    - [village centre, village name, [], "", id of the command post, place of the leader, direction he faces] from COIN_fnc_planStrikeLeader [ARRAY]
        _endTime - Time (server time) at which the task fails [NUMBER]
        _taskId  - Id of the Arma task, for the log [STRING]
        _by      - Name of the interpreter who accepted it, for the log [STRING]

    Returns:
        "succeeded" or the reason it failed [STRING]
*/

params [
    ["_plan", [], [[]]],
    ["_endTime", 0, [0]],
    ["_taskId", "", [""]],
    ["_by", "", [""]]
];

if (!isServer || {_plan isEqualTo []}) exitWith {"no plan"};

_plan params ["_centre", "_village", "", "", "_nestId", "_leaderPos", "_leaderDir"];

// The leader: civilian, unarmed, standing, belongs to the command post
private _leader = ["leader", _leaderPos, _leaderDir, COIN_leaderClasses] call COIN_fnc_createCivilianFighter;
if (isNull _leader) exitWith {
    diag_log "[COIN] strike: ERROR - the leader could not be created";
    "no leader"
};
_leader setVariable ["COIN_leaderNest", _nestId, true];

// The guards: of the command post, a share of them armored; at least COIN_leaderGuardArmorShare, more at a high readiness
COIN_leaderGuards params ["_guardsMin", "_guardsMax"];
private _count = _guardsMin + floor random ((_guardsMax - _guardsMin) + 1);
private _share = COIN_leaderGuardArmorShare max ([] call COIN_fnc_getSquadMixShare);
private _armored = ceil (_count * _share);
private _flags = [];
for "_i" from 0 to (_count - 1) do {_flags pushBack (_i < _armored)};
_flags = _flags call BIS_fnc_arrayShuffle;
// Part of the guards patrol round the leader, a group of their own, the others stand in the ring
private _patrolCount = round (_count * COIN_leaderPatrolShare);
private _patrolFlags = [];
for "_i" from 0 to (_count - 1) do {_patrolFlags pushBack (_i < _patrolCount)};
_patrolFlags = _patrolFlags call BIS_fnc_arrayShuffle;

private _group = createGroup [GRLIB_side_enemy, true];
private _patrolGroup = createGroup [GRLIB_side_enemy, true];
private _guards = [];
private _spots = [];
COIN_leaderGuardRing params ["_ringMin", "_ringMax"];
{
    // A free spot of the ring that is not close to another guard
    private _spot = [_leaderPos, _ringMin, _ringMax, _spots] call COIN_fnc_findGuardSpot;
    _spots pushBack _spot;

    private _class = [_x] call COIN_fnc_pickArmoredClass;
    private _patrols = _patrolFlags select _forEachIndex;
    private _guard = [_class, [_spot select 0, _spot select 1, 0], [_group, _patrolGroup] select _patrols] call KPLIB_fnc_createManagedUnit;
    _guard setVariable ["COIN_origin", ["camp", _nestId, -1]];
    // Facing outwards, standing where he stands until the fight begins (a patrol walks)
    _guard setDir (_leaderPos getDir _spot);
    if (!_patrols) then {_guard disableAI "PATH"};
    _guards pushBack _guard;
} forEach _flags;
[_guards] call COIN_fnc_markCoinUnits;
{
    _x setBehaviour COIN_leaderBehaviour;
    _x setCombatMode "RED";
} forEach [_group, _patrolGroup];
// The patrol: a loop of waypoints round the leader at free spots, walking
if (_patrolCount > 0) then {
    private _waypoints = [_patrolGroup, _leaderPos, COIN_leaderPatrolRadius, COIN_strikePatrolPoints, COIN_strikePatrolArrive, COIN_leaderBehaviour] call COIN_fnc_startGuardPatrol;
    diag_log format ["[COIN] strike: leader %1: patrol of %2 guards, %3 waypoints round %4", _taskId, _patrolCount, _waypoints, _leaderPos select [0, 2]];
};
[_guards] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] strike: leader %1 (%2) with %3 guards (%4 armored, %5 patrolling) in %6 at %7 for command post %8, accepted by %9",
    _taskId, typeOf _leader, count _guards, {isNil "COIN_squadTwinsLower" || {(toLower typeOf _x) in COIN_squadTwinsLower}} count _guards, _patrolCount, _village, _leaderPos select [0, 2], _nestId, _by
];

private _result = "";
private _captive = false;
private _fighting = false;
private _nextPatrolLog = 0;

while {_result isEqualTo ""} do {
    sleep COIN_strikeCheckSeconds;

    // Captive: handcuffed or surrendering (ACE); a captive leader is a prisoner (COIN_fnc_isPrisoner)
    private _captiveNow = !isNull _leader && {alive _leader} && {[_leader] call COIN_fnc_isPrisoner};
    if (_captiveNow isNotEqualTo _captive) then {
        _captive = _captiveNow;
        diag_log format ["[COIN] strike: leader %1 %2 at %3", _taskId, ["is free again", "is captive"] select _captive, getPosATL _leader];
    };

    // For the RPT with COIN_debug: where the patrol is, whether it walks
    if (COIN_debug && {_patrolCount > 0} && {time >= _nextPatrolLog}) then {
        _nextPatrolLog = time + COIN_courierProgressSeconds;
        private _walkers = (units _patrolGroup) select {alive _x};
        diag_log format [
            "[COIN] strike: leader %1 patrol: %2 alive, first at %3 m from the leader, %4 km/h, waypoint %5 of %6, path allowed %7",
            _taskId, count _walkers, if (_walkers isEqualTo []) then {-1} else {round ((_walkers select 0) distance2D _leaderPos)},
            if (_walkers isEqualTo []) then {0} else {round speed (_walkers select 0)},
            currentWaypoint _patrolGroup, count waypoints _patrolGroup,
            if (_walkers isEqualTo []) then {false} else {(_walkers select 0) checkAIFeature "PATH"}
        ];
    };

    // The guards take up the fight when the group is in combat or one of them is hurt
    if (
        !_fighting
        && {(_guards findIf {alive _x}) >= 0}
        && {([_group, _patrolGroup] findIf {behaviour (leader _x) isEqualTo "COMBAT"}) >= 0 || {(_guards findIf {alive _x && {damage _x > 0}}) >= 0}}
    ) then {
        _fighting = true;
        {_x enableAI "PATH"} forEach _guards;
        // The patrol leaves its route and fights like the others
        for "_i" from (count waypoints _patrolGroup) - 1 to 0 step -1 do {deleteWaypoint [_patrolGroup, _i]};
        diag_log format ["[COIN] strike: leader %1: the guards are in combat, %2 of %3 alive", _taskId, {alive _x} count _guards, count _guards];
    };

    private _atFob = (missionNamespace getVariable ["GRLIB_all_fobs", []]) findIf {(_leader distance2D _x) <= COIN_leaderFobRange} >= 0;

    _result = switch (true) do {
        case (GRLIB_endgame != 0 || {!COIN_enableStrikeTasks}): {"strike tasks switched off"};
        case (isNull _leader): {"the leader is gone"};
        case (!alive _leader): {"the leader died"};
        case (_captive && {_atFob}): {"succeeded"};
        case (time >= _endTime): {"time over"};
        default {""};
    };
};

if (_result isEqualTo "succeeded") then {
    private _before = combat_readiness;
    combat_readiness = (combat_readiness - COIN_strikeReadinessLoss) max 0;
    diag_log format [
        "[COIN] strike: leader %1 was brought to a FOB at %2: readiness %3 -> %4 (-%5), command post %6",
        _taskId, getPosATL _leader, round _before, round combat_readiness, COIN_strikeReadinessLoss, _nestId
    ];
};

if (_result isEqualTo "strike tasks switched off") then {
    {deleteVehicle _x} forEach ([_leader] + _guards);
} else {
    // The guards and a leader who is dead or free go when nobody sees them. A captive leader stays for the interrogation (he is a prisoner
    // like any other, whatever the result), a while, then he goes as well
    private _keep = !isNull _leader && {alive _leader} && {_captive};
    private _gone = +_guards;
    if (!_keep) then {_gone pushBack _leader};
    [_gone, "leader"] spawn COIN_fnc_removeWhenUnseen;
    if (_keep) then {
        [_leader] spawn {
            params ["_leader"];
            sleep COIN_leaderKeepSeconds;
            [[_leader], "leader"] spawn COIN_fnc_removeWhenUnseen;
        };
    };
};

diag_log format ["[COIN] strike: leader %1 is over: %2", _taskId, _result];

_result
