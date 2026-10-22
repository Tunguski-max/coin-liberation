/*
    File: fn_intelSearchLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (ticket 3.4, DESIGN 7, ADR 0021): a lie disappears without a message once a player on foot has been
        within COIN_lieSearchDistance of its fake point, the area then counts as searched. A player in a vehicle or
        helicopter does not search. The save follows (Liberation's save function, once again after
        COIN_nestSaveRetryDelay if Liberation was saving). Checks every COIN_lieSearchInterval seconds, only
        while lies exist. Runs as long as COIN_enableQuestioning is true. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        NOTHING
*/

if (!isServer) exitWith {};

while {COIN_enableQuestioning} do {
    sleep COIN_lieSearchInterval;

    private _lies = COIN_intel select {(_x select 1) < 0};
    if !(_lies isEqualTo []) then {
        private _walkers = allPlayers select {alive _x && {isNull objectParent _x}};
        private _searched = false;

        {
            private _lie = _x;
            private _fakePos = _lie select 6;
            private _index = _walkers findIf {(_x distance2D _fakePos) <= COIN_lieSearchDistance};
            if (_index >= 0) then {
                [_lie] call COIN_fnc_removeIntel;
                _searched = true;
                diag_log format [
                    "[COIN] intel: lie %1 (%2 %3) searched, %4 was %5 m from the fake point %6, removed, %7 intel left",
                    _lie select 0, _lie select 4, _lie select 5, name (_walkers select _index),
                    round ((_walkers select _index) distance2D _fakePos), _fakePos, count COIN_intel
                ];
            };
        } forEach _lies;

        if (_searched) then {
            private _saved = [] call KPLIB_fnc_doSave;
            if (!_saved) then {
                sleep COIN_nestSaveRetryDelay;
                _saved = [] call KPLIB_fnc_doSave;
            };
            diag_log format ["[COIN] intel: searched lie %1", ["not saved yet (Liberation was saving twice), goes into Liberation's next save", "saved"] select _saved];
        };
    };
};
