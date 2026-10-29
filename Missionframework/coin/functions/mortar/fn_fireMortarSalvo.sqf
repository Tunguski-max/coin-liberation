/*
    File: fn_fireMortarSalvo.sqf
    Author: COIN Liberation

    Description:
        One salvo of a mortar attack (ticket 6.7a, #158, DESIGN 9): COIN_mortarRounds rounds of the mortar's high
        explosive magazine, each at its own random point within the given spread around the FOB (real ammunition,
        real damage). The gunner fires one round at a time with doArtilleryFire; a Fired event counts the shots. The
        mortar is refilled before the salvo. Stops when the gunner or the mortar is dead, a round does not come
        within COIN_mortarFireTimeout seconds, or the target is out of the mortar's range. Must be spawned or
        called from a scheduled script. Server only.

    Parameter(s):
        _mortar - The mortar with its gunner [OBJECT]
        _fob    - Position of the FOB [ARRAY]
        _spread - Radius around the FOB in m [NUMBER]

    Returns:
        Rounds fired [NUMBER]
*/

params [
    ["_mortar", objNull, [objNull]],
    ["_fob", [], [[]], [2, 3]],
    ["_spread", 100, [0]]
];

if (!isServer || {isNull _mortar}) exitWith {0};

if (isNil {_mortar getVariable "COIN_shots"}) then {
    _mortar setVariable ["COIN_shots", 0];
    _mortar addEventHandler ["Fired", {
        params ["_unit"];
        _unit setVariable ["COIN_shots", (_unit getVariable ["COIN_shots", 0]) + 1];
    }];
};

_mortar setVehicleAmmo 1;
private _mag = (_mortar magazinesTurret [0]) select {
    getNumber (configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo") >> "indirectHit") > 0
};
if (_mag isEqualTo []) exitWith {
    diag_log format ["[COIN] mortar: ERROR - %1 has no high explosive magazine: %2", typeOf _mortar, _mortar magazinesTurret [0]];
    0
};
_mag = _mag select 0;

private _fired = 0;
for "_i" from 1 to COIN_mortarRounds do {
    private _gunner = gunner _mortar;
    if (!alive _mortar || {!alive _gunner}) exitWith {};
    if !([_fob] call COIN_fnc_mortarFobExists) exitWith {
        diag_log "[COIN] mortar: the FOB is gone, salvo stops";
    };

    private _point = _fob getPos [random _spread, random 360];
    _point = [_point select 0, _point select 1, 0];
    if !(_point inRangeOfArtillery [[_mortar], _mag]) exitWith {
        diag_log format ["[COIN] mortar: target %1 is out of range of %2, salvo stops", _point, typeOf _mortar];
    };

    private _before = _mortar getVariable ["COIN_shots", 0];
    _mortar doArtilleryFire [_point, _mag, 1];

    private _timeout = time + COIN_mortarFireTimeout;
    waitUntil {sleep 0.5; (_mortar getVariable ["COIN_shots", 0]) > _before || {time > _timeout} || {!alive _mortar} || {!alive (gunner _mortar)}};
    if ((_mortar getVariable ["COIN_shots", 0]) <= _before) exitWith {
        diag_log format ["[COIN] mortar: no round fired within %1 s (mortar alive %2, gunner alive %3), salvo stops", COIN_mortarFireTimeout, alive _mortar, alive (gunner _mortar)];
    };
    _fired = _fired + 1;
    sleep COIN_mortarRoundGap;
};

_fired
