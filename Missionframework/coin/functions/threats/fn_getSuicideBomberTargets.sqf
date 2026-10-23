/*
    File: fn_getSuicideBomberTargets.sqf
    Author: COIN Liberation

    Description:
        Targets an IED workshop can send a suicide bomber to (ticket 4.4, DESIGN 6): every player on foot (no vehicle,
        no drone: COIN_fnc_getPresence) within the given radius of the workshop who stands in a town, i.e. within the
        capture radius of a sector of Liberation's sectors_capture or sectors_bigtown (GRLIB_capture_size, the capital
        COIN_capitalCaptureFactor times that, as Liberation evaluates it). Server only.

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

private _targets = [];
{
    private _player = _x;
    if (isPlayer _player && {(vehicle _player) isEqualTo _player} && {(_player distance2D _pos) <= _radius}) then {
        private _inTown = (sectors_capture + sectors_bigtown) findIf {
            (_player distance2D (markerPos _x)) <= (GRLIB_capture_size * ([1, COIN_capitalCaptureFactor] select (_x in sectors_bigtown)))
        };
        if (_inTown >= 0) then {
            _targets pushBack _player;
        };
    };
} forEach ([] call COIN_fnc_getPresence);

_targets
