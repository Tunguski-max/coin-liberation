/*
    File: fn_runMortarGetaway.sqf
    Author: COIN Liberation

    Description:
        The getaway of a mortar squad that fired and was not eliminated (follow-up of tickets 6.7a and 6.7b):
        1. the gunner gets out of the mortar,
        2. the living fighters who are not prisoners get into the car (one drives, the others sit in the back), they walk to
           it; whoever is not in after COIN_mortarBoardSeconds is put in,
        3. the car drives to a point COIN_mortarGetawayDistance (800 m) from the mortar in the direction away from the
           FOB, on the nearest road if there is one, until it is that far from the mortar, at most COIN_mortarDriveSeconds.
        The mortar stays where it is. Nothing is deleted here, the caller takes the squad down afterwards. One log line
        per step. Must be called from a scheduled script. Server only.

    Parameter(s):
        _fighters - The fighters of the squad [ARRAY of OBJECTs]
        _mortar   - The mortar [OBJECT]
        _car      - The car [OBJECT]
        _fob      - Position of the FOB [ARRAY]

    Returns:
        The car got away: it is COIN_mortarGetawayDistance from the mortar with a driver [BOOL]
*/

params [
    ["_fighters", [], [[]]],
    ["_mortar", objNull, [objNull]],
    ["_car", objNull, [objNull]],
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer || {isNull _car} || {!alive _car}) exitWith {false};

private _spot = getPosATL _mortar;
private _crew = _fighters select {alive _x && {!([_x] call COIN_fnc_isPrisoner)}};
if (_crew isEqualTo []) exitWith {
    diag_log "[COIN] mortar: getaway: nobody is left who can drive away";
    false
};

// 1. The gunner gets out of the mortar
private _gunner = gunner _mortar;
if (!isNull _gunner && {alive _gunner}) then {
    unassignVehicle _gunner;
    _gunner action ["GetOut", _mortar];
    private _until = time + 5;
    waitUntil {sleep 0.5; vehicle _gunner isEqualTo _gunner || {time > _until}};
    if (vehicle _gunner isNotEqualTo _gunner) then {moveOut _gunner};
};

// 2. Into the car: the first drives, the others sit in the back
{_x enableAI "PATH"} forEach _crew;
private _driver = _crew select 0;
_driver assignAsDriver _car;
{_x assignAsCargo _car} forEach (_crew - [_driver]);
_crew orderGetIn true;
diag_log format ["[COIN] mortar: getaway: %1 fighters go to the car %2, %3 m away", count _crew, typeOf _car, round (_driver distance2D _car)];

private _boardEnd = time + COIN_mortarBoardSeconds;
waitUntil {sleep 2; (_crew findIf {alive _x && {vehicle _x isNotEqualTo _car}}) < 0 || {time > _boardEnd}};
// A driver who fell while boarding is replaced by the next fighter who is alive
if (!alive _driver) then {
    _driver = (_crew select {alive _x}) param [0, objNull];
    diag_log "[COIN] mortar: getaway: the driver fell, the next fighter drives";
};
if (alive _driver && {vehicle _driver isNotEqualTo _car}) then {_driver moveInDriver _car};
{
    if (alive _x && {vehicle _x isNotEqualTo _car}) then {_x moveInCargo _car};
} forEach (_crew - [_driver]);

if (!alive _driver || {!alive _car}) exitWith {
    diag_log "[COIN] mortar: getaway: the driver or the car is gone, no drive";
    false
};

// 3. Away from the FOB, 800 m from the mortar, on a road if there is one
private _towards = (_spot getDir _fob) + 180;
private _target = _spot getPos [COIN_mortarGetawayDistance + COIN_mortarGetawayOvershoot, _towards];
private _roads = _target nearRoads COIN_mortarGetawayRoadRadius;
if (_roads isNotEqualTo []) then {
    _roads = [_roads, [], {_x distance2D _target}, "ASCEND"] call BIS_fnc_sortBy;
    private _roadPos = getPosATL (_roads select 0);
    if ((_roadPos distance2D _spot) >= COIN_mortarGetawayDistance) then {_target = _roadPos};
};
if (surfaceIsWater _target) then {
    _target = [_target, 0, COIN_mortarGetawaySafeRadius, 5, 0, 0.3, 0] call BIS_fnc_findSafePos;
};
_target = [_target select 0, _target select 1, 0];

private _group = group _driver;
_group setBehaviour "SAFE";
_group setSpeedMode "FULL";
_driver doMove _target;
diag_log format ["[COIN] mortar: getaway: the car drives to %1, %2 m from the mortar, away from the FOB", _target apply {round _x}, round (_target distance2D _spot)];

private _driveEnd = time + COIN_mortarDriveSeconds;
waitUntil {
    sleep 5;
    (_car distance2D _spot) >= COIN_mortarGetawayDistance
    || {time > _driveEnd}
    || {!alive _driver}
    || {!alive _car}
};

private _away = alive _driver && {alive _car} && {(_car distance2D _spot) >= COIN_mortarGetawayDistance};
diag_log format [
    "[COIN] mortar: getaway: %1, the car is %2 m from the mortar (driver alive %3, car alive %4)",
    ["not away", "away"] select _away, round (_car distance2D _spot), alive _driver, alive _car
];
_away
