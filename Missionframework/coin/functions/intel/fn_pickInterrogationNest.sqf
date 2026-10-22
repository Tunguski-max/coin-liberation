/*
    File: fn_pickInterrogationNest.sqf
    Author: COIN Liberation

    Description:
        Which nest does a prisoner name? (ticket 3.8, DESIGN 7, ADR 0011) A fighter of a camp names the nest of his
        camp (the trail from camp to nest of phase 2), a guard of a nest names another active nest, all others follow
        the rule for a civilian (COIN_fnc_pickIntelNest). The origin is the variable COIN_origin that
        COIN_fnc_spawnNestGuards sets, [kind "camp" or "nest", nest id, camp id]. If the nest of his camp is no longer
        active, he is treated like any other. Server only.

    Parameter(s):
        _prisoner - Prisoner [OBJECT, defaults to objNull]

    Returns:
        Nest [id, type, kind, pos, seed, state], [] if no nest is active (for a guard: no other one) [ARRAY]
*/

params [
    ["_prisoner", objNull, [objNull]]
];

if (!isServer || {isNil "COIN_nests"}) exitWith {[]};

private _pos = getPosATL _prisoner;
private _origin = _prisoner getVariable ["COIN_origin", []];
if (_origin isEqualTo []) exitWith {[_pos] call COIN_fnc_pickIntelNest};

_origin params ["_kind", "_nestId"];
if (_kind isEqualTo "nest") exitWith {[_pos, _nestId] call COIN_fnc_pickIntelNest};

private _own = COIN_nests findIf {(_x select 0) isEqualTo _nestId && {(_x select 5) isEqualTo "active"}};
if (_own >= 0) exitWith {COIN_nests select _own};

[_pos] call COIN_fnc_pickIntelNest
