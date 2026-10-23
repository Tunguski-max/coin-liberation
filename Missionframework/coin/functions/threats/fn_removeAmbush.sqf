/*
    File: fn_removeAmbush.sqf
    Author: COIN Liberation

    Description:
        Removes the content of an ambush that nobody is near any more (ticket 4.5, DESIGN 6): fighters and cover
        objects are deleted. The caller has taken the ambush out of COIN_spawnedAmbushes first, so
        COIN_fnc_ambushWatch ends without calling it cleared. Server only.

    Parameter(s):
        _campId  - Id of the camp the ambush belongs to [NUMBER]
        _objects - What COIN_fnc_spawnAmbush spawned [ARRAY of OBJECTs]
        _reason  - Why, for the log [STRING]

    Returns:
        NONE
*/

params [
    ["_campId", -1, [0]],
    ["_objects", [], [[]]],
    ["_reason", "", [""]]
];

if (!isServer) exitWith {};

private _fighters = _objects select {_x isKindOf "CAManBase"};
private _alive = {alive _x} count _fighters;
{
    deleteVehicle _x;
} forEach _objects;
// Groups are created with deleteWhenEmpty, they go with their last unit
diag_log format ["[COIN] ambushes: ambush of camp %1 removed (%2), %3 of %4 fighters were alive", _campId, _reason, _alive, count _fighters];
