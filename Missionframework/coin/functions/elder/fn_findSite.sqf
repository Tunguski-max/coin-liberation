/*
    File: fn_findSite.sqf
    Author: COIN Liberation

    Description:
        The site of an aid task of a liberated town (ticket 5.20, ADR 0024, CONTEXT.md: site): the nearest village outside Liberation's
        sectors that COIN_fnc_rateSites accepts. Server only.

    Parameter(s):
        _sector   - Sector marker of the town of the elder [STRING, defaults to ""]
        _occupied - Names of the villages that are the site of another aid task now [ARRAY of STRING, defaults to []]

    Returns:
        [name, village centre, distance from the town in m], [] if there is no village [ARRAY]
*/

params [
    ["_sector", "", [""]],
    ["_occupied", [], [[]]]
];

if (!isServer || {!COIN_enableAidSites}) exitWith {[]};

private _rated = [_sector, _occupied] call COIN_fnc_rateSites;
private _index = _rated findIf {(_x select 3) isEqualTo ""};

if (_index < 0) exitWith {[]};

(_rated select _index) params ["_name", "_centre", "_distance"];
[_name, _centre, _distance]
