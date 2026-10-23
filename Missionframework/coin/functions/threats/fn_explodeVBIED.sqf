/*
    File: fn_explodeVBIED.sqf
    Author: COIN Liberation

    Description:
        Sets the charge of a VBIED off (ticket 4.3, DESIGN 6): creates the ammo COIN_vbiedCharge at the vehicle and lets
        it go off, then destroys the vehicle. Called when the driver reaches his target and when the vehicle is
        destroyed (Killed event handler, COIN_fnc_createVBIED). Only once per vehicle (COIN_vbiedDone). The blast
        is no army action: the charge is no unit of Liberation's kill manager, so it is up to the test of ticket 4.3 whether
        civilians it kills cost reputation (ADR 0022). Server only.

    Parameter(s):
        _vehicle - The VBIED [OBJECT]
        _reason  - Why it goes off, for the log [STRING]

    Returns:
        The charge went off by this call [BOOL]
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_reason", "", [""]]
];

if (!isServer || {isNull _vehicle} || {_vehicle getVariable ["COIN_vbiedDone", false]}) exitWith {false};
_vehicle setVariable ["COIN_vbiedDone", true];

private _pos = getPosATL _vehicle;
diag_log format [
    "[COIN] vbieds: VBIED %1 (%2) explodes at %3 (%4), driver %5",
    _vehicle getVariable ["COIN_vbiedId", -1], typeOf _vehicle, _pos, _reason,
    [_vehicle getVariable ["COIN_vbiedDriver", objNull]] call COIN_fnc_getFighterState
];

private _charge = createVehicle [COIN_vbiedCharge, _pos, [], 0, "CAN_COLLIDE"];
_charge setPosATL _pos;
_charge setDamage 1;
_vehicle setDamage 1;

true
