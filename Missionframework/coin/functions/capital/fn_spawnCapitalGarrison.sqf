/*
    File: fn_spawnCapitalGarrison.sqf
    Author: COIN Liberation

    Description:
        Additional garrison of the capital by the militia network (ticket 6.3a, #160, DESIGN 9, ADR 0014, ADR 0015, hook 35).
        Liberation's own garrison is the minimum with no nest left, COIN adds
            round (Liberation's infantry squads of the capital x COIN_capitalGarrisonFactor x active nests)
        squads, e.g. 3 squads and 11 nests give 5, 5 nests give 2, no nest none. They are composed as Liberation's squads
        of the capital at the same readiness (KPLIB_fnc_getSquadComp with the same squad type, so the armored mix of
        hook 9 applies) and spawn and patrol like them (KPLIB_fnc_spawnRegularSquad, add_defense_waypoints). The units are
        returned for Liberation's list of managed units, so they go when the sector is taken down. They are COIN units
        for the AI budget, but always spawn (ADR 0015), and go to Zeus. One [COIN] line says how many. Switch
        COIN_enableCapitalGarrison. Called by manage_one_sector.sqf, where it runs on the server (without a server, e.g.
        on a headless client, there is no garrison and one line says so).

    Parameter(s):
        _sector      - Marker of the capital [STRING]
        _squadType   - Squad type Liberation chose for this sector, "army" or "militia" [STRING]
        _squadCount  - Number of infantry squads Liberation spawns in the capital [NUMBER]

    Returns:
        The additional units [ARRAY of OBJECTs]
*/

params [
    ["_sector", "", [""]],
    ["_squadType", "army", [""]],
    ["_squadCount", 0, [0]]
];

if (!COIN_enableCapitalGarrison) exitWith {[]};

if (!isServer || {isNil "COIN_nests"}) exitWith {
    diag_log format ["[COIN] capital: %1: no additional garrison, this machine is no server or has no nests", _sector];
    []
};

private _active = {(_x select 5) isEqualTo "active"} count COIN_nests;
private _extra = round (_squadCount * COIN_capitalGarrisonFactor * _active);
diag_log format [
    "[COIN] capital: %1 (%2): Liberation spawns %3 squads, %4 nests are active, %5 additional squads (factor %6, squad type %7)",
    _sector, markerText _sector, _squadCount, _active, _extra, COIN_capitalGarrisonFactor, _squadType
];
if (_extra <= 0) exitWith {[]};

private _units = [];
private _centre = markerPos _sector;
for "_i" from 1 to _extra do {
    private _group = [_sector, [_squadType] call KPLIB_fnc_getSquadComp] call KPLIB_fnc_spawnRegularSquad;
    if (isNull _group) then {
        diag_log format ["[COIN] capital: %1: additional squad %2 of %3 found no spawn position", _sector, _i, _extra];
        continue;
    };
    [_group, _centre] spawn add_defense_waypoints;
    _units append (units _group);
};

[_units] call COIN_fnc_markCoinUnits;
[_units] call COIN_fnc_addToCurators;
diag_log format ["[COIN] capital: %1: %2 additional units in %3 squads spawned", _sector, count _units, _extra];

_units
