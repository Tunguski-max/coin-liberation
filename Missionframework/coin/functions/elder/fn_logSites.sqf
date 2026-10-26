/*
    File: fn_logSites.sqf
    Author: COIN Liberation

    Description:
        Check list for the site of an aid task (ticket 5.20, ADR 0024): writes to the RPT every village the site can come from with its
        houses and the reason it is rejected, then for every town (sectors_capture, also those not liberated) the village
        COIN_fnc_findSite would choose now, or why there is none. Server only, no effect on the game.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer || {!COIN_enableAidSites}) exitWith {false};

if (isNil "sectors_capture" || {isNil "sectors_allSectors"}) exitWith {
    diag_log "[COIN] site: ERROR - Liberation's sector lists are missing, no sites";
    false
};

// Fills COIN_siteList (kept for the session); the rules about the sectors the army has not liberated are checked per town below
[sectors_capture select 0] call COIN_fnc_rateSites;
diag_log format [
    "[COIN] site: %1 map locations of %2, %3 of %4 towns liberated",
    count COIN_siteList, COIN_siteTypes joinString "/", count (sectors_capture arrayIntersect (missionNamespace getVariable ["blufor_sectors", []])), count sectors_capture
];
{
    _x params ["_name", "_centre", "_houses", "_reason"];
    diag_log format ["[COIN] site: village %1 at %2, %3 houses -> %4", _name, _centre select [0, 2], _houses, ["passes the village checks", _reason] select (_reason isNotEqualTo "")];
} forEach COIN_siteList;

{
    private _sector = _x;
    private _site = [_sector] call COIN_fnc_findSite;

    if (_site isNotEqualTo []) then {
        _site params ["_name", "_centre", "_distance"];
        diag_log format ["[COIN] site: %1 (%2) -> %3 at %4, %5 m", markerText _sector, _sector, _name, _centre select [0, 2], _distance];
    } else {
        private _rated = [_sector] call COIN_fnc_rateSites;
        private _why = if (_rated isEqualTo []) then {
            format ["no village within %1 m", COIN_siteMaxDistance]
        } else {
            // The villages within reach grouped by what is wrong with them
            private _reasons = [];
            { _reasons pushBackUnique (_x select 3) } forEach _rated;
            format ["%1 villages within %2 m: %3", count _rated, COIN_siteMaxDistance, _reasons joinString "; "]
        };
        diag_log format ["[COIN] site: %1 (%2) -> none (%3)", markerText _sector, _sector, _why];
    };
} forEach sectors_capture;

true
