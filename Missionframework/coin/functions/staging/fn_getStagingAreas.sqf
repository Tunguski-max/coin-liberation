/*
    File: fn_getStagingAreas.sqf
    Author: COIN Liberation

    Description:
        All staging areas right now (ticket 6.1a, #154, ADR 0025, CONTEXT.md: Aufmarschraum): the places the militia
        launches counterattacks, relief and mortar attacks from.
        - The influence radius of every active command post (nest type "command", radius from COIN_nestSetup).
        - COIN_stagingRadiusMilitary around every military post the militia holds (Liberation sector in
          sectors_military that is not in blufor_sectors). A post the militia takes back is a staging area again.
        A destroyed nest or a captured post ends its staging area. Nothing is saved: the list follows from the saved
        nests and Liberation's sectors, it is calculated on every call (a handful of entries).
        Without COIN_enableStagingAreas the list is empty, so the callers of later tickets (6.1b, 6.1c, 6.7a) check the
        switch themselves to fall back to Liberation's behaviour. Server only.

    Parameter(s):
        NONE

    Returns:
        Staging areas [[center, radius, source], ...], source is ["nest", nest id] or ["sector", sector marker] [ARRAY]
*/

if (!isServer || {!COIN_enableStagingAreas}) exitWith {[]};

private _areas = [];

{
    _x params ["_id", "_type", "", "_pos", "", "_state"];
    if (_type isEqualTo "command" && {_state isEqualTo "active"}) then {
        _areas pushBack [_pos, [_type] call COIN_fnc_getNestRadius, ["nest", _id]];
    };
} forEach (missionNamespace getVariable ["COIN_nests", []]);

{
    _areas pushBack [markerPos _x, COIN_stagingRadiusMilitary, ["sector", _x]];
} forEach ((missionNamespace getVariable ["sectors_military", []]) - (missionNamespace getVariable ["blufor_sectors", []]));

_areas
