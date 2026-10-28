/*
    File: fn_initFavors.sqf
    Author: COIN Liberation

    Description:
        Server: the stock of favors (ticket 5.4, DESIGN 8.1, ADR 0023). Waits until Liberation's save is loaded, takes the stock and the
        counter from the COIN block of the save (entry 3: [stock, counter in minutes], save version 3; a block of version 1 or 2 has
        none and is converted: stock 0, counter 0; a new campaign starts with 0 and 0), sets COIN_favorStock and COIN_favorCounter, and
        starts the loop COIN_fnc_favorLoop (switch COIN_enableFavors; without it the numbers are kept and saved as they are). Writes the
        numbers to the RPT. Server only.

    Parameter(s):
        NONE

    Returns:
        Number of favors in stock [NUMBER]
*/

if (!isServer) exitWith {0};

private _timeout = diag_tickTime + COIN_initTimeout;
waitUntil {
    sleep 1;
    (missionNamespace getVariable ["save_is_loaded", false]) || {diag_tickTime > _timeout}
};
if !(missionNamespace getVariable ["save_is_loaded", false]) exitWith {
    diag_log format ["[COIN] favors: ERROR - Liberation's save not loaded after %1 s, no favors", COIN_initTimeout];
    0
};

private _block = missionNamespace getVariable ["COIN_loadedSaveBlock", []];
private _stock = 0;
private _counter = 0;

if (_block isNotEqualTo []) then {
    private _version = _block param [0, 0];
    if !(_version in COIN_loadableSaveVersions) then {
        // Unknown format: the block is kept as it is (COIN_fnc_getSaveBlock), the favors stay empty and are not written
        diag_log format ["[COIN] favors: save version %1 is not known, no favors loaded (the block is kept unchanged)", _version];
    } else {
        private _saved = _block param [3, []];
        if (_saved isEqualTypeParams [0, 0]) then {
            _stock = ((_saved select 0) max 0) min COIN_favorMaxStored;
            _counter = _saved select 1;
            diag_log format ["[COIN] favors: %1 favor(s) and counter %2 min loaded from the save (save version %3)", _stock, _counter toFixed 1, _version];
        } else {
            diag_log format ["[COIN] favors: save version %1 has no favors, converted to version %2 (stock 0, counter 0)", _version, COIN_saveVersion];
        };
    };
} else {
    diag_log "[COIN] favors: no COIN block in the save (new campaign), stock 0, counter 0";
};

COIN_favorStock = _stock;
COIN_favorCounter = _counter;
[false] call COIN_fnc_publishFavors;

if (COIN_enableFavors) then {
    [] spawn COIN_fnc_favorLoop;
} else {
    diag_log "[COIN] favors: favors off, the stock stays as it is";
};

_stock
