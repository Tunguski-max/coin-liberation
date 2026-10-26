/*
    File: fn_removeWhenUnseen.sqf
    Author: COIN Liberation

    Description:
        Server: removes the things an aid task (tickets 5.11 and 5.12) or a strike task (ticket 5.14, the courier car) has made
        without anybody seeing them vanish (the distances and the time are those of the aid tasks): each
        one is deleted as soon as no player within COIN_aidSightDistance has a line of sight to it, at the latest after
        COIN_aidRemoveSeconds. Checked every COIN_aidCheckSeconds. Must be spawned.

    Parameter(s):
        _objects - What is to go (patients, devices) [ARRAY of OBJECTs, defaults to []]
        _what    - What they are, for the log line [STRING, defaults to "objects"]

    Returns:
        NONE
*/

params [
    ["_objects", [], [[]]],
    ["_what", "objects", [""]]
];

if (!isServer) exitWith {};

// Seen: a player who stands near and has a line of sight
private _seen = {
    params ["_object"];
    (allPlayers - entities "HeadlessClient_F") findIf {
        alive _x
        && {(_x distance _object) <= COIN_aidSightDistance}
        && {(lineIntersectsSurfaces [eyePos _x, getPosASL _object vectorAdd [0, 0, COIN_aidSightHeight], _x, _object, true, 1, "VIEW", "FIRE"]) isEqualTo []}
    } >= 0
};

private _end = time + COIN_aidRemoveSeconds;
private _left = _objects select {!isNull _x};
while {_left isNotEqualTo [] && {time < _end}} do {
    sleep COIN_aidCheckSeconds;
    {
        if (!isNull _x && {!([_x] call _seen)}) then {
            deleteVehicle _x;
        };
    } forEach _left;
    _left = _left select {!isNull _x};
};
{deleteVehicle _x} forEach _left;

diag_log format ["[COIN] aid: %1 %2 removed", count _objects, _what];
