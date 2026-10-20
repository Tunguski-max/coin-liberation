/*
    File: fn_isDestructible.sqf
    Author: COIN Liberation

    Description:
        Can Arma destroy objects of this class (ticket 2.3)? The class exists, its destrType is not "DestructNo"
        and it has armor. Used for the core objects of nests.

    Parameter(s):
        _class - Class name [STRING]

    Returns:
        [destructible, exists, destrType, armor] [ARRAY]
*/

params [
    ["_class", "", [""]]
];

private _cfg = configFile >> "CfgVehicles" >> _class;
private _exists = isClass _cfg;
private _destrType = getText (_cfg >> "destrType");
private _armor = getNumber (_cfg >> "armor");

[_exists && {!(_destrType isEqualTo "DestructNo")} && {_armor > 0}, _exists, _destrType, _armor]
