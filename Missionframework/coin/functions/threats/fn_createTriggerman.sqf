/*
    File: fn_createTriggerman.sqf
    Author: COIN Liberation

    Description:
        Puts the triggerman of a remote-triggered IED in place (ticket 4.2b, DESIGN 6): a fighter in civilian clothes
        (COIN_fnc_createCivilianFighter) at a place from COIN_fnc_findTriggermanSpot, facing the IED, with a mobile
        phone in his hand (COIN_triggermanPhone, attached; deleted with him by COIN_fnc_triggermanLoop) who walks around
        his spot (COIN_triggermanIdleRadius). The IED
        keeps him in COIN_triggerman, he knows its id in COIN_iedId. With COIN_debug a marker and a line to the IED
        show where he stands. No place found: error line, nothing created.
        Server only.

    Parameter(s):
        _id - Id of the IED [NUMBER]

    Returns:
        [triggerman, phone (objNull without one)], [] if there is no IED of that id or no place [ARRAY]
*/

params [
    ["_id", -1, [0]]
];

if (!isServer) exitWith {[]};

private _index = COIN_ieds findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {[]};
(COIN_ieds select _index) params ["", "_nestId", "_object", "_iedPos"];

([_iedPos, _object] call COIN_fnc_findTriggermanSpot) params ["_spot", "_rejected", "_score"];
if (_spot isEqualTo []) exitWith {
    diag_log format [
        "[COIN] ieds: ERROR - no place for the triggerman of IED %1 at %2 in %3 tries, rejected by: %4, the IED has none",
        _id, _iedPos, COIN_triggermanSpotTries, ((keys _rejected) apply {format ["%1 %2x", _x, _rejected get _x]}) joinString ", "
    ];
    []
};

private _man = ["triggerman", _spot, _spot getDir _iedPos] call COIN_fnc_createCivilianFighter;
_man setVariable ["COIN_iedId", _id];
// He does not stare at the IED like a pillar: a few steps back and forth around his spot (the loop sends him away
// when the IED is gone, and stops him when he is captured)
if (COIN_triggermanIdleRadius > 0) then {
    _man enableAI "PATH";
    [group _man, _spot, COIN_triggermanIdleRadius] call BIS_fnc_taskPatrol;
};
_object setVariable ["COIN_triggerman", _man];

private _phone = objNull;
if (isClass (configFile >> "CfgVehicles" >> COIN_triggermanPhone)) then {
    _phone = createVehicle [COIN_triggermanPhone, _spot, [], 0, "CAN_COLLIDE"];
    // Not handed to Zeus: Liberation's zeus_synchro removes attached objects from the curators, the phone goes with him
    _phone attachTo [_man, [0, 0, 0], COIN_triggermanPhonePoint];
};

if (COIN_debug) then {
    private _marker = format ["COIN_triggerman_%1", _id];
    private _line = format ["%1_line", _marker];
    // Local setters first, the last global one broadcasts the whole marker once (also to late joiners)
    createMarkerLocal [_line, _spot];
    _line setMarkerPolylineLocal [_spot select 0, _spot select 1, _iedPos select 0, _iedPos select 1];
    _line setMarkerColor COIN_triggermanMarkerColor;
    createMarkerLocal [_marker, _spot];
    _marker setMarkerTypeLocal COIN_triggermanMarkerType;
    _marker setMarkerColorLocal COIN_triggermanMarkerColor;
    _marker setMarkerSizeLocal [0.7, 0.7];
    _marker setMarkerText format ["Triggerman IED %1", _id];
};

diag_log format [
    "[COIN] ieds: triggerman of IED %1 (nest %2) stands at %3, %4 m from it, %5",
    _id, _nestId, _spot, round (_spot distance2D _iedPos),
    ["in the open", "elevated", "beside a house", "beside a house, elevated"] select _score
];

[_man, _phone]
