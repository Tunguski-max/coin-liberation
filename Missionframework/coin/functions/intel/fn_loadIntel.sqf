/*
    File: fn_loadIntel.sqf
    Author: COIN Liberation

    Description:
        Server: takes the intel from the COIN block of the save (ticket 3.2, ADR 0021) and sets COIN_intel and
        COIN_intelNextId. A block of save version 1 (phase 2) has no intel: the list is empty, the nests stay as they are,
        the next save writes version 2. An invalid record is left out with a log line. With COIN_enableQuestioning the
        circles are drawn again. A true intel disappears with its nest: the handler on COIN_nestDestroyed is set here
        (COIN_fnc_removeIntelOfNest). Called by COIN_fnc_initNests before COIN_nests is set, so a save in between still
        writes the loaded block back unchanged.

    Parameter(s):
        _block - COIN block of the save, [] for a new campaign [ARRAY, defaults to []]

    Returns:
        Number of intel loaded [NUMBER]
*/

params [
    ["_block", [], [[]]]
];

if (!isServer) exitWith {0};

private _intel = [];
private _nextId = 1;

if !(_block isEqualTo []) then {
    private _version = _block select 0;
    // Version 1 (phase 2) has nests only. A later version needs its own conversion here, not this branch
    if (_version isEqualTo 1) then {
        diag_log format ["[COIN] intel: save version %1 has no intel, converted to version %2 with an empty list", _version, COIN_saveVersion];
    } else {
        {
            if (_x isEqualTypeParams [0, 0, [], 0, "", "", []]) then {
                _intel pushBack _x;
                _nextId = _nextId max ((_x select 0) + 1);
            } else {
                diag_log format ["[COIN] intel: ERROR - invalid intel in the save left out: %1", _x];
            };
        } forEach (_block param [2, []]);
        diag_log format ["[COIN] intel: %1 intel loaded from the save", count _intel];
    };
};

COIN_intel = _intel;
COIN_intelNextId = _nextId;

if (COIN_enableQuestioning) then {
    {[_x] call COIN_fnc_drawIntelMarker;} forEach COIN_intel;
};

["COIN_nestDestroyed", {
    params ["_id"];
    [_id] call COIN_fnc_removeIntelOfNest;
}] call CBA_fnc_addEventHandler;

count COIN_intel
