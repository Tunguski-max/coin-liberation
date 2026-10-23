/*
    File: fn_vbiedDrive.sqf
    Author: COIN Liberation

    Description:
        The run of one VBIED (ticket 4.3, DESIGN 6, ADR 0022), spawned by COIN_fnc_createVBIED. Every
        COIN_vbiedWatchInterval seconds:
        - the driver is sent to the target, to its new position when a moving one went further than
          COIN_vbiedRetargetDistance (a player who is dead or gone: the nearest player, none left: the driver gives up),
        - within COIN_vbiedTriggerDistance of the target the charge goes off (COIN_fnc_explodeVBIED).
        The run ends when
        - the vehicle is destroyed (the charge goes off) or deleted,
        - the driver is not free any more (dead, unconscious, captured, out of the vehicle: COIN_fnc_getFighterState)
          or the vehicle cannot move: the vehicle stands, nothing goes off,
        - he has not arrived after COIN_vbiedTimeoutMinutes, nobody is left to go for, or the switch goes off: vehicle and
          driver disappear.
        Then the garage waits COIN_vbiedCooldownMinutes (COIN_vbiedReadyAt) and the VBIED leaves the list (COIN_vbieds).
        What the run leaves (vehicle, wreck, driver) is removed like content of a nest: when no player was within
        COIN_despawnDistance for COIN_despawnDelay seconds. With COIN_debug the VBIED has a marker. Must be spawned.
        Server only.

    Parameter(s):
        _id - VBIED id [NUMBER]

    Returns:
        Nothing
*/

params [
    ["_id", -1, [0]]
];

if (!isServer) exitWith {};

private _index = COIN_vbieds findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {};
(COIN_vbieds select _index) params ["", "_garageId", "_vehicle", "_driver", "_target"];
_target params ["_kind", "_ref"];

private _presentPlayers = {
    ([] call COIN_fnc_getPresence) select {isPlayer _x}
};
private _targetPos = {
    if (_kind isEqualTo "player") then {getPosATL _ref} else {_ref}
};

private _marker = format ["COIN_vbied_%1", _id];
if (COIN_debug) then {
    createMarker [_marker, getPosATL _vehicle];
    _marker setMarkerType COIN_vbiedMarkerType;
    _marker setMarkerColor COIN_vbiedMarkerColor;
    _marker setMarkerText format ["VBIED %1 (Garage %2)", _id, _garageId];
};

private _deadline = time + COIN_vbiedTimeoutMinutes * 60;
private _destination = [0, 0, 0];
private _nextMarker = 0;
private _nextProgress = 0;
private _outcome = "";

while {_outcome isEqualTo ""} do {
    _outcome = switch (true) do {
        case (isNull _vehicle): {"vehicle deleted"};
        case (!alive _vehicle): {
            [_vehicle, "vehicle destroyed"] call COIN_fnc_explodeVBIED;
            "vehicle destroyed"
        };
        case (GRLIB_endgame != 0 || {!COIN_enableVBIEDs}): {"switched off"};
        case (([_driver] call COIN_fnc_getFighterState) isNotEqualTo "free"): {
            format ["driver %1", [_driver] call COIN_fnc_getFighterState]
        };
        case ((vehicle _driver) isNotEqualTo _vehicle): {"driver left the vehicle"};
        case (!canMove _vehicle): {"vehicle disabled"};
        case (time >= _deadline): {"timeout"};
        default {""};
    };
    if (_outcome isNotEqualTo "") exitWith {};

    // A player who is dead or gone: the nearest one, none left: nobody to go for
    if (_kind isEqualTo "player" && {!alive _ref}) then {
        private _players = call _presentPlayers;
        if (_players isEqualTo []) then {
            _outcome = "no target left";
        } else {
            _ref = _players select 0;
            {
                if ((_x distance2D _vehicle) < (_ref distance2D _vehicle)) then {_ref = _x};
            } forEach _players;
            diag_log format ["[COIN] vbieds: VBIED %1 lost its target, goes for %2", _id, name _ref];
        };
    };
    if (_outcome isNotEqualTo "") exitWith {};

    private _pos = call _targetPos;
    if ((_vehicle distance2D _pos) <= COIN_vbiedTriggerDistance) then {
        [_vehicle, format ["reached its target (%1 m)", round (_vehicle distance2D _pos)]] call COIN_fnc_explodeVBIED;
        _outcome = "exploded";
    } else {
        if ((_pos distance2D _destination) > COIN_vbiedRetargetDistance) then {
            _destination = _pos;
            _driver doMove _pos;
        };
    };

    if (time >= _nextProgress) then {
        diag_log format [
            "[COIN] vbieds: VBIED %1 at %2, %3 m from its target, %4 km/h, engine %5, driver %6",
            _id, getPosATL _vehicle, round (_vehicle distance2D _pos), round speed _vehicle, isEngineOn _vehicle,
            [_driver] call COIN_fnc_getFighterState
        ];
        _nextProgress = time + COIN_vbiedProgressInterval;
    };

    if (COIN_debug && {time >= _nextMarker}) then {
        _marker setMarkerPos (getPosATL _vehicle);
        _nextMarker = time + COIN_vbiedMarkerInterval;
    };

    sleep COIN_vbiedWatchInterval;
};

deleteMarker _marker;
COIN_vbiedReadyAt set [_garageId, time + COIN_vbiedCooldownMinutes * 60];
COIN_vbieds deleteAt (COIN_vbieds findIf {(_x select 0) isEqualTo _id});
diag_log format [
    "[COIN] vbieds: VBIED %1 of garage %2 is used up (%3), garage ready again in %4 min, %5 VBIEDs under way",
    _id, _garageId, _outcome, COIN_vbiedCooldownMinutes, count COIN_vbieds
];

// A driver who gives up or runs out of time disappears, the rest stays until nobody is near
if (_outcome in ["timeout", "no target left", "switched off", "vehicle deleted"]) exitWith {
    deleteVehicle _driver;
    deleteVehicle _vehicle;
};

private _lastNear = time;
private _removed = false;
while {GRLIB_endgame == 0 && {!_removed} && {!isNull _vehicle || {!isNull _driver}}} do {
    private _at = [getPosATL _driver, getPosATL _vehicle] select (!isNull _vehicle);
    if (((call _presentPlayers) findIf {(_x distance2D _at) <= COIN_despawnDistance}) >= 0) then {
        _lastNear = time;
    } else {
        if ((time - _lastNear) >= COIN_despawnDelay) then {
            deleteVehicle _driver;
            deleteVehicle _vehicle;
            _removed = true;
            diag_log format ["[COIN] vbieds: VBIED %1 removed (no player within %2 m for %3 s)", _id, COIN_despawnDistance, COIN_despawnDelay];
        };
    };
    sleep COIN_spawnCheckInterval;
};
