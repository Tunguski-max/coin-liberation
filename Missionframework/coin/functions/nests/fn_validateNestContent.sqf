/*
    File: fn_validateNestContent.sqf
    Author: COIN Liberation

    Description:
        Checks the content classes once on server start (ticket 2.3, ADR 0019):
        - core objects (COIN_nestCores) must be classes Arma can destroy (COIN_fnc_isDestructible), otherwise the type
          gets COIN_nestCoreFallback. Every core class is logged with destrType and armor.
        - props (COIN_nestProps) only have to exist, missing ones are left out.
        - building templates (COIN_nestBuildingTemplates) and terrain templates (COIN_terrainTemplates): objects of
          missing classes are left out, a nest template needs exactly one core object, a camp template none; a core
          class that cannot be destroyed is replaced by the type's core object.
        Fills COIN_nestValidCores (type -> class), COIN_nestValidProps (type -> classes),
        COIN_nestValidTemplates ([type, house class in lower case, objects]) and
        COIN_validTerrainTemplates ([type or "camp", objects]).

    Parameter(s):
        NONE

    Returns:
        Number of core classes that had to be replaced [NUMBER]
*/

if (!isServer) exitWith {0};

([COIN_nestCoreFallback] call COIN_fnc_isDestructible) params ["_fbOk", "_fbExists", "_fbDestrType", "_fbArmor"];
if (!_fbOk) then {
    diag_log format ["[COIN] nests: WARNING - fallback core %1 may not be destructible (exists %2, destrType %3, armor %4)", COIN_nestCoreFallback, _fbExists, _fbDestrType, _fbArmor];
};

COIN_nestValidCores = createHashMap;
private _replaced = 0;
{
    _x params ["_type", "_class"];
    ([_class] call COIN_fnc_isDestructible) params ["_ok", "_exists", "_destrType", "_armor"];
    if (_ok) then {
        COIN_nestValidCores set [_type, _class];
        diag_log format ["[COIN] nests: core of %1 is %2 (destrType %3, armor %4)", _type, _class, _destrType, _armor];
    } else {
        COIN_nestValidCores set [_type, COIN_nestCoreFallback];
        _replaced = _replaced + 1;
        diag_log format ["[COIN] nests: core %1 of %2 cannot be destroyed (exists %3, destrType %4, armor %5), using %6", _class, _type, _exists, _destrType, _armor, COIN_nestCoreFallback];
    };
} forEach COIN_nestCores;

COIN_nestValidProps = createHashMap;
{
    _x params ["_type", "_classes"];
    private _valid = _classes select {isClass (configFile >> "CfgVehicles" >> _x)};
    private _missing = _classes - _valid;
    if !(_missing isEqualTo []) then {
        diag_log format ["[COIN] nests: props of %1 not found and left out: %2", _type, _missing];
    };
    COIN_nestValidProps set [_type, _valid];
} forEach COIN_nestProps;

// Mine class (CfgVehicles, e.g. ATMine) that uses an ammunition class (e.g. ATMine_Range_Ammo), "" if none.
// Looked up once per ammunition, the search runs over all of CfgVehicles
private _mineClasses = createHashMap;
private _mineClassOf = {
    params ["_ammo"];
    if !(_ammo in _mineClasses) then {
        private _found = "";
        {
            if ((getText (_x >> "ammo")) isEqualTo _ammo && {(configName _x) isKindOf "MineBase"}) exitWith {
                _found = configName _x;
            };
        } forEach ("true" configClasses (configFile >> "CfgVehicles"));
        _mineClasses set [_ammo, _found];
    };
    _mineClasses get _ammo
};

// Usable objects of one template, [] if the template is not used: malformed entries and missing classes are left out,
// mines get their mine class, the template needs exactly _coresWanted core objects (1 for a nest, 0 for a camp),
// a core class that cannot be destroyed is replaced by the type's core object
private _checkObjects = {
    params ["_label", "_type", "_objects", "_coresWanted"];
    // Entries must be [class, [x, y, z], direction, role]
    private _wellFormed = _objects select {_x isEqualTypeParams ["", [], 0, ""] && {count (_x select 1) == 3}};
    if (count _wellFormed < count _objects) then {
        diag_log format ["[COIN] nests: ERROR - %1: malformed entries left out: %2", _label, _objects - _wellFormed];
    };
    // Deep copy, so a replaced core class does not change the config list
    _wellFormed = +_wellFormed;
    // Mines are exported as their ammunition (what Eden places), createMine needs the mine class that uses it
    {
        _x params ["_class", "", "", "_role"];
        if (_role isEqualTo "mine" && {!isClass (configFile >> "CfgVehicles" >> _class)}) then {
            _x set [0, [_class] call _mineClassOf];
        };
    } forEach _wellFormed;
    private _valid = _wellFormed select {isClass (configFile >> "CfgVehicles" >> (_x select 0))};
    if (count _valid < count _wellFormed) then {
        diag_log format ["[COIN] nests: %1: classes not found and left out: %2", _label, (_wellFormed - _valid) apply {_x select 0}];
    };
    private _cores = _valid select {(_x select 3) isEqualTo "core"};
    if (count _cores != _coresWanted) exitWith {
        diag_log format ["[COIN] nests: ERROR - %1 has %2 core objects instead of %3, not used", _label, count _cores, _coresWanted];
        []
    };
    {
        if !(([_x select 0] call COIN_fnc_isDestructible) select 0) then {
            private _class = COIN_nestValidCores getOrDefault [_type, COIN_nestCoreFallback];
            diag_log format ["[COIN] nests: %1: core %2 cannot be destroyed, using %3", _label, _x select 0, _class];
            _x set [0, _class];
        };
    } forEach _cores;
    _valid
};

COIN_nestValidTemplates = [];
{
    _x params [["_type", ""], ["_houseClass", ""], ["_objects", []]];
    private _valid = [format ["template %1 of %2 in %3", _forEachIndex, _type, _houseClass], _type, _objects, 1] call _checkObjects;
    if !(_valid isEqualTo []) then {
        COIN_nestValidTemplates pushBack [_type, toLower _houseClass, _valid];
    };
} forEach COIN_nestBuildingTemplates;
diag_log format ["[COIN] nests: %1 of %2 building templates usable", count COIN_nestValidTemplates, count COIN_nestBuildingTemplates];

// Terrain templates: nest types need one core object, camps none
COIN_validTerrainTemplates = [];
{
    _x params [["_type", ""], ["_objects", []]];
    private _label = format ["terrain template %1 of %2", _forEachIndex, _type];
    private _isCamp = _type isEqualTo "camp";
    if (!_isCamp && {([COIN_nestCores, _type] call COIN_fnc_findByType) isEqualTo []}) then {
        diag_log format ["[COIN] nests: ERROR - %1: unknown type (nest type or ""camp""), not used", _label];
        continue;
    };
    private _valid = [_label, _type, _objects, [1, 0] select _isCamp] call _checkObjects;
    if !(_valid isEqualTo []) then {
        COIN_validTerrainTemplates pushBack [_type, _valid];
    };
} forEach COIN_terrainTemplates;
diag_log format [
    "[COIN] nests: %1 of %2 terrain templates usable (%3 for camps), nest types without one: %4",
    count COIN_validTerrainTemplates, count COIN_terrainTemplates,
    {(_x select 0) isEqualTo "camp"} count COIN_validTerrainTemplates,
    (COIN_nestCores apply {_x select 0}) select {
        private _type = _x;
        (COIN_validTerrainTemplates findIf {(_x select 0) isEqualTo _type}) < 0
    }
];

_replaced
