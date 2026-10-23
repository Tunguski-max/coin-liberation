/*
    File: fn_findByType.sqf
    Author: COIN Liberation

    Description:
        Row of a config table that is keyed by a type or kind (nest type, warning kind) in its first column
        (COIN_nestSetup, COIN_nestBuildingShare, COIN_nestDebugColors, COIN_campsPerNest, COIN_nestReadinessDrop, COIN_warningKinds).

    Parameter(s):
        _table - Config table [ARRAY of ARRAYs]
        _type  - Nest type, e.g. "command", or kind, e.g. "ied" [STRING]

    Returns:
        Row of the type, [] if the table has no row for it [ARRAY]
*/

params [
    ["_table", [], [[]]],
    ["_type", "", [""]]
];

private _index = _table findIf {(_x select 0) isEqualTo _type};
if (_index < 0) exitWith {[]};

_table select _index
