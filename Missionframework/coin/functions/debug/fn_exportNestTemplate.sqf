/*
    File: fn_exportNestTemplate.sqf
    Author: COIN Liberation

    Description:
        Export of a building template (ADR 0019, ticket #44): takes the house the player looks at (or the nearest
        building) and every placed object inside its outline, and writes them with class, position in the house model,
        direction relative to the house and role to the clipboard, in the format of coin_templates.sqf.
        Role: "core" for the object with the variable name "core" (Eden) or, if there is none, the first object of the
        type's class in COIN_nestCores; "vehicle" for land vehicles; "prop" for the rest. Units and the player are left out.
        For the debug console of the mission (local host); the test guide of #44 has the same code for an Eden scenario.

    Parameter(s):
        _type  - Nest type the template is for, e.g. "vbiedGarage" [STRING]
        _house - House, objNull for the one the player looks at [OBJECT, defaults to objNull]

    Returns:
        Template as text, "" if there is no house [STRING]
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

private _objects = (nearestObjects [_house, [], (_halfX max _halfY) + _margin]) select {
    private _local = _house worldToModel (ASLToAGL (getPosASL _x));
    !(_x isEqualTo _house)
    && {getObjectType _x >= 8}
    && {!(_x isKindOf "CAManBase")}
    && {abs (_local select 0) <= _halfX + _margin}
    && {abs (_local select 1) <= _halfY + _margin}
};

private _coreIndex = _objects findIf {(vehicleVarName _x) isEqualTo "core"};
if (_coreIndex < 0) then {
    _coreIndex = _objects findIf {(typeOf _x) isEqualTo _coreClass};
};

private _lines = [];
{
    private _local = _house worldToModel (ASLToAGL (getPosASL _x));
    private _dir = ((getDir _x) - (getDir _house) + 360) mod 360;
    private _role = switch (true) do {
        case (_forEachIndex == _coreIndex): {"core"};
        case (_x isKindOf "LandVehicle"): {"vehicle"};
        default {"prop"};
    };
    _lines pushBack format [
        "        [""%1"", [%2, %3, %4], %5, ""%6""]",
        typeOf _x, (_local select 0) toFixed 3, (_local select 1) toFixed 3, (_local select 2) toFixed 3, _dir toFixed 1, _role
    ];
} forEach _objects;

private _text = format ["    [""%1"", ""%2"", [%3%4%3    ]],", _type, typeOf _house, toString [10], _lines joinString ("," + toString [10])];
copyToClipboard _text;
diag_log format ["[COIN] debug: template of %1 in %2 with %3 objects%4", _type, typeOf _house, count _objects, ["", ", no core object found"] select (_coreIndex < 0)];
diag_log _text;
hint format ["Template %1 in %2: %3 objects%4, copied to the clipboard", _type, typeOf _house, count _objects, ["", ", NO core object"] select (_coreIndex < 0)];

_text
