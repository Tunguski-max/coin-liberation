/*
    File: fn_vbiedLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop of the VBIED garages (ticket 4.3, DESIGN 6, ADR 0022). Every COIN_vbiedCheckInterval seconds each
        garage that is active, has fewer than COIN_vbiedBudgetPerGarage VBIEDs under way and is not waiting out its
        cooldown (COIN_vbiedReadyAt, COIN_vbiedCooldownMinutes after its last VBIED was used up) looks for targets in
        its influence radius (COIN_fnc_getVBIEDTargets: FOBs and players). With a target, one roll against
        COIN_vbiedChance; a hit sends a VBIED to a random target (COIN_fnc_createVBIED). A destroyed garage sends
        none (logged once), VBIEDs already under way finish their run. Sets COIN_vbieds, COIN_vbiedNextId and
        COIN_vbiedReadyAt (not saved: a restart starts with ready garages). Runs as long as COIN_enableVBIEDs is true.
        Started by COIN_fnc_initNests. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

// VBIED = [id, garage id, vehicle, driver, target] (COIN_fnc_createVBIED)
COIN_vbieds = [];
COIN_vbiedNextId = 1;
// Garage id -> mission time from which it may send the next VBIED
COIN_vbiedReadyAt = createHashMap;

diag_log format [
    "[COIN] vbieds: loop on, a roll every %1 s per ready garage, chance %2, cooldown %3 min, %4 garages active",
    COIN_vbiedCheckInterval, COIN_vbiedChance, COIN_vbiedCooldownMinutes,
    {(_x select 1) isEqualTo "vbiedGarage" && {(_x select 5) isEqualTo "active"}} count COIN_nests
];

private _reportedDestroyed = [];

while {GRLIB_endgame == 0 && {COIN_enableVBIEDs}} do {
    sleep COIN_vbiedCheckInterval;

    {
        _x params ["_garageId", "_type", "", "_pos", "", "_state"];

        if (_state isNotEqualTo "active") then {
            if !(_garageId in _reportedDestroyed) then {
                _reportedDestroyed pushBack _garageId;
                diag_log format ["[COIN] vbieds: garage %1 is destroyed, it sends no VBIEDs any more", _garageId];
            };
            continue;
        };

        if (({(_x select 1) isEqualTo _garageId} count COIN_vbieds) >= COIN_vbiedBudgetPerGarage) then {continue};
        if (time < (COIN_vbiedReadyAt getOrDefault [_garageId, 0])) then {continue};

        private _targets = [_pos, [_type] call COIN_fnc_getNestRadius] call COIN_fnc_getVBIEDTargets;
        if (_targets isEqualTo []) then {continue};

        private _roll = random 1;
        diag_log format [
            "[COIN] vbieds: garage %1 has %2 targets in reach, roll %3 (a VBIED below %4)",
            _garageId, count _targets, (round (_roll * 100)) / 100, COIN_vbiedChance
        ];
        if (_roll >= COIN_vbiedChance) then {continue};

        [_garageId, selectRandom _targets] call COIN_fnc_createVBIED;
    } forEach (COIN_nests select {(_x select 1) isEqualTo "vbiedGarage"});
};

diag_log "[COIN] vbieds: loop off";

true
