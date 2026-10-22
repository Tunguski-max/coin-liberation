/*
    File: fn_drawIEDMarkers.sqf
    Author: COIN Liberation

    Description:
        Debug map for the IEDs (ticket 4.1a, lobby parameter "COIN Debug"): one icon per IED with id and workshop,
        colour COIN_iedDebugColor, and a line to its workshop in the colour of the nest type (COIN_nestDebugColors).
        Runs on the server with global markers, so every player sees them, late joiners too.
        Draws again on every call, markers of IEDs that are gone are deleted.

    Parameter(s):
        NONE

    Returns:
        Number of IEDs drawn [NUMBER]
*/

if (!isServer || {isNil "COIN_ieds"}) exitWith {0};

private _drawn = missionNamespace getVariable ["COIN_iedMarkerIds", []];
private _present = COIN_ieds apply {_x select 0};
{
    deleteMarker format ["COIN_ied_%1", _x];
    deleteMarker format ["COIN_ied_%1_line", _x];
} forEach (_drawn - _present);
COIN_iedMarkerIds = _present;

{
    _x params ["_id", "_nestId", "", "_pos"];

    private _nestIndex = COIN_nests findIf {(_x select 0) isEqualTo _nestId};
    if (_nestIndex < 0) then {continue};
    private _nest = COIN_nests select _nestIndex;
    _nest params ["", "_nestType", "", "_nestPos"];
    private _lineColor = ([COIN_nestDebugColors, _nestType] call COIN_fnc_findByType) param [1, "ColorBlack"];

    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    private _line = format ["COIN_ied_%1_line", _id];
    deleteMarker _line;
    createMarkerLocal [_line, _pos];
    _line setMarkerPolylineLocal [_pos select 0, _pos select 1, _nestPos select 0, _nestPos select 1];
    _line setMarkerColor _lineColor;

    private _icon = format ["COIN_ied_%1", _id];
    deleteMarker _icon;
    createMarkerLocal [_icon, _pos];
    _icon setMarkerTypeLocal "mil_destroy";
    _icon setMarkerColorLocal COIN_iedDebugColor;
    _icon setMarkerSizeLocal [0.6, 0.6];
    _icon setMarkerText format ["IED %1 (Nest %2)", _id, _nestId];
} forEach COIN_ieds;

if (COIN_debug) then {
    diag_log format ["[COIN] ieds: debug markers drawn for %1 IEDs", count COIN_ieds];
};

count COIN_ieds
