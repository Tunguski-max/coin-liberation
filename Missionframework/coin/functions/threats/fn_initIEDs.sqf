/*
    File: fn_initIEDs.sqf
    Author: COIN Liberation

    Description:
        Server start of the IEDs (ticket 4.1a, DESIGN 6, ADR 0022). Called by COIN_fnc_initNests once the nests are
        known. IEDs are not saved, so every start lays them anew: every active IED workshop lays its full budget
        (COIN_iedBudgetPerWorkshop) with COIN_fnc_createIED, together at most COIN_maxActiveIEDs. Then starts the
        loop that lets the army set them off (COIN_fnc_iedLoop) and draws the debug map when COIN_debug is on.
        Sets COIN_ieds (layout in COIN_fnc_createIED) and COIN_iedNextId. Logs the IEDs per workshop.
        Called, not spawned: the loop it starts is spawned inside.

    Parameter(s):
        NONE

    Returns:
        Number of IEDs [NUMBER]
*/

if (!isServer) exitWith {0};

COIN_ieds = [];
COIN_iedNextId = 1;

{
    _x params ["_nestId", "_nestType", "", "", "", "_state"];
    if (_nestType isEqualTo "iedWorkshop" && {_state isEqualTo "active"}) then {
        for "_i" from 1 to COIN_iedBudgetPerWorkshop do {
            [_nestId] call COIN_fnc_createIED;
        };
        diag_log format [
            "[COIN] ieds: workshop %1 laid %2 of %3 IEDs",
            _nestId, {(_x select 1) isEqualTo _nestId} count COIN_ieds, COIN_iedBudgetPerWorkshop
        ];
    };
} forEach COIN_nests;
diag_log format ["[COIN] ieds: %1 IEDs laid (at most %2)", count COIN_ieds, COIN_maxActiveIEDs];

if (COIN_debug) then {
    [] call COIN_fnc_drawIEDMarkers;
};

[] spawn COIN_fnc_iedLoop;

count COIN_ieds
