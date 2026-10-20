/*
    File: fn_debugNestContent.sqf
    Author: COIN Liberation

    Description:
        Debug helper for tuning the props of a nest type (ticket #44): puts the core object, every prop of
        COIN_nestProps and, for the VBIED garage, every vehicle of COIN_vbiedGarageVehicles in a row in front of the
        player, each with a map marker and an RPT line (class, destrType, armor). Called with "" it removes them again.
        Local host / debug console only ("Lokal ausführen"), the objects are not saved by Liberation.

    Parameter(s):
        _type - Nest type, e.g. "iedWorkshop", or "" to clear [STRING]

    Returns:
        Number of objects spawned [NUMBER]
*/

params [
    ["_type", "", [""]]
];

// Spacing of the row in m
private _spacing = 5;

{
    deleteVehicle _x;
} forEach (missionNamespace getVariable ["COIN_debugContent", []]);
{
    deleteMarkerLocal _x;
} forEach (allMapMarkers select {(_x find "COIN_debugContent_") == 0});
COIN_debugContent = [];

if (_type isEqualTo "") exitWith {0};

private _classes = [([COIN_nestCores, _type] call COIN_fnc_findByType) param [1, COIN_nestCoreFallback]];
_classes append (([COIN_nestProps, _type] call COIN_fnc_findByType) param [1, []]);
if (_type isEqualTo "vbiedGarage") then {
    _classes append COIN_vbiedGarageVehicles;
};

private _origin = player getPos [10, getDir player];
private _side = (getDir player) + 90;
{
    private _class = _x;
    private _cfg = configFile >> "CfgVehicles" >> _class;
    private _label = format ["%1 %2%3", _forEachIndex, _class, ["", " (core)"] select (_forEachIndex == 0)];
    if (isClass _cfg) then {
        private _pos = _origin getPos [_forEachIndex * _spacing, _side];
        private _object = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
        _object setVariable ["KP_liberation_preplaced", true];
        COIN_debugContent pushBack _object;
        private _marker = createMarkerLocal [format ["COIN_debugContent_%1", _forEachIndex], _pos];
        _marker setMarkerTypeLocal "mil_dot";
        _marker setMarkerTextLocal _label;
        diag_log format ["[COIN] debug: %1, destrType %2, armor %3", _label, getText (_cfg >> "destrType"), getNumber (_cfg >> "armor")];
    } else {
        diag_log format ["[COIN] debug: %1 does not exist", _label];
    };
} forEach _classes;

[COIN_debugContent] call COIN_fnc_addToCurators;
hint format ["%1: %2 objects, numbers on the map and in the RPT", _type, count COIN_debugContent];

count COIN_debugContent
