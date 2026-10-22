/*
    File: fn_isUnsafe.sqf
    Author: COIN Liberation

    Description:
        Is it too dangerous for a civilian to talk? (ticket 3.4, DESIGN 7) True while an armed enemy (the militia, any
        living fighter that is not captive or unconscious) is within COIN_unsafeRadius of him. Then he refuses and the
        interpreter gets no intel, see COIN_fnc_questionCivilian. Off with COIN_enableUnsafeRefusal. Server only.

    Parameter(s):
        _civ - Civilian [OBJECT, defaults to objNull]

    Returns:
        Enemies are close [BOOL]
*/

params [
    ["_civ", objNull, [objNull]]
];

if (!isServer || {isNull _civ} || {!COIN_enableUnsafeRefusal}) exitWith {false};

(_civ nearEntities ["CAManBase", COIN_unsafeRadius]) findIf {
    alive _x
    && {(side group _x) isEqualTo GRLIB_side_enemy}
    && {!captive _x}
    && {!(lifeState _x isEqualTo "INCAPACITATED")}
    && {!(_x getVariable ["ace_isUnconscious", false])}
} >= 0
