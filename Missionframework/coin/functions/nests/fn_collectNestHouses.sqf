/*
    File: fn_collectNestHouses.sqf
    Author: COIN Liberation

    Description:
        Houses that can hold a building nest (ticket 2.2, ADR 0018): in a town (Liberation's sectors_capture, not the
        capital), at the edge, i.e. COIN_nestBuildingRing from the town's centre, intact, not in COIN_nestBuildingExcludedClasses,
        with at least the smallest number of building positions in COIN_nestBuildingMinPositions and allowed by
        COIN_fnc_isNestSpotAllowed. Footprint (m², from boundingBoxReal) and building positions let each nest type ask
        for its own minimum (COIN_nestBuildingMinArea, COIN_nestBuildingMinPositions).
        A house in the ring of two towns is listed once. Collected once per new campaign.

    Parameter(s):
        NONE

    Returns:
        Houses [ARRAY of [position (whole metres), town marker, class, footprint in m², building positions]]
*/

COIN_nestBuildingRing params ["_ringMin", "_ringMax"];

private _excluded = COIN_nestBuildingExcludedClasses apply {toLower _x};
private _minPositions = selectMin (COIN_nestBuildingMinPositions apply {_x select 1});
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
            && {!(toLower typeOf _house in _excluded)}
            && {(_center distance2D _pos) >= _ringMin}
            && {count (_house buildingPos -1) >= _minPositions}
            && {[_pos] call COIN_fnc_isNestSpotAllowed}
        ) then {
            _seen set [_pos, true];
            (boundingBoxReal _house) params ["_corner1", "_corner2"];
            private _area = round abs (((_corner2 select 0) - (_corner1 select 0)) * ((_corner2 select 1) - (_corner1 select 1)));
            _houses pushBack [_pos, _town, typeOf _house, _area, count (_house buildingPos -1)];
        };
    } forEach (_center nearObjects ["House", _ringMax]);
} forEach sectors_capture;

_houses
