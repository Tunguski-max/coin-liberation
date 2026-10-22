/*
    File: fn_iedWatch.sqf
    Author: COIN Liberation

    Description:
        Exact check of one IED while BLUFOR is within COIN_iedAlertDistance of it (ticket 4.1a, DESIGN 6). Spawned by
        the statement of the IED's engine trigger (COIN_fnc_createIED), so nothing runs while nobody is near. Every
        COIN_iedAlertInterval seconds: COIN_fnc_iedTriggered says whether the army sets the IED off, then it goes off
        (setDamage 1, like Liberation's own). An IED object that is gone or destroyed is removed (COIN_fnc_removeIED).
        Ends when the trigger is no longer active (BLUFOR left, IED removed), with Liberation's endgame or when
        COIN_enableIEDs is switched off in the debug console. A trigger starts at most one watch (COIN_watching).
        Must be spawned.

    Parameter(s):
        _trigger - The IED's engine trigger, carries the IED id in COIN_iedId [OBJECT]

    Returns:
        Nothing
*/

params [
    ["_trigger", objNull, [objNull]]
];

if (!isServer) exitWith {};

private _id = _trigger getVariable ["COIN_iedId", -1];

while {GRLIB_endgame == 0 && {COIN_enableIEDs} && {triggerActivated _trigger}} do {
    private _index = COIN_ieds findIf {(_x select 0) isEqualTo _id};
    if (_index < 0) exitWith {};

    (COIN_ieds select _index) params ["", "_nestId", "_object", "_pos"];
    if (isNull _object || {!alive _object}) exitWith {
        [_id] call COIN_fnc_removeIED;
    };

    // The flag keeps a blast that needs a moment from being logged twice
    if (!(_object getVariable ["COIN_setOff", false]) && {[_pos] call COIN_fnc_iedTriggered}) then {
        diag_log format ["[COIN] ieds: IED %1 (nest %2) at %3 set off by the army", _id, _nestId, _pos];
        _object setVariable ["COIN_setOff", true];
        _object setDamage 1;
    };

    sleep COIN_iedAlertInterval;
};

_trigger setVariable ["COIN_watching", false];
