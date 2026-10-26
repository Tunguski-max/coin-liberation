/*
    File: fn_planSiteAmbush.sqf
    Author: COIN Liberation

    Description:
        Decides whether an ambush waits at the site of an aid task, when the task is accepted (ticket 5.22, ADR 0024, DESIGN 8.2):
        1. a nest (any type, state "active") has the village centre within its influence radius (COIN_fnc_getNestRadius),
           otherwise the task is safe,
        2. the chance COIN_aidAmbushChance (rolled, new at every task),
        3. COIN_fnc_findSiteAmbushSpot finds a place.
        The numbers of fighters, cover objects and fighters in houses are rolled here too. What is decided is written to the RPT
        with the roll and the nest. Whether there is room in the camp budget is asked when the fighters spawn
        (COIN_fnc_runSiteAmbush). Nothing is spawned here. Switch COIN_enableAidAmbush. Server only.

    Parameter(s):
        _site   - [name, village centre, distance] from COIN_fnc_findSite [ARRAY]
        _toward - Where the army comes from, the elder's place [ARRAY]

    Returns:
        [nest id, position, direction, position on the road or [], fighters, cover objects, fighters in houses], [] if the task is safe [ARRAY]
*/

params [
    ["_site", [], [[]]],
    ["_toward", [], [[]]]
];

if (!isServer || {!COIN_enableAidAmbush} || {_site isEqualTo []} || {isNil "COIN_nests"}) exitWith {[]};

_site params ["_name", "_centre"];

// The nests that have the village in their influence radius, the nearest first
private _covering = (COIN_nests select {
    (_x select 5) isEqualTo "active" && {((_x select 3) distance2D _centre) <= ([_x select 1] call COIN_fnc_getNestRadius)}
}) apply {[(_x select 3) distance2D _centre, _x]};
_covering sort true;

if (_covering isEqualTo []) exitWith {
    diag_log format ["[COIN] danger: no ambush at %1, no active nest has it in range", _name];
    []
};

private _nest = (_covering select 0) select 1;
private _nestDistance = round ((_covering select 0) select 0);
private _roll = random 1;
// Two decimals for the RPT
private _rolled = (round (_roll * 100)) / 100;
if (_roll >= COIN_aidAmbushChance) exitWith {
    diag_log format [
        "[COIN] danger: no ambush at %1, roll %2 >= chance %3 (%4 nests in range, nearest nest %5 %6 at %7 m)",
        _name, _rolled, COIN_aidAmbushChance, count _covering, _nest select 0, _nest select 1, _nestDistance
    ];
    []
};

private _spot = [_centre, _toward] call COIN_fnc_findSiteAmbushSpot;
if (_spot isEqualTo []) exitWith {
    diag_log format ["[COIN] danger: no ambush at %1, roll %2, but no place for it %3 to %4 m before the village", _name, _rolled, COIN_aidAmbushDistance select 0, COIN_aidAmbushDistance select 1];
    []
};
_spot params ["_pos", "_dir", "_roadPos"];

COIN_aidAmbushFighters params ["_fightersMin", "_fightersMax"];
COIN_aidAmbushCoverCount params ["_coverMin", "_coverMax"];
COIN_aidAmbushHouseFighters params ["_houseMin", "_houseMax"];
private _fighters = _fightersMin + floor random ((_fightersMax - _fightersMin) + 1);
private _cover = (_coverMin + floor random ((_coverMax - _coverMin) + 1)) min _fighters;
private _house = _houseMin + floor random ((_houseMax - _houseMin) + 1);

diag_log format [
    "[COIN] danger: ambush at %1, roll %2 < chance %3, nest %4 %5 at %6 m",
    _name, _rolled, COIN_aidAmbushChance, _nest select 0, _nest select 1, _nestDistance
];
diag_log format [
    "[COIN] danger: ambush at %1: %2 fighters, %3 cover objects and %4 in houses, at %5 (%6 m from the village, %7, facing %8)",
    _name, _fighters, _cover, _house, _pos, round (_pos distance2D _centre), ["free ground", "beside a road"] select (_roadPos isNotEqualTo []), round _dir
];

[_nest select 0, _pos, _dir, _roadPos, _fighters, _cover, _house]
