/*
    File: fn_removeIntel.sqf
    Author: COIN Liberation

    Description:
        Server: removes one intel from COIN_intel and deletes its map markers (circle, symbol and, with COIN_debug, the
        marker of the fake point). Used for a true intel whose nest is destroyed (COIN_fnc_removeIntelOfNest) and for a
        lie that has been searched (COIN_fnc_intelSearchLoop). The save is the caller's business.

    Parameter(s):
        _intel - [id, nestId, center, radius, level, shownType, fakePos] [ARRAY, defaults to []]

    Returns:
        Intel was in the list [BOOL]
*/

params [
    ["_intel", [], [[]]]
];

if (!isServer || {count _intel < 7}) exitWith {false};

private _id = _intel select 0;
private _index = COIN_intel findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {false};

COIN_intel deleteAt _index;
deleteMarker format ["COIN_intel_%1_area", _id];
deleteMarker format ["COIN_intel_%1", _id];
deleteMarker format ["COIN_intel_%1_fake", _id];

true
