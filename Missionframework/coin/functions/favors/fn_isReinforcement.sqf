/*
    File: fn_isReinforcement.sqf
    Author: COIN Liberation

    Description:
        Is this the group of the reinforcement that is on its way? (ticket 5.19) The loops of the radio (COIN_fnc_radioFollowLoop,
        COIN_fnc_watchReinforcement) end when it is not any more: COIN_reinforcement is empty or has another group. Server only.

    Parameter(s):
        _group - The group [GROUP, defaults to grpNull]

    Returns:
        It is the group of the reinforcement that is on its way [BOOL]
*/

params [
    ["_group", grpNull, [grpNull]]
];

!isNull _group && {((missionNamespace getVariable ["COIN_reinforcement", []]) param [0, grpNull]) isEqualTo _group}
