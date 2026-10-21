/*
    File: fn_findGuardRingSpots.sqf
    Author: COIN Liberation

    Description:
        Spots for the stationary guards of a terrain nest or a camp (tickets #31 and 2.9, ADR 0020): about
        COIN_nestTerrainGuardShare of the guards stand in a ring of COIN_nestTerrainGuardRing around the centre and
        look outwards. The spots are spread evenly around the ring, not on a placed object and not on water. Their
        places are not from the seed on purpose, guards are dynamic (ADR 0020).
        Objects reaching beyond the inner ring (camouflage nets) cannot be kept clear of, guards may stand below them
        (test 2026-10-21: the net's outline left almost no ring spots). Server only.

    Parameter(s):
        _pos        - Centre of the nest or camp [POSITION]
        _guardCount - Number of guards in all [NUMBER]
        _outlines   - Placed objects [ARRAY of [position ATL, radius]]

    Returns:
        Spots, fewer than wanted if a try found none [ARRAY of [position ATL, direction]]
*/

params [
    ["_pos", [0, 0, 0], [[]]],
    ["_guardCount", 0, [0]],
    ["_outlines", [], [[]]]
];

private _ringCount = round (_guardCount * COIN_nestTerrainGuardShare);
COIN_nestTerrainGuardRing params ["_ringMin", "_ringMax"];
private _blockers = _outlines select {(_x select 1) < _ringMin};
private _spots = [];
private _startAngle = random 360;

for "_i" from 0 to (_ringCount - 1) do {
    for "_try" from 1 to COIN_nestTerrainGuardTries do {
        // Within its own share of the ring, so the guards do not bunch up
        private _angle = _startAngle + (_i + random 1) * 360 / _ringCount;
        private _spot = _pos getPos [_ringMin + random (_ringMax - _ringMin), _angle];
        if (
            !surfaceIsWater _spot
            && {(_blockers findIf {(_spot distance2D (_x select 0)) < (_x select 1) + COIN_nestTerrainGuardClearance}) < 0}
        ) exitWith {
            _spots pushBack [[_spot select 0, _spot select 1, 0], _angle];
        };
    };
};

_spots
