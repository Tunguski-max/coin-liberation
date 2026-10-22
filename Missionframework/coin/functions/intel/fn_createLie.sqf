/*
    File: fn_createLie.sqf
    Author: COIN Liberation

    Description:
        Makes a lie (ticket 3.4, DESIGN 7, ADR 0021): a circle on the map that looks like a true one, with a random nest
        type (from a hint on, a rumor shows none) and a random level, so also a random size. It points to no nest (nest id
        -1) and has a hidden fake point (COIN_fnc_findFakeSpot) it is built around like around a real nest. It is its own
        circle and never shrinks. It disappears when a player on foot has searched the fake point
        (COIN_fnc_intelSearchLoop). Record as in the save: [id, -1, center, radius, level, shownType, fakePos]. Server only.

    Parameter(s):
        _origin - Position of the civilian who lies [ARRAY, defaults to [0, 0, 0]]

    Returns:
        The intel record, [] if no fake point was found [ARRAY]
*/

params [
    ["_origin", [0, 0, 0], [[]], [2, 3]]
];

if (!isServer) exitWith {[]};

private _fakePos = [_origin] call COIN_fnc_findFakeSpot;
if (_fakePos isEqualTo []) exitWith {
    diag_log format ["[COIN] intel: no fake point found within %1 tries near %2, no lie made", COIN_lieSpotTries, _origin];
    []
};

private _level = selectRandom ["rumor", "hint", "tip"];
private _radius = [_level] call COIN_fnc_getIntelRadius;
private _shownType = ["", selectRandom (COIN_nestTypeNames apply {_x select 0})] select !(_level isEqualTo "rumor");

private _id = COIN_intelNextId;
COIN_intelNextId = COIN_intelNextId + 1;
private _intel = [_id, -1, [_fakePos, _radius] call COIN_fnc_offsetCenter, _radius, _level, _shownType, _fakePos];
COIN_intel pushBack _intel;

[_intel] call COIN_fnc_drawIntelMarker;

_intel
