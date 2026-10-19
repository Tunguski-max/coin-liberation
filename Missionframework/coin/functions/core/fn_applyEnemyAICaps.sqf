/*
    File: fn_applyEnemyAICaps.sqf
    Author: COIN Liberation

    Description:
        Sets Liberation's three caps for enemy AI on this machine (ADR 0015, ticket 2.13). The server calls it from
        COIN_fnc_aiBudget, clients when the server publishes COIN_enemyAICaps. Clients need the values for
        Liberation's overlay hint "cap reached". Their own kp_liberation_config.sqf sets Liberation's original
        values again when they join, so they take the published ones afterwards.

    Parameter(s):
        _caps - [sector cap, battlegroup cap, patrol cap] [ARRAY of NUMBERs]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_caps", [], [[]], 3]
];

if ((count _caps) != 3) exitWith {false};

GRLIB_sector_cap = _caps select 0;
GRLIB_battlegroup_cap = _caps select 1;
GRLIB_patrol_cap = _caps select 2;

true
