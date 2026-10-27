/*
    File: fn_planStrikeLeader.sqf
    Author: COIN Liberation

    Description:
        Plan of the strike task "Arrest leader" (ticket 5.15, DESIGN 8.2), made when it is offered (a kind without a plan is not
        offered). The leader belongs to a command post, one of the active ones at random. He stays at a house of a map village (the sites
        of the aid tasks, COIN_siteList, ticket 5.20) at least COIN_leaderMinNestDistance from that command post, one of the
        COIN_leaderVillageChoices nearest at random. The house is any house of the village, he stands beside it (a free spot
        COIN_leaderSpotRadius m from its wall). The units do not care for the players: they appear at the beginning, wherever the
        players are. Server only.

    Parameter(s):
        _origin - Where the one stands who told of it, for the log [ARRAY, defaults to [0, 0, 0]]

    Returns:
        [village centre, village name, [] (no destination), "", id of the command post, place of the leader, direction he faces],
        [] if there is no such village [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]]]
];

if (!isServer || {isNil "COIN_nests"} || {isNil "sectors_capture"}) exitWith {[]};

private _commands = COIN_nests select {(_x select 1) isEqualTo "command" && {(_x select 5) isEqualTo "active"}};
if (_commands isEqualTo []) exitWith {[]};
private _nest = selectRandom _commands;
private _nestPos = _nest select 3;

// The list of the villages is made on the first rating of any town (it does not depend on the town)
if (isNil "COIN_siteList") then {
    [sectors_capture select 0] call COIN_fnc_rateSites;
};
if (isNil "COIN_siteList") exitWith {[]};

// Villages that pass the checks of the aid tasks and are far enough from the command post, the nearest first
private _villages = COIN_siteList select {
    (_x select 3) isEqualTo "" && {((_x select 1) distance2D _nestPos) >= COIN_leaderMinNestDistance}
};
_villages = [_villages, [], {(_x select 1) distance2D _nestPos}, "ASCEND"] call BIS_fnc_sortBy;
if (_villages isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: leader: no village %1 m or more from command post %2", COIN_leaderMinNestDistance, _nest select 0];
    []
};

// A house of the village and a free spot beside it, in a few tries with other villages and houses
private _choices = _villages select [0, COIN_leaderVillageChoices];
private _plan = [];
private _tries = 0;
while {_plan isEqualTo [] && {_choices isNotEqualTo []}} do {
    private _village = _choices deleteAt (floor random count _choices);
    _village params ["_name", "_centre"];

    private _houses = (nearestTerrainObjects [_centre select [0, 2], COIN_siteHouseTypes, COIN_siteHouseRadius, false, true]) select {alive _x};
    for "_try" from 1 to COIN_leaderSpotTries do {
        if (_plan isNotEqualTo [] || {_houses isEqualTo []}) exitWith {};
        _tries = _tries + 1;
        private _house = selectRandom _houses;
        private _housePos = getPosATL _house;
        private _radius = (boundingBoxReal _house) select 2;
        private _spot = [_housePos, _radius, _radius + COIN_leaderSpotRadius, COIN_leaderSpotClearance, 0, COIN_leaderSpotGradient, 0, [], [_housePos, _housePos]] call BIS_fnc_findSafePos;
        if (
            _spot isEqualType []
            && {count _spot >= 2}
            && {(_spot select 0) isEqualType 0}
            && {(_spot distance2D _housePos) >= _radius}
        ) then {
            _plan = [
                _centre, _name, [], "", _nest select 0,
                [_spot select 0, _spot select 1, 0],
                // He faces away from the house, to the road or the village
                _housePos getDir _spot
            ];
        };
    };
};

if (_plan isEqualTo []) then {
    diag_log format ["[COIN] strike: leader: no free spot at a house of the %1 villages near command post %2 (%3 tries)", count _villages, _nest select 0, _tries];
} else {
    diag_log format [
        "[COIN] strike: leader plan: command post %1 at %2, village %3, %4 m from it, spot %5 (%6 villages, %7 tries), %8 m from the origin",
        _nest select 0, _nestPos select [0, 2], _plan select 1, round ((_plan select 0) distance2D _nestPos), (_plan select 5) select [0, 2],
        count _villages, _tries, round ((_plan select 0) distance2D _origin)
    ];
};

_plan
