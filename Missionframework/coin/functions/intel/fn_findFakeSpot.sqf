/*
    File: fn_findFakeSpot.sqf
    Author: COIN Liberation

    Description:
        The hidden fake point of a lie (ticket 3.4, DESIGN 7, ADR 0021): a place where a nest could plausibly be, so the
        circle around it looks like a real one. Either the edge of a town within COIN_intelNestRange of the origin (the
        ring a building nest uses, COIN_nestBuildingRing) or open ground there (the rules of terrain nests,
        COIN_fnc_checkTerrainSpot); COIN_lieTownShare is the share of towns. Both pass the rules every nest place must
        pass (COIN_fnc_isNestSpotAllowed: land, map edge, start base, capital, sectors). At most COIN_lieSpotTries tries.
        Server only.

    Parameter(s):
        _origin - Position of the civilian who lies [ARRAY, defaults to [0, 0, 0]]

    Returns:
        Position in whole metres, [] if no place was found [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]], [2, 3]]
];

if (!isServer) exitWith {[]};

COIN_nestBuildingRing params ["_ringMin", "_ringMax"];
private _towns = sectors_capture select {((markerPos _x) distance2D _origin) <= COIN_intelNestRange};

private _result = [];
for "_i" from 1 to COIN_lieSpotTries do {
    private _candidate = [];
    private _ok = false;

    if (random 1 < COIN_lieTownShare) then {
        if !(_towns isEqualTo []) then {
            _candidate = (markerPos (selectRandom _towns)) getPos [_ringMin + random (_ringMax - _ringMin), random 360];
            _ok = [_candidate] call COIN_fnc_isNestSpotAllowed;
        };
    } else {
        _candidate = _origin getPos [random COIN_intelNestRange, random 360];
        _ok = [_candidate] call COIN_fnc_isNestSpotAllowed
            && {([_candidate, COIN_nestTerrainMinDistTown, COIN_nestTerrainMinDistRoad, COIN_nestTerrainFlatRadius, COIN_nestTerrainMaxGradient] call COIN_fnc_checkTerrainSpot) isEqualTo ""};
    };

    if (_ok) exitWith {
        _result = [round (_candidate select 0), round (_candidate select 1), 0];
    };
};

_result
