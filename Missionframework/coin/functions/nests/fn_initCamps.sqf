/*
    File: fn_initCamps.sqf
    Author: COIN Liberation

    Description:
        Server start of the camps (ticket 2.7, DESIGN 5.1, decision E8). Called by COIN_fnc_initNests once the nests
        are known. Camps are not saved, so every start creates them anew:
        - COIN_campCapacity from COIN_fnc_getCampCapacity,
        - that many camps (COIN_fnc_createCamp): at places that keep the placement rules, each belonging to the nearest
          active nest that still has a free slot. A camp without a place is left out with an error line.
        - COIN_camps (layout in COIN_fnc_createCamp), COIN_spawnedCamps (camp id -> what the spawn loop keeps),
          COIN_campReplacements (mission times at which a cleared camp is replaced), COIN_campNextId.
        During the session COIN_fnc_manageCamps replaces, moves and retires camps (ticket 2.10).
        Logs every camp with its distances and the camps per nest. Listens to COIN_nestDestroyed: the capacity is
        calculated and logged again (COIN_fnc_manageCamps retires the surplus). Draws the debug map when COIN_debug is on.

    Parameter(s):
        NONE

    Returns:
        Number of camps [NUMBER]
*/

if (!isServer) exitWith {0};

COIN_camps = [];
COIN_campNextId = 1;
COIN_campReplacements = [];
COIN_spawnedCamps = createHashMap;
([] call COIN_fnc_getCampCapacity) params ["_capacity", "_active", "_total"];
COIN_campCapacity = _capacity;
diag_log format ["[COIN] camps: capacity %1 (weight of the active nests %2 of %3, at most %4)", _capacity, _active, _total, COIN_campMax];

for "_i" from 1 to _capacity do {
    [] call COIN_fnc_createCamp;
};

// Per nest, to check that none supplies more camps than its weight
{
    _x params ["_nestId", "_nestType", "", "", "", "_state"];
    private _weight = [_nestType] call COIN_fnc_getCampWeight;
    diag_log format [
        "[COIN] camps: nest %1 (%2, %3) supplies %4 of %5 camps",
        _nestId, _nestType, _state, {(_x select 1) isEqualTo _nestId} count COIN_camps, _weight
    ];
} forEach COIN_nests;
diag_log format ["[COIN] camps: %1 of %2 camps created", count COIN_camps, _capacity];

// A destroyed nest lowers the capacity; COIN_fnc_manageCamps retires its camps and the surplus
["COIN_nestDestroyed", {
    params ["_nestId", "_nestType"];
    ([] call COIN_fnc_getCampCapacity) params ["_capacity", "_active", "_total"];
    COIN_campCapacity = _capacity;
    diag_log format [
        "[COIN] camps: nest %1 (%2) destroyed, capacity now %3 (weight of the active nests %4 of %5), %6 camps exist, %7 of them belong to this nest",
        _nestId, _nestType, _capacity, _active, _total, count COIN_camps, {(_x select 1) isEqualTo _nestId} count COIN_camps
    ];
    if (COIN_debug) then {
        [] call COIN_fnc_drawCampMarkers;
    };
}] call CBA_fnc_addEventHandler;

if (COIN_debug) then {
    [] call COIN_fnc_drawCampMarkers;
};

count COIN_camps
