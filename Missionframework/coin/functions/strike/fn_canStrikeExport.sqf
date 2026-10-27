/*
    File: fn_canStrikeExport.sqf
    Author: COIN Liberation

    Description:
        Requirement of the strike task "Export" (ticket 5.18, DESIGN 8.2): there is an airfield of COIN_exportAirfields with a town that
        the militia holds within COIN_exportTownRange m (COIN_fnc_findExportAirfields). Server only.

    Parameter(s):
        NONE

    Returns:
        The kind can be offered now [BOOL]
*/

// Writes the reason for each airfield that is left out to the RPT (the offer is made when a questioning has a result, not all the time)
count ([true] call COIN_fnc_findExportAirfields) > 0
