/*
    File: fn_findGuardSpot.sqf
    Author: COIN Liberation

    Description:
        A place for a guard of a strike task (tickets 5.15 and 5.18): in a ring round a centre, free of other objects
        (COIN_strikeGuardClearance, BIS_fnc_findSafePos), on ground not steeper than COIN_strikeGuardGradient, and at least
        COIN_strikeGuardSpacing m from the places already taken. At most COIN_strikeGuardTries tries; none found: a plain place of the ring.

    Parameter(s):
        _centre  - Centre of the ring [ARRAY, defaults to [0, 0, 0]]
        _ringMin - Least distance from the centre in m [NUMBER, defaults to 0]
        _ringMax - Greatest distance from the centre in m [NUMBER, defaults to 0]
        _taken   - Places of the guards already placed [ARRAY, defaults to []]

    Returns:
        The place [ARRAY]
*/

params [
    ["_centre", [0, 0, 0], [[]]],
    ["_ringMin", 0, [0]],
    ["_ringMax", 0, [0]],
    ["_taken", [], [[]]]
];

private _spot = [];
for "_try" from 1 to COIN_strikeGuardTries do {
    private _candidate = [_centre, _ringMin, _ringMax, COIN_strikeGuardClearance, 0, COIN_strikeGuardGradient, 0, [], [_centre, _centre]] call BIS_fnc_findSafePos;
    if (
        _candidate isEqualType []
        && {count _candidate >= 2}
        && {(_candidate select 0) isEqualType 0}
        && {(_candidate distance2D _centre) >= _ringMin}
        && {(_taken findIf {(_x distance2D _candidate) < COIN_strikeGuardSpacing}) < 0}
    ) exitWith {_spot = _candidate};
};
if (_spot isEqualTo []) then {
    _spot = _centre getPos [_ringMin + random (_ringMax - _ringMin), random 360];
};

_spot
