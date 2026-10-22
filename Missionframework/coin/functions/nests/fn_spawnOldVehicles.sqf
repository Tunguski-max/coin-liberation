/*
    File: fn_spawnOldVehicles.sqf
    Author: COIN Liberation

    Description:
        Old vehicles of a weapons cache (ticket 2.9a, DESIGN 5, ADR 0014): a cache guards COIN_cacheOldVehicles
        [min, max] of them, the seed of the nest decides how many and which class of COIN_oldVehicleClasses (so the
        cache looks the same on every visit). Every vehicle stands on a free, flat spot COIN_oldVehicleDist from the
        nest position, next to the house of a building nest or the template of a terrain nest, and looks away from the
        nest. Direction and distance of the spot also come from the seed; a spot that is taken, in water or too steep is
        replaced by the next try (COIN_oldVehicleTries). A vehicle without a spot is left out with a log line.
        - Manned (KPLIB_fnc_spawnVehicle), the crew counts as guards and is marked as COIN units for the AI budget. The
          driver stays put (no PATH), the gunner fights as normal AI.
        - Locked for players (LOCKEDPLAYER), also when the crew is dead, so the militia's armour cannot be captured.
          KP_liberation_preplaced keeps Liberation from saving it.
        Called by COIN_fnc_spawnBuildingNest and COIN_fnc_spawnTerrainNest for nests of type "cache". The vehicles come
        back with every spawn while the cache is active, a destroyed cache does not spawn at all. The caller hands the
        result to Zeus together with the nest's objects and removes it with them. Server only, must run scheduled.

    Parameter(s):
        _nest - Nest [ARRAY: id, type, kind, pos, seed, state]

    Returns:
        Vehicles and their crew [ARRAY of OBJECTs]
*/

params [
    ["_nest", [], [[]]]
];

if (!isServer || {!COIN_enableOldVehicles}) exitWith {[]};

_nest params ["_id", "", "", "_pos", "_seed"];

// Value streams of the seed (COIN_fnc_seededRandom index), apart from those of the other nest functions
private _streamCount = 8000;
private _streamClass = 8100;        // + n: class of vehicle n
private _streamSpot = 8200;         // + (n x tries + try) x 2: direction and distance of a try

private _classes = COIN_oldVehicleClasses select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_classes isEqualTo []) exitWith {
    diag_log format ["[COIN] nests: no class of COIN_oldVehicleClasses exists, cache %1 without old vehicles (%2)", _id, COIN_oldVehicleClasses];
    []
};

COIN_cacheOldVehicles params ["_countMin", "_countMax"];
COIN_oldVehicleDist params ["_distMin", "_distMax"];
private _count = _countMin + floor ([_seed, _streamCount, _countMax - _countMin + 1] call COIN_fnc_seededRandom);

private _objects = [];
private _placed = 0;
for "_n" from 0 to (_count - 1) do {
    private _class = _classes select floor ([_seed, _streamClass + _n, count _classes] call COIN_fnc_seededRandom);

    private _spot = [];
    for "_try" from 0 to (COIN_oldVehicleTries - 1) do {
        private _index = _streamSpot + (_n * COIN_oldVehicleTries + _try) * 2;
        private _dir = [_seed, _index, 360] call COIN_fnc_seededRandom;
        private _dist = _distMin + ([_seed, _index + 1, _distMax - _distMin] call COIN_fnc_seededRandom);
        private _candidate = (_pos getPos [_dist, _dir]) findEmptyPosition [0, COIN_oldVehicleSearch, _class];
        if (
            !(_candidate isEqualTo [])
            && {!surfaceIsWater _candidate}
            && {!(((AGLToASL _candidate) isFlatEmpty [-1, -1, COIN_oldVehicleMaxGradient, 5, 0, false]) isEqualTo [])}
        ) exitWith {
            _spot = _candidate;
        };
    };
    if (_spot isEqualTo []) then {
        diag_log format ["[COIN] nests: no free spot for a %1 within %2 tries, cache %3 has one old vehicle less", _class, COIN_oldVehicleTries, _id];
        continue;
    };

    private _vehicle = [_spot, _class, true, false] call KPLIB_fnc_spawnVehicle;
    if (isNull _vehicle) then {
        diag_log format ["[COIN] nests: cache %1 got no old vehicle, %2 could not be spawned", _id, _class];
        continue;
    };

    _vehicle setDir (_pos getDir _spot);
    _vehicle setVectorUp surfaceNormal (position _vehicle);
    _vehicle setVehicleLock "LOCKEDPLAYER";
    _vehicle setVariable ["KP_liberation_preplaced", true];

    private _crew = crew _vehicle;
    (driver _vehicle) disableAI "PATH";
    [_crew] call COIN_fnc_markCoinUnits;
    _objects pushBack _vehicle;
    _objects append _crew;
    _placed = _placed + 1;
    diag_log format ["[COIN] nests: cache %1 old vehicle %2 at %3, %4 m from the nest, %5 crew", _id, _class, _spot, round (_pos distance2D _spot), count _crew];
};

diag_log format ["[COIN] nests: cache %1 has %2 of %3 old vehicles", _id, _placed, _count];

_objects
