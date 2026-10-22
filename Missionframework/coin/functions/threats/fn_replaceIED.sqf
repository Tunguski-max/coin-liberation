/*
    File: fn_replaceIED.sqf
    Author: COIN Liberation

    Description:
        Replacement of a used IED (ticket 4.1b, DESIGN 6): called by COIN_fnc_removeIED for every IED that is gone. A
        workshop that is destroyed, or a switch that is off, lays nothing (IEDs already laid stay). Otherwise waits
        COIN_iedBudgetRegenMinutes, then the workshop lays a new IED elsewhere (COIN_fnc_createIED). No place or the
        global cap reached: one more try after the same time, until it works, the workshop is destroyed,
        COIN_enableIEDs/COIN_enableIEDRegen go off or Liberation's endgame starts. Waiting times are not saved. No
        polling: one sleeping thread per replacement. Must be spawned. Server only.

    Parameter(s):
        _nestId - Id of the workshop [NUMBER]

    Returns:
        Nothing
*/

params [
    ["_nestId", -1, [0]]
];

if (!isServer) exitWith {};

// Does the workshop still lay IEDs? Logs why not.
private _mayReplace = {
    if (!COIN_enableIEDs || {!COIN_enableIEDRegen}) exitWith {false};
    private _nestIndex = COIN_nests findIf {(_x select 0) isEqualTo _nestId};
    if (_nestIndex < 0 || {((COIN_nests select _nestIndex) select 5) isNotEqualTo "active"}) exitWith {
        diag_log format ["[COIN] ieds: workshop %1 is destroyed, no replacement", _nestId];
        false
    };
    true
};

if !(call _mayReplace) exitWith {};
diag_log format ["[COIN] ieds: workshop %1 replaces a used IED in %2 min", _nestId, COIN_iedBudgetRegenMinutes];

while {GRLIB_endgame == 0} do {
    sleep (COIN_iedBudgetRegenMinutes * 60);
    if !(call _mayReplace) exitWith {};

    private _ied = [_nestId] call COIN_fnc_createIED;
    if (_ied isNotEqualTo []) exitWith {
        diag_log format [
            "[COIN] ieds: workshop %1 replaced a used IED with IED %2, %3 of %4 IEDs now",
            _nestId, _ied select 0, {(_x select 1) isEqualTo _nestId} count COIN_ieds, COIN_iedBudgetPerWorkshop
        ];
        if (COIN_debug) then {
            [] call COIN_fnc_drawIEDMarkers;
        };
    };

    diag_log format ["[COIN] ieds: workshop %1 could not replace an IED, next try in %2 min", _nestId, COIN_iedBudgetRegenMinutes];
};
