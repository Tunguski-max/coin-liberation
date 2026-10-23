/*
    File: fn_createVBIED.sqf
    Author: COIN Liberation

    Description:
        Sends one VBIED from a garage to a target (ticket 4.3, DESIGN 6, ADR 0022): a civilian vehicle of the garage's
        list (COIN_vbiedGarageVehicles) at a spawn point 800-1200 m from the target, out of sight, on a road
        (COIN_fnc_findVBIEDSpot), with a lone driver, a fighter in civilian clothes (COIN_fnc_createCivilianFighter,
        role "vbiedDriver"). He drives to the target, follows a moving one and ignores everything else
        (COIN_fnc_vbiedDrive). Destroying the vehicle sets the charge off (Killed event handler). Vehicle and driver
        are added to Zeus. Not saved. VBIED = [id, garage id, vehicle, driver, target]; appended to COIN_vbieds.
        Server only.

    Parameter(s):
        _garageId - Id of the garage [NUMBER]
        _target   - ["fob", position] or ["player", unit] (COIN_fnc_getVBIEDTargets) [ARRAY]

    Returns:
        The VBIED, [] if there was no spawn point or the vehicle could not be created [ARRAY]
*/

params [
    ["_garageId", -1, [0]],
    ["_target", [], [[]]]
];

if (!isServer) exitWith {[]};

_target params ["_kind", "_ref"];
private _targetPos = if (_kind isEqualTo "player") then {getPosATL _ref} else {_ref};

([_targetPos] call COIN_fnc_findVBIEDSpot) params [["_spot", []], ["_dir", 0]];
if (_spot isEqualTo []) exitWith {[]};

// A class of the list that does not exist (mod missing) is skipped, as at the garage itself
private _classes = COIN_vbiedGarageVehicles select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_classes isEqualTo []) exitWith {
    diag_log "[COIN] vbieds: ERROR - none of COIN_vbiedGarageVehicles exists, no VBIED";
    []
};
private _class = selectRandom _classes;
private _vehicle = createVehicle [_class, _spot, [], 0, "NONE"];
if (isNull _vehicle) exitWith {
    diag_log format ["[COIN] vbieds: ERROR - vehicle %1 could not be created, no VBIED", _class];
    []
};
_vehicle setDir _dir;
_vehicle setPosATL _spot;

private _driver = ["vbiedDriver", _spot, _dir] call COIN_fnc_createCivilianFighter;
_driver moveInDriver _vehicle;
// Standing still is the default of a fighter in civilian clothes; the driver drives
_driver enableAI "PATH";
(group _driver) setSpeedMode "FULL";

private _id = COIN_vbiedNextId;
COIN_vbiedNextId = _id + 1;
_vehicle setVariable ["COIN_vbiedId", _id];
_vehicle setVariable ["COIN_vbiedDriver", _driver];
// A destroyed vehicle sets the charge off, even long after the driver stopped or died
_vehicle addEventHandler ["Killed", {
    params ["_vehicle"];
    [_vehicle, "vehicle destroyed"] call COIN_fnc_explodeVBIED;
}];
[[_vehicle]] call COIN_fnc_addToCurators;

private _vbied = [_id, _garageId, _vehicle, _driver, _target];
COIN_vbieds pushBack _vbied;

diag_log format [
    "[COIN] vbieds: VBIED %1 (%2) of garage %3 starts at %4, %5 m from its target (%6 %7)",
    _id, _class, _garageId, _spot, round (_spot distance2D _targetPos), _kind, if (_kind isEqualTo "player") then {name _ref} else {_ref}
];

[_id] spawn COIN_fnc_vbiedDrive;

_vbied
