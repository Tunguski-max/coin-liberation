/*
    File: fn_campFitsBudget.sqf
    Author: COIN Liberation

    Description:
        Tells whether a camp with the given number of fighters may spawn now (ADR 0015, ticket 2.13).
        A camp spawns complete or not at all: only while all COIN units together, nest guards included,
        stay within COIN_maxCampAI after the camp has spawned. Nests are never limited and do not ask.
        Without COIN_enableAIBudget camps are not limited. Runs on the server.

    Parameter(s):
        _fighters - Units the camp would spawn, crews included [NUMBER]

    Returns:
        Camp may spawn [BOOL]
*/

params [
    ["_fighters", 0, [0]]
];

if (!COIN_enableAIBudget) exitWith {true};

private _coinUnits = [] call COIN_fnc_countCoinUnits;
private _fits = (_coinUnits + _fighters) <= COIN_maxCampAI;

if (COIN_debug) then {
    diag_log format ["[COIN] budget: camp with %1 fighters %2 (COIN units %3, camp budget %4)", _fighters, ["does not fit", "fits"] select _fits, _coinUnits, COIN_maxCampAI];
};

_fits
