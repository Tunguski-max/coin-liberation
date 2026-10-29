/*
    File: fn_makeSearchable.sqf
    Author: COIN Liberation

    Description:
        Server: makes a vehicle of a strike task searchable for documents (tickets 5.14 and 5.16): it gets the public variables the search
        looks at (COIN_searchable, COIN_searchOpen; the event that made the vehicle opens it while it stands) and the action
        "Search documents" on all machines (COIN_fnc_addSearchAction) with the vehicle as JIP key. The search itself is
        COIN_fnc_searchDocuments.

    Parameter(s):
        _vehicle - The car or truck [OBJECT, defaults to objNull]
        _label   - Key of the text of the action; empty = COIN_searchLabel [STRING, defaults to ""]
        _barText - Key of the text of the progress bar; empty = COIN_searchBarText [STRING, defaults to ""]

    Returns:
        Nothing
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_label", "", [""]],
    ["_barText", "", [""]]
];

if (!isServer || {isNull _vehicle}) exitWith {};

_vehicle setVariable ["COIN_searchable", true, true];
_vehicle setVariable ["COIN_searchOpen", false, true];
[_vehicle, _label, _barText] remoteExec ["COIN_fnc_addSearchAction", 0, _vehicle];
