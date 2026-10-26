/*
    File: fn_canRepairInfrastructure.sqf
    Author: COIN Liberation

    Description:
        Client: may this unit repair the devices of an aid task "Repair infrastructure"? (ticket 5.12, DESIGN 8.2). Only
        an ACE engineer (the EOD slot, ACE_isEngineer of COIN_roleTraits, else the engineer entry of the class) who is on foot,
        alive and carries one of COIN_aidRepairTools. Used by the action condition (every frame, so cheap) and while the
        progress bar runs.

    Parameter(s):
        _unit - The player [OBJECT, defaults to objNull]

    Returns:
        The unit may repair [BOOL]
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit || {!KP_liberation_ace} || {!alive _unit} || {(vehicle _unit) isNotEqualTo _unit}) exitWith {false};

// Set by the slot (COIN_fnc_applyRoleTraits), a number or a boolean as in ACE
private _set = _unit getVariable ["ACE_isEngineer", -1];
private _engineer = if (_set isEqualType true) then {
    _set
} else {
    if (_set >= 0) then {_set > 0} else {(getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "engineer")) > 0}
};

_engineer && {(COIN_aidRepairTools arrayIntersect (items _unit)) isNotEqualTo []}
