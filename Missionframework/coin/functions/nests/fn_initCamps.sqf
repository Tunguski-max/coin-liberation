/*
    File: fn_initCamps.sqf
    Author: COIN Liberation

    Description:
        Server start of the camps (ticket 2.7, DESIGN 5.1, decision E8). Called by COIN_fnc_initNests once the nests
        are known. Camps are not saved, so every start creates them anew:
        - COIN_campCapacity from COIN_fnc_getCampCapacity,
        - that many camps at places that keep the placement rules (COIN_fnc_findCampSpot, ticket 2.8), each belonging
          to the nearest active nest that still has a free slot (a nest supplies at most as many camps as its weight,
          COIN_fnc_getCampWeight). A camp without a place is left out with an error line.
        - COIN_camps = [[id, nest id, position], ...].
        Logs every camp with its distances (COIN_fnc_describeCampSpot) and the camps per nest. Listens to COIN_nestDestroyed: the capacity is calculated and logged
        again, camps are not removed yet. Draws the debug map when COIN_debug is on.

    Parameter(s):
        NONE

    Returns:
        Number of camps [NUMBER]
*/

if (!isServer) exitWith {0};

COIN_camps = [];
([] call COIN_fnc_getCampCapacity) params ["_capacity", "_active", "_total"];
COIN_campCapacity = _capacity;
diag_log format ["[COIN] camps: capacity %1 (weight of the active nests %2 of %3, at most %4)", _capacity, _active, _total, COIN_campMax];

// Camps per nest id
private _used = createHashMap;

for "_i" from 1 to _capacity do {
    private _owners = COIN_nests select {
        (_x select 5) isEqualTo "active"
        && {(_used getOrDefault [_x select 0, 0]) < ([_x select 1] call COIN_fnc_getCampWeight)}
    };
    if (_owners isEqualTo []) exitWith {
        diag_log format ["[COIN] camps: no active nest has a free slot left, %1 of %2 camps created", count COIN_camps, _capacity];
    };

    ([] call COIN_fnc_findCampSpot) params ["_pos", "_rejected"];
    if (_pos isEqualTo []) then {
        diag_log format [
            "[COIN] camps: ERROR - no place for a camp in %1 tries, rejected by: %2, camp left out",
            COIN_campPlaceAttempts, ((keys _rejected) apply {format ["%1 %2x", _x, _rejected get _x]}) joinString ", "
        ];
        continue
    };
    private _tries = 1;
    {
        _tries = _tries + _x;
    } forEach (values _rejected);

    _owners = [_owners, [], {(_x select 3) distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;
    private _owner = _owners select 0;
    _owner params ["_nestId", "_nestType", "", "_nestPos"];
    _used set [_nestId, (_used getOrDefault [_nestId, 0]) + 1];

    private _id = count COIN_camps + 1;
    COIN_camps pushBack [_id, _nestId, _pos];
    diag_log format [
        "[COIN] camps: camp %1 at %2 belongs to nest %3 (%4), %5 m away; %6; %7 tries",
        _id, _pos, _nestId, _nestType, round (_pos distance2D _nestPos), [_pos] call COIN_fnc_describeCampSpot, _tries
    ];
};

// Per nest, to check that none supplies more camps than its weight
{
    _x params ["_nestId", "_nestType", "", "", "", "_state"];
    private _weight = [_nestType] call COIN_fnc_getCampWeight;
    diag_log format ["[COIN] camps: nest %1 (%2, %3) supplies %4 of %5 camps", _nestId, _nestType, _state, _used getOrDefault [_nestId, 0], _weight];
} forEach COIN_nests;
diag_log format ["[COIN] camps: %1 of %2 camps created", count COIN_camps, _capacity];

// A destroyed nest lowers the capacity; its camps go with the replacement ticket (2.10)
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
