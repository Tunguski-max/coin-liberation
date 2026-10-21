/*
    File: fn_nestSpawnLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop that spawns and removes the content of nests near players (ticket 2.3, DESIGN 5):
        - spawn when the nearest player or drone (COIN_fnc_getPresence) is at most COIN_spawnDistance away,
        - remove when nobody was within COIN_despawnDistance for COIN_despawnDelay seconds.
        Active building nests spawn with COIN_fnc_spawnBuildingNest, terrain nests with COIN_fnc_spawnTerrainNest
        (only while COIN_enableTerrainNests is true).
        A nest that could not be spawned (house gone, no terrain template) is not tried again until the next server start.
        Destruction (ticket 2.4, COIN_fnc_destroyNest): a Killed handler on the core object and a BuildingChanged
        handler for the house (swap to a ruin) report it at once, and every check also looks at the core object and
        the house: a dead core object or a collapsed house destroys the nest. A core object deleted by Zeus is no destruction, the nest spawns again
        next time. A destroyed nest stays until it is removed and never spawns again.
        Runs every COIN_spawnCheckInterval seconds as long as COIN_enableNestSpawn is true; switched off, all
        spawned content is removed. Started by COIN_fnc_initNests once the nests are known. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

diag_log format [
    "[COIN] nests: spawn loop on, spawn at %1 m, removal after %2 s beyond %3 m, check every %4 s",
    COIN_spawnDistance, COIN_despawnDelay, COIN_despawnDistance, COIN_spawnCheckInterval
];

// Nest id -> [objects and units, time a player was last within COIN_despawnDistance, core object]
private _spawned = createHashMap;
private _failed = [];

// Nest id -> house of a spawned building nest. Follows the house when Arma swaps it for a damaged version,
// a swap to a ruin destroys the nest
COIN_nestWatchedHouses = createHashMap;
if (COIN_enableNestDestruction) then {
    addMissionEventHandler ["BuildingChanged", {
        params ["_from", "_to", "_isRuin"];
        private _id = -1;
        {
            if (_y isEqualTo _from) exitWith {_id = _x};
        } forEach COIN_nestWatchedHouses;
        if (_id < 0) exitWith {};
        if (_isRuin) then {
            COIN_nestWatchedHouses deleteAt _id;
            [_id, "house collapsed"] call COIN_fnc_destroyNest;
        } else {
            COIN_nestWatchedHouses set [_id, _to];
        };
    }];
};

private _despawn = {
    params ["_id", "_entry", "_reason"];
    _entry params ["_objects"];
    COIN_nestWatchedHouses deleteAt _id;
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
        // Nobody present counts as out of range for both spawn and removal
        private _hasPresence = !(_present isEqualTo []);
        private _distance = if (_hasPresence) then {selectMin (_present apply {_x distance2D _pos})} else {-1};
        private _entry = _spawned getOrDefault [_id, []];

        if (_entry isEqualTo []) then {
            if (
                _hasPresence
                && {_distance <= COIN_spawnDistance}
                && {_state isEqualTo "active"}
                && {_kind isEqualTo "building" || COIN_enableTerrainNests}
                && {!(_id in _failed)}
            ) then {
                private _content = if (_kind isEqualTo "building") then {
                    [_x, _distance] call COIN_fnc_spawnBuildingNest
                } else {
                    [_x, _distance] call COIN_fnc_spawnTerrainNest
                };
                if (_content isEqualTo []) then {
                    _failed pushBack _id;
                } else {
                    private _core = (_content select {!isNil {_x getVariable "COIN_nestId"}}) param [0, objNull];
                    // Reports the destruction at once (also Zeus' "destroy"); deleting the object fires no Killed
                    if (COIN_enableNestDestruction && {!isNull _core}) then {
                        _core addEventHandler ["Killed", {
                            params ["_core"];
                            [_core getVariable ["COIN_nestId", -1], "core object destroyed"] call COIN_fnc_destroyNest;
                        }];
                    };
                    private _house = _core getVariable ["COIN_nestHouse", objNull];
                    if (!isNull _house) then {
                        COIN_nestWatchedHouses set [_id, _house];
                    };
                    _spawned set [_id, [_content, time, _core]];
                };
            };
        } else {
            // Destruction the handlers cannot see: a house that died without a swap, a core object that died without Killed
            _entry params ["", "", "_core"];
            private _house = COIN_nestWatchedHouses getOrDefault [_id, objNull];
            if (COIN_enableNestDestruction && {_state isEqualTo "active"}) then {
                switch (true) do {
                    case (!isNull _core && {!alive _core}): {[_id, "core object destroyed"] call COIN_fnc_destroyNest};
                    case (!isNull _house && {!alive _house}): {[_id, "house collapsed"] call COIN_fnc_destroyNest};
                };
            };
            if (_hasPresence && {_distance <= COIN_despawnDistance}) then {
                _entry set [1, time];
            } else {
                if ((time - (_entry select 1)) >= COIN_despawnDelay) then {
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
