/*
    File: fn_planAmbush.sqf
    Author: COIN Liberation

    Description:
        What an ambush looks like when it spawns (ticket 4.5, DESIGN 6), decided from the seed of its camp so it is the
        same on every visit: the number of fighters (COIN_ambushFighters) and of cover objects (COIN_ambushCoverCount, at
        most one per fighter). The loop asks the budget with the number of fighters before it spawns (ADR 0015). Server
        only.

    Parameter(s):
        _camp - Camp with an ambush [ARRAY, layout in COIN_fnc_createCamp]

    Returns:
        [fighters, cover objects] [ARRAY]
*/

params [
    ["_camp", [], [[]]]
];

_camp params ["", "", "", "", "_seed"];

// Value streams of the seed (COIN_fnc_seededRandom index), apart from those of COIN_fnc_planCamp
private _streamFighters = 8000;
private _streamCover = 8100;

COIN_ambushFighters params ["_fightersMin", "_fightersMax"];
COIN_ambushCoverCount params ["_coverMin", "_coverMax"];

private _fighters = _fightersMin + floor ([_seed, _streamFighters, _fightersMax - _fightersMin + 1] call COIN_fnc_seededRandom);
private _cover = (_coverMin + floor ([_seed, _streamCover, _coverMax - _coverMin + 1] call COIN_fnc_seededRandom)) min _fighters;

[_fighters, _cover]
