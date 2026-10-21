/*
    File: fn_removeCamp.sqf
    Author: COIN Liberation

    Description:
        Removes the content of a camp that nobody is near any more (ticket 2.9, DESIGN 5.1): objects, guards and the
        technical are deleted. The technical is the exception when a player took it, so a vehicle someone is driving
        is never deleted under them: it stays if a player or a unit that is no longer enemy sits in it, or if it
        stands empty farther than COIN_campTechnicalLeash from the camp. A technical that was taken or destroyed is
        not there when the camp spawns again (camp entry "technical gone"). Server only.

    Parameter(s):
        _camp   - Camp [ARRAY: id, nest id, position, discovered, seed, technical gone]
        _entry  - What the spawn loop kept: [spawned objects and units, last time a player was near, technical] [ARRAY]
        _reason - Why, for the log [STRING]

    Returns:
        NONE
*/

params [
    ["_camp", [], [[]]],
    ["_entry", [], [[]]],
    ["_reason", "", [""]]
];

_camp params ["_id", "", "_pos"];
_entry params ["_objects", "", "_technical"];

private _technicalState = "none";
if (!isNull _technical) then {
    if (!alive _technical) then {
        _technicalState = "destroyed";
    } else {
        private _crew = crew _technical;
        private _taken = (_crew findIf {isPlayer _x || {!((side group _x) isEqualTo GRLIB_side_enemy)}}) >= 0;
        private _left = _crew isEqualTo [] && {(_technical distance2D _pos) > COIN_campTechnicalLeash};
        if (_taken || _left) then {
            // Kept for the players: no longer part of the camp
            _technicalState = "taken";
            _objects = _objects - [_technical] - _crew;
        } else {
            _technicalState = "removed";
        };
    };
    // Taken or destroyed, it does not come back with the camp
    if (_technicalState in ["taken", "destroyed"]) then {
        _camp set [5, true];
    };
};

private _guards = _objects select {_x isKindOf "CAManBase" && {isNull objectParent _x}};
private _alive = {alive _x} count _guards;
{
    deleteVehicle _x;
} forEach _objects;
// Groups are created with deleteWhenEmpty, they go with their last unit
diag_log format ["[COIN] camps: camp %1 removed (%2), %3 of %4 guards were alive, technical %5", _id, _reason, _alive, count _guards, _technicalState];
