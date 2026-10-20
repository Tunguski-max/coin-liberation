/*
    File: fn_validateNestContent.sqf
    Author: COIN Liberation

    Description:
        Checks the classes of COIN_nestCores and COIN_nestProps once on server start (ticket 2.3).
        A core object must be a class Arma can destroy: it exists, its destrType is not "DestructNo" and it has armor.
        Otherwise the type gets COIN_nestCoreFallback. Props only have to exist, missing ones are left out.
        Every core class is logged with destrType and armor, so it can be compared with the test in game.
        Fills COIN_nestValidCores (type -> class) and COIN_nestValidProps (type -> classes).

    Parameter(s):
        NONE

    Returns:
        Number of core classes that had to be replaced [NUMBER]
*/

if (!isServer) exitWith {0};

private _describe = {
    params ["_class"];
    private _cfg = configFile >> "CfgVehicles" >> _class;
    [isClass _cfg, getText (_cfg >> "destrType"), getNumber (_cfg >> "armor")]
};
private _destructible = {
    params ["_class"];
    ([_class] call _describe) params ["_exists", "_destrType", "_armor"];
    _exists && {!(_destrType isEqualTo "DestructNo")} && {_armor > 0}
};

([COIN_nestCoreFallback] call _describe) params ["_fbExists", "_fbDestrType", "_fbArmor"];
if !([COIN_nestCoreFallback] call _destructible) then {
    diag_log format ["[COIN] nests: WARNING - fallback core %1 may not be destructible (exists %2, destrType %3, armor %4)", COIN_nestCoreFallback, _fbExists, _fbDestrType, _fbArmor];
};

COIN_nestValidCores = createHashMap;
private _replaced = 0;
{
    _x params ["_type", "_class"];
    ([_class] call _describe) params ["_exists", "_destrType", "_armor"];
    if ([_class] call _destructible) then {
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

_replaced
