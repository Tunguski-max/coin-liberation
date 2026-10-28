/*
    File: fn_favorLoop.sqf
    Author: COIN Liberation

    Description:
        Server: the counter of the favors (ticket 5.4, DESIGN 8.1). Every COIN_favorTickSeconds, as long as the reputation
        (Liberation's KP_liberation_civ_rep) is COIN_favorRepThreshold or more, at least one player is online and the stock is
        below COIN_favorMaxStored, the counter COIN_favorCounter (minutes) runs. At COIN_favorGainMinutes a favor comes
        (COIN_favorStock + 1, a line in the RPT) and the counter starts again with what is left. Below the reputation or without a
        player the counter stands still and the stock stays. With the stock full the counter does not run and stays at 0 (a counter
        thrown back by COIN_fnc_delayFavor below 0 stays). The numbers are published for the debug record (COIN_fnc_publishFavors).
        Server only.

    Parameter(s):
        NONE

    Returns:
        Loop ended [BOOL]
*/

if (!isServer) exitWith {false};

private _lastRunning = false;
private _last = diag_tickTime;

while {COIN_enableFavors} do {
    sleep COIN_favorTickSeconds;
    // Real time since the last step, so a lagging server does not slow the counter
    private _step = (diag_tickTime - _last) / 60;
    _last = diag_tickTime;

    private _reputation = missionNamespace getVariable ["KP_liberation_civ_rep", 0];
    private _players = count (allPlayers select {!(_x isKindOf "HeadlessClient_F")});
    private _room = COIN_favorStock < COIN_favorMaxStored;
    private _running = _reputation >= COIN_favorRepThreshold && {_players > 0} && {_room};
    private _changed = _running isNotEqualTo _lastRunning;
    _lastRunning = _running;

    if (_running) then {
        COIN_favorCounter = COIN_favorCounter + _step;
        if (COIN_favorCounter >= COIN_favorGainMinutes) then {
            COIN_favorCounter = COIN_favorCounter - COIN_favorGainMinutes;
            COIN_favorStock = COIN_favorStock + 1;
            _changed = true;
            diag_log format [
                "[COIN] favors: a new favor, stock %1 of %2 (reputation %3, counter %4 min left over)",
                COIN_favorStock, COIN_favorMaxStored, round _reputation, COIN_favorCounter toFixed 1
            ];
        };
    };
    // A full stock does not collect: the counter starts at 0 when a favor is used
    if (COIN_favorStock >= COIN_favorMaxStored) then {COIN_favorCounter = COIN_favorCounter min 0};

    if (_changed) then {
        diag_log format [
            "[COIN] favors: counter %1 (reputation %2, players online %3, stock %4 of %5)",
            ["stands still", "runs"] select _running, round _reputation, _players, COIN_favorStock, COIN_favorMaxStored
        ];
    };
    // Published when something changed; with COIN_debug at every step, so the debug record shows the counter
    if (_changed || {COIN_debug}) then {[_running] call COIN_fnc_publishFavors};
};

false
