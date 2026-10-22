/*
    File: fn_findIEDSpot.sqf
    Author: COIN Liberation

    Description:
        Place for an IED (ticket 4.1a, DESIGN 6): on a road of any kind (tracks included) in the influence radius of its
        workshop, on the carriageway or at most COIN_iedMaxRoadOffset beside it, and
        - at least COIN_iedMinDistSector from every sector centre (not in the town core),
        - at least COIN_iedMinDistBase from the start base and every FOB,
        - at least COIN_iedMinDistIED from every other IED (COIN_ieds, all workshops).
        Tries COIN_iedPlaceAttempts random points, cheap rules first, the road search last. The rules apply to the
        random point (before the road search) and again to the spot beside the road.
        Server only.

    Parameter(s):
        _nestPos - Position of the workshop [ARRAY]
        _radius  - Influence radius of the workshop in m [NUMBER]

    Returns:
        [position in whole metres or [] if none was found, rejected points per rule (HASHMAP rule -> number)] [ARRAY]
*/

params [
    ["_nestPos", [], [[]]],
    ["_radius", 0, [0]]
];

if (!isServer) exitWith {[[], createHashMap]};

private _bases = [startbase] + (missionNamespace getVariable ["GRLIB_all_fobs", []]);
private _others = (missionNamespace getVariable ["COIN_ieds", []]) apply {_x select 3};

// The rule a position breaks, "" if none
private _fault = {
    params ["_pos"];
    switch (true) do {
        case (surfaceIsWater _pos): {"water"};
        case ((_pos distance2D _nestPos) > _radius): {"radius"};
        case ((sectors_allSectors findIf {(_pos distance2D (markerPos _x)) < COIN_iedMinDistSector}) >= 0): {"sector"};
        case ((_bases findIf {(_pos distance2D _x) < COIN_iedMinDistBase}) >= 0): {"base"};
        case ((_others findIf {(_pos distance2D _x) < COIN_iedMinDistIED}) >= 0): {"otherIED"};
        default {""};
    }
};

private _spot = [];
private _rejected = createHashMap;

for "_i" from 1 to COIN_iedPlaceAttempts do {
    private _point = _nestPos getPos [_radius * sqrt random 1, random 360];
    private _rule = [_point] call _fault;

    if (_rule isEqualTo "") then {
        private _roads = _point nearRoads COIN_iedRoadSearchRadius;
        if (_roads isEqualTo []) then {
            _rule = "noRoad";
        } else {
            private _candidate = (selectRandom _roads) getPos [random COIN_iedMaxRoadOffset, random 360];
            _candidate = [round (_candidate select 0), round (_candidate select 1), 0];
            _rule = [_candidate] call _fault;
            if (_rule isEqualTo "") then {
                _spot = _candidate;
            };
        };
    };

    if (_rule isEqualTo "") exitWith {};
    _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
};

[_spot, _rejected]
