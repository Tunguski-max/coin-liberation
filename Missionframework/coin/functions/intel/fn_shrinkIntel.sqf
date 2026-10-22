/*
    File: fn_shrinkIntel.sqf
    Author: COIN Liberation

    Description:
        Triangulation (ticket 3.3, DESIGN 7, ADR 0021): a further true hit on a nest that already has a circle makes
        this circle smaller, no new one. New radius = old radius x COIN_triangulationFactor, never bigger than the radius
        of the new level, never smaller than COIN_intelRadiusMin and never bigger than the old radius (a rumor after a
        tip changes nothing). The nest stays inside the new circle but not in its middle (COIN_intelCenterOffset), and the
        new circle lies inside the old one if a place is found in COIN_intelCenterTries tries, else the one that sticks
        out least. The shown type is set by the first hint or tip, the level only gets better. The circle is drawn again.
        Server only.

    Parameter(s):
        _intel       - Existing intel [id, nestId, center, radius, level, shownType, fakePos] [ARRAY, defaults to []]
        _level       - Level of the new hit: "rumor", "hint" or "tip" [STRING, defaults to "rumor"]
        _levelRadius - Radius of that level [NUMBER, defaults to 0]
        _nest        - Nest [id, type, kind, pos, seed, state] [ARRAY, defaults to []]

    Returns:
        The intel record, changed in place [ARRAY]
*/

params [
    ["_intel", [], [[]]],
    ["_level", "rumor", [""]],
    ["_levelRadius", 0, [0]],
    ["_nest", [], [[]]]
];

if (!isServer || {count _intel < 7} || {count _nest < 6}) exitWith {_intel};

_intel params ["_id", "", "_center", "_oldRadius", "_oldLevel", "_shownType"];
_nest params ["_nestId", "_type", "", "_nestPos"];

private _changed = false;

private _newRadius = (((_oldRadius * COIN_triangulationFactor) min _levelRadius) max COIN_intelRadiusMin) min _oldRadius;
if (_newRadius < _oldRadius) then {
    private _minShare = COIN_intelCenterOffset select 0;
    private _maxShare = COIN_intelCenterOffset select 1;
    private _bestCenter = _center;
    private _bestExcess = 1e10;     // m the new circle sticks out of the old one
    for "_i" from 1 to COIN_intelCenterTries do {
        private _offset = _newRadius * (_minShare + random (_maxShare - _minShare));
        private _candidate = _nestPos getPos [_offset, random 360];
        private _excess = (_candidate distance2D _center) + _newRadius - _oldRadius;
        if (_excess < _bestExcess) then {
            _bestExcess = _excess;
            _bestCenter = _candidate;
        };
        if (_excess <= 0) exitWith {};
    };
    _intel set [2, _bestCenter];
    _intel set [3, _newRadius];
    _changed = true;
    diag_log format [
        "[COIN] intel: nest %1 (%2) %3 hit, circle made smaller: %4 m -> %5 m at %6 (intel %7, %8)",
        _nestId, _type, _level, _oldRadius, _newRadius, _bestCenter, _id,
        ["inside the old circle", format ["sticks out %1 m of the old circle", round _bestExcess]] select (_bestExcess > 0)
    ];
};

// The first hint or tip names the type, a rumor does not
if (_shownType isEqualTo "" && {!(_level isEqualTo "rumor")}) then {
    _intel set [5, _type];
    _changed = true;
    diag_log format ["[COIN] intel: nest %1 (%2) %3 hit names the type for intel %4", _nestId, _type, _level, _id];
};

private _levels = ["rumor", "hint", "tip"];
if ((_levels find _level) > (_levels find _oldLevel)) then {
    _intel set [4, _level];
    _changed = true;
};

if (_changed) then {
    [_intel] call COIN_fnc_drawIntelMarker;
} else {
    diag_log format ["[COIN] intel: nest %1 (%2) %3 hit adds nothing to intel %4 (%5 m, %6)", _nestId, _type, _level, _id, _oldRadius, _oldLevel];
};

_intel
