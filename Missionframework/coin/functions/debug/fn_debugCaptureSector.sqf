/*
    File: fn_debugCaptureSector.sqf
    Author: COIN Liberation

    Description:
        Debug function for the console (ticket 6.1a, #154, formerly 6.8): captures a sector for the army through
        Liberation's own flow (sector_liberated_remote_call: readiness gain, blufor_sectors, production, reputation gain,
        victory check, save, and 45 s later possibly a counterattack), so the tests of phase 6 need no fight.
        Without a sector it only lists the sectors the militia still holds, by type with their marker names.
        Refused for an active sector (a player is near, Liberation's sector script runs for it): move away first. The capital is refused unless
        _allowCapital is true: taking it ends the campaign, and Liberation then deletes the save.
        On a dedicated server run it with the server exec of the debug console. Server only.

    Parameter(s):
        _sector       - Sector marker name, e.g. "military_2"; "" lists the sectors [STRING, defaults to ""]
        _allowCapital - Allow the capital (ends the campaign) [BOOL, defaults to false]

    Returns:
        Capture was started [BOOL]
*/

params [
    ["_sector", "", [""]],
    ["_allowCapital", false, [false]]
];

if (!isServer) exitWith {false};

private _armySectors = missionNamespace getVariable ["blufor_sectors", []];

if (_sector isEqualTo "") exitWith {
    {
        diag_log format [
            "[COIN] debug: sectors the militia holds, %1: %2", _x,
            (((missionNamespace getVariable [_x, []]) - _armySectors) apply {format ["%1 (%2)", _x, markerText _x]}) joinString ", "
        ];
    } forEach ["sectors_military", "sectors_factory", "sectors_capture", "sectors_bigtown"];
    false
};

if !(_sector in (missionNamespace getVariable ["sectors_allSectors", []])) exitWith {
    diag_log format ["[COIN] debug: capture refused, %1 is no sector (call it without a sector to list them)", _sector];
    false
};

if (_sector in _armySectors) exitWith {
    diag_log format ["[COIN] debug: capture refused, %1 (%2) is already the army's", _sector, markerText _sector];
    false
};

// Liberation's own sector script is still running for an active sector and would not know about the capture
if (_sector in (missionNamespace getVariable ["active_sectors", []])) exitWith {
    diag_log format ["[COIN] debug: capture refused, %1 (%2) is active (a player is near), move away until it is not", _sector, markerText _sector];
    false
};

if (_sector in (missionNamespace getVariable ["sectors_bigtown", []]) && {!_allowCapital}) exitWith {
    diag_log format ["[COIN] debug: capture refused, %1 (%2) is the capital, taking it ends the campaign (second parameter true allows it)", _sector, markerText _sector];
    false
};

diag_log format ["[COIN] debug: capturing %1 (%2) through Liberation's flow", _sector, markerText _sector];
[_sector] spawn sector_liberated_remote_call;

true
