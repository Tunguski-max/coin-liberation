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

private _row = [COIN_nestSetup, _type] call COIN_fnc_findByType;
if (_row isEqualTo []) exitWith {
    diag_log format ["[COIN] nests: ERROR - nest type %1 is missing in COIN_nestSetup, radius 0", _type];
    0
};

_row select 2
