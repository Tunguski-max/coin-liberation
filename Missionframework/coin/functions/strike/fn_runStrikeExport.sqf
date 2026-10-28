/*
    File: fn_runStrikeExport.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Export" (ticket 5.18, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the beginning (it may
        sleep). A civilian plane (the first class of COIN_exportPlaneClasses that exists) stands on the runway of the airfield, without
        a crew and locked (COIN_exportLockPlane), a COIN vehicle (no reputation when it is destroyed), handed to Zeus. Beside it stand
        the goods: a truck without a crew (the covered truck of Liberation's preset) and a technical with its militia crew (a vehicle of
        militia_vehicles), both COIN vehicles; they do not matter for the result.
        COIN_exportGuards militia fighters in uniform (armored by the squad mix of the readiness, COIN_fnc_mixClass, ADR 0014) guard
        it, each at a free spot (COIN_fnc_findGuardSpot): COIN_exportPatrolShare of them walk a patrol round the plane (a group of
        their own, COIN_fnc_startGuardPatrol), the others stand in a ring, looking outwards. They take up the fight (they may move, the
        patrol leaves its route) as soon as a group is in combat or one of them is hurt. They are made with Liberation's kill manager,
        marked as COIN units, handed to Zeus, and come from the nest of the plan, so a prisoner names that nest. Units spawn whatever
        the distance of the players is. There is no real take-off: the plane never moves. Every COIN_strikeCheckSeconds:
        - succeeded: the plane is destroyed (not just damaged): combat_readiness falls by COIN_strikeReadinessLoss once,
        - failed: the end time is reached.
        What is left goes when nobody sees it (COIN_fnc_removeWhenUnseen), at once if the strike tasks are switched off. Server only.

    Parameter(s):
        _plan    - [position of the runway, name of the airfield, [], "", id of the nest, position of the plane, direction of the plane,
                   name of the town] from COIN_fnc_planStrikeExport [ARRAY]
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

_plan params ["", "_airfield", "", "", "_nestId", "_planePos", "_planeDir"];

private _class = (COIN_exportPlaneClasses select {isClass (configFile >> "CfgVehicles" >> _x)}) param [0, ""];
if (_class isEqualTo "") exitWith {
    diag_log "[COIN] strike: ERROR - none of COIN_exportPlaneClasses exists, no export";
    "no plane class"
};

// The plane: on the runway, no crew, it never takes off
private _plane = createVehicle [_class, _planePos, [], 0, "CAN_COLLIDE"];
if (isNull _plane) exitWith {
    diag_log format ["[COIN] strike: ERROR - the plane %1 could not be created", _class];
    "no plane"
};
_plane setDir _planeDir;
clearWeaponCargoGlobal _plane;
clearMagazineCargoGlobal _plane;
clearItemCargoGlobal _plane;
clearBackpackCargoGlobal _plane;
if (COIN_exportLockPlane) then {_plane lock 2};
// A COIN vehicle costs no reputation when the army destroys it (COIN_fnc_civVehicleDestroyed)
_plane setVariable ["COIN_isCoinVehicle", true];

// The goods beside the plane, one on each side of it: an empty truck and a technical that stands there with its crew
private _goods = [];
private _goodsCrew = [];
{
    _x params ["_goodsClass", "_side", "_withCrew"];
    private _wanted = _planePos getPos [COIN_exportVehicleDistance, _planeDir + _side];
    private _spot = _wanted findEmptyPosition [0, COIN_exportVehicleSearch, _goodsClass];
    if (_spot isEqualTo []) then {_spot = _wanted};
    private _vehicle = objNull;
    if (_withCrew) then {
        // Liberation's own function: crew (militia crew for a technical) and the kill manager
        _vehicle = [[_spot select 0, _spot select 1, 0], _goodsClass, true, false] call KPLIB_fnc_spawnVehicle;
        if (!isNull _vehicle) then {_goodsCrew append (crew _vehicle)};
    } else {
        _vehicle = createVehicle [_goodsClass, [_spot select 0, _spot select 1, 0], [], 0, "NONE"];
        clearWeaponCargoGlobal _vehicle;
        clearMagazineCargoGlobal _vehicle;
        clearItemCargoGlobal _vehicle;
        clearBackpackCargoGlobal _vehicle;
    };
    if (isNull _vehicle) then {
        diag_log format ["[COIN] strike: ERROR - export vehicle %1 could not be created", _goodsClass];
    } else {
        _vehicle setDir _planeDir;
        _vehicle setVariable ["COIN_isCoinVehicle", true];
        _goods pushBack _vehicle;
    };
} forEach [
    [opfor_transport_truck, 90, false],
    [selectRandom militia_vehicles, -90, true]
];
[_goodsCrew] call COIN_fnc_markCoinUnits;

// The guards: militia in uniform. A share of them patrols round the plane (a group of its own), the others stand in a ring round it,
// looking outwards, until the fight begins
COIN_exportGuards params ["_guardsMin", "_guardsMax"];
COIN_exportGuardRing params ["_ringMin", "_ringMax"];
private _count = _guardsMin + floor random ((_guardsMax - _guardsMin) + 1);
private _patrolCount = round (_count * COIN_exportPatrolShare);
private _group = createGroup [GRLIB_side_enemy, true];
private _patrolGroup = createGroup [GRLIB_side_enemy, true];
private _guards = [];
private _spots = [];
for "_i" from 0 to (_count - 1) do {
    private _patrols = _i < _patrolCount;
    // A free spot of the ring that is not close to another guard
    private _spot = [_planePos, _ringMin, _ringMax, _spots] call COIN_fnc_findGuardSpot;
    _spots pushBack _spot;
    private _guard = [[selectRandom militia_squad] call COIN_fnc_mixClass, [_spot select 0, _spot select 1, 0], [_group, _patrolGroup] select _patrols] call KPLIB_fnc_createManagedUnit;
    if (_nestId >= 0) then {_guard setVariable ["COIN_origin", ["camp", _nestId, -1]]};
    // Facing outwards, standing where he stands until the fight begins (a patrol walks)
    _guard setDir (_planePos getDir _spot);
    if (!_patrols) then {_guard disableAI "PATH"};
    _guards pushBack _guard;
};
[_guards] call COIN_fnc_markCoinUnits;
{
    _x setBehaviour COIN_exportBehaviour;
    _x setCombatMode "RED";
} forEach [_group, _patrolGroup];
private _waypoints = 0;
if (_patrolCount > 0) then {
    _waypoints = [_patrolGroup, _planePos, COIN_exportPatrolRadius, COIN_strikePatrolPoints, COIN_strikePatrolArrive, COIN_exportBehaviour] call COIN_fnc_startGuardPatrol;
};
[[_plane] + _goods + _goodsCrew + _guards] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] strike: export %1 (%2) with %3 guards (%4 patrolling, %5 waypoints) and %6 vehicles beside it at %7, %8, accepted by %9",
    _taskId, _class, count _guards, _patrolCount, _waypoints, count _goods, _airfield, _planePos select [0, 2], _by
];

private _result = "";
private _fighting = false;

while {_result isEqualTo ""} do {
    sleep COIN_strikeCheckSeconds;

    // The guards take up the fight when a group is in combat or one of them is hurt
    if (
        !_fighting
        && {(_guards findIf {alive _x}) >= 0}
        && {([_group, _patrolGroup] findIf {behaviour (leader _x) isEqualTo "COMBAT"}) >= 0 || {(_guards findIf {alive _x && {damage _x > 0}}) >= 0}}
    ) then {
        _fighting = true;
        {_x enableAI "PATH"} forEach _guards;
        // The patrol leaves its route and fights like the others
        for "_i" from (count waypoints _patrolGroup) - 1 to 0 step -1 do {deleteWaypoint [_patrolGroup, _i]};
        diag_log format ["[COIN] strike: export %1: the guards are in combat, %2 of %3 alive", _taskId, {alive _x} count _guards, count _guards];
    };

    _result = switch (true) do {
        case (GRLIB_endgame != 0 || {!COIN_enableStrikeTasks}): {"strike tasks switched off"};
        case (isNull _plane || {!alive _plane}): {"succeeded"};
        case (time >= _endTime): {"time over"};
        default {""};
    };
};

if (_result isEqualTo "succeeded") then {
    private _before = combat_readiness;
    combat_readiness = (combat_readiness - COIN_strikeReadinessLoss) max 0;
    diag_log format [
        "[COIN] strike: export %1: the plane at %2 is destroyed: readiness %3 -> %4 (-%5)",
        _taskId, _airfield, round _before, round combat_readiness, COIN_strikeReadinessLoss
    ];
};

private _everything = [_plane] + _goods + _goodsCrew + _guards;
if (_result isEqualTo "strike tasks switched off") then {
    {deleteVehicle _x} forEach _everything;
} else {
    // What is left vanishes when nobody sees it, not before the eyes of the army: no real take-off
    [_everything, "export"] spawn COIN_fnc_removeWhenUnseen;
};

diag_log format ["[COIN] strike: export %1 is over: %2", _taskId, _result];

_result
