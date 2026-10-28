/*
    File: fn_getStagingAreasAt.sqf
    Author: COIN Liberation

    Description:
        The staging areas that contain a position (ticket 6.1a, #154, ADR 0025): COIN_fnc_getStagingAreas, only the
        entries whose centre is at most their radius away (2D). Empty if the position is in no staging area, or the
        feature is off. Server only.

    Parameter(s):
        _pos - Position [ARRAY]

    Returns:
        Staging areas containing the position, same entries as COIN_fnc_getStagingAreas [ARRAY]
*/

params [
    ["_pos", [], [[]], [2, 3]]
];

([] call COIN_fnc_getStagingAreas) select {(_pos distance2D (_x select 0)) <= (_x select 1)}
