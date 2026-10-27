/*
    File: fn_addSearchAction.sqf
    Author: COIN Liberation

    Description:
        Client: gives a stopped vehicle the action "Search documents" (the courier's car, ticket 5.14; a truck of the arms transport as "Search
        delivery documents", ticket 5.16; DESIGN 8.2) in the yellow text of
        Liberation's own entries (fn_addActionsPlayer), German or else English
        by the game language. It shows when the car is alive and stopped (COIN_searchOpen, public) and the player is
        within COIN_searchRange, and asks the server to search (COIN_fnc_searchDocuments), which checks again.
        With ACE the search runs on the progress bar for COIN_searchSeconds (it ends if the player walks away, the car is
        destroyed or somebody else searched; Escape cancels it), without ACE it is done at once.
        The server sends it to all machines with the car as JIP key, so a late joiner gets it too.

    Parameter(s):
        _vehicle - The car or truck [OBJECT, defaults to objNull]
        _label   - Text of the action, [German, English]; empty = COIN_searchLabel [ARRAY, defaults to []]
        _barText - Text of the progress bar, [German, English]; empty = COIN_searchBarText [ARRAY, defaults to []]

    Returns:
        NONE
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_label", [], [[]]],
    ["_barText", [], [[]]]
];

if (!hasInterface || {isNull _vehicle}) exitWith {};

private _index = [1, 0] select (language isEqualTo "German");
if (_label isEqualTo []) then {_label = COIN_searchLabel};
if (_barText isEqualTo []) then {_barText = COIN_searchBarText};

_vehicle addAction [
    ["<t color='#FFFF00'>", _label select _index, "</t>"] joinString "",
    {
        params ["_target", "_caller", "_actionId", "_actionArgs"];
        _actionArgs params ["_barText"];

        // With ACE the search takes COIN_searchSeconds on a progress bar (like a repair), without it the search is at once
        if (isNil "ace_common_fnc_progressBar") exitWith {
            [_target, _caller] remoteExecCall ["COIN_fnc_searchDocuments", 2];
        };
        private _index = [1, 0] select (language isEqualTo "German");

        [
            COIN_searchSeconds,
            [_target],
            {
                params ["_args"];
                _args params ["_target"];
                [_target, player] remoteExecCall ["COIN_fnc_searchDocuments", 2];
            },
            {},
            _barText select _index,
            {
                params ["_args"];
                _args params ["_target"];
                alive _target
                && {_target getVariable ["COIN_searchOpen", false]}
                && {(player distance _target) <= (COIN_searchRange + COIN_searchRangeMargin)}
            }
        ] call ace_common_fnc_progressBar;
    },
    [_barText],
    6,
    true,
    true,
    "",
    "alive _target && {_target getVariable ['COIN_searchOpen', false]} && {(_this distance _target) <= COIN_searchRange}",
    COIN_searchRange
];
