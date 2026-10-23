/*
    File: fn_drawCampMarkers.sqf
    Author: COIN Liberation

    Description:
        Debug map for the camps (ticket 2.11, lobby parameter "COIN Debug"): one icon per camp with id, nest, whether it
        was discovered and, if it is not active, its state (moving, cleared, retired), and a line to its nest.
        Color of the nest type (COIN_nestDebugColors), grey if the nest is destroyed or the camp is cleared or retired.
        The ambushes of the camps are drawn with it (COIN_fnc_drawAmbushMarkers, ticket 4.5).
        Runs on the server with global markers, so every player sees them, late joiners too.
        Draws again on every call, existing markers of a camp are replaced, markers of camps that are gone are deleted.

    Parameter(s):
        NONE

    Returns:
        Number of camps drawn [NUMBER]
*/

if (!isServer || {isNil "COIN_camps"}) exitWith {0};

// Markers of camps that left the list (moved, replaced, retired)
private _drawn = missionNamespace getVariable ["COIN_campMarkerIds", []];
private _present = COIN_camps apply {_x select 0};
{
    deleteMarker format ["COIN_camp_%1", _x];
    deleteMarker format ["COIN_camp_%1_line", _x];
} forEach (_drawn - _present);
COIN_campMarkerIds = _present;

{
    _x params ["_id", "_nestId", "_pos", "_discovered", "", "", "_state"];

    private _nestIndex = COIN_nests findIf {(_x select 0) isEqualTo _nestId};
    if (_nestIndex < 0) then {continue};
    private _nest = COIN_nests select _nestIndex;
    _nest params ["", "_nestType", "", "_nestPos", "", "_nestState"];

    private _color = if (_nestState isEqualTo "destroyed" || {_state in ["cleared", "retired"]}) then {
        "ColorGrey"
    } else {
        ([COIN_nestDebugColors, _nestType] call COIN_fnc_findByType) param [1, "ColorBlack"]
    };
    private _text = format ["Camp %1 (Nest %2)", _id, _nestId];
    if (_discovered) then {
        _text = _text + " discovered";
    };
    if (_state != "active") then {
        _text = format ["%1 %2", _text, _state];
    };

    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    private _line = format ["COIN_camp_%1_line", _id];
    deleteMarker _line;
    createMarkerLocal [_line, _pos];
    _line setMarkerPolylineLocal [_pos select 0, _pos select 1, _nestPos select 0, _nestPos select 1];
    _line setMarkerColor _color;

    private _icon = format ["COIN_camp_%1", _id];
    deleteMarker _icon;
    createMarkerLocal [_icon, _pos];
    _icon setMarkerTypeLocal "mil_triangle";
    _icon setMarkerColorLocal _color;
    _icon setMarkerSizeLocal [0.7, 0.7];
    _icon setMarkerText _text;
} forEach COIN_camps;

if (COIN_debug) then {
    diag_log format ["[COIN] camps: debug markers drawn for %1 camps", count COIN_camps];
};

if (COIN_enableAmbushes) then {
    [] call COIN_fnc_drawAmbushMarkers;
};

count COIN_camps
