/*
    File: fn_receiveSaveBlock.sqf
    Author: COIN Liberation

    Description:
        Takes entry 22 of Liberation's save (the COIN block) while Liberation loads its save (hook in save_manager.sqf,
        ADR 0005). Only stores it: the COIN config may not be loaded yet at that point. COIN_fnc_initNests reads it
        after save_is_loaded. Not called for a new campaign or a pre 0.96.5 save, then the block stays empty.

    Parameter(s):
        _block - Entry 22 of the save, [] if the save has none (e.g. a save from phase 1) [ARRAY]

    Returns:
        Block was stored [BOOL]
*/

params [
    ["_block", [], [[]]]
];

COIN_loadedSaveBlock = _block;

true
