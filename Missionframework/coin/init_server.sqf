/*
    File: init_server.sqf
    Author: COIN Liberation

    Description:
        Server part of the COIN module. Called by COIN_fnc_init after Liberation's
        init.sqf has finished on the server (dedicated server or local host).
        COIN systems are started here in later phases.
*/

diag_log "[COIN] init (server)";

// Phase 1 check: which save key and which lobby values Liberation ended up with
diag_log format ["[COIN] init: save key %1", GRLIB_save_key];
diag_log format [
    "[COIN] init: lobby values LimitedZeus=%1 ZeusAddEnemies=%2 VictoryCondition=%3 SuppMod=%4 ResourcesMultiplier=%5 (factor) CommanderZeus=%6",
    KP_liberation_limited_zeus, KP_liberation_enemies_zeus, KP_liberation_victoryCondition,
    KP_liberation_suppMod, GRLIB_resources_multiplier, KP_liberation_commander_zeus
];
