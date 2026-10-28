/*
    File: fn_isReliefGone.sqf
    Author: COIN Liberation
    Description:
        Is the source of a relief gone, so the relief is called off? (ticket 6.1c, #156, hook 33)
        Replaces Liberation's "radio tower captured": for a staging area the source no longer counts when its command post
        is destroyed or its military post captured (it is no longer in COIN_fnc_getStagingAreas). For a radio tower
        (switch off) it is Liberation's check. Server only.

    Parameter(s):
        _relief - Result of COIN_fnc_getRelief [ARRAY]

    Returns:
        The source is gone [BOOL]
*/

params [
    ["_relief", [], [[]], 3]
];

if (!isServer) exitWith {false};

private _source = _relief select 1;

if ((_source select 0) isEqualTo "tower") exitWith {
    (_source select 1) in blufor_sectors
};

(([] call COIN_fnc_getStagingAreas) findIf {(_x select 2) isEqualTo _source}) < 0
