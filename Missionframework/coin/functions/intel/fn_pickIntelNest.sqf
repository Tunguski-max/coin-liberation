/*
    File: fn_pickIntelNest.sqf
    Author: COIN Liberation

    Description:
        Which nest does a civilian know something about? (ticket 3.1, DESIGN 7) A random active nest within
        COIN_intelNestRange of the civilian; if there is none, the nearest active nest on the map. So geography counts,
        and the last nests can still be found. Server only.

    Parameter(s):
        _pos - Position of the civilian [ARRAY, defaults to [0, 0, 0]]

    Returns:
        Nest [id, type, kind, pos, seed, state], [] if no nest is active [ARRAY]
*/

params [
    ["_pos", [0, 0, 0], [[]], [2, 3]]
];

if (!isServer || {isNil "COIN_nests"}) exitWith {[]};

private _active = COIN_nests select {(_x select 5) isEqualTo "active"};
if (_active isEqualTo []) exitWith {[]};

private _near = _active select {((_x select 3) distance2D _pos) <= COIN_intelNestRange};
if (_near isEqualTo []) then {
    private _sorted = [_active, [], {(_x select 3) distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;
    _near = [_sorted select 0];
};

selectRandom _near
