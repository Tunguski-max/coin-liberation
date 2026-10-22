/*
    File: fn_getCampExclusion.sqf
    Author: COIN Liberation

    Description:
        Centres of the exclusion zones (ticket 2.8 and 2.10, DESIGN 5.1): every captured sector (Liberation's
        blufor_sectors, marker names) and every FOB (GRLIB_all_fobs). No camp stands within COIN_campExclusionRadius
        of them, COIN_fnc_findCampSpot keeps away when it places one and COIN_fnc_manageCamps moves one that a new
        zone catches.

    Parameter(s):
        NONE

    Returns:
        Positions [ARRAY]
*/

((missionNamespace getVariable ["blufor_sectors", []]) apply {markerPos _x}) + (missionNamespace getVariable ["GRLIB_all_fobs", []])
