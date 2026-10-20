/*
    File: fn_getNestRadius.sqf
    Author: COIN Liberation

    Description:
        Influence radius of a nest type from COIN_nestSetup. The radius is not saved (ADR 0018),
        so a changed value applies to running campaigns as well.

    Parameter(s):
        _type - Nest type, e.g. "command" [STRING]

    Returns:
        Influence radius in m, 0 for a type missing in COIN_nestSetup [NUMBER]
*/

params [
    ["_type", "", [""]]
];

private _index = COIN_nestSetup findIf {(_x select 0) isEqualTo _type};
if (_index < 0) exitWith {
    diag_log format ["[COIN] nests: ERROR - nest type %1 is missing in COIN_nestSetup, radius 0", _type];
    0
};

(COIN_nestSetup select _index) select 2
