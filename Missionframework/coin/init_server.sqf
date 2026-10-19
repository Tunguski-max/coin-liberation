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

// Phase 1 check: BLUFOR preset (light brigade) and what the build menu ended up with
diag_log format [
    "[COIN] init: blufor preset %1, build lists light=%2 heavy=%3 air=%4 static=%5 support=%6, elite=%7",
    KP_liberation_preset_blufor, count light_vehicles, count heavy_vehicles, count air_vehicles,
    count static_vehicles, count support_vehicles, elite_vehicles
];

// Phase 1 check: OPFOR preset (militia) and which vehicles Liberation can pick for the militia
diag_log format [
    "[COIN] init: opfor preset %1, militia_vehicles=%2, opfor_vehicles=%3, battlegroup_vehicles=%4, choppers=%5, air=%6, transports=%7",
    KP_liberation_preset_opfor, militia_vehicles, opfor_vehicles, opfor_battlegroup_vehicles,
    opfor_choppers, opfor_air, opfor_troup_transports
];
