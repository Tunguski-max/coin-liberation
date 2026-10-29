/*
    File: fn_announceMortarAttack.sqf
    Author: COIN Liberation

    Description:
        After the first salvo of a mortar attack (ticket 6.7b, #159, DESIGN 9) the side learns of it:
        - a message "Mortar fire on FOB ..." on every client, German or English (COIN_fnc_showNotification, kind "mortar"),
          switch COIN_enableMortarMessage,
        - a circle of COIN_mortarCircleRadius (400 m) on the map around the firing position, with an own symbol
          (COIN_mortarCircleMarkerType). The squad lies in the circle, but not in its middle (COIN_fnc_offsetCenter),
          so the circle does not give the exact place away. Switch COIN_enableMortarCircle. Markers are global, not saved,
          COIN_fnc_removeMortarCircle takes them away.
        Server only.

    Parameter(s):
        _fobName - Name of the FOB that is shelled [STRING]
        _spot    - Position of the mortar [ARRAY]

    Returns:
        Prefix of the circle's markers for COIN_fnc_removeMortarCircle, "" if there is no circle [STRING]
*/

params [
    ["_fobName", "", [""]],
    ["_spot", [], [[]], [2, 3]]
];

if (!isServer) exitWith {""};

if (COIN_enableMortarMessage) then {
    ["mortar", _fobName] remoteExecCall ["COIN_fnc_showNotification", 0];
};

if (!COIN_enableMortarCircle) exitWith {
    diag_log format ["[COIN] mortar: FOB %1: message %2, circle off", _fobName, COIN_enableMortarMessage];
    ""
};

private _prefix = format ["COIN_mortar_%1", round time];
private _center = [_spot, COIN_mortarCircleRadius] call COIN_fnc_offsetCenter;

// Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
private _area = format ["%1_area", _prefix];
createMarkerLocal [_area, _center];
_area setMarkerShapeLocal "ELLIPSE";
_area setMarkerBrushLocal "SolidBorder";
_area setMarkerSizeLocal [COIN_mortarCircleRadius, COIN_mortarCircleRadius];
_area setMarkerAlphaLocal COIN_intelMarkerAlpha;
_area setMarkerColor COIN_mortarCircleColor;

createMarkerLocal [_prefix, _center];
_prefix setMarkerTypeLocal COIN_mortarCircleMarkerType;
_prefix setMarkerTextLocal (["", format ["Mortar attack on FOB %1", _fobName]] select COIN_debug);
_prefix setMarkerColor COIN_mortarCircleColor;

diag_log format [
    "[COIN] mortar: FOB %1: message %2, circle of %3 m at %4, the squad is %5 m from its middle",
    _fobName, COIN_enableMortarMessage, COIN_mortarCircleRadius, _center apply {round _x}, round (_spot distance2D _center)
];

_prefix
