/*
    File: fn_drawCampMarkers.sqf
    Author: COIN Liberation

    Description:
        Debug map for the camps (ticket 2.11, lobby parameter "COIN Debug"): one icon per camp with id and nest, and a
        line to its nest. Color of the nest type (COIN_nestDebugColors), grey if the nest is destroyed.
        Runs on the server with global markers, so every player sees them, late joiners too.
        Draws again on every call, existing markers of a camp are replaced.

    Parameter(s):
        NONE

    Returns:
        Number of camps drawn [NUMBER]
*/

if (!isServer || {isNil "COIN_camps"}) exitWith {0};

{
    _x params ["_id", "_nestId", "_pos"];

    private _nest = COIN_nests select (COIN_nests findIf {(_x select 0) isEqualTo _nestId});
    _nest params ["", "_nestType", "", "_nestPos", "", "_nestState"];

    private _color = if (_nestState isEqualTo "destroyed") then {
        "ColorGrey"
    } else {
        ([COIN_nestDebugColors, _nestType] call COIN_fnc_findByType) param [1, "ColorBlack"]
    };

    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    private _line = format ["COIN_camp_%1_line", _id];
    deleteMarker _line;
    createMarkerLocal [_line, _pos];
    _line setMarkerColorLocal _color;
    _line setMarkerPolyline [_pos select 0, _pos select 1, _nestPos select 0, _nestPos select 1];

    private _icon = format ["COIN_camp_%1", _id];
    deleteMarker _icon;
    createMarkerLocal [_icon, _pos];
    _icon setMarkerTypeLocal "mil_triangle";
    _icon setMarkerColorLocal _color;
    _icon setMarkerSizeLocal [0.7, 0.7];
    _icon setMarkerText format ["Camp %1 (Nest %2)", _id, _nestId];
} forEach COIN_camps;

if (COIN_debug) then {
    diag_log format ["[COIN] camps: debug markers drawn for %1 camps", count COIN_camps];
};

count COIN_camps
