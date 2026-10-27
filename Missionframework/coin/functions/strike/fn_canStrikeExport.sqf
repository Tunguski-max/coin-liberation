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

count ([] call COIN_fnc_findExportAirfields) > 0
