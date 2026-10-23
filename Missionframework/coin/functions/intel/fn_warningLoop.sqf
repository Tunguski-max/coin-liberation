/*
    File: fn_warningLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (tickets 3.6, 4.8): a warning disappears with its threat. It is removed, with its map markers, as
        soon as its threat is no longer one a civilian can warn of (COIN_fnc_getWarnableThreats): a camp that is cleared,
        moving, retired, moved or removed, an IED that went off, was defused or deleted. Checks every
        COIN_warningCheckInterval seconds, only while warnings exist. Runs as long as COIN_enableQuestioning is true.
        Must be spawned.

    Parameter(s):
        NONE

    Returns:
        NOTHING
*/

if (!isServer) exitWith {};

while {COIN_enableQuestioning} do {
    sleep COIN_warningCheckInterval;

    if !(COIN_warnings isEqualTo []) then {
        private _threats = ([] call COIN_fnc_getWarnableThreats) apply {[_x select 0, _x select 1]};
        private _gone = COIN_warnings select {
            private _key = [_x select 1, _x select 2];
            (_threats findIf {_x isEqualTo _key}) < 0
        };
        {
            private _warningId = _x select 0;
            deleteMarker format ["COIN_warning_%1_area", _warningId];
            deleteMarker format ["COIN_warning_%1", _warningId];
            COIN_warnings = COIN_warnings select {(_x select 0) != _warningId};
            diag_log format ["[COIN] intel: warning %1 removed, %2 %3 is gone, %4 warnings left", _warningId, _x select 1, _x select 2, count COIN_warnings];
        } forEach _gone;
    };
};
