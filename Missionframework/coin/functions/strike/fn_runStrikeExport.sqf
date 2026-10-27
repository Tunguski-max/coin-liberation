/*
    File: fn_runStrikeExport.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Export" (ticket 5.18, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the beginning (it may
        sleep). A civilian plane (the first class of COIN_exportPlaneClasses that exists) stands on the runway of the airfield, without
        a crew and locked (COIN_exportLockPlane), a COIN vehicle (no reputation when it is destroyed), handed to Zeus.
        COIN_exportGuards militia fighters in uniform stand round it, looking outwards, and take up the fight (they may move) as soon as
        their group is in combat or one of them is hurt. They are made with Liberation's kill manager, marked as COIN units, handed to
        Zeus, and come from the nest of the plan, so a prisoner names that nest. Units spawn whatever the distance of the players is.
        There is no real take-off: the plane never moves. Every COIN_strikeCheckSeconds:
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
_plane setVehiclePosition [_planePos, [], 0, "CAN_COLLIDE"];
_plane setDir _planeDir;
clearWeaponCargoGlobal _plane;
clearMagazineCargoGlobal _plane;
clearItemCargoGlobal _plane;
clearBackpackCargoGlobal _plane;
if (COIN_exportLockPlane) then {_plane lock 2};
// A COIN vehicle costs no reputation when the army destroys it (COIN_fnc_civVehicleDestroyed)
_plane setVariable ["COIN_isCoinVehicle", true];

// The guards: militia in uniform in a ring round the plane, looking outwards, standing until the fight begins
COIN_exportGuards params ["_guardsMin", "_guardsMax"];
COIN_exportGuardRing params ["_ringMin", "_ringMax"];
private _count = _guardsMin + floor random ((_guardsMax - _guardsMin) + 1);
private _group = createGroup [GRLIB_side_enemy, true];
private _guards = [];
for "_i" from 0 to (_count - 1) do {
    // Each guard in his own sector of the circle, so they stand all round the plane
    private _angle = (_i * 360 / _count) + random (360 / _count);
    private _spot = _planePos getPos [_ringMin + random (_ringMax - _ringMin), _angle];
    private _guard = [selectRandom militia_squad, [_spot select 0, _spot select 1, 0], _group] call KPLIB_fnc_createManagedUnit;
    if (_nestId >= 0) then {_guard setVariable ["COIN_origin", ["camp", _nestId, -1]]};
    _guard setDir (_planePos getDir _spot);
    _guard disableAI "PATH";
    _guards pushBack _guard;
};
[_guards] call COIN_fnc_markCoinUnits;
_group setBehaviour COIN_exportBehaviour;
_group setCombatMode "RED";
[[_plane] + _guards] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] strike: export %1 (%2) with %3 guards at %4, %5, accepted by %6",
    _taskId, _class, count _guards, _airfield, _planePos select [0, 2], _by
];

private _result = "";
private _fighting = false;

while {_result isEqualTo ""} do {
    sleep COIN_strikeCheckSeconds;

    // The guards take up the fight when the group is in combat or one of them is hurt
    if (
        !_fighting
        && {(_guards findIf {alive _x}) >= 0}
        && {(behaviour (leader _group)) isEqualTo "COMBAT" || {(_guards findIf {alive _x && {damage _x > 0}}) >= 0}}
    ) then {
        _fighting = true;
        {_x enableAI "PATH"} forEach _guards;
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

if (_result isEqualTo "strike tasks switched off") then {
    {deleteVehicle _x} forEach ([_plane] + _guards);
} else {
    // What is left vanishes when nobody sees it, not before the eyes of the army: no real take-off
    [[_plane] + _guards, "export"] spawn COIN_fnc_removeWhenUnseen;
};

diag_log format ["[COIN] strike: export %1 is over: %2", _taskId, _result];

_result
