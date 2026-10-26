/*
    File: fn_runStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the beginning
        (it may sleep). A civilian car of COIN_courierVehicles with a lone driver, a fighter in civilian clothes (COIN_fnc_createCivilianFighter,
        role "courier"), stands on the road at the start and drives to the destination at most COIN_courierSpeed km/h; the order is
        repeated every COIN_courierRepathSeconds. The car and the driver spawn whatever the distance of the players is. The car
        is a COIN vehicle (no reputation when it is destroyed), handed to Zeus, its cargo empty. Every COIN_strikeCheckSeconds:
        - the car is stopped when the driver is not free (dead, unconscious, captured), left the car, or the car cannot move:
          then the action "Search documents" shows (COIN_fnc_addCourierAction, COIN_fnc_searchDocuments),
        - searched: success, the documents name a nest (a true hit, level "tip", COIN_fnc_createIntel; the nest of the plan if it is
          still active, else any a civilian of the start would know of), announced to everybody, and a subtitle for the one who searched,
        - failed: the car is destroyed or burned out (the documents are lost), the car that is not stopped has come within
          COIN_courierArriveDistance of the destination, or the end time is reached.
        What is left (car, wreck, driver) goes when nobody sees it (COIN_fnc_removeWhenUnseen), at once if the strike tasks are switched off.
        Server only.

    Parameter(s):
        _plan    - [start position, start town, destination position, destination town, nest id, direction] from COIN_fnc_planStrikeCourier [ARRAY]
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

_plan params ["_startPos", "_startName", "_endPos", "_endName", "_nestId", "_startDir"];

private _classes = COIN_courierVehicles select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_classes isEqualTo []) exitWith {
    diag_log "[COIN] strike: ERROR - none of COIN_courierVehicles exists, no courier";
    "no vehicle class"
};
private _class = selectRandom _classes;

private _vehicle = createVehicle [_class, _startPos, [], 0, "NONE"];
if (isNull _vehicle) exitWith {
    diag_log format ["[COIN] strike: ERROR - courier car %1 could not be created", _class];
    "no vehicle"
};
_vehicle setDir _startDir;
_vehicle setPosATL _startPos;
// The car carries documents, nothing else: the cargo is emptied
clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;

private _driver = ["courier", _startPos, _startDir] call COIN_fnc_createCivilianFighter;
_driver moveInDriver _vehicle;
// Standing still is the default of a fighter in civilian clothes; the driver drives
_driver enableAI "PATH";
(group _driver) setSpeedMode "LIMITED";
_vehicle limitSpeed COIN_courierSpeed;

// A COIN vehicle costs no reputation when the army destroys it (COIN_fnc_civVehicleDestroyed)
_vehicle setVariable ["COIN_isCoinVehicle", true];
// COIN_courierOpen (the action shows) is public, the rest is the server's
_vehicle setVariable ["COIN_courier", true, true];
_vehicle setVariable ["COIN_courierOpen", false, true];
[[_vehicle]] call COIN_fnc_addToCurators;
[_vehicle] remoteExec ["COIN_fnc_addCourierAction", 0, _vehicle];

_driver doMove _endPos;
diag_log format [
    "[COIN] strike: courier %1 (%2) starts in %3 at %4 for %5, %6 m by air, accepted by %7",
    _taskId, _class, _startName, _startPos, _endName, round (_startPos distance2D _endPos), _by
];

private _result = "";
private _stopped = false;
private _nextPath = time + COIN_courierRepathSeconds;

while {_result isEqualTo ""} do {
    sleep COIN_strikeCheckSeconds;

    _result = switch (true) do {
        case (GRLIB_endgame != 0 || {!COIN_enableStrikeTasks}): {"strike tasks switched off"};
        case (_vehicle getVariable ["COIN_courierSearched", false]): {"succeeded"};
        case (isNull _vehicle): {"the car is gone"};
        case (!alive _vehicle): {"the car burned out, the documents are lost"};
        case (time >= _endTime): {"time over"};
        case (!_stopped && {(_vehicle distance2D _endPos) <= COIN_courierArriveDistance}): {"the car arrived"};
        default {""};
    };
    if (_result isNotEqualTo "") exitWith {};

    if (
        !_stopped
        && {
            ([_driver] call COIN_fnc_getFighterState) isNotEqualTo "free"
            || {(vehicle _driver) isNotEqualTo _vehicle}
            || {!canMove _vehicle}
        }
    ) then {
        _stopped = true;
        _vehicle setVariable ["COIN_courierOpen", true, true];
        diag_log format [
            "[COIN] strike: courier %1 stopped at %2, %3 m from the destination (driver %4, car can move: %5)",
            _taskId, getPosATL _vehicle, round (_vehicle distance2D _endPos), [_driver] call COIN_fnc_getFighterState, canMove _vehicle
        ];
    };

    if (!_stopped && {time >= _nextPath}) then {
        _driver doMove _endPos;
        _nextPath = time + COIN_courierRepathSeconds;
    };
};

if (_result isEqualTo "succeeded") then {
    // The documents name the nest of the plan; if it is gone, any nest a civilian of the start town would know of
    private _nest = (COIN_nests select {(_x select 0) isEqualTo _nestId && {(_x select 5) isEqualTo "active"}}) param [0, []];
    if (_nest isEqualTo []) then {
        _nest = [_startPos] call COIN_fnc_pickIntelNest;
    };
    private _intel = [_nest, "tip"] call COIN_fnc_createIntel;
    if (_intel isEqualTo []) then {
        diag_log format ["[COIN] strike: courier %1: no intel could be made (nest %2)", _taskId, _nest];
    } else {
        diag_log format [
            "[COIN] strike: courier %1: the documents name nest %2 (%3), circle of %4 m at %5 (intel %6)",
            _taskId, _nest select 0, _nest select 1, _intel select 3, _intel select 2, _intel select 0
        ];
        ["intel"] remoteExecCall ["COIN_fnc_showNotification", 0];
        private _searcher = _vehicle getVariable ["COIN_courierSearchedBy", objNull];
        if (!isNull _searcher) then {
            [COIN_courierFoundSpeaker, COIN_courierFoundText] remoteExecCall ["COIN_fnc_showCourierFound", owner _searcher];
        };
    };
};

if (_result isEqualTo "strike tasks switched off") then {
    {deleteVehicle _x} forEach [_driver, _vehicle];
} else {
    // The car vanishes when nobody sees it, not before the eyes of the army
    [[_vehicle, _driver], "courier"] spawn COIN_fnc_removeWhenUnseen;
};

diag_log format ["[COIN] strike: courier %1 is over: %2", _taskId, _result];

_result
