/*
    File: fn_createWarning.sqf
    Author: COIN Liberation

    Description:
        Makes a warning for a civilian (tickets 3.6 and 4.8, DESIGN 7): a circle on the map around a threat close to
        him (COIN_fnc_getWarnableThreats: an active camp, an IED), within the range of its kind and with the radius of
        its kind (COIN_warningKinds). The threat lies in the circle, but not in its middle (COIN_fnc_offsetCenter).
        A threat that already has a warning is not chosen again; among all threats in range without one chance decides,
        whatever their kind. Without one there is no warning (the civilian then knows nothing). The warning is not
        saved, camps and IEDs are not saved either. It goes with its threat (COIN_fnc_warningLoop). Warnings have their
        own symbol, color and id. Server only.

    Parameter(s):
        _pos - Position of the civilian [ARRAY, defaults to [0, 0, 0]]

    Returns:
        The warning [id, kind, threat id, center, radius], [] if there is no threat to warn of [ARRAY]
*/

params [
    ["_pos", [0, 0, 0], [[]], [2, 3]]
];

if (!isServer || {isNil "COIN_warnings"}) exitWith {[]};

private _warned = COIN_warnings apply {[_x select 1, _x select 2]};
private _inRange = ([] call COIN_fnc_getWarnableThreats) select {
    _x params ["_kind", "", "_threatPos"];
    (_threatPos distance2D _pos) <= (([COIN_warningKinds, _kind] call COIN_fnc_findByType) param [1, 0])
};
private _candidates = _inRange select {
    private _key = [_x select 0, _x select 1];
    (_warned findIf {_x isEqualTo _key}) < 0
};
if (_candidates isEqualTo []) exitWith {
    diag_log format [
        "[COIN] intel: no warning, %1 within reach of the civilian",
        ["no threat", format ["%1 threats, all with a warning already", count _inRange]] select (count _inRange > 0)
    ];
    []
};

(selectRandom _candidates) params ["_kind", "_threatId", "_threatPos", "_label"];
([COIN_warningKinds, _kind] call COIN_fnc_findByType) params ["", "", "_radius"];
private _center = [_threatPos, _radius] call COIN_fnc_offsetCenter;

private _id = COIN_warningNextId;
COIN_warningNextId = COIN_warningNextId + 1;
private _warning = [_id, _kind, _threatId, _center, _radius];
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
_icon setMarkerTextLocal (["", format ["Warning %1 -> %2", _id, _label]] select COIN_debug);
_icon setMarkerColor COIN_warningMarkerColor;

diag_log format [
    "[COIN] intel: warning %1 for %2, %3 m from the civilian, %4 threats to choose from",
    _id, _label, round (_threatPos distance2D _pos), count _candidates
];

_warning
