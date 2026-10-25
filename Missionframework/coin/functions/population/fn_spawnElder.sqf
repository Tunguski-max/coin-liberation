/*
    File: fn_spawnElder.sqf
    Author: COIN Liberation

    Description:
        Spawns the elder of a liberated town (ticket 5.9a, DESIGN 8, ADR 0011): a civilian made like the others of the own
        population (preset list civilians, KPLIB_fnc_createManagedUnit, so killing him costs reputation through
        Liberation's kill manager), in a group of his own without waypoints, so he stands where he is put and does not
        walk around. He gets the clothes of COIN_elderUniforms and COIN_elderHeadgear (classes that do not exist are
        left out) and the name COIN_elderNameFormat with the name of the town. He is marked COIN_elder, which the
        interpreter's question about the militia respects (COIN_fnc_canQuestion). Handed to Zeus; in debug mode he is
        on the map. Server only.

    Parameter(s):
        _sector - Sector marker of the town [STRING, defaults to ""]
        _spot   - [position, direction] where he stands, from COIN_fnc_findElderSpot [ARRAY, defaults to []]

    Returns:
        The elder [OBJECT, objNull if none was made]
*/

params [
    ["_sector", "", [""]],
    ["_spot", [], [[]]]
];

if (!isServer || {_sector isEqualTo ""} || {_spot isEqualTo []}) exitWith {objNull};
_spot params ["_pos", "_dir"];

private _group = createGroup [GRLIB_side_civilian, true];
private _elder = [selectRandom civilians, _pos, _group] call KPLIB_fnc_createManagedUnit;
if (isNull _elder) exitWith {
    diag_log format ["[COIN] population: ERROR - the elder of %1 (%2) could not be created", markerText _sector, _sector];
    objNull
};

_elder setVariable ["COIN_elder", true, true];
_elder setDir _dir;
_elder setPosATL [_pos select 0, _pos select 1, 0];
_elder disableAI "PATH";

// Clothes from the config, a class without the mod is left out
private _uniforms = COIN_elderUniforms select {isClass (configFile >> "CfgWeapons" >> _x)};
if (_uniforms isNotEqualTo []) then {
    _elder forceAddUniform (selectRandom _uniforms);
};
private _headgear = COIN_elderHeadgear select {isClass (configFile >> "CfgWeapons" >> _x)};
if (_headgear isNotEqualTo []) then {
    removeHeadgear _elder;
    _elder addHeadgear (selectRandom _headgear);
};

private _name = format [COIN_elderNameFormat, markerText _sector];
[_elder, _name] remoteExecCall ["setName", 0, _elder];

[[_elder]] call COIN_fnc_addToCurators;

if (COIN_debug) then {
    private _marker = format ["COIN_elder_%1", _sector];
    deleteMarker _marker;
    createMarker [_marker, _pos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorCIV";
    _marker setMarkerSize [0.7, 0.7];
    _marker setMarkerText _name;
};

diag_log format [
    "[COIN] population: %1 (%2) has the elder %3 (%4) at %5, facing %6",
    markerText _sector, _sector, _name, typeOf _elder, _pos apply {round _x}, round _dir
];

_elder
