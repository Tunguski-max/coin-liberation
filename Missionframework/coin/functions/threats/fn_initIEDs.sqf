/*
    File: fn_initIEDs.sqf
    Author: COIN Liberation

    Description:
        Server start of the IEDs (ticket 4.1a, DESIGN 6, ADR 0022). Called by COIN_fnc_initNests once the nests are
        known. IEDs are not saved, so every start lays them anew: every active IED workshop lays its full budget
        (COIN_iedBudgetPerWorkshop) with COIN_fnc_createIED, together at most COIN_maxActiveIEDs. Draws the
        debug map when COIN_debug is on and starts the loop of the triggermen of remote IEDs (COIN_fnc_triggermanLoop,
        ticket 4.2b, while COIN_enableIEDRemote is on). No loop runs here: every IED has an engine trigger that starts its
        exact check when BLUFOR comes near (COIN_fnc_createIED, COIN_fnc_iedWatch).
        Sets COIN_ieds (layout in COIN_fnc_createIED) and COIN_iedNextId. Logs the IEDs per workshop.
        Called, not spawned.

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

// The triggermen of the remote IEDs come and go with the players (ticket 4.2b)
if (COIN_enableIEDRemote) then {
    [] spawn COIN_fnc_triggermanLoop;
} else {
    diag_log "[COIN] ieds: remote IEDs off, no triggermen";
};

count COIN_ieds
