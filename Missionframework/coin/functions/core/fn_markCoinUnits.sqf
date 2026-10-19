/*
    File: fn_markCoinUnits.sqf
    Author: COIN Liberation

    Description:
        Marks units as spawned by the COIN layer (nest guards, camp fighters, crews), so the AI budget can count
        them and put them on top of Liberation's caps (ADR 0015, ticket 2.13). Every COIN spawn calls this for its units.
        The mark lives on the unit, so it ends with the unit. Must run where the units are created, i.e. on the server.

    Parameter(s):
        _units - Units to mark [ARRAY of OBJECTs]

    Returns:
        Number of marked units [NUMBER]
*/

params [
    ["_units", [], [[]]]
];

private _marked = 0;
{
    if (!isNull _x) then {
        _x setVariable ["COIN_isCoinUnit", true];
        _marked = _marked + 1;
    };
} forEach _units;

_marked
