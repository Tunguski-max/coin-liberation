/*
    File: fn_drawIntelMarker.sqf
    Author: COIN Liberation

    Description:
        Draws the map markers of one intel (ticket 3.1): a circle with the radius of the intel and an icon in its
        middle. A rumor shows the neutral symbol, a hint or tip the symbol of the nest type (COIN_intelMarkerTypes,
        ticket 3.3). Global markers, so every player sees them, late joiners too. Draws again on every call, existing
        markers of the intel are replaced (COIN_fnc_shrinkIntel). With COIN_debug the icon names the intel, the nest it
        points to and the level. Server only.

    Parameter(s):
        _intel - [id, nestId, center, radius, level, shownType, fakePos] [ARRAY, defaults to []]

    Returns:
        Intel was drawn [BOOL]
*/

params [
    ["_intel", [], [[]]]
];

if (!isServer || {count _intel < 7}) exitWith {false};

_intel params ["_id", "_nestId", "_center", "_radius", "_level", "_shownType"];

// Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
private _area = format ["COIN_intel_%1_area", _id];
deleteMarker _area;
createMarkerLocal [_area, _center];
_area setMarkerShapeLocal "ELLIPSE";
_area setMarkerBrushLocal "SolidBorder";
_area setMarkerSizeLocal [_radius, _radius];
_area setMarkerAlphaLocal COIN_intelMarkerAlpha;
_area setMarkerColor COIN_intelMarkerColor;

private _icon = format ["COIN_intel_%1", _id];
deleteMarker _icon;
createMarkerLocal [_icon, _center];
_icon setMarkerTypeLocal (([COIN_intelMarkerTypes, _shownType] call COIN_fnc_findByType) param [1, COIN_intelMarkerNeutral]);
_icon setMarkerTextLocal (["", format ["Intel %1 -> nest %2 (%3)", _id, _nestId, _level]] select COIN_debug);
_icon setMarkerColor COIN_intelMarkerColor;

true
