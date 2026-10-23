/*
    File: fn_findVBIEDSpot.sqf
    Author: COIN Liberation

    Description:
        Spawn point for a VBIED (ticket 4.3, DESIGN 6): on a road COIN_vbiedSpawnDistance (800-1200 m) from the target,
        out of sight. A spot is rejected when
        - it is in water or its distance to the target (measured on the road itself) is outside the range,
        - a player (COIN_fnc_getPresence) is closer than COIN_vbiedMinPlayerDistance,
        - a player within COIN_vbiedSightDistance has a clear line of sight to it (the roof of the car, COIN_vbiedSightHeight).
        Tries COIN_vbiedSpawnTries random points, cheap rules first, the road search last. The car faces the target.
        Server only.

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
private _range = COIN_vbiedSpawnDistance;
private _present = [] call COIN_fnc_getPresence;

// The rule a spot breaks, "" if none
private _fault = {
    params ["_spot"];
    private _distance = _spot distance2D _targetPos;
    private _roof = ATLToASL [_spot select 0, _spot select 1, COIN_vbiedSightHeight];
    switch (true) do {
        case (surfaceIsWater _spot): {"water"};
        case (_distance < (_range select 0) || {_distance > (_range select 1)}): {"distance"};
        case ((_present findIf {(_x distance2D _spot) < COIN_vbiedMinPlayerDistance}) >= 0): {"playerClose"};
        case ((_present findIf {
            (_x distance2D _spot) <= COIN_vbiedSightDistance
            && {(lineIntersectsSurfaces [eyePos _x, _roof, _x, vehicle _x, true, 1, "VIEW", "FIRE"]) isEqualTo []}
        }) >= 0): {"seen"};
        default {""};
    }
};

private _result = [];
private _rejected = createHashMap;

for "_i" from 1 to COIN_vbiedSpawnTries do {
    private _point = [_targetX, _targetY, 0] getPos [(_range select 0) + random ((_range select 1) - (_range select 0)), random 360];
    private _rule = "";
    if (surfaceIsWater _point) then {
        _rule = "water";
    } else {
        private _roads = _point nearRoads COIN_vbiedRoadSearchRadius;
        if (_roads isEqualTo []) then {
            _rule = "noRoad";
        } else {
            private _road = selectRandom _roads;
            private _spot = getPosATL _road;
            _spot = [_spot select 0, _spot select 1, 0];
            _rule = [_spot] call _fault;
            if (_rule isEqualTo "") then {
                // A road has no front: face the end that points towards the target
                private _dir = getDir _road;
                private _toTarget = _spot getDir _targetPos;
                if (abs ((((_dir - _toTarget) + 540) mod 360) - 180) > 90) then {
                    _dir = _dir + 180;
                };
                _result = [_spot, _dir];
            };
        };
    };

    if (_rule isEqualTo "") exitWith {};
    _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
};

if (_result isEqualTo []) then {
    diag_log format [
        "[COIN] vbieds: no spawn point in %1 tries, rejected by: %2",
        COIN_vbiedSpawnTries, ((keys _rejected) apply {format ["%1 %2x", _x, _rejected get _x]}) joinString ", "
    ];
};

_result
