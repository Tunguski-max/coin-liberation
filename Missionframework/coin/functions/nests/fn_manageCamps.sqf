/*
    File: fn_manageCamps.sqf
    Author: COIN Liberation

    Description:
        Life of the camps during a session (ticket 2.10, DESIGN 5.1 "Nachschub und Wechsel"), once per check of the
        spawn loop. A camp has a state (COIN_fnc_createCamp): "active", "moving" (removed and set up elsewhere),
        "cleared" (replaced after a delay, COIN_fnc_checkCampCleared) or "retired" (removed, not replaced). In order:
        1. camps of a destroyed nest are retired, then the surplus over the capacity (COIN_campCapacity, which follows
           the nests): first camps that are not spawned and not discovered, last spawned ones,
        2. active camps inside a new exclusion zone (captured sector, FOB, COIN_fnc_getCampExclusion) and undiscovered
           camps whose COIN_campRelocateMinutes are over move: "moving",
        3. a camp that is not spawned and not "active" is dropped at once; a moving one is set up again elsewhere. A
           spawned one stays until the spawn loop removes its content (nobody sees it vanish),
        4. replacements that are due (COIN_campReplacements, mission times) create a camp while the capacity has room;
           where no camp can be created, one more try follows after the shortest replacement delay.
        Switched off by COIN_enableCampLifecycle. Redraws the debug map when something changed. Server only.

    Parameter(s):
        NONE

    Returns:
        Something changed [BOOL]
*/

if (!isServer || {isNil "COIN_camps"} || {!COIN_enableCampLifecycle}) exitWith {false};

private _changed = false;
private _spawned = COIN_spawnedCamps;
COIN_campReplaceMinutes params ["_retryMinutes"];

private _setState = {
    params ["_camp", "_state", "_why"];
    _camp set [6, _state];
    _changed = true;
    diag_log format ["[COIN] camps: camp %1 (nest %2) at %3 is now %4 (%5)", _camp select 0, _camp select 1, _camp select 2, _state, _why];
};

// 1. Camps of destroyed nests, then the surplus over the capacity
private _destroyed = (COIN_nests select {(_x select 5) isEqualTo "destroyed"}) apply {_x select 0};
{
    if ((_x select 1) in _destroyed) then {
        [_x, "retired", "its nest is destroyed"] call _setState;
    };
} forEach ([] call COIN_fnc_getActiveCamps);

private _active = [] call COIN_fnc_getActiveCamps;
private _surplus = count _active - COIN_campCapacity;
if (_surplus > 0) then {
    // Not spawned and undiscovered first, spawned ones last
    private _ranked = [_active, [], {([0, 2] select ((_x select 0) in _spawned)) + ([0, 1] select (_x select 3))}, "ASCEND"] call BIS_fnc_sortBy;
    for "_i" from 0 to (_surplus - 1) do {
        [_ranked select _i, "retired", format ["%1 camps for a capacity of %2", count _active, COIN_campCapacity]] call _setState;
    };
};

// 2. A new exclusion zone, undiscovered camps that stood long enough
private _zones = [] call COIN_fnc_getCampExclusion;
{
    private _camp = _x;
    if ((_camp select 6) isEqualTo "active") then {
        if ((_zones findIf {((_camp select 2) distance2D _x) < COIN_campExclusionRadius}) >= 0) then {
            [_camp, "moving", "inside an exclusion zone"] call _setState;
        } else {
            if (!(_camp select 3) && {!((_camp select 0) in _spawned)} && {time >= (_camp select 7)}) then {
                [_camp, "moving", "undiscovered for too long"] call _setState;
            };
        };
    };
} forEach (COIN_camps apply {_x});

// 3. Camps that are not spawned leave now, moving ones are set up elsewhere
{
    _x params ["_id", "", "", "", "", "", "_state"];
    if (_state != "active" && {!(_id in _spawned)}) then {
        COIN_camps = COIN_camps select {(_x select 0) != _id};
        _changed = true;
        diag_log format ["[COIN] camps: camp %1 removed from the list (%2)", _id, _state];
        if (_state isEqualTo "moving") then {
            if (([] call COIN_fnc_createCamp) isEqualTo []) then {
                COIN_campReplacements pushBack (time + _retryMinutes * 60);
            };
        };
    };
} forEach (COIN_camps apply {_x});

// 4. Replacements that are due
private _due = COIN_campReplacements select {_x <= time};
COIN_campReplacements = COIN_campReplacements select {_x > time};
{
    if (count ([] call COIN_fnc_getActiveCamps) < COIN_campCapacity) then {
        if (([] call COIN_fnc_createCamp) isEqualTo []) then {
            COIN_campReplacements pushBack (time + _retryMinutes * 60);
        } else {
            _changed = true;
        };
    } else {
        diag_log format ["[COIN] camps: no replacement, %1 camps for a capacity of %2", count ([] call COIN_fnc_getActiveCamps), COIN_campCapacity];
    };
} forEach _due;

if (_changed && {COIN_debug}) then {
    [] call COIN_fnc_drawCampMarkers;
};

_changed
