/*
    File: fn_drawAmbushMarkers.sqf
    Author: COIN Liberation

    Description:
        Debug map for the ambushes (ticket 4.5, lobby parameter "COIN Debug"): one icon per ambush with its camp and,
        if it is cleared or its camp is no longer active, that state, and a line to its camp. Grey if cleared or if
        its camp is not active, else COIN_ambushMarkerColor. Runs on the server with global markers, so every player
        sees them, late joiners too. Draws again on every call, markers of ambushes that are gone are deleted. Called by
        COIN_fnc_drawCampMarkers.

    Parameter(s):
        NONE

    Returns:
        Number of ambushes drawn [NUMBER]
*/

if (!isServer || {isNil "COIN_camps"}) exitWith {0};

// Camps with an ambush
private _withAmbush = COIN_camps select {(_x param [8, []]) isNotEqualTo []};

private _drawn = missionNamespace getVariable ["COIN_ambushMarkerIds", []];
private _present = _withAmbush apply {_x select 0};
{
    deleteMarker format ["COIN_ambush_%1", _x];
    deleteMarker format ["COIN_ambush_%1_line", _x];
} forEach (_drawn - _present);
COIN_ambushMarkerIds = _present;

{
    _x params ["_campId", "", "_campPos", "", "", "", "_state"];
    (_x select 8) params ["_pos", "", "_cleared"];

    private _color = [COIN_ambushMarkerColor, "ColorGrey"] select (_cleared || {_state isNotEqualTo "active"});
    private _text = format ["Ambush (Camp %1)", _campId];
    if (_cleared) then {
        _text = _text + " cleared";
    };

    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    private _line = format ["COIN_ambush_%1_line", _campId];
    deleteMarker _line;
    createMarkerLocal [_line, _pos];
    _line setMarkerPolylineLocal [_pos select 0, _pos select 1, _campPos select 0, _campPos select 1];
    _line setMarkerColor _color;

    private _icon = format ["COIN_ambush_%1", _campId];
    deleteMarker _icon;
    createMarkerLocal [_icon, _pos];
    _icon setMarkerTypeLocal COIN_ambushMarkerType;
    _icon setMarkerColorLocal _color;
    _icon setMarkerSizeLocal [COIN_ambushMarkerSize, COIN_ambushMarkerSize];
    _icon setMarkerText _text;
} forEach _withAmbush;

if (COIN_debug) then {
    diag_log format ["[COIN] ambushes: debug markers drawn for %1 ambushes", count _withAmbush];
};

count _withAmbush
