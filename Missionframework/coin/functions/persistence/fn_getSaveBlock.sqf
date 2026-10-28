/*
    File: fn_getSaveBlock.sqf
    Author: COIN Liberation

    Description:
        Builds entry 22 of Liberation's save (hook in KPLIB_fnc_getSaveData, ADR 0005, ADR 0018, ADR 0021):
        [COIN_saveVersion, [nest, ...], [intel, ...], [favor stock, favor counter in minutes]] with nest = [id, type, kind, pos, seed, state],
        intel = [id, nestId, center, radius, level, shownType, fakePos] and the favors of ticket 5.4 (save version 3, entry 3; before
        COIN_fnc_initFavors has set them, those of the loaded block are written back).
        As long as the COIN module has no nests (nests switched off, unknown save version, or a save before COIN_fnc_initNests is done),
        the loaded block is written back unchanged, so a save never loses its nests or intel.

    Parameter(s):
        NONE

    Returns:
        COIN block for the save [ARRAY]
*/

if (!isNil "COIN_nests") exitWith {
    // The favors: the numbers of the module, before they are set those of the loaded block (a block of version 2 has none: 0 and 0)
    private _favors = if (isNil "COIN_favorStock" || {isNil "COIN_favorCounter"}) then {
        (missionNamespace getVariable ["COIN_loadedSaveBlock", []]) param [3, [0, 0]]
    } else {
        [COIN_favorStock, COIN_favorCounter]
    };
    [COIN_saveVersion, COIN_nests, missionNamespace getVariable ["COIN_intel", []], _favors]
};

missionNamespace getVariable ["COIN_loadedSaveBlock", []]
