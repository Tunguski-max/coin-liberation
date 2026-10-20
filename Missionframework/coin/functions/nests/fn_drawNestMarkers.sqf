/*
    File: fn_drawNestMarkers.sqf
    Author: COIN Liberation

    Description:
        Debug map (ticket 2.5, lobby parameter "COIN Debug"): one area marker per nest with its influence radius and
        one icon with id, type and kind. Color by type (COIN_nestDebugColors), destroyed nests are grey.
        Runs on the server with global markers, so every player sees them, late joiners too.
        Draws again on every call (e.g. after a nest is destroyed), existing markers of a nest are replaced.

    Parameter(s):
        NONE

    Returns:
        Number of nests drawn [NUMBER]
*/

if (!isServer || {isNil "COIN_nests"}) exitWith {0};

{
    _x params ["_id", "_type", "_kind", "_pos", "_seed", "_state"];

    private _colorIndex = COIN_nestDebugColors findIf {(_x select 0) isEqualTo _type};
    private _color = "ColorBlack";
    if (_colorIndex >= 0) then {
        _color = (COIN_nestDebugColors select _colorIndex) select 1;
    };
    private _destroyed = _state isEqualTo "destroyed";
    if (_destroyed) then {
        _color = "ColorGrey";
    };
    private _radius = [_type] call COIN_fnc_getNestRadius;

    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    private _area = format ["COIN_nest_%1_area", _id];
    deleteMarker _area;
    createMarkerLocal [_area, _pos];
    _area setMarkerShapeLocal "ELLIPSE";
    _area setMarkerBrushLocal "Border";
    _area setMarkerSizeLocal [_radius, _radius];
    _area setMarkerColor _color;

    private _icon = format ["COIN_nest_%1", _id];
    deleteMarker _icon;
    createMarkerLocal [_icon, _pos];
    _icon setMarkerTypeLocal (["mil_objective", "mil_destroy"] select _destroyed);
    _icon setMarkerColorLocal _color;
    _icon setMarkerText format ["Nest %1 %2 (%3)", _id, _type, _kind];
} forEach COIN_nests;

if (COIN_debug) then {
    diag_log format ["[COIN] nests: debug markers drawn for %1 nests", count COIN_nests];
};

count COIN_nests
