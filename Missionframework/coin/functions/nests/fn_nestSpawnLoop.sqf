/*
    File: fn_nestSpawnLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop that spawns and removes the content of nests near players (ticket 2.3, DESIGN 5):
        - spawn when the nearest player or drone (COIN_fnc_getPresence) is at most COIN_spawnDistance away,
        - remove when nobody was within COIN_despawnDistance for COIN_despawnDelay seconds.
        Only active building nests spawn for now, terrain nests follow with the template mechanics (ticket 2.3, part 2).
        A nest whose house is gone is not tried again until the next server start.
        Runs every COIN_spawnCheckInterval seconds as long as COIN_enableNestSpawn is true; switched off, all
        spawned content is removed. Started by COIN_fnc_initNests once the nests are known. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

[] call COIN_fnc_validateNestContent;
diag_log format [
    "[COIN] nests: spawn loop on, spawn at %1 m, removal after %2 s beyond %3 m, check every %4 s",
    COIN_spawnDistance, COIN_despawnDelay, COIN_despawnDistance, COIN_spawnCheckInterval
];

// Nest id -> [objects and units, groups, time a player was last within COIN_despawnDistance]
private _spawned = createHashMap;
private _failed = [];

private _despawn = {
    params ["_id", "_entry", "_reason"];
    _entry params ["_objects"];
    private _guards = _objects select {_x isKindOf "CAManBase"};
    private _alive = {alive _x} count _guards;
    {
        deleteVehicle _x;
    } forEach _objects;
    // Groups are created with deleteWhenEmpty, they go with their last unit
    diag_log format ["[COIN] nests: nest %1 removed (%2), %3 of %4 guards were alive", _id, _reason, _alive, count _guards];
};

while {COIN_enableNestSpawn} do {
    private _present = [] call COIN_fnc_getPresence;

    {
        _x params ["_id", "_type", "_kind", "_pos", "_seed", "_state"];
        private _distance = if (_present isEqualTo []) then {1e10} else {selectMin (_present apply {_x distance2D _pos})};
        private _entry = _spawned getOrDefault [_id, []];

        if (_entry isEqualTo []) then {
            if (
                _distance <= COIN_spawnDistance
                && {_kind isEqualTo "building"}
                && {_state isEqualTo "active"}
                && {!(_id in _failed)}
            ) then {
                private _content = [_x, _distance] call COIN_fnc_spawnBuildingNest;
                if (_content isEqualTo []) then {
                    _failed pushBack _id;
                } else {
                    _spawned set [_id, _content + [time]];
                };
            };
        } else {
            if (_distance <= COIN_despawnDistance) then {
                _entry set [2, time];
            } else {
                if ((time - (_entry select 2)) >= COIN_despawnDelay) then {
                    [_id, _entry, format ["no player within %1 m for %2 s", COIN_despawnDistance, COIN_despawnDelay]] call _despawn;
                    _spawned deleteAt _id;
                };
            };
        };
    } forEach COIN_nests;

    sleep COIN_spawnCheckInterval;
};

{
    [_x, _y, "spawning switched off"] call _despawn;
} forEach _spawned;
diag_log "[COIN] nests: spawn loop off";

true
