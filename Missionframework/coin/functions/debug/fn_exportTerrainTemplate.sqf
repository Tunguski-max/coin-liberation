/*
    File: fn_exportTerrainTemplate.sqf
    Author: COIN Liberation

    Description:
        Export of a terrain template (ADR 0020, ticket #31): takes the centre arrow (the object with the variable name
        "centre", otherwise the nearest COIN_terrainTemplateCentreClass within COIN_terrainTemplateCentreSearch of the
        player) and every placed object within COIN_terrainTemplateRadius of it, and writes them with class, offset
        from the arrow (x to its right, y to its front), height above the terrain, direction relative to the arrow and
        role as one line "COIN_terrainTemplates pushBack [...];" to the clipboard and the RPT, ready to paste into
        coin_templates.sqf. The arrow itself is not exported.
        Role: "core" for the object with the variable name "core" or, if there is none, the first object of the type's
        class in COIN_nestCores (camps have no core object); "mine" for mines; "vehicle" for land vehicles; "prop" for
        the rest. Only objects placed in the editor or by Zeus count, as in COIN_fnc_exportNestTemplate.
        For the debug console of the mission; docs/templates.md has the same export for a plain Eden scenario.
        The clipboard works in single player and on the local host only.

    Parameter(s):
        _type - Nest type the template is for, e.g. "cache", or "camp" [STRING]

    Returns:
        Template line, "" if there is no centre arrow [STRING]
*/

params [
    ["_type", "", [""]]
];

private _centre = missionNamespace getVariable ["centre", objNull];
if !(_centre isEqualType objNull) then {_centre = objNull};
if (isNull _centre) then {
    _centre = (nearestObjects [player, [COIN_terrainTemplateCentreClass], COIN_terrainTemplateCentreSearch]) param [0, objNull];
};
if (isNull _centre) exitWith {
    hint format ["No centre arrow (%1) within %2 m", COIN_terrainTemplateCentreClass, COIN_terrainTemplateCentreSearch];
    ""
};

private _isCamp = _type isEqualTo "camp";
private _coreClass = if (_isCamp) then {""} else {([COIN_nestCores, _type] call COIN_fnc_findByType) param [1, ""]};
private _centreDir = getDir _centre;
private _inside = {(_x distance2D _centre) <= COIN_terrainTemplateRadius};

private _objects = (nearestObjects [_centre, [], COIN_terrainTemplateRadius]) select {
    !(_x isEqualTo _centre)
    && {getObjectType _x == 8}
    && {!(_x isKindOf "CAManBase")}
    && {!(_x isKindOf "Logic")}
    && {!(_x isKindOf "WeaponHolder")}
    // Placeable objects only: no ambient effects (FxWindGrass, HouseFly), mines are added below
    && {isClass (configFile >> "CfgVehicles" >> typeOf _x)}
    && {((typeOf _x) find "Fx") != 0}
    && {!(_x isEqualTo (vehicle player))}
};
_objects append (allMines select _inside);

private _coreIndex = -1;
if (!_isCamp) then {
    _coreIndex = _objects findIf {(vehicleVarName _x) isEqualTo "core"};
    if (_coreIndex < 0) then {
        _coreIndex = _objects findIf {(typeOf _x) isEqualTo _coreClass};
    };
};

private _entries = [];
{
    // Offset in the arrow's frame: x to its right, y to its front
    ((getPosASL _x) vectorDiff (getPosASL _centre)) params ["_dx", "_dy"];
    private _right = _dx * cos _centreDir - _dy * sin _centreDir;
    private _front = _dx * sin _centreDir + _dy * cos _centreDir;
    private _dir = ((getDir _x) - _centreDir + 360) mod 360;
    private _role = switch (true) do {
        case (_forEachIndex == _coreIndex): {"core"};
        case (_x in allMines): {"mine"};
        case (_x isKindOf "LandVehicle"): {"vehicle"};
        default {"prop"};
    };
    _entries pushBack format [
        "[""%1"",[%2,%3,%4],%5,""%6""]",
        typeOf _x, _right toFixed 3, _front toFixed 3, ((getPosATL _x) select 2) toFixed 3, _dir toFixed 1, _role
    ];
} forEach _objects;

private _text = format ["COIN_terrainTemplates pushBack [""%1"",[%2]];", _type, _entries joinString ","];
private _coreMissing = !_isCamp && {_coreIndex < 0};
copyToClipboard _text;
diag_log format ["[COIN] debug: terrain template of %1 with %2 objects%3", _type, count _objects, ["", ", no core object found"] select _coreMissing];
diag_log _text;
hint format [
    "Terrain template %1: %2 objects%3, %4",
    _type, count _objects, ["", ", NO core object"] select _coreMissing,
    ["text in the RPT only (no clipboard on a dedicated server)", "copied to the clipboard and in the RPT"] select isServer
];

_text
