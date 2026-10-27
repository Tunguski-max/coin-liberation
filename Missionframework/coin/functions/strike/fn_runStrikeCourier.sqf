/*
    File: fn_runStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the beginning
        (it may sleep). A car of COIN_courierVehicles (one with enough seats) stands on the road at the start. The courier drives it
        and COIN_courierGuards guards sit in it: militia fighters of Liberation's militia_squad in uniform, so the car is plainly hostile
        (no technical, nothing mounted). They are made like the fighters of a camp (Liberation's kill manager, marked as COIN
        units, handed to Zeus) and come from the nest of the plan (COIN_origin), so a prisoner names that nest. The car drives to the
        destination at most COIN_courierSpeed km/h, the order is repeated every COIN_courierRepathSeconds; shot at, the group fights as
        every group. Car and men spawn whatever the distance of the players is. The car is a COIN vehicle (no reputation when it is
        destroyed), its cargo empty. Every COIN_strikeCheckSeconds:
        - the car is stopped when the courier is out (dead, captured), left the car, or the car cannot move, or he is unconscious and the
          car stands. This is looked at every time: a courier who wakes up drives on. While it is stopped the action "Search
          documents" shows (COIN_fnc_addCourierAction, COIN_fnc_searchDocuments),
        - searched: success, the documents name a nest (a true hit, level "tip", COIN_fnc_createIntel; the nest of the plan if it is
          still active, else any a civilian of the start would know of), announced to everybody, and a subtitle for the one who searched,
        - failed: the car is destroyed or burned out (the documents are lost), the car that is not stopped has come back within
          COIN_courierArriveDistance of its start, or the end time is reached.
        The car drives to the destination, waits there COIN_courierWaitSeconds and drives back to the start (like the convoy of Liberation's
        secondary mission, which also starts wherever it is and does not care for the players).
        What is left (car, wreck, men) goes when nobody sees it (COIN_fnc_removeWhenUnseen), at once if the strike tasks are switched off.
        With COIN_debug a marker follows the car. Server only.

    Parameter(s):
        _plan    - [start position, start town, destination position, destination name, nest id, direction] from COIN_fnc_planStrikeCourier [ARRAY]
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
private _endLabel = if (_endName isEqualType []) then {_endName select 0} else {_endName};

COIN_courierGuards params ["_guardsMin", "_guardsMax"];
private _wanted = _guardsMin + floor random ((_guardsMax - _guardsMin) + 1);

// Cars that exist and seat the guards; if none seats them all, the one with the most seats takes fewer
private _classes = COIN_courierVehicles select {isClass (configFile >> "CfgVehicles" >> _x)};
private _seats = {getNumber (configFile >> "CfgVehicles" >> _this >> "transportSoldier")};
if (_classes isEqualTo []) exitWith {
    diag_log "[COIN] strike: ERROR - none of COIN_courierVehicles exists, no courier";
    "no vehicle class"
};
private _roomy = _classes select {(_x call _seats) >= _wanted};
private _class = "";
if (_roomy isNotEqualTo []) then {
    _class = selectRandom _roomy;
} else {
    private _sorted = [_classes, [], {_x call _seats}, "DESCEND"] call BIS_fnc_sortBy;
    _class = _sorted select 0;
};
private _guards = _wanted min (_class call _seats);

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

// The courier drives, the guards sit in the back; all militia in uniform, from the nest of the plan
private _group = createGroup [GRLIB_side_enemy, true];
private _men = [];
for "_i" from 0 to _guards do {
    private _man = [selectRandom militia_squad, _startPos, _group] call KPLIB_fnc_createManagedUnit;
    _man setVariable ["COIN_origin", ["camp", _nestId, -1]];
    if (_i == 0) then {
        _man moveInDriver _vehicle;
        _man setVariable ["COIN_role", "courier", true];
    } else {
        _man moveInCargo _vehicle;
    };
    _men pushBack _man;
};
private _driver = _men select 0;
[_men] call COIN_fnc_markCoinUnits;
_group setBehaviour COIN_courierBehaviour;
_group setSpeedMode "LIMITED";
_vehicle limitSpeed COIN_courierSpeed;

// A COIN vehicle costs no reputation when the army destroys it (COIN_fnc_civVehicleDestroyed)
_vehicle setVariable ["COIN_isCoinVehicle", true];
// COIN_courierOpen (the action shows) is public, the rest is the server's
_vehicle setVariable ["COIN_courier", true, true];
_vehicle setVariable ["COIN_courierOpen", false, true];
[[_vehicle] + _men] call COIN_fnc_addToCurators;
[_vehicle] remoteExec ["COIN_fnc_addCourierAction", 0, _vehicle];

_driver doMove _endPos;
diag_log format [
    "[COIN] strike: courier %1 (%2) with %3 guards starts in %4 at %5 for %6, %7 m by air, accepted by %8",
    _taskId, _class, _guards, _startName, _startPos, _endLabel, round (_startPos distance2D _endPos), _by
];

private _result = "";
private _stopped = false;
private _nextPath = time + COIN_courierRepathSeconds;
// The way: "out" to the destination, "wait" there, "back" to the start
private _phase = "out";
private _waitUntil = 0;

// With COIN_debug the car has a marker that follows it (the players cannot tell it from other cars otherwise)
private _marker = format ["COIN_courier_%1", _taskId];
if (COIN_debug) then {
    createMarker [_marker, getPosATL _vehicle];
    _marker setMarkerType (COIN_courierMarker select 0);
    _marker setMarkerColor (COIN_courierMarker select 1);
    _marker setMarkerText format ["%1 -> %2", _startName, _endLabel];
};
private _nextMarker = 0;

while {_result isEqualTo ""} do {
    sleep COIN_strikeCheckSeconds;

    if (COIN_debug && {time >= _nextMarker} && {!isNull _vehicle}) then {
        _marker setMarkerPos (getPosATL _vehicle);
        _nextMarker = time + COIN_strikeMarkerSeconds;
    };

    _result = switch (true) do {
        case (GRLIB_endgame != 0 || {!COIN_enableStrikeTasks}): {"strike tasks switched off"};
        case (_vehicle getVariable ["COIN_courierSearched", false]): {"succeeded"};
        case (isNull _vehicle): {"the car is gone"};
        case (!alive _vehicle): {"the car burned out, the documents are lost"};
        case (time >= _endTime): {"time over"};
        case (_phase isEqualTo "back" && {!_stopped} && {(_vehicle distance2D _startPos) <= COIN_courierArriveDistance}): {"the car came back to its start"};
        default {""};
    };
    if (_result isNotEqualTo "") exitWith {};

    // Stopped: the courier is out (dead, captured) or left the car, the car cannot move, or he is unconscious and the car stands.
    // Looked at again every time: a courier who wakes up drives on, and the search is not possible while the car is under way
    private _driverState = [_driver] call COIN_fnc_getFighterState;
    private _stoppedNow = _driverState isEqualTo "out"
        || {(vehicle _driver) isNotEqualTo _vehicle}
        || {!canMove _vehicle}
        || {_driverState isEqualTo "down" && {(speed _vehicle) < COIN_courierStoppedSpeed}};
    if (_stoppedNow isNotEqualTo _stopped) then {
        _stopped = _stoppedNow;
        _vehicle setVariable ["COIN_courierOpen", _stopped, true];
        diag_log format [
            "[COIN] strike: courier %1 %2 at %3, %4 m from the destination (courier %5, car can move: %6)",
            _taskId, ["drives on", "stopped"] select _stopped, getPosATL _vehicle, round (_vehicle distance2D _endPos), _driverState, canMove _vehicle
        ];
        // A courier who woke up is sent on again
        if (!_stopped) then {_driver doMove ([_endPos, _startPos] select (_phase isEqualTo "back"))};
    };

    if (!_stopped) then {
        switch (_phase) do {
            case "out": {
                if ((_vehicle distance2D _endPos) <= COIN_courierArriveDistance) then {
                    _phase = "wait";
                    _waitUntil = time + COIN_courierWaitSeconds;
                    diag_log format ["[COIN] strike: courier %1 is at the destination %2, waits %3 s", _taskId, _endLabel, COIN_courierWaitSeconds];
                } else {
                    if (time >= _nextPath) then {
                        _driver doMove _endPos;
                        _nextPath = time + COIN_courierRepathSeconds;
                    };
                };
            };
            case "wait": {
                if (time >= _waitUntil) then {
                    _phase = "back";
                    _driver doMove _startPos;
                    _nextPath = time + COIN_courierRepathSeconds;
                    diag_log format ["[COIN] strike: courier %1 drives back to %2", _taskId, _startName];
                };
            };
            case "back": {
                if (time >= _nextPath) then {
                    _driver doMove _startPos;
                    _nextPath = time + COIN_courierRepathSeconds;
                };
            };
        };
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
    {deleteVehicle _x} forEach ([_vehicle] + _men);
} else {
    // The car and the men vanish when nobody sees them, not before the eyes of the army
    [[_vehicle] + _men, "courier"] spawn COIN_fnc_removeWhenUnseen;
};

deleteMarker _marker;
diag_log format ["[COIN] strike: courier %1 is over: %2", _taskId, _result];

_result
