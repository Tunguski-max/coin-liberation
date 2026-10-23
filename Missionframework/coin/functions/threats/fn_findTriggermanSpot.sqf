/*
    File: fn_findTriggermanSpot.sqf
    Author: COIN Liberation

    Description:
        Place for the triggerman of a remote-triggered IED (ticket 4.2b, DESIGN 6): COIN_triggermanDistance (60-150 m)
        from the IED, with a clear line of sight to it (nothing of the terrain or an object in between: trees and houses block it), on dry land, not on a
        road and not under a roof. Tries COIN_triggermanSpotTries points, part of them beside a house
        (COIN_triggermanHouseShare), and takes the best one: beside a house (within COIN_triggermanHouseRadius of its
        wall, the house taken as a circle) is worth 2,
        higher than the IED by COIN_triggermanHeightGain m worth 1. A house stops the search at once.
        Server only.

    Parameter(s):
        _iedPos - Position of the IED [ARRAY]
        _ignore - The IED object, the line of sight does not stop at it [OBJECT, defaults to objNull]

    Returns:
        [position ATL or [] if none was found, rejected points per rule (HASHMAP rule -> number), score (0-3)] [ARRAY]
*/

params [
    ["_iedPos", [], [[]]],
    ["_ignore", objNull, [objNull]]
];

if (!isServer) exitWith {[[], createHashMap, 0]};

COIN_triggermanDistance params ["_minDist", "_maxDist"];

// Houses a man can stand beside, with their half size (those with building positions: no walls, no sheds without a floor)
private _houses = ((nearestObjects [_iedPos, ["House"], _maxDist + COIN_triggermanHouseRadius]) select {
    (count (_x buildingPos -1)) > 0
}) apply {[_x, (sizeOf typeOf _x) / 2]};
private _target = ATLToASL [_iedPos select 0, _iedPos select 1, COIN_triggermanTargetHeight];
private _iedHeight = getTerrainHeightASL _iedPos;

private _best = [];
private _bestScore = -1;
private _rejected = createHashMap;

for "_i" from 1 to COIN_triggermanSpotTries do {
    private _candidate = if (_houses isNotEqualTo [] && {random 1 < COIN_triggermanHouseShare}) then {
        (selectRandom _houses) params ["_house", "_halfSize"];
        _house getPos [_halfSize + COIN_triggermanHouseOffset, random 360]
    } else {
        _iedPos getPos [_minDist + random (_maxDist - _minDist), random 360]
    };
    _candidate = [_candidate select 0, _candidate select 1, 0];

    private _rule = switch (true) do {
        case ((_candidate distance2D _iedPos) < _minDist || {(_candidate distance2D _iedPos) > _maxDist}): {"distance"};
        case (surfaceIsWater _candidate): {"water"};
        case ((_candidate nearRoads COIN_triggermanRoadClearance) isNotEqualTo []): {"road"};
        case (lineIntersects [ATLToASL [_candidate select 0, _candidate select 1, COIN_triggermanGroundClearance], ATLToASL [_candidate select 0, _candidate select 1, COIN_triggermanHeadroom]]): {"covered"};
        case ((lineIntersectsSurfaces [ATLToASL [_candidate select 0, _candidate select 1, COIN_triggermanEyeHeight], _target, _ignore, objNull, true, 1, "VIEW", "FIRE"]) isNotEqualTo []): {"noSight"};
        default {""};
    };

    if (_rule isNotEqualTo "") then {
        _rejected set [_rule, (_rejected getOrDefault [_rule, 0]) + 1];
        continue;
    };

    private _nearHouse = (_houses findIf {(_candidate distance2D (_x select 0)) <= (_x select 1) + COIN_triggermanHouseRadius}) >= 0;
    private _higher = ((getTerrainHeightASL _candidate) - _iedHeight) >= COIN_triggermanHeightGain;
    private _score = (2 * ([0, 1] select _nearHouse)) + ([0, 1] select _higher);
    if (_score > _bestScore) then {
        _best = _candidate;
        _bestScore = _score;
    };
    if (_nearHouse) exitWith {};
};

[_best, _rejected, _bestScore max 0]
