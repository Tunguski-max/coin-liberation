/*
    File: fn_iedLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop over all IEDs (ticket 4.1a, DESIGN 6), every COIN_iedCheckInterval seconds:
        - the army is near an IED (COIN_fnc_iedTriggered): the IED goes off (setDamage 1, like Liberation's own),
        - an IED object that is gone or destroyed (shot, blown up, defused with ACE, deleted in Zeus) leaves COIN_ieds.
        One log line per IED that leaves the list. Shots and blasts need no check, a destroyed IED goes off by itself.
        Ends with Liberation's endgame or when COIN_enableIEDs is switched off in the debug console.
        Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

while {GRLIB_endgame == 0 && {COIN_enableIEDs}} do {
    {
        _x params ["_id", "_nestId", "_object", "_pos"];

        // The flag keeps a blast that needs a moment from being logged twice
        if (!isNull _object && {alive _object} && {!(_object getVariable ["COIN_setOff", false])} && {[_pos] call COIN_fnc_iedTriggered}) then {
            diag_log format ["[COIN] ieds: IED %1 (nest %2) at %3 set off by the army", _id, _nestId, _pos];
            _object setVariable ["COIN_setOff", true];
            _object setDamage 1;
        };
    } forEach COIN_ieds;

    private _gone = COIN_ieds select {isNull (_x select 2) || {!alive (_x select 2)}};
    if (_gone isNotEqualTo []) then {
        COIN_ieds = COIN_ieds - _gone;
        {
            diag_log format ["[COIN] ieds: IED %1 (nest %2) at %3 is gone, %4 IEDs left", _x select 0, _x select 1, _x select 3, count COIN_ieds];
        } forEach _gone;
        if (COIN_debug) then {
            [] call COIN_fnc_drawIEDMarkers;
        };
    };

    sleep COIN_iedCheckInterval;
};

diag_log "[COIN] ieds: loop ended";
