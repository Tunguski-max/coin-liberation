/*
    File: fn_triggermanLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop of the triggermen of remote-triggered IEDs (ticket 4.2b, DESIGN 6, ADR 0022). Every
        COIN_spawnCheckInterval seconds, as for the guards of a nest:
        - spawns the triggerman of a remote IED when the nearest player or drone (COIN_fnc_getPresence) is at most
          COIN_triggermanSpawnDistance away (COIN_fnc_createTriggerman); always, whatever the AI budget says. An IED
          without a place for him is not tried again until the players were away,
        - removes him (and his phone and marker) when nobody was within COIN_despawnDistance for COIN_despawnDelay
          seconds, the IED being gone or not,
        - notes when he is out (dead, captured, deleted: COIN_fnc_getFighterState): the IED gets COIN_triggermanOut
          and never has a triggerman again, so it never goes off by remote, but it stays and must be defused. One who is
          alive comes back at the next visit.
        The detonation itself is COIN_fnc_iedWatch. Runs as long as COIN_enableIEDs and COIN_enableIEDRemote are
        true; switched off, all triggermen are removed. Started by COIN_fnc_initIEDs. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

diag_log format [
    "[COIN] ieds: triggerman loop on, spawn at %1 m, removal after %2 s beyond %3 m, check every %4 s",
    COIN_triggermanSpawnDistance, COIN_despawnDelay, COIN_despawnDistance, COIN_spawnCheckInterval
];

// IED id -> [triggerman, phone, time a player was last within COIN_despawnDistance, position of the IED]
private _spawned = createHashMap;
// Ids of IEDs without a place for a triggerman
private _noPlace = [];

private _distanceTo = {
    params ["_pos", "_present"];
    if (_present isEqualTo []) then {-1} else {selectMin (_present apply {_x distance2D _pos})}
};

private _remove = {
    params ["_id", "_reason"];
    (_spawned deleteAt _id) params ["_man", "_phone"];
    private _state = [_man] call COIN_fnc_getFighterState;
    deleteVehicle _phone;
    deleteVehicle _man;
    deleteMarker format ["COIN_triggerman_%1", _id];
    deleteMarker format ["COIN_triggerman_%1_line", _id];
    // Groups are created with deleteWhenEmpty, they go with their only unit
    diag_log format ["[COIN] ieds: triggerman of IED %1 removed (%2), he was %3", _id, _reason, _state];
};

while {GRLIB_endgame == 0 && {COIN_enableIEDs} && {COIN_enableIEDRemote}} do {
    private _present = [] call COIN_fnc_getPresence;

    // The ones in place first, so the IED of one who is out is marked before anything is spawned below
    {
        private _id = _x;
        (_spawned get _id) params ["_man", "", "", "_pos"];

        private _index = COIN_ieds findIf {(_x select 0) isEqualTo _id};
        if (_index >= 0) then {
            private _object = (COIN_ieds select _index) select 2;
            if (!(_object getVariable ["COIN_triggermanOut", false]) && {([_man] call COIN_fnc_getFighterState) isEqualTo "out"}) then {
                _object setVariable ["COIN_triggermanOut", true];
                diag_log format [
                    "[COIN] ieds: triggerman of IED %1 is out (alive %2, handcuffed %3, surrendering %4, captive %5), the IED will not go off by remote any more",
                    _id, alive _man, _man getVariable ["ace_captives_isHandcuffed", false], _man getVariable ["ace_captives_isSurrendering", false], captive _man
                ];
            };
        };

        private _distance = [_pos, _present] call _distanceTo;
        if (_distance >= 0 && {_distance <= COIN_despawnDistance}) then {
            (_spawned get _id) set [2, time];
        } else {
            if ((time - ((_spawned get _id) select 2)) >= COIN_despawnDelay) then {
                [_id, format ["no player within %1 m for %2 s", COIN_despawnDistance, COIN_despawnDelay]] call _remove;
            };
        };
    } forEach (keys _spawned);

    // A place is looked for again once the players were away, or when the IED is gone
    _noPlace = _noPlace select {
        private _id = _x;
        private _index = COIN_ieds findIf {(_x select 0) isEqualTo _id};
        _index >= 0 && {
            private _distance = [((COIN_ieds select _index) select 3), _present] call _distanceTo;
            _distance >= 0 && {_distance <= COIN_despawnDistance}
        }
    };

    {
        _x params ["_id", "", "_object", "_pos", "_variant"];
        if (
            _variant isNotEqualTo "remote"
            || {_id in _spawned}
            || {_id in _noPlace}
            || {_object getVariable ["COIN_triggermanOut", false]}
        ) then {continue};

        private _distance = [_pos, _present] call _distanceTo;
        if (_distance < 0 || {_distance > COIN_triggermanSpawnDistance}) then {continue};

        private _made = [_id] call COIN_fnc_createTriggerman;
        if (_made isEqualTo []) then {
            _noPlace pushBack _id;
        } else {
            _spawned set [_id, _made + [time, _pos]];
        };
    } forEach (COIN_ieds apply {_x});

    sleep COIN_spawnCheckInterval;
};

// Switched off: nothing of it stays
{[_x, "triggermen switched off"] call _remove} forEach (keys _spawned);
diag_log "[COIN] ieds: triggerman loop off";

true
