/*
    File: fn_getSuicideBomberTargets.sqf
    Author: COIN Liberation

    Description:
        Targets an IED workshop can send a suicide bomber to (ticket 4.4, DESIGN 6): every player on foot (no vehicle,
        no drone: COIN_fnc_getPresence) within the given radius of the workshop. Server only.

    Parameter(s):
        _pos    - Position of the workshop [ARRAY]
        _radius - Influence radius of the workshop in m [NUMBER]

    Returns:
        Players [ARRAY of OBJECTs]
*/

params [
    ["_pos", [], [[]]],
    ["_radius", 0, [0]]
];

if (!isServer) exitWith {[]};

([] call COIN_fnc_getPresence) select {
    isPlayer _x && {(vehicle _x) isEqualTo _x} && {(_x distance2D _pos) <= _radius}
}
