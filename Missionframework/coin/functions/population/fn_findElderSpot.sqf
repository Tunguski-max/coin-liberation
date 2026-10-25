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
{
    private _box = boundingBoxReal _x;
    _box params ["_min", "_max"];
    private _area = ((_max select 0) - (_min select 0)) * ((_max select 1) - (_min select 1));
    private _height = (_max select 2) - (_min select 2);
    if (_area < COIN_elderMinBuildingArea || {_height < COIN_elderMinBuildingHeight} || {damage _x >= 1}) then {continue};

    // A mosque beats every house, the keyword adds more than any ground area can
    private _type = toLower typeOf _x;
    private _isMosque = (COIN_elderBuildingKeywords findIf {(_type find _x) >= 0}) >= 0;
    private _score = _area + ([0, 1000000] select _isMosque);
    if (_score > _bestScore) then {
        _best = _x;
        _bestScore = _score;
    };
} forEach (nearestObjects [_center, ["House"], COIN_elderSearchRadius]);

if (isNull _best) exitWith {
    diag_log format ["[COIN] population: no building near %1 (%2) for the elder, he stands at the centre", markerText _sector, _sector];
    [_center, 0, ""]
};

private _buildingPos = getPosATL _best;
private _reach = (boundingBoxReal _best) select 2;
COIN_elderSpotDistance params ["_near", "_far"];
private _pos = [_buildingPos, _reach + _near, _reach + _far, COIN_populationSpotClearance, 0, COIN_populationMaxGradient, 0, [], [_center, _center]] call BIS_fnc_findSafePos;

[_pos, _buildingPos getDir _pos, typeOf _best]
