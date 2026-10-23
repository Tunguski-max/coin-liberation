/*
    File: fn_suicideBomberLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop of the suicide bombers of the IED workshops (ticket 4.4, DESIGN 6, ADR 0022). Every
        COIN_suicideBomberCheckInterval seconds each workshop that is active, has fewer than
        COIN_suicideBomberBudgetPerWorkshop bombers under way and is not waiting out its cooldown
        (COIN_suicideBomberReadyAt, COIN_suicideBomberCooldownMinutes after its last bomber was used up) looks for
        players on foot in its influence radius (COIN_fnc_getSuicideBomberTargets). With one, a roll against the
        chance of the reputation band (COIN_suicideBomberChances, COIN_fnc_getReputationBand); a hit sends a bomber to a
        random one of them (COIN_fnc_createSuicideBomber). A destroyed workshop sends none (logged once), bombers
        already under way finish their run. Sets COIN_suicideBombers, COIN_suicideBomberNextId and
        COIN_suicideBomberReadyAt (not saved: a restart starts with ready workshops). Runs as long as
        COIN_enableSuicideBombers is true. Started by COIN_fnc_initNests. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

// Bomber = [id, workshop id, unit] (COIN_fnc_createSuicideBomber)
COIN_suicideBombers = [];
COIN_suicideBomberNextId = 1;
// Workshop id -> mission time from which it may send the next bomber
COIN_suicideBomberReadyAt = createHashMap;

diag_log format [
    "[COIN] suicideBombers: loop on, a roll every %1 s per ready workshop, chances by reputation band %2, cooldown %3 min, %4 workshops active",
    COIN_suicideBomberCheckInterval, COIN_suicideBomberChances, COIN_suicideBomberCooldownMinutes,
    {(_x select 1) isEqualTo "iedWorkshop" && {(_x select 5) isEqualTo "active"}} count COIN_nests
];

private _reportedDestroyed = [];

while {GRLIB_endgame == 0 && {COIN_enableSuicideBombers}} do {
    sleep COIN_suicideBomberCheckInterval;

    {
        _x params ["_workshopId", "_type", "", "_pos", "", "_state"];

        if (_state isNotEqualTo "active") then {
            if !(_workshopId in _reportedDestroyed) then {
                _reportedDestroyed pushBack _workshopId;
                diag_log format ["[COIN] suicideBombers: workshop %1 is destroyed, it sends no suicide bombers any more", _workshopId];
            };
            continue;
        };

        if (({(_x select 1) isEqualTo _workshopId} count COIN_suicideBombers) >= COIN_suicideBomberBudgetPerWorkshop) then {continue};
        if (time < (COIN_suicideBomberReadyAt getOrDefault [_workshopId, 0])) then {continue};

        private _radius = [_type] call COIN_fnc_getNestRadius;
        private _targets = [_pos, _radius] call COIN_fnc_getSuicideBomberTargets;
        if (_targets isEqualTo []) then {
            // Players in reach but none on foot: says why the workshop does not roll
            private _inReach = ([] call COIN_fnc_getPresence) select {isPlayer _x && {(_x distance2D _pos) <= _radius}};
            if (_inReach isNotEqualTo []) then {
                diag_log format [
                    "[COIN] suicideBombers: workshop %1 has %2 players in reach, none of them on foot (no roll)",
                    _workshopId, count _inReach
                ];
            };
            continue;
        };

        private _band = [] call COIN_fnc_getReputationBand;
        private _row = [COIN_suicideBomberChances, _band] call COIN_fnc_findByType;
        private _chance = if (_row isEqualTo []) then {0} else {_row select 1};
        private _roll = random 1;
        diag_log format [
            "[COIN] suicideBombers: workshop %1 has %2 players on foot in reach, reputation %3, roll %4 (a bomber below %5)",
            _workshopId, count _targets, _band, (round (_roll * 100)) / 100, _chance
        ];
        if (_roll >= _chance) then {continue};

        [_workshopId, selectRandom _targets] call COIN_fnc_createSuicideBomber;
    } forEach (COIN_nests select {(_x select 1) isEqualTo "iedWorkshop"});
};

diag_log "[COIN] suicideBombers: loop off";

true
