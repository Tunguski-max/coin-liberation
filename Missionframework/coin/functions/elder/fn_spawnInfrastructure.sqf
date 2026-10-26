/*
    File: fn_spawnInfrastructure.sqf
    Author: COIN Liberation

    Description:
        Server: makes the devices of an aid task "Repair infrastructure" (ticket 5.12, DESIGN 8.2): COIN_aidRepairObjects
        (rolled) generators (classes of COIN_aidRepairClasses that exist in this game), each at a free spot
        (BIS_fnc_findSafePos) around the place (the elder's place in the town, or with a site (ticket 5.21) the centre of the
        village), at least the first value of the radius from it and COIN_aidRepairSpacing from each other. A device that finds no such spot in COIN_aidRepairSpotTries tries is left
        out. Each one smokes (an object of COIN_aidRepairSmokeClass, a global object, so a late joiner sees it), cannot
        be destroyed and waits for a repair (COIN_infraOpen, public). Every client gets the action "Repair"
        (COIN_fnc_addRepairAction) with the device as JIP key. Handed to Zeus with its smoke. The devices are repaired
        through COIN_fnc_repairInfrastructure and closed by COIN_fnc_closeInfrastructure.

    Parameter(s):
        _taskId - Id of the Arma task, for the log [STRING, defaults to ""]
        _town   - Name of the town or village, for the log [STRING, defaults to ""]
        _pos    - Where the elder stands, or the village centre [ARRAY, defaults to [0, 0, 0]]
        _radius - [min, max] m from _pos where a device stands [ARRAY, defaults to COIN_aidRepairRadius]

    Returns:
        [devices, smokes], the smoke is also given back so the task can remove it if Zeus deleted its device [ARRAY of ARRAYs of OBJECTs]
*/

params [
    ["_taskId", "", [""]],
    ["_town", "", [""]],
    ["_pos", [0, 0, 0], [[]]],
    ["_radius", COIN_aidRepairRadius, [[]]]
];

if (!isServer || {_taskId isEqualTo ""}) exitWith {[[], []]};

private _classes = COIN_aidRepairClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_classes isEqualTo []) exitWith {
    diag_log format ["[COIN] aid: ERROR - none of the classes of COIN_aidRepairClasses exists, no devices in %1", _town];
    [[], []]
};

COIN_aidRepairObjects params ["_min", "_max"];
_radius params ["_minRadius", "_maxRadius"];
private _count = _min + floor (random ((_max - _min) + 1));

private _devices = [];
private _spots = [];
private _created = [];
private _smokes = [];

for "_i" from 1 to _count do {
    // A free spot that is far enough from the elder and from the other devices; none after the tries, no device
    private _spot = [];
    for "_try" from 1 to COIN_aidRepairSpotTries do {
        private _candidate = [_pos, _minRadius, _maxRadius, COIN_aidRepairSpotClearance, 0, COIN_aidRepairMaxGradient, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
        if (
            _candidate isEqualType []
            && {count _candidate >= 2}
            && {(_candidate select 0) isEqualType 0}
            && {(_candidate distance2D _pos) >= _minRadius}
            && {(_spots findIf {(_x distance2D _candidate) < COIN_aidRepairSpacing}) < 0}
        ) exitWith {_spot = _candidate};
    };
    if (_spot isEqualTo []) then {
        diag_log format ["[COIN] aid: no spot for device %1 in %2", _i, _town];
        continue;
    };
    _spots pushBack _spot;

    private _device = createVehicle [selectRandom _classes, [_spot select 0, _spot select 1, 0], [], 0, "CAN_COLLIDE"];
    _device setDir (random 360);
    _device setPosATL [_spot select 0, _spot select 1, 0];
    _device allowDamage false;

    private _smoke = createVehicle [COIN_aidRepairSmokeClass, [_spot select 0, _spot select 1, COIN_aidRepairSmokeHeight], [], 0, "CAN_COLLIDE"];


    // COIN_infraOpen is public (the action shows), the rest is the server's
    _device setVariable ["COIN_infra", true, true];
    _device setVariable ["COIN_infraOpen", true, true];
    _device setVariable ["COIN_infraSmoke", _smoke];
    _device setVariable ["COIN_infraTown", _town];

    [_device] remoteExec ["COIN_fnc_addRepairAction", 0, _device];

    _devices pushBack _device;
    _created pushBack _device;
    _created pushBack _smoke;
    _smokes pushBack _smoke;
};

[_created] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] aid: %1 devices in %2 (%3), %4 to %5 m from the elder at %6",
    count _devices, _town, _devices apply {typeOf _x}, _minRadius, _maxRadius, _pos apply {round _x}
];

[_devices, _smokes]
