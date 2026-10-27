/*
    File: fn_runStrikeConvoy.sqf
    Author: COIN Liberation

    Description:
        The event of the strike task "Intercept arms transport" (ticket 5.16, DESIGN 8.2), called by COIN_fnc_runStrikeTask at the
        beginning (it may sleep). The convoy of COIN_convoyOrder (technicals, trucks of Liberation's preset, a car whose passengers all
        wear vest and helmet) stands on the road at the start of the plan, one group, and drives along the waypoints of the plan to the
        end of the route next to the cache. The fighters are militia in uniform, made like those of a camp (Liberation's kill manager,
        marked as COIN units, handed to Zeus). Technicals and trucks are made by Liberation's own vehicle function with its crew, the
        car is a COIN vehicle (no reputation when it is destroyed).
        Only damage of the players counts (COIN_fnc_guardConvoyVehicle, as in Liberation, so civilian cars do not decide the task). Car andmen spawn whatever the distance of the players is. The
        convoy drives at the "LIMITED" speed of its group, in file like the convoy of Liberation's hijack mission (no speed limit per
        vehicle: the ones behind would not catch up), led by the driver of the first vehicle. Like there it flees (behaviour
        COIN_convoyFleeBehaviour, speed COIN_convoyFleeSpeed) as soon as a vehicle is lost, damaged beyond COIN_convoyAttackDamage or
        without its driver (COIN_convoyFleeWhenAttacked); otherwise shot at, the group fights as every group. Every COIN_strikeCheckSeconds:
        - succeeded: every vehicle is destroyed or burned out (a vehicle that only stands counts as alive, a convoy is destroyed),
        - failed: a vehicle that is alive has come within COIN_convoyArriveDistance of the end of the route or of the cache, it is stuck
          (COIN_convoyStuckLimit), or the end time is reached.
        A convoy that stands although its driver lives and the group is not in combat is sent on again by new waypoints from where it
        is. The RPT tells when the convoy passes the two points of the task (with the time window), with COIN_debug also its
        progress and a marker that follows the first vehicle. What is left goes when nobody sees it (COIN_fnc_removeWhenUnseen), at once if
        the strike tasks are switched off. Server only.

    Parameter(s):
        _plan    - Plan from COIN_fnc_planStrikeConvoy [ARRAY]
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

_plan params ["_pos1", "_name1", "_pos2", "_name2", "_cacheId", "_spawn", "_waypoints", "_endPos", "_windows", "_startName", "_length"];

// Where the cache is: reached also when the vehicle stands there (the road ends up to COIN_convoyCacheRoadSearch m from it)
private _nestPos = ((COIN_nests select {(_x select 0) isEqualTo _cacheId}) param [0, []]) param [3, _endPos];

private _technicals = [COIN_convoyTechnicals, militia_vehicles] select (COIN_convoyTechnicals isEqualTo []);
private _trucks = [COIN_convoyTrucks, [opfor_ammobox_transport, opfor_transport_truck]] select (COIN_convoyTrucks isEqualTo []);

private _group = createGroup [GRLIB_side_enemy, true];
private _vehicles = [];
private _crew = [];

{
    private _what = _x;
    (_spawn select _forEachIndex) params ["_place", "_dir"];
    private _vehicle = objNull;

    if (_what isEqualTo "car") then {
        // The car carries the armored infantry: the driver and as many passengers as COIN_convoyCarPassengers, as the seats allow
        private _seats = {getNumber (configFile >> "CfgVehicles" >> _this >> "transportSoldier")};
        private _classes = COIN_courierVehicles select {isClass (configFile >> "CfgVehicles" >> _x) && {(_x call _seats) >= 1}};
        private _roomy = _classes select {(_x call _seats) >= COIN_convoyCarPassengers};
        private _sorted = [_classes, [], {_x call _seats}, "DESCEND"] call BIS_fnc_sortBy;
        private _class = if (_roomy isNotEqualTo []) then {selectRandom _roomy} else {if (_sorted isEqualTo []) then {""} else {_sorted select 0}};
        if (_class isNotEqualTo "") then {
            _vehicle = createVehicle [_class, _place, [], 0, "NONE"];
            _vehicle setDir _dir;
            _vehicle setPosATL _place;
            clearWeaponCargoGlobal _vehicle;
            clearMagazineCargoGlobal _vehicle;
            clearItemCargoGlobal _vehicle;
            clearBackpackCargoGlobal _vehicle;
            _vehicle setVariable ["COIN_isCoinVehicle", true];
            private _men = (1 + (COIN_convoyCarPassengers min ((_class call _seats) - 1)));
            for "_i" from 1 to _men do {
                private _man = [[true] call COIN_fnc_pickArmoredClass, _place, _group] call KPLIB_fnc_createManagedUnit;
                _man setVariable ["COIN_origin", ["camp", _cacheId, -1]];
                if (_i isEqualTo 1) then {_man moveInDriver _vehicle} else {_man moveInCargo _vehicle};
                _crew pushBack _man;
            };
        };
    } else {
        private _class = switch (_what) do {
            case "technical": {selectRandom _technicals};
            case "truckOpen": {_trucks select 0};
            default {_trucks select (1 min ((count _trucks) - 1))};
        };
        // Liberation's own function: crew (militia crew for the technicals) and the kill manager. The crew is taken over by the convoy group
        _vehicle = [_place, _class, true, false] call KPLIB_fnc_spawnVehicle;
        if (!isNull _vehicle) then {
            _vehicle setDir _dir;
            _vehicle setPosATL _place;
            _vehicle setVariable ["COIN_isCoinVehicle", true];
            private _men = crew _vehicle;
            _men joinSilent _group;
            _crew append _men;
        };
    };

    if (isNull _vehicle) then {
        diag_log format ["[COIN] strike: ERROR - convoy vehicle %1 (%2) could not be created", _what, _forEachIndex];
    } else {
        [_vehicle] call COIN_fnc_guardConvoyVehicle;
        _vehicles pushBack _vehicle;
    };
} forEach COIN_convoyOrder;

if (_vehicles isEqualTo []) exitWith {
    diag_log "[COIN] strike: ERROR - no vehicle of the convoy could be created";
    "no vehicles"
};

[_crew] call COIN_fnc_markCoinUnits;
[_vehicles + _crew] call COIN_fnc_addToCurators;

// As Liberation's hijack mission: a moment for the group to settle after the crews have joined it, then the driver of the first vehicle
// leads (else the rank decides and a gunner or a man in the car may lead, the vehicle in front would follow the one behind it)
sleep COIN_convoySettleSeconds;
private _frontDriver = driver (_vehicles select 0);
if (!isNull _frontDriver) then {_group selectLeader _frontDriver};

private _behaviour = COIN_convoyBehaviour;
private _speedMode = "LIMITED";
_group setBehaviour _behaviour;
_group setCombatMode COIN_convoyCombatMode;
_group setFormation COIN_convoyFormation;
_group setSpeedMode _speedMode;

// The way: waypoints along the route, so the convoy takes the road the plan named (a plain order would find its own way)
private _giveWay = {
    params ["_from"];
    while {(count waypoints _group) > 0} do {deleteWaypoint ((waypoints _group) select 0)};
    {
        private _waypoint = _group addWaypoint [_x, 0];
        _waypoint setWaypointType "MOVE";
        _waypoint setWaypointSpeed _speedMode;
        _waypoint setWaypointBehaviour _behaviour;
        _waypoint setWaypointFormation COIN_convoyFormation;
        _waypoint setWaypointCompletionRadius COIN_convoyWaypointRadius;
    } forEach (_waypoints select [_from, count _waypoints]);
};
// The others follow the leader of the group, and only then the waypoints are given (doFollow after them stopped the convoy; the leader
// does not follow himself)
{_x doFollow (leader _group)} forEach (units _group select {_x isNotEqualTo (leader _group)});
[0] call _giveWay;

diag_log format [
    "[COIN] strike: convoy %1 with %2 vehicles and %3 men starts in %4 for cache %5, %6 m by road, %7 waypoints, accepted by %8, led from vehicle %9",
    _taskId, count _vehicles, count _crew, _startName, _cacheId, _length, count _waypoints, _by, _vehicles find (vehicle (leader _group))
];

private _marker = format ["COIN_convoy_%1", _taskId];
if (COIN_debug) then {
    createMarker [_marker, getPosATL (_vehicles select 0)];
    _marker setMarkerType (COIN_convoyDebugMarker select 0);
    _marker setMarkerColor (COIN_convoyDebugMarker select 1);
    _marker setMarkerText format ["convoy %1", _cacheId];
};

private _result = "";
private _passed = [false, false];
private _begin = time;
private _stillSince = -1;
private _stuckCount = 0;
private _nextProgress = 0;
private _attacked = false;

while {_result isEqualTo ""} do {
    sleep COIN_strikeCheckSeconds;

    private _alive = _vehicles select {alive _x};
    // The first vehicle of the convoy that lives and has a driver: it leads and tells whether the convoy stands
    private _leadIndex = _alive findIf {alive (driver _x)};
    private _lead = if (_leadIndex >= 0) then {_alive select _leadIndex} else {objNull};

    _result = switch (true) do {
        case (GRLIB_endgame != 0 || {!COIN_enableStrikeTasks}): {"strike tasks switched off"};
        case (_alive isEqualTo []): {"succeeded"};
        case ((_alive findIf {(_x distance2D _endPos) <= COIN_convoyArriveDistance || {(_x distance2D _nestPos) <= COIN_convoyArriveDistance}}) >= 0): {"the convoy reached the depot"};
        case (time >= _endTime): {"time over"};
        default {""};
    };
    if (_result isNotEqualTo "") exitWith {};

    if (COIN_debug && {!isNull _lead}) then {_marker setMarkerPos (getPosATL _lead)};

    // As Liberation's hijack mission: the first vehicle that is lost, damaged or has lost its driver, and the convoy flees (combat, full speed)
    if (COIN_convoyFleeWhenAttacked && {!_attacked}) then {
        private _hit = _vehicles findIf {!alive _x || {(damage _x) > COIN_convoyAttackDamage} || {!alive (driver _x)}};
        if (_hit >= 0) then {
            _attacked = true;
            _behaviour = COIN_convoyFleeBehaviour;
            _speedMode = COIN_convoyFleeSpeed;
            _group setBehaviour _behaviour;
            _group setSpeedMode _speedMode;
            {
                _x setWaypointBehaviour _behaviour;
                _x setWaypointSpeed _speedMode;
            } forEach (waypoints _group);
            diag_log format ["[COIN] strike: convoy %1 is attacked (vehicle %2), it flees: %3, %4", _taskId, _hit, _behaviour, _speedMode];
        };
    };

    // For the RPT: when the convoy passes a point of the task, to compare with the time window
    {
        private _point = [_pos1, _pos2] select _forEachIndex;
        if (!_x && {(_alive findIf {(_x distance2D _point) <= COIN_convoyPointNear}) >= 0}) then {
            _passed set [_forEachIndex, true];
            private _seconds = round (time - _begin);
            diag_log format [
                "[COIN] strike: convoy %1 passes point %2 (%3) %4 s after the beginning, window %5 to %6 s",
                _taskId, _forEachIndex + 1, ([_name1, _name2] select _forEachIndex) select 0, _seconds,
                ((_windows select _forEachIndex) select 0), ((_windows select _forEachIndex) select 1)
            ];
        };
    } forEach _passed;

    if (!isNull _lead) then {
        if (time >= _nextProgress) then {
            _nextProgress = time + COIN_convoyProgressSeconds;
            // The distance of every vehicle to the first one and its speed: how far the convoy has fallen apart
            diag_log format [
                "[COIN] strike: convoy %1: %2 of %3 vehicles, first at %4, %5 km/h, %6 m from the end, waypoint %7 of %8, %9",
                _taskId, count _alive, count _vehicles, getPosATL _lead, round (speed _lead), round (_lead distance2D _endPos),
                currentWaypoint _group, count waypoints _group, behaviour (leader _group)
            ];
            diag_log format [
                "[COIN] strike: convoy %1: vehicles (distance to the first, speed): %2",
                _taskId, _alive apply {format ["%1 m %2 km/h", round (_x distance2D _lead), round (speed _x)]}
            ];
        };

        // A convoy that stands although its driver lives and nobody fights is stuck (a ditch, a jam, a road that does not lead on): sent on from where it is
        if ((speed _lead) >= COIN_convoyStuckSpeed || {!_attacked && {(behaviour (leader _group)) isEqualTo "COMBAT"}}) then {
            _stillSince = -1;
        } else {
            if (_stillSince < 0) then {_stillSince = time};
            if ((time - _stillSince) >= COIN_convoyStuckSeconds) then {
                _stillSince = time;
                _stuckCount = _stuckCount + 1;
                if (_stuckCount > COIN_convoyStuckLimit) then {
                    _result = format ["stuck, %1 m from the end", round (_lead distance2D _endPos)];
                } else {
                    // The waypoint nearest to the first vehicle and the ones after it
                    private _nearest = 0;
                    private _nearestDistance = 1e9;
                    {
                        if ((_lead distance2D _x) < _nearestDistance) then {
                            _nearestDistance = _lead distance2D _x;
                            _nearest = _forEachIndex;
                        };
                    } forEach _waypoints;
                    diag_log format ["[COIN] strike: convoy %1 is stuck at %2, sent on from waypoint %3 (%4 of %5)", _taskId, getPosATL _lead, _nearest, _stuckCount, COIN_convoyStuckLimit];
                    [_nearest] call _giveWay;
                };
            };
        };
    };
};

if (_result isEqualTo "strike tasks switched off") then {
    {deleteVehicle _x} forEach (_vehicles + _crew);
} else {
    // What is left vanishes when nobody sees it, not before the eyes of the army
    [_vehicles + _crew, "convoy"] spawn COIN_fnc_removeWhenUnseen;
};

if (_result isEqualTo "succeeded") then {
    private _before = combat_readiness;
    combat_readiness = (combat_readiness - COIN_strikeReadinessLossConvoy) max 0;
    private _nest = (COIN_nests select {(_x select 0) isEqualTo _cacheId && {(_x select 5) isEqualTo "active"}}) param [0, []];
    // The tip names the cache the convoy was driving to; if it is gone meanwhile, any nest a civilian of the start would know of
    if (_nest isEqualTo []) then {_nest = [_pos1] call COIN_fnc_pickIntelNest};
    private _intel = if (_nest isEqualTo []) then {[]} else {[_nest, "tip"] call COIN_fnc_createIntel};
    diag_log format [
        "[COIN] strike: convoy %1 destroyed: readiness %2 -> %3 (-%4), cache %5, %6",
        _taskId, round _before, round combat_readiness, COIN_strikeReadinessLossConvoy, _cacheId,
        if (_intel isEqualTo []) then {"no intel could be made"} else {format ["intel %1 (%2 m circle at %3)", _intel select 0, _intel select 3, _intel select 2]}
    ];
    if (_intel isNotEqualTo []) then {["intel"] remoteExecCall ["COIN_fnc_showNotification", 0]};
};

deleteMarker _marker;
diag_log format ["[COIN] strike: convoy %1 is over: %2", _taskId, _result];

_result
