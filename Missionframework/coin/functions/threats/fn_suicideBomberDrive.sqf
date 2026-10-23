/*
    File: fn_suicideBomberDrive.sqf
    Author: COIN Liberation

    Description:
        The run of one suicide bomber (ticket 4.4, DESIGN 6, ADR 0022), spawned by COIN_fnc_createSuicideBomber. Every
        COIN_suicideBomberWatchInterval seconds:
        - the nearest player (COIN_fnc_getPresence) is his target, so he goes for the nearest group and changes when
          another one is closer (BLUFOR AI is neither target nor trigger),
        - every COIN_suicideBomberOrderInterval seconds he gets his order again (stand up, walk to the target). That
          is how he ignores ACE's "Get Down!" (setUnitPos "DOWN") and "Go Away!" (doMove away), which only act at once,
        - within COIN_suicideBomberYellDistance of the target he shouts once (COIN_suicideBomberYellSound, chance
          COIN_suicideBomberYellChance),
        - within COIN_suicideBomberTriggerDistance of the target the vest goes off (COIN_fnc_explodeSuicideBomber).
        The run ends when
        - he is not free any more (dead, unconscious, captured: COIN_fnc_getFighterState): nothing more happens here (a
          man shot dead may still go off, the Killed handler of COIN_fnc_createSuicideBomber),
        - the vest went off,
        - he has not arrived after COIN_suicideBomberTimeoutMinutes, no player is left to go for, or the switch goes
          off: he disappears.
        Then the workshop waits COIN_suicideBomberCooldownMinutes (COIN_suicideBomberReadyAt) and the bomber leaves the
        list (COIN_suicideBombers). What the run leaves (the body) is removed like content of a nest: when no player was
        within COIN_despawnDistance for COIN_despawnDelay seconds. With COIN_debug he has a marker. Must be spawned.
        Server only.

    Parameter(s):
        _id - Bomber id [NUMBER]

    Returns:
        Nothing
*/

params [
    ["_id", -1, [0]]
];

if (!isServer) exitWith {};

private _index = COIN_suicideBombers findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {};
(COIN_suicideBombers select _index) params ["", "_workshopId", "_unit"];

private _presentPlayers = {
    ([] call COIN_fnc_getPresence) select {isPlayer _x}
};

private _marker = format ["COIN_suicideBomber_%1", _id];
if (COIN_debug) then {
    createMarker [_marker, getPosATL _unit];
    _marker setMarkerType COIN_suicideBomberMarkerType;
    _marker setMarkerColor COIN_suicideBomberMarkerColor;
    _marker setMarkerText format ["Suicide bomber %1 (Workshop %2)", _id, _workshopId];
};

private _deadline = time + COIN_suicideBomberTimeoutMinutes * 60;
private _nextOrder = 0;
private _nextMarker = 0;
private _nextProgress = 0;
private _yelled = false;
private _outcome = "";

while {_outcome isEqualTo ""} do {
    private _state = [_unit] call COIN_fnc_getFighterState;
    _outcome = switch (true) do {
        case (isNull _unit): {"gone"};
        case (GRLIB_endgame != 0 || {!COIN_enableSuicideBombers}): {"switched off"};
        case (_state isNotEqualTo "free"): {format ["bomber %1", _state]};
        case (time >= _deadline): {"timeout"};
        default {""};
    };
    if (_outcome isNotEqualTo "") exitWith {};

    // The nearest player is his target
    private _target = objNull;
    private _distance = 1e10;
    {
        if ((_x distance2D _unit) < _distance) then {
            _target = _x;
            _distance = _x distance2D _unit;
        };
    } forEach (call _presentPlayers);
    if (isNull _target) exitWith {_outcome = "no target left"};

    // Shortly before the blast he shouts (sound of Drongos Map Population, silent without the mod)
    if (!_yelled && {_distance <= COIN_suicideBomberYellDistance}) then {
        _yelled = true;
        if (random 1 < COIN_suicideBomberYellChance && {isClass (configFile >> "CfgSounds" >> COIN_suicideBomberYellSound)}) then {
            [_unit, [COIN_suicideBomberYellSound, COIN_suicideBomberYellRange]] remoteExec ["say3D", 0];
            diag_log format ["[COIN] suicideBombers: suicide bomber %1 shouts (%2), %3 m from %4", _id, COIN_suicideBomberYellSound, round _distance, name _target];
        };
    };

    if (_distance <= COIN_suicideBomberTriggerDistance) then {
        [_unit, format ["reached %1 (%2 m)", name _target, round _distance]] call COIN_fnc_explodeSuicideBomber;
        _outcome = "exploded";
    } else {
        if (time >= _nextOrder) then {
            _unit setUnitPos "UP";
            _unit doMove (getPosATL _target);
            _nextOrder = time + COIN_suicideBomberOrderInterval;
        };
    };

    if (time >= _nextProgress) then {
        diag_log format [
            "[COIN] suicideBombers: suicide bomber %1 at %2, %3 m from %4, %5 km/h",
            _id, getPosATL _unit, round _distance, name _target, round speed _unit
        ];
        _nextProgress = time + COIN_suicideBomberProgressInterval;
    };

    if (COIN_debug && {time >= _nextMarker}) then {
        _marker setMarkerPos (getPosATL _unit);
        _nextMarker = time + COIN_suicideBomberMarkerInterval;
    };

    sleep COIN_suicideBomberWatchInterval;
};

deleteMarker _marker;
COIN_suicideBomberReadyAt set [_workshopId, time + COIN_suicideBomberCooldownMinutes * 60];
COIN_suicideBombers deleteAt (COIN_suicideBombers findIf {(_x select 0) isEqualTo _id});
diag_log format [
    "[COIN] suicideBombers: suicide bomber %1 of workshop %2 is used up (%3), workshop ready again in %4 min, %5 bombers under way",
    _id, _workshopId, _outcome, COIN_suicideBomberCooldownMinutes, count COIN_suicideBombers
];

// A bomber who runs out of time or has nobody left disappears, the rest (his body) stays until nobody is near
if (_outcome in ["timeout", "no target left", "switched off", "gone"]) exitWith {
    deleteVehicle _unit;
};

private _lastNear = time;
private _removed = false;
while {GRLIB_endgame == 0 && {!_removed} && {!isNull _unit}} do {
    if (((call _presentPlayers) findIf {(_x distance2D _unit) <= COIN_despawnDistance}) >= 0) then {
        _lastNear = time;
    } else {
        if ((time - _lastNear) >= COIN_despawnDelay) then {
            deleteVehicle _unit;
            _removed = true;
            diag_log format ["[COIN] suicideBombers: suicide bomber %1 removed (no player within %2 m for %3 s)", _id, COIN_despawnDistance, COIN_despawnDelay];
        };
    };
    sleep COIN_spawnCheckInterval;
};
