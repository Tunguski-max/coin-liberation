/*
    File: fn_removeIED.sqf
    Author: COIN Liberation

    Description:
        Takes an IED out of COIN_ieds and deletes its engine trigger (ticket 4.1a). Called when the IED object is gone
        (Deleted event handler of the object: defused with ACE, deleted in Zeus, cleaned up after the blast) and by
        COIN_fnc_iedWatch when it finds the object destroyed. The object itself is not touched. One log line, the debug
        map is drawn again. An id that is not in the list (already removed) does nothing. Server only.

    Parameter(s):
        _id - IED id [NUMBER]

    Returns:
        The IED was removed by this call [BOOL]
*/

params [
    ["_id", -1, [0]]
];

if (!isServer || {isNil "COIN_ieds"}) exitWith {false};

private _index = COIN_ieds findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {false};

(COIN_ieds deleteAt _index) params ["", "_nestId", "", "_pos", "", "_trigger"];
deleteVehicle _trigger;

diag_log format ["[COIN] ieds: IED %1 (nest %2) at %3 is gone, %4 IEDs left", _id, _nestId, _pos, count COIN_ieds];

if (COIN_debug) then {
    [] call COIN_fnc_drawIEDMarkers;
};

true
