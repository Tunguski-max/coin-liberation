/*
    File: fn_removeIntelOfNest.sqf
    Author: COIN Liberation

    Description:
        Server: removes every intel that points to a nest, with its map markers (ticket 3.2, ADR 0021: a true marker
        disappears with its nest). Called on the event COIN_nestDestroyed (set in COIN_fnc_loadIntel). The save is not
        triggered here: COIN_fnc_destroyNest saves right after the event, and that save already holds the shortened list.
        A lie (nest id -1) is no intel of any nest and stays.

    Parameter(s):
        _nestId - Nest id [NUMBER, defaults to -1]

    Returns:
        Number of intel removed [NUMBER]
*/

params [
    ["_nestId", -1, [0]]
];

if (!isServer || {_nestId < 0}) exitWith {0};

private _removed = COIN_intel select {(_x select 1) isEqualTo _nestId};
{
    deleteMarker format ["COIN_intel_%1_area", _x select 0];
    deleteMarker format ["COIN_intel_%1", _x select 0];
} forEach _removed;
COIN_intel = COIN_intel select {!((_x select 1) isEqualTo _nestId)};

if !(_removed isEqualTo []) then {
    diag_log format ["[COIN] intel: nest %1 destroyed, %2 intel removed (ids %3), %4 left", _nestId, count _removed, _removed apply {_x select 0}, count COIN_intel];
};

count _removed
