/*
    File: fn_runMortarAttack.sqf
    Author: COIN Liberation

    Description:
        The course of one mortar attack (ticket 6.7a, #158, DESIGN 9), after COIN_fnc_startMortarAttack:
        1. the squad spawns at the given spot (COIN_fnc_spawnMortarSquad), with COIN_debug a marker shows it,
        2. after COIN_mortarStartDelay seconds it fires one salvo per entry of COIN_mortarSpread, the first spreads
           around the FOB with the first radius, the next ones tighter (the squad ranges in), COIN_mortarSalvoGap
           seconds apart, one log line per salvo; it stops when the gunner or the mortar is dead or the FOB is gone,
        3. the squad stays COIN_mortarHoldSeconds after the last salvo, or less if all its fighters are dead (the attack
           is over then),
        4. then it is taken down: everything is deleted as soon as no player is within COIN_mortarRemoveDistance,
           checked every COIN_mortarRemoveSeconds (dead fighters and the mortar included).
        Sets COIN_mortarActive to false when the attack is over (before the take-down) and sets the cooldown. Must be spawned. Server only.

    Parameter(s):
        _fob    - Position of the FOB that is shelled [ARRAY]
        _spot   - Position of the mortar [ARRAY]
        _reason - Why the attack starts, for the log [STRING]

    Returns:
        NONE
*/

params [
    ["_fob", [], [[]], [2, 3]],
    ["_spot", [], [[]], [2, 3]],
    ["_reason", "", [""]]
];

if (!isServer) exitWith {};

private _fobName = [_fob] call KPLIB_fnc_getFobName;
private _squad = [_spot, _fob] call COIN_fnc_spawnMortarSquad;
if (_squad isEqualTo []) exitWith {
    COIN_mortarActive = false;
};
_squad params ["_group", "_fighters", "_mortar"];

private _areas = ([_spot] call COIN_fnc_getStagingAreasAt) apply {[_x] call COIN_fnc_describeStagingArea};
diag_log format [
    "[COIN] mortar: attack on FOB %1 (%2) starts (%3): %4 fighters with %5 at %6, %7 m from the FOB, %8",
    _fobName, _fob apply {round _x}, _reason, count _fighters, typeOf _mortar, _spot apply {round _x}, round (_spot distance2D _fob),
    if (_areas isEqualTo []) then {"outside a staging area"} else {"in " + (_areas joinString "; ")}
];

private _marker = "";
if (COIN_debug) then {
    _marker = createMarker [format ["COIN_mortarSquad_%1", round time], _spot];
    _marker setMarkerType "mil_triangle";
    _marker setMarkerColor COIN_mortarMarkerColor;
    _marker setMarkerText format ["Mörsertrupp (FOB %1)", _fobName];
};

private _fobExists = {(GRLIB_all_fobs findIf {(_x distance2D _fob) < 50}) >= 0};
private _canFire = {alive _mortar && {alive (gunner _mortar)}};
private _anyAlive = {(_fighters findIf {alive _x}) >= 0};

sleep COIN_mortarStartDelay;

private _total = count COIN_mortarSpread;
{
    private _salvo = _forEachIndex + 1;
    if !(call _canFire) exitWith {
        diag_log format ["[COIN] mortar: attack on FOB %1: gunner or mortar is dead, no salvo %2 of %3", _fobName, _salvo, _total];
    };
    if !(call _fobExists) exitWith {
        diag_log format ["[COIN] mortar: attack on FOB %1: the FOB is gone, no salvo %2 of %3", _fobName, _salvo, _total];
    };

    private _fired = [_mortar, _fob, _x] call COIN_fnc_fireMortarSalvo;
    diag_log format ["[COIN] mortar: attack on FOB %1: salvo %2 of %3, %4 of %5 rounds fired, spread %6 m", _fobName, _salvo, _total, _fired, COIN_mortarRounds, _x];

    if (_salvo < _total) then {
        private _next = time + COIN_mortarSalvoGap;
        waitUntil {sleep 1; time > _next || {!(call _canFire)}};
    };
} forEach COIN_mortarSpread;

// In position until the time is up or all of them are dead
private _holdEnd = time + COIN_mortarHoldSeconds;
waitUntil {sleep 5; time > _holdEnd || {!(call _anyAlive)} || {!COIN_enableMortarAttacks}};
diag_log format [
    "[COIN] mortar: attack on FOB %1 over (%2), %3 of %4 fighters alive",
    _fobName, ["the squad is eliminated", "time is up, the squad is taken down"] select (call _anyAlive), {alive _x} count _fighters, count _fighters
];

// The attack is over: the FOB waits COIN_mortarCooldownSeconds, the next attack may start while the squad is taken down
COIN_mortarCooldowns set [[_fob] call COIN_fnc_mortarFobKey, time + COIN_mortarCooldownSeconds];
COIN_mortarActive = false;

// Taken down when nobody is near
private _playerNear = {
    ((allPlayers - entities "HeadlessClient_F") findIf {alive _x && {(_x distance2D _spot) < COIN_mortarRemoveDistance}}) >= 0
};
waitUntil {sleep COIN_mortarRemoveSeconds; !(call _playerNear)};

{deleteVehicle _x} forEach (_fighters + [_mortar]);
deleteGroup _group;
if (_marker isNotEqualTo "") then {deleteMarker _marker};
diag_log format ["[COIN] mortar: squad of the attack on FOB %1 removed", _fobName];

