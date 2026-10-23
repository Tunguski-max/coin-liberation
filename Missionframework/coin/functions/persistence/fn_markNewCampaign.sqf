/*
    File: fn_markNewCampaign.sqf
    Author: COIN Liberation

    Description:
        Notes that Liberation found no save and starts a new campaign (hook in save_manager.sqf, branch "Save nil").
        Only sets COIN_newCampaign: the COIN config may not be loaded yet at that point. COIN_fnc_initReputation reads
        it after save_is_loaded and sets the start reputation (ticket 5.7, ADR 0009). Not called for a loaded save.

    Parameter(s):
        NONE

    Returns:
        Flag was set [BOOL]
*/

COIN_newCampaign = true;

true
