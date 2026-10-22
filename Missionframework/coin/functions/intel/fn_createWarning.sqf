/*
    File: fn_createWarning.sqf
    Author: COIN Liberation

    Description:
        Makes a warning for a civilian (ticket 3.6, DESIGN 7): a circle on the map around an active camp within
        COIN_warningRange of him. The camp lies in the circle, but not in its middle (COIN_fnc_offsetCenter). A camp that
        already has a warning is not chosen again; without such a camp in range there is no warning (the civilian then
        knows nothing). The warning is not saved, camps are not saved either. It goes when the camp is cleared, moved or
        removed (COIN_fnc_warningLoop). Warnings have their own symbol, color and id. Server only.

    Parameter(s):
        _pos - Position of the civilian [ARRAY, defaults to [0, 0, 0]]

    Returns:
        The warning [id, campId, center, radius], [] if there is no camp to warn of [ARRAY]
*/

params [
    ["_pos", [0, 0, 0], [[]], [2, 3]]
];

if (!isServer || {isNil "COIN_camps"} || {isNil "COIN_warnings"}) exitWith {[]};

private _warned = COIN_warnings apply {_x select 1};
private _candidates = COIN_camps select {
    (_x select 6) isEqualTo "active"
    && {((_x select 2) distance2D _pos) <= COIN_warningRange}
    && {!((_x select 0) in _warned)}
};
if (_candidates isEqualTo []) exitWith {[]};

private _camp = selectRandom _candidates;
_camp params ["_campId", "_nestId", "_campPos"];

private _radius = COIN_warningRadius;
private _center = [_campPos, _radius] call COIN_fnc_offsetCenter;

private _id = COIN_warningNextId;
COIN_warningNextId = COIN_warningNextId + 1;
private _warning = [_id, _campId, _center, _radius];
COIN_warnings pushBack _warning;

// Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
private _area = format ["COIN_warning_%1_area", _id];
createMarkerLocal [_area, _center];
_area setMarkerShapeLocal "ELLIPSE";
_area setMarkerBrushLocal "SolidBorder";
_area setMarkerSizeLocal [_radius, _radius];
_area setMarkerAlphaLocal COIN_intelMarkerAlpha;
_area setMarkerColor COIN_warningMarkerColor;

private _icon = format ["COIN_warning_%1", _id];
createMarkerLocal [_icon, _center];
_icon setMarkerTypeLocal COIN_warningMarkerType;
_icon setMarkerTextLocal (["", format ["Warning %1 -> camp %2 (nest %3)", _id, _campId, _nestId]] select COIN_debug);
_icon setMarkerColor COIN_warningMarkerColor;

diag_log format [
    "[COIN] intel: warning %1 for camp %2 (nest %3) at %4, %5 m from the civilian, %6 camps in range",
    _id, _campId, _nestId, _campPos, round (_campPos distance2D _pos), count _candidates
];

_warning
