/*
    File: fn_curatorSync.sqf
    Author: COIN Liberation

    Description:
        Server loop: objects handed to Zeus with COIN_fnc_addToCurators are added again to every curator that does not
        have them yet, e.g. a curator Liberation creates when the commander joins later or asks for Zeus again.
        Deleted objects are dropped from COIN_curatorObjects, dead ones are skipped (Liberation removes them anyway).
        Runs every COIN_curatorSyncInterval seconds, a value of 0 or less stops it. Must be spawned.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

while {COIN_curatorSyncInterval > 0} do {
    sleep COIN_curatorSyncInterval;

    if !(isNil "COIN_curatorObjects") then {
        COIN_curatorObjects = COIN_curatorObjects select {!isNull _x};
        private _alive = COIN_curatorObjects select {alive _x};
        if !(_alive isEqualTo []) then {
            {
                private _missing = _alive - (curatorEditableObjects _x);
                if !(_missing isEqualTo []) then {
                    _x addCuratorEditableObjects [_missing, true];
                };
            } forEach allCurators;
        };
    };
};

true
