/*
    File: fn_findSuicideBomberSpot.sqf
    Author: COIN Liberation

    Description:
        Spawn point for a suicide bomber (ticket 4.4, DESIGN 6): COIN_suicideBomberSpawnDistance (100-200 m) from the
        target, out of sight. A spot is rejected when
        - it is in water, steeper than COIN_suicideBomberMaxSlope or under a roof (a building, COIN_suicideBomberHeadroom),
        - a player (COIN_fnc_getPresence) is closer than COIN_suicideBomberMinPlayerDistance,
        - a player within COIN_suicideBomberSightDistance has a clear line of sight to the head of a man standing there
          (COIN_suicideBomberSightHeight).
        Tries COIN_suicideBomberSpawnTries random points, cheap rules first. The bomber faces the target. Server only.

    Parameter(s):
        _targetPos - Position of the target [ARRAY]

    Returns:
        [position ATL, direction] or [] if none was found [ARRAY]
*/

params [
    ["_targetPos", [], [[]]]
];

if (!isServer) exitWith {[]};

_targetPos params ["_targetX", "_targetY"];
COIN_suicideBomberSpawnDistance params ["_minDist", "_maxDist"];
private _present = [] call COIN_fnc_getPresence;

// The rule a spot breaks, "" if none
private _fault = {
    params ["_spot"];
    switch (true) do {
        case (surfaceIsWater _spot): {"water"};
        case (((surfaceNormal _spot) select 2) < COIN_suicideBomberMaxSlope): {"steep"};
        case (lineIntersects [ATLToASL [_spot select 0, _spot select 1, COIN_suicideBomberGroundClearance], ATLToASL [_spot select 0, _spot select 1, COIN_suicideBomberHeadroom]]): {"covered"};
        case ((_present findIf {(_x distance2D _spot) < COIN_suicideBomberMinPlayerDistance}) >= 0): {"playerClose"};
        case ((_present findIf {
            (_x distance2D _spot) <= COIN_suicideBomberSightDistance
            && {(lineIntersectsSurfaces [eyePos _x, ATLToASL [_spot select 0, _spot select 1, COIN_suicideBomberSightHeight], _x, vehicle _x, true, 1, "VIEW", "FIRE"]) isEqualTo []}
        }) >= 0): {"seen"};
        default {""};
    }
};

private _result = [];
private _rejected = createHashMap;

for "_i" from 1 to COIN_suicideBomberSpawnTries do {
    private _point = [_targetX, _targetY, 0] getPos [_minDist + random (_maxDist - _minDist), random 360];
    private _spot = [_point select 0, _point select 1, 0];
    private _rule = [_spot] call _fault;

    if (_rule isEqualTo "") exitWith {
        _result = [_spot, _spot getDir _targetPos];
    };
    _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
};

if (_result isEqualTo []) then {
    diag_log format [
        "[COIN] suicideBombers: no spawn point in %1 tries, rejected by: %2",
        COIN_suicideBomberSpawnTries, ((keys _rejected) apply {format ["%1 %2x", _x, _rejected get _x]}) joinString ", "
    ];
};

_result
