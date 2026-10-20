/*
    File: fn_getSaveBlock.sqf
    Author: COIN Liberation

    Description:
        Builds entry 22 of Liberation's save (hook in KPLIB_fnc_getSaveData, ADR 0005, ADR 0018):
        [COIN_saveVersion, [nest, ...]] with nest = [id, type, kind, pos, seed, state].
        As long as the COIN module has no nests (nests switched off, or a save before COIN_fnc_initNests is done),
        the loaded block is written back unchanged, so a save never loses its nests.

    Parameter(s):
        NONE

    Returns:
        COIN block for the save [ARRAY]
*/

if (!isNil "COIN_nests") exitWith {
    [COIN_saveVersion, COIN_nests]
};

missionNamespace getVariable ["COIN_loadedSaveBlock", []]
