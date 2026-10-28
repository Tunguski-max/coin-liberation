/*
    File: fn_drawStagingMarkers.sqf
    Author: COIN Liberation

    Description:
        Debug map (ticket 6.1a, #154, lobby parameter "COIN Debug"): one circle and one label per staging area, in
        COIN_stagingDebugColor. Runs on the server with global markers, so every player sees them, late joiners too.
        Draws everything again on every call: the markers of the last call are deleted first, so an area that ended
        (nest destroyed, military post captured) disappears. Only with COIN_debug. Server only.

    Parameter(s):
        NONE

    Returns:
        Number of staging areas drawn [NUMBER]
*/

if (!isServer) exitWith {0};

{deleteMarker _x} forEach (missionNamespace getVariable ["COIN_stagingMarkers", []]);
COIN_stagingMarkers = [];

if (!COIN_debug) exitWith {0};

private _areas = [] call COIN_fnc_getStagingAreas;

{
    _x params ["_pos", "_radius", "_source"];

    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    private _circle = format ["COIN_staging_%1_area", _forEachIndex];
    createMarkerLocal [_circle, _pos];
    _circle setMarkerShapeLocal "ELLIPSE";
    _circle setMarkerBrushLocal "Border";
    _circle setMarkerSizeLocal [_radius, _radius];
    _circle setMarkerColor COIN_stagingDebugColor;

    private _label = format ["COIN_staging_%1", _forEachIndex];
    createMarkerLocal [_label, _pos];
    _label setMarkerTypeLocal "mil_flag";
    _label setMarkerColorLocal COIN_stagingDebugColor;
    _label setMarkerText format ["Aufmarschraum: %1", [_x] call COIN_fnc_describeStagingArea];

    COIN_stagingMarkers append [_circle, _label];
} forEach _areas;

count _areas
