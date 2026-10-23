/*
    File: fn_explodeSuicideBomber.sqf
    Author: COIN Liberation

    Description:
        Sets the vest of a suicide bomber off (ticket 4.4, DESIGN 6): creates the ammo COIN_suicideBomberCharge at
        the man and lets it go off, then kills him. Called when he reaches his target and, with the chance
        COIN_suicideBomberShotChance, when he is killed (Killed event handler, COIN_fnc_createSuicideBomber). Only once
        per man (COIN_suicideBomberDone). Like the charge of a VBIED it is no unit of Liberation's kill manager, so
        civilians it kills cost no reputation (ADR 0022). Server only.

    Parameter(s):
        _unit   - The suicide bomber [OBJECT]
        _reason - Why it goes off, for the log [STRING]

    Returns:
        The charge went off by this call [BOOL]
*/

params [
    ["_unit", objNull, [objNull]],
    ["_reason", "", [""]]
];

if (!isServer || {isNull _unit} || {_unit getVariable ["COIN_suicideBomberDone", false]}) exitWith {false};
_unit setVariable ["COIN_suicideBomberDone", true];

private _pos = getPosATL _unit;
diag_log format [
    "[COIN] suicideBombers: suicide bomber %1 explodes at %2 (%3)",
    _unit getVariable ["COIN_suicideBomberId", -1], _pos, _reason
];

private _charge = createVehicle [COIN_suicideBomberCharge, _pos, [], 0, "CAN_COLLIDE"];
if (isNull _charge) then {
    diag_log format ["[COIN] suicideBombers: ERROR - charge %1 could not be created, he dies without a blast", COIN_suicideBomberCharge];
} else {
    _charge setPosATL _pos;
    triggerAmmo _charge;
    _charge setDamage 1;
};
_unit setDamage 1;

true
