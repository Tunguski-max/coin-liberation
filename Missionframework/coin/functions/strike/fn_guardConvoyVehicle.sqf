/*
    File: fn_guardConvoyVehicle.sqf
    Author: COIN Liberation

    Description:
        Protects a vehicle of the arms transport (ticket 5.16) from damage that does not come from the players, as the vehicles of
        Liberation's convoy hijack mission are (there its HandleDamage lets only damage of BLUFOR through). Without it civilian cars
        drive full speed into the convoy and the convoy rams itself, and the task is decided by something else than the players.
        Unlike Liberation a hit that is not let through does not set the damage of the part to 0 (that would repair it) but leaves it as
        it is. Damage without a source or instigator (fire, a vehicle that burns out) is let through, or a burning vehicle would never be
        destroyed. With COIN_debug the RPT tells of a blocked hit of more than COIN_convoyBlockedLogDamage (at most
        COIN_convoyBlockedLogMax lines per vehicle). Switch: COIN_convoyBlockOtherDamage. Server only (where the vehicle is local).

    Parameter(s):
        _vehicle - The vehicle [OBJECT]

    Returns:
        Nothing
*/

params [
    ["_vehicle", objNull, [objNull]]
];

if (!isServer || {isNull _vehicle} || {!COIN_convoyBlockOtherDamage}) exitWith {};

_vehicle addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator"];

    // The side of whoever did it: the instigator (the shooter, also in a vehicle), else the source (a man or a vehicle with its crew)
    private _byObject = [_source, _instigator] select (!isNull _instigator);
    if (isNull _byObject) exitWith {_damage};

    private _side = if (_byObject isKindOf "CAManBase") then {side group _byObject} else {side _byObject};
    if (_side isEqualTo GRLIB_side_friendly) exitWith {_damage};

    // Not by the players: the damage the part has stays as it is
    private _current = if (_hitIndex < 0) then {damage _unit} else {_unit getHitIndex _hitIndex};
    if (COIN_debug && {(_damage - _current) > COIN_convoyBlockedLogDamage}) then {
        private _logged = _unit getVariable ["COIN_blockedLogs", 0];
        if (_logged < COIN_convoyBlockedLogMax) then {
            _unit setVariable ["COIN_blockedLogs", _logged + 1];
            diag_log format [
                "[COIN] strike: convoy vehicle %1: damage of %2 (%3, %4) blocked, part %5, %6 -> %7",
                typeOf _unit, typeOf _byObject, _side, _projectile, _selection, _current toFixed 2, _damage toFixed 2
            ];
        };
    };
    _current
}];
