/*
    File: fn_getCampCover.sqf
    Author: COIN Liberation

    Description:
        Cover around a camp spot (ticket 2.8, DESIGN 5.1: flat ground "mit Deckung"): number of terrain objects of
        COIN_campCoverTypes (trees, bushes, rocks) within COIN_campCoverRadius.

    Parameter(s):
        _pos - Position [ARRAY]

    Returns:
        Number of cover objects [NUMBER]
*/

params [
    ["_pos", [], [[]]]
];

count (nearestTerrainObjects [_pos, COIN_campCoverTypes, COIN_campCoverRadius, false, true])
