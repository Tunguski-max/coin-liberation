/*
    File: fn_collectNestHouses.sqf
    Author: COIN Liberation

    Description:
        Houses that can hold a building nest (ticket 2.2, ADR 0018): in a town (Liberation's sectors_capture, not the
        capital), at the edge, i.e. COIN_nestBuildingRing from the town's centre, intact, with at least
        COIN_nestBuildingMinPositions building positions and allowed by COIN_fnc_isNestSpotAllowed.
        A house in the ring of two towns is listed once. Collected once per new campaign.

    Parameter(s):
        NONE

    Returns:
        Houses [ARRAY of [position (whole metres), town marker]]
*/

COIN_nestBuildingRing params ["_ringMin", "_ringMax"];

private _houses = [];
private _seen = createHashMap;

{
    private _town = _x;
    private _center = markerPos _town;

    {
        private _house = _x;
        // Whole metres like every nest position, z 0 (the house is found again by its position)
        private _pos = (getPosATL _house) apply {round _x};
        _pos set [2, 0];

        if (
            !(_pos in _seen)
            && {alive _house}
            && {(_center distance2D _pos) >= _ringMin}
            && {count (_house buildingPos -1) >= COIN_nestBuildingMinPositions}
            && {[_pos] call COIN_fnc_isNestSpotAllowed}
        ) then {
            _seen set [_pos, true];
            _houses pushBack [_pos, _town];
        };
    } forEach (nearestObjects [_center, ["House"], _ringMax]);
} forEach sectors_capture;

_houses
