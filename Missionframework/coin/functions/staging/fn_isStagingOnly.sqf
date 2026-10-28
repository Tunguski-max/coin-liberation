/*
    File: fn_isStagingOnly.sqf
    Author: COIN Liberation

    Description:
        Must a counterattack on this target start in a staging area (ticket 6.1b, #155, ADR 0025)? Asked by
        spawn_battlegroup.sqf (hook 32) before it picks the spawn point. True with COIN_enableStagingAreas and
        COIN_enableStagingCounterattacks, except for a counterattack on the capital: it stays without a condition,
        as in Liberation. Server only.

    Parameter(s):
        _target - Sector marker the counterattack aims at, "" for a random battlegroup without a target [STRING]

    Returns:
        Only spawn points in a staging area [BOOL]
*/

params [
    ["_target", "", [""]]
];

if (!isServer || {!COIN_enableStagingAreas} || {!COIN_enableStagingCounterattacks}) exitWith {false};

!(_target in (missionNamespace getVariable ["sectors_bigtown", []]))
