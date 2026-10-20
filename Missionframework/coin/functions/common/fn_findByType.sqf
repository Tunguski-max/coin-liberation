/*
    File: fn_findByType.sqf
    Author: COIN Liberation

    Description:
        Row of a config table that is keyed by nest type in its first column
        (COIN_nestSetup, COIN_nestBuildingShare, COIN_nestDebugColors, later COIN_campsPerNest, COIN_nestReadinessDrop).

    Parameter(s):
        _table - Config table [ARRAY of ARRAYs]
        _type  - Nest type, e.g. "command" [STRING]

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
