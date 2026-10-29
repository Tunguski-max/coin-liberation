/*
    File: fn_removeMortarCircle.sqf
    Author: COIN Liberation

    Description:
        Takes the circle of a mortar attack off the map (ticket 6.7b, #159): when the squad is eliminated or taken down.
        Harmless for a prefix that is already gone or empty. Server only.

    Parameter(s):
        _prefix - What COIN_fnc_announceMortarAttack returned [STRING]

    Returns:
        A circle was removed [BOOL]
*/

params [
    ["_prefix", "", [""]]
];

if (!isServer || {_prefix isEqualTo ""}) exitWith {false};

deleteMarker format ["%1_area", _prefix];
deleteMarker _prefix;
diag_log format ["[COIN] mortar: circle %1 removed", _prefix];
true
