/*
    File: fn_createIntel.sqf
    Author: COIN Liberation

    Description:
        Makes the intel for a true hit on a nest (ticket 3.1, DESIGN 7): a circle on the map for the whole side. The nest
        lies in the circle, but not in its middle: the centre is moved away by a share of the radius
        (COIN_intelCenterOffset), so the circle does not give the nest away. Record, in the format of the save (ADR 0021,
        saved from ticket 3.2): [id, nestId, center, radius, level, shownType, fakePos]. The shown type is empty for a
        rumor. A nest has one circle only: a further true hit makes the existing one smaller (COIN_fnc_shrinkIntel,
        ticket 3.3). Server only.

    Parameter(s):
        _nest  - Nest [id, type, kind, pos, seed, state] [ARRAY, defaults to []]
        _level - "rumor", "hint" or "tip" [STRING, defaults to "rumor"]

    Returns:
        The intel record (new or shrunk), [] if it could not be made [ARRAY]
*/

params [
    ["_nest", [], [[]]],
    ["_level", "rumor", [""]]
];

if (!isServer || {count _nest < 6}) exitWith {[]};

_nest params ["_nestId", "_type", "", "_nestPos"];

private _radius = switch (_level) do {
    case "rumor": {COIN_intelRadiusRumor};
    case "hint": {COIN_intelRadiusHint};
    case "tip": {COIN_intelRadiusTip};
    default {0};
};
if (_radius <= 0) exitWith {
    diag_log format ["[COIN] intel: ERROR - unknown level %1, no intel made", _level];
    []
};

// One circle per nest: a lie (nest id -1) never matches
private _existing = COIN_intel findIf {(_x select 1) isEqualTo _nestId};
if (_existing >= 0) exitWith {
    [COIN_intel select _existing, _level, _radius, _nest] call COIN_fnc_shrinkIntel
};

private _minShare = COIN_intelCenterOffset select 0;
private _maxShare = COIN_intelCenterOffset select 1;
private _offset = _radius * (_minShare + random (_maxShare - _minShare));
private _center = _nestPos getPos [_offset, random 360];

private _id = COIN_intelNextId;
COIN_intelNextId = COIN_intelNextId + 1;
private _shownType = ["", _type] select !(_level isEqualTo "rumor");
private _intel = [_id, _nestId, _center, _radius, _level, _shownType, []];
COIN_intel pushBack _intel;

[_intel] call COIN_fnc_drawIntelMarker;

_intel
