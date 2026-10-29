/*
    File: fn_spawnCapitalHeavy.sqf
    Author: COIN Liberation

    Description:
        Fixed heavy equipment of the capital (ticket 6.3b, #161, DESIGN 9, ADR 0014, hook 35): the vehicles of
        COIN_capitalHeavyVehicles (2 T-72BA, 1 ZSU-23-4) and COIN_capitalAAInfantry Igla gunners on high building
        spots. Independent of the weapons caches and of the network.
        - Vehicles: manned and placed like Liberation's sector vehicles (KPLIB_fnc_spawnVehicle, add_defense_waypoints).
          Locked for players (LOCKEDPLAYER) also when the crew is dead, as the old vehicles of the caches (ADR 0007).
          KP_liberation_preplaced keeps Liberation from saving them.
        - A vehicle that is destroyed stays gone until the server restarts (COIN_capitalHeavyLost, not persisted, entry =
          index in COIN_capitalHeavyVehicles). The next activation spawns only what is not lost. A vehicle that is still
          alive when the sector is taken down comes back with the next activation.
        - Igla gunners: the highest spots of the buildings within COIN_capitalAARadius of the middle, at least
          COIN_capitalAASpacing apart (the RPT line gives the height of each). They are taken from the first class of
          COIN_capitalAAClasses that exists and stay in their spot until an enemy comes (building_defence_ai).
        All units are COIN units for the AI budget but always spawn (ADR 0015) and go to Zeus. One [COIN] line says what
        spawned. Switch COIN_enableCapitalHeavy. Called by manage_one_sector.sqf (server, scheduled; without a server,
        e.g. on a headless client, nothing spawns and one line says so).

    Parameter(s):
        _sector - Marker of the capital [STRING]

    Returns:
        Vehicles, crews and gunners for Liberation's list of managed units [ARRAY of OBJECTs]
*/

params [
    ["_sector", "", [""]]
];

if (!COIN_enableCapitalHeavy) exitWith {[]};

if (!isServer || {!canSuspend}) exitWith {
    diag_log format ["[COIN] capital: %1: no heavy equipment, this machine is no server or the call is not scheduled", _sector];
    []
};

private _centre = markerPos _sector;
private _units = [];
private _lost = missionNamespace getVariable ["COIN_capitalHeavyLost", []];

// Vehicles
private _vehicleCount = 0;
{
    private _class = _x;
    private _index = _forEachIndex;

    if (_index in _lost) then {
        diag_log format ["[COIN] capital: %1: %2 (no. %3) was destroyed and stays gone until the server restarts", _sector, _class, _index];
        continue;
    };
    if !(isClass (configFile >> "CfgVehicles" >> _class)) then {
        diag_log format ["[COIN] capital: %1: class %2 does not exist, left out", _sector, _class];
        continue;
    };

    private _vehicle = [_centre, _class] call KPLIB_fnc_spawnVehicle;
    if (isNull _vehicle) then {
        diag_log format ["[COIN] capital: %1: %2 (no. %3) found no spawn position", _sector, _class, _index];
        continue;
    };

    _vehicle setVehicleLock "LOCKEDPLAYER";
    _vehicle setVariable ["KP_liberation_preplaced", true];
    _vehicle setVariable ["COIN_capitalHeavyIndex", _index];
    // MPKilled as Liberation's kill_manager: the vehicle is local to the server, but the event is the safe way when the owner changes
    _vehicle addMPEventHandler ["MPKilled", {
        params ["_killed"];
        if (!isServer) exitWith {};
        private _destroyed = _killed getVariable ["COIN_capitalHeavyIndex", -1];
        private _lostNow = missionNamespace getVariable ["COIN_capitalHeavyLost", []];
        if (_destroyed >= 0 && {!(_destroyed in _lostNow)}) then {
            _lostNow pushBack _destroyed;
            COIN_capitalHeavyLost = _lostNow;
            diag_log format ["[COIN] capital: %1 (no. %2) destroyed, stays gone until the server restarts", typeOf _killed, _destroyed];
        };
    }];

    private _crew = crew _vehicle;
    if (!isNull group (driver _vehicle)) then {
        [group (driver _vehicle), _centre] spawn add_defense_waypoints;
    };
    [_crew] call COIN_fnc_markCoinUnits;
    [[_vehicle] + _crew] call COIN_fnc_addToCurators;
    _units pushBack _vehicle;
    _units append _crew;
    _vehicleCount = _vehicleCount + 1;
    diag_log format ["[COIN] capital: %1: %2 (no. %3) at %4, %5 m from the middle, %6 crew", _sector, _class, _index, getPosATL _vehicle, round (_centre distance2D _vehicle), count _crew];
} forEach COIN_capitalHeavyVehicles;

// Igla gunners on high building spots
private _gunnerCount = 0;
private _aaClass = "";
{
    if (isClass (configFile >> "CfgVehicles" >> _x)) exitWith {_aaClass = _x};
} forEach COIN_capitalAAClasses;

if (COIN_capitalAAInfantry > 0) then {
    if (_aaClass isEqualTo "") then {
        diag_log format ["[COIN] capital: %1: no class of COIN_capitalAAClasses exists, no Igla gunners (%2)", _sector, COIN_capitalAAClasses];
    } else {
        private _spots = [];
        {
            _spots append ([_x] call BIS_fnc_buildingPositions);
        } forEach ((nearestObjects [_centre, ["House"], COIN_capitalAARadius]) select {alive _x});
        // Highest first: [height, position] pairs sorted descending
        _spots = _spots apply {[_x select 2, _x]};
        _spots sort false;
        _spots = _spots apply {_x select 1};

        private _chosen = [];
        {
            private _spot = _x;
            if (_chosen findIf {(_x distance2D _spot) < COIN_capitalAASpacing} < 0) then {
                _chosen pushBack _spot;
            };
            if (count _chosen >= COIN_capitalAAInfantry) exitWith {};
        } forEach _spots;

        private _group = createGroup [GRLIB_side_enemy, true];
        {
            private _gunner = [_aaClass, _x, _group] call KPLIB_fnc_createManagedUnit;
            _gunner setPos _x;
            _gunner setDir (random 360);
            [_gunner, _sector] spawn building_defence_ai;
            _units pushBack _gunner;
            _gunnerCount = _gunnerCount + 1;
            diag_log format ["[COIN] capital: %1: Igla gunner %2 at %3, %4 m above ground", _sector, _aaClass, _x, round (_x select 2)];
        } forEach _chosen;

        if (_gunnerCount > 0) then {
            [units _group] call COIN_fnc_markCoinUnits;
            [units _group] call COIN_fnc_addToCurators;
        } else {
            deleteGroup _group;
        };
        if (_gunnerCount < COIN_capitalAAInfantry) then {
            diag_log format ["[COIN] capital: %1: only %2 of %3 Igla gunners, %4 high building spots found", _sector, _gunnerCount, COIN_capitalAAInfantry, count _spots];
        };
    };
};

diag_log format [
    "[COIN] capital: %1: heavy equipment: %2 of %3 vehicles (%4 destroyed earlier), %5 Igla gunners",
    _sector, _vehicleCount, count COIN_capitalHeavyVehicles, count _lost, _gunnerCount
];

_units
