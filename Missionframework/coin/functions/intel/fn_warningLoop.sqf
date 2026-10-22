/*
    File: fn_warningLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (ticket 3.6): a warning disappears with its camp. It is removed, with its map markers, as soon as the
        camp is no longer "active" (cleared, moving, retired) or no longer in the camp list (moved, removed). Checks every
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
        private _gone = COIN_warnings select {
            private _campId = _x select 1;
            private _index = COIN_camps findIf {(_x select 0) isEqualTo _campId};
            _index < 0 || {!(((COIN_camps select _index) select 6) isEqualTo "active")}
        };
        {
            deleteMarker format ["COIN_warning_%1_area", _x select 0];
            deleteMarker format ["COIN_warning_%1", _x select 0];
            COIN_warnings = COIN_warnings - [_x];
            diag_log format ["[COIN] intel: warning %1 removed, camp %2 is gone, %3 warnings left", _x select 0, _x select 1, count COIN_warnings];
        } forEach _gone;
    };
};
