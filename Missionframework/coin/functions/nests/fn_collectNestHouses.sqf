/*
    File: fn_collectNestHouses.sqf
    Author: COIN Liberation

    Description:
        Houses that can hold a building nest (ticket 2.2, ADR 0018): in a town (Liberation's sectors_capture, not the
        capital), at the edge, i.e. COIN_nestBuildingRing from the town's centre, intact, not in COIN_nestBuildingExcludedClasses, with at least
        COIN_nestBuildingMinPositions building positions and allowed by COIN_fnc_isNestSpotAllowed.
        The footprint (m², from boundingBoxReal) lets each nest type ask for a minimum size (COIN_nestBuildingMinArea).
        A house in the ring of two towns is listed once. Collected once per new campaign.

    Parameter(s):
        NONE

    Returns:
        Houses [ARRAY of [position (whole metres), town marker, class, footprint in m²]]
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
            && {!(typeOf _house in COIN_nestBuildingExcludedClasses)}
            && {(_center distance2D _pos) >= _ringMin}
            && {count (_house buildingPos -1) >= COIN_nestBuildingMinPositions}
            && {[_pos] call COIN_fnc_isNestSpotAllowed}
        ) then {
            _seen set [_pos, true];
            (boundingBoxReal _house) params ["_corner1", "_corner2"];
            private _area = round abs (((_corner2 select 0) - (_corner1 select 0)) * ((_corner2 select 1) - (_corner1 select 1)));
            _houses pushBack [_pos, _town, typeOf _house, _area];
        };
    } forEach (_center nearObjects ["House", _ringMax]);
} forEach sectors_capture;

_houses
