/*
    File: fn_planCamp.sqf
    Author: COIN Liberation

    Description:
        What a camp looks like when it spawns (ticket 2.9, DESIGN 5.1), decided from the camp's seed so it is the same
        on every visit: the camp template and its direction, the number of fighters (COIN_campGuardsMin to Max) and
        whether a technical stands in it (chance COIN_campTechnicalChance, class from the militia vehicles, never one
        that was taken or destroyed before). The loop asks the budget with the number of fighters before it spawns.
        Server only.

    Parameter(s):
        _camp - Camp [ARRAY: id, nest id, position, discovered, seed, technical gone]

    Returns:
        [guards, camp template index, direction, technical class ("" if none), fighters in all], [] if there is no
        usable camp template [ARRAY]
*/

params [
    ["_camp", [], [[]]]
];

_camp params ["_id", "", "", "", "_seed", "_technicalGone"];

// Value streams of the seed (COIN_fnc_seededRandom index), the same as terrain nests use where they mean the same
private _streamGuards = 5000;
private _streamTechnical = 5200;
private _streamTechnicalClass = 5300;
private _streamTemplate = 7000;
private _streamDir = 7100;

private _templates = COIN_validTerrainTemplates select {(_x select 0) isEqualTo "camp"};
if (_templates isEqualTo []) exitWith {
    diag_log format ["[COIN] camps: ERROR - no usable camp template, camp %1 not spawned", _id];
    []
};

private _templateIndex = floor ([_seed, _streamTemplate, count _templates] call COIN_fnc_seededRandom);
private _dir = round ([_seed, _streamDir, 360] call COIN_fnc_seededRandom);
private _guards = COIN_campGuardsMin + floor ([_seed, _streamGuards, COIN_campGuardsMax - COIN_campGuardsMin + 1] call COIN_fnc_seededRandom);

private _technicalClass = "";
if (
    !_technicalGone
    && {COIN_enableCampTechnical}
    && {!(militia_vehicles isEqualTo [])}
    && {([_seed, _streamTechnical, 1] call COIN_fnc_seededRandom) < COIN_campTechnicalChance}
) then {
    _technicalClass = militia_vehicles select (floor ([_seed, _streamTechnicalClass, count militia_vehicles] call COIN_fnc_seededRandom));
};

[_guards, _templateIndex, _dir, _technicalClass, _guards + ([0, COIN_campTechnicalCrew] select (_technicalClass != ""))]
