/*
    File: fn_describeStagingArea.sqf
    Author: COIN Liberation

    Description:
        Short text of a staging area for the log and the debug map (ticket 6.1a, #154), e.g.
        "command post (nest 3), radius 2500" or "military post military_2 (Kalae Barracks), radius 2000". Server only.

    Parameter(s):
        _area - One entry of COIN_fnc_getStagingAreas [ARRAY]

    Returns:
        Text [STRING]
*/

params [
    ["_area", [], [[]], 3]
];

_area params ["", "_radius", "_source"];
_source params ["_kind", "_ref"];

if (_kind isEqualTo "nest") exitWith {
    format ["command post (nest %1), radius %2", _ref, _radius]
};

format ["military post %1 (%2), radius %3", _ref, markerText _ref, _radius]
