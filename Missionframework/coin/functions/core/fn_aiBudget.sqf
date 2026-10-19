/*
    File: fn_aiBudget.sqf
    Author: COIN Liberation

    Description:
        Server loop of the AI budget for enemy AI (ADR 0015, changed 2026-10-19, ticket 2.13).
        Liberation's three caps (sectors, battlegroups, patrols) get one value: COIN_maxEnemyAI times the Unitcap
        factor of the lobby. Liberation counts every OPFOR unit, so the loop adds the current number of COIN units
        to that value; COIN units thereby come on top instead of using up Liberation's share. The caps are published
        as COIN_enemyAICaps for the clients (overlay hint), also for late joiners. No hook: the caps are globals that
        Liberation reads anew at every check.
        Runs as long as COIN_enableAIBudget is true. Switched off at runtime, Liberation's original caps come back.
        Must run on the server only.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

// Liberation's values after its config (already multiplied by the Unitcap factor)
private _original = [GRLIB_sector_cap, GRLIB_battlegroup_cap, GRLIB_patrol_cap];
private _base = round (COIN_maxEnemyAI * GRLIB_unitcap);

diag_log format [
    "[COIN] budget: Liberation caps sector/battlegroup/patrol %1 -> %2 (COIN_maxEnemyAI %3 x Unitcap %4) plus COIN units, camps while COIN units <= %5",
    _original, _base, COIN_maxEnemyAI, GRLIB_unitcap, COIN_maxCampAI
];

// Applies the caps here and sends them to the clients
private _publish = {
    params ["_caps"];
    COIN_enemyAICaps = _caps;
    [COIN_enemyAICaps] call COIN_fnc_applyEnemyAICaps;
    publicVariable "COIN_enemyAICaps";
};

private _lastCap = -1;

while {COIN_enableAIBudget} do {
    private _coinUnits = [] call COIN_fnc_countCoinUnits;
    private _cap = _base + _coinUnits;

    if (_cap != _lastCap) then {
        [[_cap, _cap, _cap]] call _publish;
        // The first application is always logged, every later change only with COIN_debug
        if (_lastCap < 0 || COIN_debug) then {
            diag_log format ["[COIN] budget: Liberation caps sector/battlegroup/patrol now %1/%2/%3 (%4 + %5 COIN units)", GRLIB_sector_cap, GRLIB_battlegroup_cap, GRLIB_patrol_cap, _base, _coinUnits];
        };
        _lastCap = _cap;
    };

    sleep COIN_aiBudgetInterval;
};

[_original] call _publish;
diag_log format ["[COIN] budget: switched off, Liberation caps back to %1", _original];

true
