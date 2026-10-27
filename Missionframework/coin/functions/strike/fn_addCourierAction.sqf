/*
    File: fn_addCourierAction.sqf
    Author: COIN Liberation

    Description:
        Client: gives the stopped car of the courier the action "Search documents" (ticket 5.14, DESIGN 8.2) in the yellow text of
        Liberation's own entries (fn_addActionsPlayer), German or else English
        by the game language. It shows when the car is alive and stopped (COIN_courierOpen, public) and the player is
        within COIN_courierSearchRange, and asks the server to search (COIN_fnc_searchDocuments), which checks again.
        With ACE the search runs on the progress bar for COIN_courierSearchSeconds (it ends if the player walks away, the car is
        destroyed or somebody else searched; Escape cancels it), without ACE it is done at once.
        The server sends it to all machines with the car as JIP key, so a late joiner gets it too.

    Parameter(s):
        _vehicle - The car [OBJECT, defaults to objNull]

    Returns:
        NONE
*/

params [
    ["_vehicle", objNull, [objNull]]
];

if (!hasInterface || {isNull _vehicle}) exitWith {};

private _index = [1, 0] select (language isEqualTo "German");

_vehicle addAction [
    ["<t color='#FFFF00'>", COIN_courierSearchLabel select _index, "</t>"] joinString "",
    {
        params ["_target", "_caller"];

        // With ACE the search takes COIN_courierSearchSeconds on a progress bar (like a repair), without it the search is at once
        if (isNil "ace_common_fnc_progressBar") exitWith {
            [_target, _caller] remoteExecCall ["COIN_fnc_searchDocuments", 2];
        };
        private _index = [1, 0] select (language isEqualTo "German");

        [
            COIN_courierSearchSeconds,
            [_target],
            {
                params ["_args"];
                _args params ["_target"];
                [_target, player] remoteExecCall ["COIN_fnc_searchDocuments", 2];
            },
            {},
            COIN_courierSearchBarText select _index,
            {
                params ["_args"];
                _args params ["_target"];
                alive _target
                && {_target getVariable ["COIN_courierOpen", false]}
                && {(player distance _target) <= (COIN_courierSearchRange + COIN_courierSearchRangeMargin)}
            }
        ] call ace_common_fnc_progressBar;
    },
    nil,
    6,
    true,
    true,
    "",
    "alive _target && {_target getVariable ['COIN_courierOpen', false]} && {(_this distance _target) <= COIN_courierSearchRange}",
    COIN_courierSearchRange
];
