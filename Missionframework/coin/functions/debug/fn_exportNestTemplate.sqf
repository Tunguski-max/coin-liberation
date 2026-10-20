/*
    File: fn_exportNestTemplate.sqf
    Author: COIN Liberation

    Description:
        Export of a building template (ADR 0019, ticket #44): takes the house the player looks at (or the nearest
        building) and every placed object inside its outline, and writes them with class, position in the house model,
        direction relative to the house and role as one line "COIN_nestBuildingTemplates pushBack [...];" to the
        clipboard and the RPT, ready to paste into coin_templates.sqf.
        Role: "core" for the object with the variable name "core" (Eden) or, if there is none, the first object of the
        type's class in COIN_nestCores; "mine" for mines (live, decided 2026-10-20); "vehicle" for land vehicles;
        "prop" for the rest.
        Only objects placed in the editor or by Zeus count: no terrain objects, units, logics, weapon holders or the
        player's vehicle, no ambient effects. Positions are taken at the object's contact point
        (getPosASL), as the spawn sets them.
        For the debug console of the mission; docs/templates.md has the same export for a plain Eden scenario.
        The clipboard works in single player and on the local host only.

    Parameter(s):
        _type  - Nest type the template is for, e.g. "vbiedGarage" [STRING]
        _house - House, objNull for the one the player looks at [OBJECT, defaults to objNull]

    Returns:
        Template line, "" if there is no house [STRING]
*/

params [
    ["_type", "", [""]],
    ["_house", objNull, [objNull]]
];

if (isNull _house) then {
    _house = [nearestBuilding player, cursorObject] select (cursorObject isKindOf "House");
};
if (isNull _house) exitWith {
    hint "No house found";
    ""
};

// Objects up to this far outside the house outline still belong to it, e.g. a vehicle in front of a garage
private _margin = 3;
([_house] call COIN_fnc_halfSize) params ["_halfX", "_halfY"];
private _coreClass = ([COIN_nestCores, _type] call COIN_fnc_findByType) param [1, ""];

private _inside = {
    private _local = _house worldToModel (ASLToAGL (getPosASL _x));
    abs (_local select 0) <= _halfX + _margin && {abs (_local select 1) <= _halfY + _margin}
};

// Search radius reaches the corners of the outline, the rectangle check does the rest
private _objects = (nearestObjects [_house, [], vectorMagnitude [_halfX + _margin, _halfY + _margin, 0]]) select {
    !(_x isEqualTo _house)
    && {getObjectType _x == 8}
    && {!(_x isKindOf "CAManBase")}
    && {!(_x isKindOf "Logic")}
    && {!(_x isKindOf "WeaponHolder")}
    // Placeable objects only: no ambient effects (FxWindGrass, HouseFly), mines are added below
    && {isClass (configFile >> "CfgVehicles" >> typeOf _x)}
    && {((typeOf _x) find "Fx") != 0}
    && {!(_x isEqualTo (vehicle player))}
    && _inside
};
_objects append (allMines select _inside);

private _coreIndex = _objects findIf {(vehicleVarName _x) isEqualTo "core"};
if (_coreIndex < 0) then {
    _coreIndex = _objects findIf {(typeOf _x) isEqualTo _coreClass};
};

private _entries = [];
{
    private _local = _house worldToModel (ASLToAGL (getPosASL _x));
    private _dir = ((getDir _x) - (getDir _house) + 360) mod 360;
    private _role = switch (true) do {
        case (_forEachIndex == _coreIndex): {"core"};
        case (_x in allMines): {"mine"};
        case (_x isKindOf "LandVehicle"): {"vehicle"};
        default {"prop"};
    };
    _entries pushBack format [
        "[""%1"",[%2,%3,%4],%5,""%6""]",
        typeOf _x, (_local select 0) toFixed 3, (_local select 1) toFixed 3, (_local select 2) toFixed 3, _dir toFixed 1, _role
    ];
} forEach _objects;

private _text = format ["COIN_nestBuildingTemplates pushBack [""%1"",""%2"",[%3]];", _type, typeOf _house, _entries joinString ","];
copyToClipboard _text;
diag_log format ["[COIN] debug: template of %1 in %2 with %3 objects%4", _type, typeOf _house, count _objects, ["", ", no core object found"] select (_coreIndex < 0)];
diag_log _text;
hint format [
    "Template %1 in %2: %3 objects%4, %5",
    _type, typeOf _house, count _objects, ["", ", NO core object"] select (_coreIndex < 0),
    ["text in the RPT only (no clipboard on a dedicated server)", "copied to the clipboard and in the RPT"] select isServer
];

_text
