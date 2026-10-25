/*
    File: fn_findElderSpot.sqf
    Author: COIN Liberation

    Description:
        Finds the place where the elder of a liberated town stands (ticket 5.9a, DESIGN 8): at a building near the centre
        of the town, a mosque (class name contains one of COIN_elderBuildingKeywords) if there is one within
        COIN_elderSearchRadius, else the house with the largest ground area. Buildings smaller than
        COIN_elderMinBuildingArea or lower than COIN_elderMinBuildingHeight (walls, sheds) do not count. He stands outside,
        COIN_elderSpotDistance m from the building, and looks away from it. Without a building he stands at the centre.
        The caller keeps the result, so the elder is always at the same place. Server only.

    Parameter(s):
        _sector - Sector marker of the town [STRING, defaults to ""]

    Returns:
        [position, direction, building class name] [ARRAY]
*/

params [
    ["_sector", "", [""]]
];

private _center = markerPos _sector;
if (!isServer || {_sector isEqualTo ""}) exitWith {[_center, 0, ""]};

private _best = objNull;
private _bestScore = -1;
private _bestReach = 0;
{
    private _building = _x;
    (boundingBoxReal _building) params ["_min", "_max"];
    private _width = (_max select 0) - (_min select 0);
    private _length = (_max select 1) - (_min select 1);
    private _height = (_max select 2) - (_min select 2);
    if ((_width * _length) < COIN_elderMinBuildingArea || {_height < COIN_elderMinBuildingHeight} || {damage _building >= 1}) then {continue};

    // A mosque beats every house, the keyword adds more than any ground area can
    private _type = toLower typeOf _building;
    private _isMosque = (COIN_elderBuildingKeywords findIf {(_type find _x) >= 0}) >= 0;
    private _score = (_width * _length) + ([0, 1000000] select _isMosque);
    if (_score > _bestScore) then {
        _best = _building;
        _bestScore = _score;
        _bestReach = (_width max _length) / 2;
    };
} forEach (nearestObjects [_center, ["House"], COIN_elderSearchRadius]);

if (isNull _best) exitWith {
    diag_log format ["[COIN] population: no building near %1 (%2) for the elder, he stands at the centre", markerText _sector, _sector];
    [_center, 0, ""]
};

// From the middle of the building, beyond half of its longer side, so outside of it
private _buildingPos = _best modelToWorld (boundingCenter _best);
COIN_elderSpotDistance params ["_near", "_far"];
private _pos = [_buildingPos, _bestReach + _near, _bestReach + _far, COIN_populationSpotClearance, 0, COIN_populationMaxGradient, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
if (_pos isEqualTo _center) then {
    diag_log format ["[COIN] population: no free spot at %1 for the elder of %2 (%3), he stands at the centre", typeOf _best, markerText _sector, _sector];
};

[_pos, _buildingPos getDir _pos, typeOf _best]
