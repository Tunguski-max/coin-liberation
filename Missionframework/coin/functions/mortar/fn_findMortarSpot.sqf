/*
    File: fn_findMortarSpot.sqf
    Author: COIN Liberation

    Description:
        Position for the mortar squad of a mortar attack (ticket 6.7a, #158, DESIGN 9): COIN_mortarDistance
        (1500-2500 m) from the FOB, out of sight of the players, preferably inside a staging area, on flat ground.
        Tries COIN_mortarSpotTries random points in two passes: first only inside a staging area, then anywhere.
        A point is rejected when it is
        - in water, steeper than COIN_mortarMinNormalZ, on or beside a road, under a roof or a tree,
        - closer than COIN_mortarMinDistSector to a sector centre, closer than COIN_mortarMinDistBase to the start base
          or a FOB,
        - closer than COIN_mortarMinDistPlayer to a player, or seen by a player within COIN_mortarSightDistance
          (line of sight from his eyes to a point 1.5 m above the ground).
        Server only.

    Parameter(s):
        _fob - Position of the FOB that is shelled [ARRAY]

    Returns:
        [position or [] if none was found, the spot is inside a staging area, rejected points per rule (HASHMAP rule -> number)] [ARRAY]
*/

params [
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer) exitWith {[[], false, createHashMap]};

COIN_mortarDistance params ["_distMin", "_distMax"];

private _players = (allPlayers - entities "HeadlessClient_F") select {alive _x};
private _bases = [startbase] + (missionNamespace getVariable ["GRLIB_all_fobs", []]);
private _rejected = createHashMap;

// The rule a point breaks, "" if none
private _fault = {
    params ["_point"];
    private _eye = ATLToASL [_point select 0, _point select 1, 1.5];
    switch (true) do {
        case (surfaceIsWater _point): {"water"};
        case (((surfaceNormal _point) select 2) < COIN_mortarMinNormalZ): {"slope"};
        case (isOnRoad _point || {(_point nearRoads 15) isNotEqualTo []}): {"road"};
        case (lineIntersects [ATLToASL [_point select 0, _point select 1, 0.5], ATLToASL [_point select 0, _point select 1, 8]]): {"covered"};
        case ((sectors_allSectors findIf {(_point distance2D (markerPos _x)) < COIN_mortarMinDistSector}) >= 0): {"sector"};
        case ((_bases findIf {(_point distance2D _x) < COIN_mortarMinDistBase}) >= 0): {"base"};
        case ((_players findIf {(_x distance2D _point) < COIN_mortarMinDistPlayer}) >= 0): {"playerNear"};
        case ((_players findIf {
            (_x distance2D _point) < COIN_mortarSightDistance
            && {(lineIntersectsSurfaces [eyePos _x, _eye, _x, objNull, true, 1, "VIEW", "FIRE"]) isEqualTo []}
        }) >= 0): {"seen"};
        default {""};
    }
};

private _spot = [];
private _inArea = false;
{
    private _needArea = _x;
    for "_i" from 1 to COIN_mortarSpotTries do {
        private _point = _fob getPos [_distMin + random (_distMax - _distMin), random 360];
        _point = [_point select 0, _point select 1, 0];

        if (_needArea && {([_point] call COIN_fnc_getStagingAreasAt) isEqualTo []}) then {
            _rejected set ["outsideArea", (_rejected getOrDefault ["outsideArea", 0]) + 1];
            continue;
        };
        private _rule = [_point] call _fault;
        if (_rule isNotEqualTo "") then {
            _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
            continue;
        };
        _spot = _point;
        break;
    };
    if (_spot isNotEqualTo []) exitWith {};
} forEach [true, false];

if (_spot isNotEqualTo []) then {
    _inArea = ([_spot] call COIN_fnc_getStagingAreasAt) isNotEqualTo [];
};

[_spot, _inArea, _rejected]
