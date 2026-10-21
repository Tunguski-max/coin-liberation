/*
    File: fn_findCampSpot.sqf
    Author: COIN Liberation

    Description:
        Simple place for a camp (ticket 2.7, DESIGN 5.1): a random position on land, at least COIN_campMinDistMapEdge
        from the map edge and COIN_campMinDistStartBase from the start base. Tries COIN_campPlaceAttempts times.
        The real placement rules (towns, roads, flat ground, exclusion zone) replace this in ticket 2.8.
        Server only.

    Parameter(s):
        NONE

    Returns:
        Position in whole metres, [] if no place was found [ARRAY]
*/

if (!isServer) exitWith {[]};

private _edge = COIN_campMinDistMapEdge;
private _range = worldSize - 2 * _edge;
private _spot = [];

for "_i" from 1 to COIN_campPlaceAttempts do {
    private _candidate = [round (_edge + random _range), round (_edge + random _range), 0];
    if (!(surfaceIsWater _candidate) && {(_candidate distance2D startbase) >= COIN_campMinDistStartBase}) exitWith {
        _spot = _candidate;
    };
};

_spot
