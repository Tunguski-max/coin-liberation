/*
    File: fn_rateSites.sqf
    Author: COIN Liberation

    Description:
        Every map village within COIN_siteMaxDistance of a liberated town, nearest first, each with the reason it cannot be the site
        of an aid task (ticket 5.20, ADR 0024). A village is a map location of COIN_siteTypes. The first that applies:
        - it is in COIN_siteExcludedLocations (a camp, FOB or factory the house filter does not catch),
        - fewer than COIN_siteMinHouses houses (map objects of COIN_siteHouseTypes) stand within COIN_siteHouseRadius (a camp, a lone farm),
        - the village centre is less than COIN_siteMinSectorDistance from a town or less than COIN_siteMinOtherSectorDistance from a
          factory, military post or tower,
        - it is less than COIN_siteMinEnemySectorDistance from a sector the army has not liberated (checked at every call),
        - it is the site of another aid task already.
        The village centre is the middle of the houses around the map label, which often sits at the edge. What does not depend on the
        town (name, houses, centre, distance to the sectors) is worked out on the first call and kept. Server only.

    Parameter(s):
        _sector   - Sector marker of the town [STRING, defaults to ""]
        _occupied - Names of the villages that are the site of another aid task now [ARRAY of STRING, defaults to []]

    Returns:
        [name, village centre, distance from the town in m (whole), reason, houses]; the reason is "" if the village can be used [ARRAY]
*/

params [
    ["_sector", "", [""]],
    ["_occupied", [], [[]]]
];

if (!isServer || {_sector isEqualTo ""} || {isNil "sectors_allSectors"}) exitWith {[]};

// [distance in m, marker] of the sector nearest to a position
private _nearestSector = {
    params ["_pos", "_sectors"];
    if (_sectors isEqualTo []) exitWith {[1e9, ""]};
    private _byDistance = _sectors apply {[_pos distance2D (markerPos _x), _x]};
    _byDistance sort true;
    _byDistance select 0
};

// Village -> [name, centre, houses, reason it is no site whatever the town]
if (isNil "COIN_siteList") then {
    private _excluded = COIN_siteExcludedLocations apply {toLower _x};
    private _townSectors = sectors_allSectors arrayIntersect (sectors_capture + sectors_bigtown);
    private _otherSectors = sectors_allSectors - _townSectors;
    private _all = nearestLocations [[worldSize / 2, worldSize / 2, 0], COIN_siteTypes, worldSize];

    COIN_siteList = _all apply {
        private _name = text _x;
        // 2D: a position with a height (the label has one) makes the search a sphere, and houses in high country were missed
        private _labelPos = (locationPosition _x) select [0, 2];
        private _houses = (nearestTerrainObjects [_labelPos, COIN_siteHouseTypes, COIN_siteHouseRadius, false, true]) select {alive _x};
        private _centre = if (_houses isEqualTo []) then {_labelPos + [0]} else {
            private _sum = [0, 0];
            {_sum = [(_sum select 0) + ((getPos _x) select 0), (_sum select 1) + ((getPos _x) select 1)]} forEach _houses;
            [(_sum select 0) / count _houses, (_sum select 1) / count _houses, 0]
        };
        _centre = _centre apply {round _x};

        // A town (sectors_capture, sectors_bigtown) keeps COIN_siteMinSectorDistance, a factory, military post or tower COIN_siteMinOtherSectorDistance
        private _nearTown = [_centre, _townSectors] call _nearestSector;
        private _nearOther = [_centre, _otherSectors] call _nearestSector;
        private _marginTown = (_nearTown select 0) - COIN_siteMinSectorDistance;
        private _marginOther = (_nearOther select 0) - COIN_siteMinOtherSectorDistance;
        private _nearest = [_nearTown, _nearOther] select (_marginOther < _marginTown);
        private _tooNear = _marginTown < 0 || {_marginOther < 0};
        private _reason = if (_name isEqualTo "") then {
            "no name"
        } else { if (toLower _name in _excluded) then {
            "on the exclusion list"
        } else {
            if (count _houses < COIN_siteMinHouses) then {
                format ["only %1 houses", count _houses]
            } else {
                if (_tooNear) then {
                    format ["%1 m from sector %2", round (_nearest select 0), markerText (_nearest select 1)]
                } else {""}
            }
        }};
        [_name, _centre, count _houses, _reason]
    };
};

private _origin = markerPos _sector;
// The town itself is not an enemy sector: a town that is not liberated yet is rated as if it were (the check list of the RPT)
private _enemy = sectors_allSectors - (missionNamespace getVariable ["blufor_sectors", []]) - [_sector];
private _occupiedLower = _occupied apply {toLower _x};

private _rated = [];
{
    _x params ["_name", "_centre", "_houses", "_reason"];
    private _distance = _origin distance2D _centre;

    if (_distance <= COIN_siteMaxDistance) then {
        if (_reason isEqualTo "" && {_enemy isNotEqualTo []}) then {
            private _nearEnemy = [_centre, _enemy] call _nearestSector;
            if ((_nearEnemy select 0) < COIN_siteMinEnemySectorDistance) then {
                _reason = format ["%1 m from enemy sector %2", round (_nearEnemy select 0), markerText (_nearEnemy select 1)];
            };
        };
        if (_reason isEqualTo "" && {toLower _name in _occupiedLower}) then {
            _reason = "site of another aid task";
        };
        _rated pushBack [_name, _centre, round _distance, _reason, _houses];
    };
} forEach COIN_siteList;

[_rated, [], {_x select 2}, "ASCEND"] call BIS_fnc_sortBy
