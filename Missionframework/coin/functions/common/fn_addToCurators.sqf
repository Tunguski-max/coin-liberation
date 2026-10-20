/*
    File: fn_addToCurators.sqf
    Author: COIN Liberation

    Description:
        Makes objects and units the COIN layer creates editable for every curator, so Zeus can see and delete them
        (CLAUDE.md, every COIN spawn goes through here). The objects are also kept in COIN_curatorObjects:
        COIN_fnc_curatorSync adds them to curators created later (Liberation creates one per player on request).
        Liberation's zeus_synchro.sqf removes dead and attached objects from all curators, so COIN content must
        not be attached with attachTo if Zeus should keep it (docs/kp-liberation-map.md section 6).
        Server only.

    Parameter(s):
        _objects - Objects and units [ARRAY of OBJECTs]

    Returns:
        Number of objects added [NUMBER]
*/

params [
    ["_objects", [], [[]]]
];

if (!isServer) exitWith {0};

_objects = _objects select {!isNull _x};
if (isNil "COIN_curatorObjects") then {
    COIN_curatorObjects = [];
};
COIN_curatorObjects append _objects;

{
    _x addCuratorEditableObjects [_objects, true];
} forEach allCurators;

count _objects
