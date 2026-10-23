/*
    File: fn_getVBIEDTargets.sqf
    Author: COIN Liberation

    Description:
        Targets a VBIED garage can send its vehicle to (ticket 4.3, DESIGN 6): every FOB and every player (on foot or
        in a vehicle, no drones, no aircraft high above the ground: COIN_fnc_getPresence) within the given radius of the
        garage. Server only.

    Parameter(s):
        _pos    - Position of the garage [ARRAY]
        _radius - Influence radius of the garage in m [NUMBER]

    Returns:
        Targets, ["fob", position] or ["player", unit] each [ARRAY]
*/

params [
    ["_pos", [], [[]]],
    ["_radius", 0, [0]]
];

if (!isServer) exitWith {[]};

private _targets = [];
{
    if ((_x distance2D _pos) <= _radius) then {
        _targets pushBack ["fob", _x];
    };
} forEach (missionNamespace getVariable ["GRLIB_all_fobs", []]);

{
    if (isPlayer _x && {(_x distance2D _pos) <= _radius}) then {
        _targets pushBack ["player", _x];
    };
} forEach ([] call COIN_fnc_getPresence);

_targets
