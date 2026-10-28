/*
    File: fn_canGiveRadioOrder.sqf
    Author: COIN Liberation

    Description:
        May this player give radio orders to the reinforcement? (ticket 5.19, DESIGN 8.1). Alive, and the commander or a squad leader (the
        start of the role description is in COIN_radioRoles) or an interpreter (the role description starts with COIN_interpreterRole, or
        COIN_interpreter is set by COIN_fnc_applyInterpreter). Nobody else: gunners, medics, EOD and pilots have no orders. A unit with
        COIN_radioOrders set may too, for a test in another slot. Used by the client for the menu and again by the server before an
        order is carried out. Needs COIN_enableRadio.

    Parameter(s):
        _unit - The player's unit [OBJECT, defaults to objNull]

    Returns:
        The unit may give orders [BOOL]
*/

params [
    ["_unit", objNull, [objNull]]
];

if (!COIN_enableRadio || {isNull _unit} || {!alive _unit}) exitWith {false};

private _role = roleDescription _unit;
(_role find COIN_interpreterRole) isEqualTo 0
|| {_unit getVariable ["COIN_interpreter", false]}
|| {_unit getVariable ["COIN_radioOrders", false]}
|| {COIN_radioRoles findIf {(_role find _x) isEqualTo 0} >= 0}
