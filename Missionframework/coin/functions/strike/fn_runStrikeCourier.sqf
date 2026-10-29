/*
    File: fn_runStrikeCourier.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Intercept courier" (ticket 5.14, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the beginning
        (it may sleep). A car of COIN_strikeCarClasses (one with enough seats) stands on the road at the start. The courier drives it
        and COIN_courierGuards guards sit in it: militia fighters of Liberation's militia_squad in uniform, so the car is plainly hostile
        (no technical, nothing mounted). They are made like the fighters of a camp (Liberation's kill manager, marked as COIN
        units, handed to Zeus) and come from the nest of the plan (COIN_origin), so a prisoner names that nest. The car drives to the
        destination at most COIN_courierSpeed km/h, the order is repeated every COIN_courierRepathSeconds; shot at, the group fights as
        every group. Car and men spawn whatever the distance of the players is. The car is a COIN vehicle (no reputation when it is
        destroyed), its cargo empty. Every COIN_strikeCheckSeconds:
        - the car is stopped when the courier is out (dead, captured), left the car, or the car cannot move, or he is unconscious and the
          car stands. This is looked at every time: a courier who wakes up drives on. While it is stopped the action "Search
          documents" shows (COIN_fnc_addSearchAction, COIN_fnc_searchDocuments),
        - searched: success, the documents name a nest (a true hit, level "tip", COIN_fnc_createIntel; the nest of the plan if it is
          still active, else any a civilian of the start would know of), announced to everybody, and a subtitle for the one who searched,
        - failed: the car is destroyed or burned out (the documents are lost), the car that is not stopped has come back within
          COIN_courierArriveDistance of its start, it is stuck (COIN_courierStuckLimit), or the end time is reached.
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
private _endLabel = if (_endName isEqualType []) then {_endName select 1} else {_endName};

COIN_courierGuards params ["_guardsMin", "_guardsMax"];
private _wanted = _guardsMin + floor random ((_guardsMax - _guardsMin) + 1);

// Cars that exist and seat the guards; if none seats them all, the one with the most seats takes fewer
private _classes = COIN_strikeCarClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
private _seats = {getNumber (configFile >> "CfgVehicles" >> _this >> "transportSoldier")};
if (_classes isEqualTo []) exitWith {
    diag_log "[COIN] strike: ERROR - none of COIN_strikeCarClasses exists, no courier";
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

// For the RPT: what stands at the start (a courier that does not move may be wedged)
private _around = (nearestObjects [_startPos, [], COIN_strikeRoadClearance]) apply {format ["%1 (%2 m)", typeOf _x, round (_x distance2D _startPos)]};
diag_log format ["[COIN] strike: courier start %1, objects within %2 m: %3", _startPos, COIN_strikeRoadClearance, _around];

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
[[_vehicle] + _men] call COIN_fnc_addToCurators;
// The action "Search documents" shows while the car is stopped (COIN_searchOpen, set below)
[_vehicle] call COIN_fnc_makeSearchable;

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
// For the RPT and for a car that sticks: when the next line is due, since when the car stands, how often it was sent on
private _nextProgress = 0;
private _stillSince = -1;
private _stuckCount = 0;

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
        case (_vehicle getVariable ["COIN_searched", false]): {"succeeded"};
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
        _vehicle setVariable ["COIN_searchOpen", _stopped, true];
        diag_log format [
            "[COIN] strike: courier %1 %2 at %3, %4 m from the destination (courier %5, car can move: %6)",
            _taskId, ["drives on", "stopped"] select _stopped, getPosATL _vehicle, round (_vehicle distance2D _endPos), _driverState, canMove _vehicle
        ];
        // A courier who woke up is sent on again
        if (!_stopped) then {_driver doMove ([_endPos, _startPos] select (_phase isEqualTo "back"))};
    };

    if (!_stopped) then {
        private _goal = [_endPos, _startPos] select (_phase isEqualTo "back");

        if (time >= _nextProgress) then {
            _nextProgress = time + COIN_courierProgressSeconds;
            diag_log format [
                "[COIN] strike: courier %1 %2 at %3, %4 km/h, %5 m from its goal, courier %6",
                _taskId, _phase, getPosATL _vehicle, round (speed _vehicle), round (_vehicle distance2D _goal), _driverState
            ];
        };

        // A car that stands on the way although the courier is free is stuck (the road does not lead on, a jam, a ditch). Close to its goal
        // it has arrived as near as it can get, farther away it is sent on, and after COIN_courierStuckLimit times the task fails
        if (_phase in ["out", "back"]) then {
            if ((speed _vehicle) >= COIN_courierStuckSpeed) then {
                _stillSince = -1;
            } else {
                if (_stillSince < 0) then {_stillSince = time};
                if ((time - _stillSince) >= COIN_courierStuckSeconds) then {
                    _stillSince = time;
                    private _gap = _vehicle distance2D _goal;
                    if (_gap <= COIN_courierStuckDistance) then {
                        diag_log format ["[COIN] strike: courier %1 stands %2 m from its goal, that is as near as it gets (%3)", _taskId, round _gap, _phase];
                        if (_phase isEqualTo "out") then {
                            _phase = "wait";
                            _waitUntil = time + COIN_courierWaitSeconds;
                        } else {
                            _result = "the car came back to its start";
                        };
                    } else {
                        _stuckCount = _stuckCount + 1;
                        if (_stuckCount > COIN_courierStuckLimit) then {
                            _result = format ["stuck, %1 m from its goal", round _gap];
                        } else {
                            diag_log format ["[COIN] strike: courier %1 is stuck %2 m from its goal at %3, sent on (%4 of %5)", _taskId, round _gap, getPosATL _vehicle, _stuckCount, COIN_courierStuckLimit];
                            _driver doMove _goal;
                            _nextPath = time + COIN_courierRepathSeconds;
                        };
                    };
                };
            };
        };

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
    [
        _nestId, _startPos, _vehicle getVariable ["COIN_searchedBy", objNull],
        COIN_courierFoundSpeaker, COIN_courierFoundText, format ["courier %1", _taskId]
    ] call COIN_fnc_giveDocumentsTip;
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
