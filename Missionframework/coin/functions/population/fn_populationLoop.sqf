/*
    File: fn_populationLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop for the own population of liberated towns (ticket 3.7, DESIGN 7, ADR 0011): Liberation has no
        civilians in a town the army holds. A town gets COIN_populationCount civilians (rolled per spawn) when
        - it is a liberated town (sectors_capture and blufor_sectors, so no supply point, outpost or capital),
        - Liberation is done with it (not in active_sectors: its own civilians and defenders are gone),
        - the nearest player or drone (COIN_fnc_getPresence) is at most COIN_spawnDistance away,
        - they fit the civilian budget: as with a camp all or none (ADR 0015), only the own civilians count against
          COIN_maxCivilians, Liberation's do not. Without COIN_enableAIBudget there is no limit. A town that waits for
          room is written to the RPT once.
        They are removed when nobody was within COIN_despawnDistance for COIN_despawnDelay seconds, and at once when
        the town is no longer free (lost to the enemy or active again). The civilians are new at every visit.
        Each town has one elder besides them (ticket 5.9a, COIN_enableElder, DESIGN 8): he spawns and goes with the others
        and counts against the budget with them (all or none). He stands at the same place at every visit (found once per
        town, COIN_fnc_findElderSpot, not saved). When he dies the town has no elder for COIN_elderAbsenceMinutes, a new
        one comes with the first visit after that.
        Checked every COIN_spawnCheckInterval seconds as long as COIN_enablePopulation is true; switched off, all of
        them are removed. Started by init_server.sqf. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

// Liberation's sector lists are filled by its own init; the COIN init runs after it, the timeout is only a safety net
private _timeout = diag_tickTime + COIN_initTimeout;
waitUntil {
    sleep 1;
    (!isNil "blufor_sectors" && {!isNil "sectors_capture"} && {!isNil "active_sectors"}) || {diag_tickTime > _timeout}
};
if (isNil "blufor_sectors" || {isNil "sectors_capture"} || {isNil "active_sectors"}) exitWith {
    diag_log "[COIN] population: ERROR - Liberation's sector lists are missing, no population";
    false
};

diag_log format [
    "[COIN] population: loop on, %1 civilians per town, spawn at %2 m, removal after %3 s beyond %4 m, budget %5 (%6)",
    COIN_populationCount, COIN_spawnDistance, COIN_despawnDelay, COIN_despawnDistance, COIN_maxCivilians, ["not limited", "limited"] select COIN_enableAIBudget
];

// Sector -> [civilians, time a player was last within COIN_despawnDistance]
private _spawned = createHashMap;
// Sector -> number of civilians it waits to spawn (logged once), kept so the roll does not change every check
private _waiting = createHashMap;
// Sector -> [position, direction, building] where the elder stands, found at the first spawn and kept for the session
private _elderSpots = createHashMap;
// Sector -> time from which the town gets an elder again, set when he died
private _elderAbsent = createHashMap;

private _remove = {
    params ["_sector", "_reason"];
    private _civs = (_spawned deleteAt _sector) select 0;
    private _alive = {alive _x} count _civs;
    {deleteVehicle _x} forEach _civs;
    deleteMarker format ["COIN_elder_%1", _sector];
    // Groups are created with deleteWhenEmpty, they go with their last unit
    diag_log format ["[COIN] population: %1 (%2) removed (%3), %4 of %5 civilians were alive", markerText _sector, _sector, _reason, _alive, count _civs];
};

while {COIN_enablePopulation} do {
    private _present = [] call COIN_fnc_getPresence;
    private _free = sectors_capture select {_x in blufor_sectors && {!(_x in active_sectors)}};

    // Removal first, so the room they take is free for the spawns below
    {
        private _sector = _x;
        private _entry = _spawned get _sector;
        if !(_sector in _free) then {
            [_sector, "town is not free any more"] call _remove;
        } else {
            // _entry select 2: the elder is there and not known to be dead, select 3: the elder
            if (_entry select 2 && {!alive (_entry select 3)}) then {
                _entry set [2, false];
                _elderAbsent set [_sector, time + (COIN_elderAbsenceMinutes * 60)];
                deleteMarker format ["COIN_elder_%1", _sector];
                diag_log format [
                    "[COIN] population: the elder of %1 (%2) is dead, the town has no elder for %3 min",
                    markerText _sector, _sector, COIN_elderAbsenceMinutes
                ];
            };

            private _near =(_present findIf {(_x distance2D (markerPos _sector)) <= COIN_despawnDistance}) >= 0;
            if (_near) then {
                _entry set [1, time];
            } else {
                if ((time - (_entry select 1)) >= COIN_despawnDelay) then {
                    [_sector, format ["no player within %1 m for %2 s", COIN_despawnDistance, COIN_despawnDelay]] call _remove;
                };
            };
        };
    } forEach (keys _spawned);

    // A town that waited for room and is not free any more has nothing to wait for
    {
        if !(_x in _free) then {_waiting deleteAt _x};
    } forEach (keys _waiting);

    {
        private _sector = _x;
        if (_sector in _spawned) then {continue};

        private _distance = if (_present isEqualTo []) then {-1} else {selectMin (_present apply {_x distance2D (markerPos _sector)})};
        if (_distance < 0 || {_distance > COIN_spawnDistance}) then {
            _waiting deleteAt _sector;
            continue;
        };

        COIN_populationCount params ["_min", "_max"];
        private _count = _waiting getOrDefault [_sector, _min + floor (random ((_max - _min) + 1))];
        private _living = 0;
        {_living = _living + ({alive _x} count (_y select 0))} forEach _spawned;

        // The elder comes with the town unless he died less than COIN_elderAbsenceMinutes ago; he counts against the budget
        private _withElder = COIN_enableElder && {(_elderAbsent getOrDefault [_sector, 0]) <= time};
        private _total = _count + ([0, 1] select _withElder);

        if (COIN_enableAIBudget && {(_living + _total) > COIN_maxCivilians}) then {
            if !(_sector in _waiting) then {
                _waiting set [_sector, _count];
                diag_log format [
                    "[COIN] population: %1 (%2) waits, budget: %3 own civilians + %4 > %5",
                    markerText _sector, _sector, _living, _total, COIN_maxCivilians
                ];
            };
            continue;
        };

        if (_sector in _waiting) then {
            _waiting deleteAt _sector;
            diag_log format ["[COIN] population: %1 (%2) fits the budget now", markerText _sector, _sector];
        };
        private _civs = [_sector, _count] call COIN_fnc_spawnPopulation;
        private _elder = objNull;
        if (_withElder) then {
            if !(_sector in _elderSpots) then {
                _elderSpots set [_sector, [_sector] call COIN_fnc_findElderSpot];
            };
            _elder = [_sector, _elderSpots get _sector] call COIN_fnc_spawnElder;
            _elderAbsent deleteAt _sector;
            if (!isNull _elder) then {
                _civs pushBack _elder;
            };
        };
        _spawned set [_sector, [_civs, time, !isNull _elder, _elder]];
        diag_log format [
            "[COIN] population: %1 (%2) spawned %3 civilians%7, player %4 m away, own civilians now %5 of %6",
            markerText _sector, _sector, count _civs, round _distance, _living + count _civs, COIN_maxCivilians,
            [" (no elder)", " including the elder"] select (!isNull _elder)
        ];
    } forEach _free;

    sleep COIN_spawnCheckInterval;
};

// Switched off: nothing of it stays
{[_x, "population switched off"] call _remove} forEach (keys _spawned);

true
