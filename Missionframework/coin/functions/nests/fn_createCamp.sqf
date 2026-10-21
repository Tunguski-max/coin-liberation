/*
    File: fn_createCamp.sqf
    Author: COIN Liberation

    Description:
        Creates one camp as data (tickets 2.7, 2.8 and 2.10, DESIGN 5.1): a place that keeps the placement rules
        (COIN_fnc_findCampSpot) and, as owner, the nearest active nest that still has a free slot (a nest supplies at
        most as many camps as its weight, COIN_fnc_getCampWeight; camps that count are COIN_fnc_getActiveCamps).
        Camp = [id, nest id, position, discovered, seed, technical gone, state, relocate at]:
        - discovered: set by the spawn loop when the camp spawns for the first time,
        - seed: the camp looks the same on every visit of this session (not saved),
        - technical gone: a technical that was taken or destroyed does not come back (COIN_fnc_removeCamp),
        - state: "active", "moving", "cleared" or "retired" (COIN_fnc_manageCamps),
        - relocate at: mission time (time) from which an undiscovered camp moves, COIN_campRelocateMinutes.
        Appends the camp to COIN_camps and logs it with its distances. Server only.

    Parameter(s):
        NONE

    Returns:
        The camp, [] if no nest has a free slot or no place was found [ARRAY]
*/

if (!isServer) exitWith {[]};

private _used = createHashMap;
{
    private _nestId = _x select 1;
    _used set [_nestId, (_used getOrDefault [_nestId, 0]) + 1];
} forEach ([] call COIN_fnc_getActiveCamps);

private _owners = COIN_nests select {
    (_x select 5) isEqualTo "active"
    && {(_used getOrDefault [_x select 0, 0]) < ([_x select 1] call COIN_fnc_getCampWeight)}
};
if (_owners isEqualTo []) exitWith {
    diag_log "[COIN] camps: no active nest has a free slot, no camp created";
    []
};

([] call COIN_fnc_findCampSpot) params ["_pos", "_rejected"];
if (_pos isEqualTo []) exitWith {
    diag_log format [
        "[COIN] camps: ERROR - no place for a camp in %1 tries, rejected by: %2, camp left out",
        COIN_campPlaceAttempts, ((keys _rejected) apply {format ["%1 %2x", _x, _rejected get _x]}) joinString ", "
    ];
    []
};
private _tries = 1;
{
    _tries = _tries + _x;
} forEach (values _rejected);

_owners = [_owners, [], {(_x select 3) distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;
(_owners select 0) params ["_nestId", "_nestType", "", "_nestPos"];

private _id = COIN_campNextId;
COIN_campNextId = _id + 1;
COIN_campRelocateMinutes params ["_relocateMin", "_relocateMax"];
private _camp = [_id, _nestId, _pos, false, floor random COIN_campSeedRange, false, "active", time + (_relocateMin + random (_relocateMax - _relocateMin)) * 60];
COIN_camps pushBack _camp;

diag_log format [
    "[COIN] camps: camp %1 at %2 belongs to nest %3 (%4), %5 m away; %6; %7 tries",
    _id, _pos, _nestId, _nestType, round (_pos distance2D _nestPos), [_pos] call COIN_fnc_describeCampSpot, _tries
];

_camp
