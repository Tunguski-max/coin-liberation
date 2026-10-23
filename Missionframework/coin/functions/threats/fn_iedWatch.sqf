/*
    File: fn_iedWatch.sqf
    Author: COIN Liberation

    Description:
        Exact check of one IED while BLUFOR is within COIN_iedAlertDistance of it (ticket 4.1a, DESIGN 6). Spawned by
        the statement of the IED's engine trigger (COIN_fnc_createIED), so nothing runs while nobody is near. Every
        COIN_iedAlertInterval seconds: COIN_fnc_iedTriggered says whether the army sets the IED off (a remote IED:
        only when its triggerman is free, ticket 4.2b, COIN_fnc_getFighterState), then it goes off
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

    (COIN_ieds select _index) params ["", "_nestId", "_object", "_pos", "_variant"];
    if (isNull _object || {!alive _object}) exitWith {
        [_id] call COIN_fnc_removeIED;
    };

    // The flag keeps a blast that needs a moment from being logged twice
    if !(_object getVariable ["COIN_setOff", false]) then {
        // A buried IED goes off under the army. A remote one has no pressure fuse: its triggerman sets it off when the
        // army is that close and he is free to act (not dead, unconscious or captured)
        private _by = "";
        if (_variant isEqualTo "remote") then {
            if (
                (([_object getVariable ["COIN_triggerman", objNull]] call COIN_fnc_getFighterState) isEqualTo "free")
                && {[_pos, COIN_iedRemoteRadius, COIN_iedRemoteRadius, COIN_iedRemoteCount] call COIN_fnc_iedTriggered}
            ) then {_by = "its triggerman"};
        } else {
            if ([_pos] call COIN_fnc_iedTriggered) then {_by = "the army"};
        };

        if (_by isNotEqualTo "") then {
            diag_log format ["[COIN] ieds: IED %1 (%2, nest %3) at %4 set off by %5", _id, _variant, _nestId, _pos, _by];
            _object setVariable ["COIN_setOff", true];
            _object setDamage 1;
        };
    };

    sleep COIN_iedAlertInterval;
};

_trigger setVariable ["COIN_watching", false];
