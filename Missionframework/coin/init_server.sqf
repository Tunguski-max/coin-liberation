/*
    File: init_server.sqf
    Author: COIN Liberation

    Description:
        Server part of the COIN module. Called by COIN_fnc_init after Liberation's
        init.sqf has finished on the server (dedicated server or local host).
        COIN systems are started here in later phases.
*/

diag_log "[COIN] init (server)";
diag_log format ["[COIN] init: debug=%1 (lobby parameter COIN Debug or COIN_debug in the config)", COIN_debug];

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

// Equipment limits (ticket 1.9, ADR 0007): locks start empty on every server start, they are not persisted
if (COIN_enableVehicleLimits) then {
    COIN_vehicleLocks = [];
    publicVariable "COIN_vehicleLocks";
    diag_log format ["[COIN] init: vehicle limits on %1", COIN_vehicleLimits];
};

// Secondary mission FOB hunting (ticket 2.12, ADR 0011): checked on start in hooks 15 and 16, no loop
diag_log format ["[COIN] init: FOB hunting switched off=%1", COIN_disableFobHunting];

// Liberation's IEDs and town ambushes (ticket 4.7, ADR 0008): decided in hooks 22 and 23, no loop
if ([] call COIN_fnc_replacesLiberationThreats) then {
    diag_log "[COIN] init: Liberation threats replaced=true (sector IEDs off, town IEDs and ambush off; convoy raid and sector guerilla stay)";
} else {
    diag_log "[COIN] init: Liberation threats replaced=false (Liberation IEDs and ambushes run as before)";
};

// Reputation (ticket 5.7, ADR 0009): start value of a new campaign, logs the value of a loaded save
[] spawn COIN_fnc_initReputation;
[] call COIN_fnc_initReputationEvents;
// Readiness drop when a nest is destroyed (ticket 6.6b, #153, ADR 0013): registered before the nests are loaded or created
[] call COIN_fnc_initReadinessEvents;
if (COIN_enableInformantFrequency) then {
    [] spawn COIN_fnc_informantFrequencyLoop;
} else {
    diag_log "[COIN] init: informant frequency by reputation off, Liberation's values stay";
};

// Favors (ticket 5.4, DESIGN 8.1, ADR 0023): the stock and the counter come from the save, the counter runs at a high reputation
[] spawn COIN_fnc_initFavors;

// AI budget (ticket 2.13, ADR 0015): Liberation's caps = COIN_maxEnemyAI x Unitcap, COIN units on top
if (COIN_enableAIBudget) then {
    [] spawn COIN_fnc_aiBudget;
} else {
    diag_log format ["[COIN] init: AI budget off, Liberation caps stay sector/battlegroup/patrol %1/%2/%3", GRLIB_sector_cap, GRLIB_battlegroup_cap, GRLIB_patrol_cap];
};

// Zeus: everything COIN spawns is added to every curator, also to curators created later
[] spawn COIN_fnc_curatorSync;

// Militia network (tickets 2.1 and 2.5, ADR 0018): nests from entry 22 of the save, new ones for a new campaign
if (COIN_enableNests) then {
    [] spawn COIN_fnc_initNests;
} else {
    diag_log "[COIN] init: nests off, none are created, a COIN block in the save is kept unchanged";
};

// Staging areas (ticket 6.1a, #154, ADR 0025): command posts and military posts of the militia, logged and drawn on a change
if (COIN_enableStagingAreas) then {
    diag_log format ["[COIN] init: staging areas on, military post radius %1 m, check every %2 s", COIN_stagingRadiusMilitary, COIN_stagingCheckSeconds];
    [] spawn COIN_fnc_stagingLoop;
} else {
    diag_log "[COIN] init: staging areas off";
};

// Readiness cap (ticket 6.6a, #152, ADR 0013, ADR 0025): the network strength of the nests caps combat_readiness
if (COIN_capReadinessByNetwork) then {
    diag_log format ["[COIN] init: readiness cap on, floor %1, check every %2 s", COIN_readinessCapFloor, COIN_readinessCapSeconds];
    [] spawn COIN_fnc_readinessCapLoop;
} else {
    diag_log "[COIN] init: readiness cap off, Liberation's readiness stays";
};

// Intel (ticket 3.1, DESIGN 7): circles on the map from the interpreter's questions. Empty until COIN_fnc_initNests
// has loaded the save (ticket 3.2, COIN_fnc_loadIntel)
if (COIN_enableQuestioning) then {
    COIN_intel = [];
    COIN_intelNextId = 1;
    // Cooldown of each interpreter (ticket 3.5): player UID -> end time, not saved, survives the respawn of the unit
    COIN_cooldownEnds = createHashMap;
    // Warnings of camps and IEDs (tickets 3.6, 4.8): [id, kind, threat id, center, radius], not saved
    COIN_warnings = [];
    COIN_warningNextId = 1;
    [] spawn COIN_fnc_warningLoop;
    diag_log format ["[COIN] init: questioning on, nest range %1 m, talk range %2 m, cooldown %3 (%4 s)", COIN_intelNestRange, COIN_talkRange, COIN_enableCooldown, COIN_questionCooldown];
    // Lies (ticket 3.4): a player on foot at the fake point removes the lie
    [] spawn COIN_fnc_intelSearchLoop;
} else {
    diag_log "[COIN] init: questioning off";
};

// Own population of liberated towns (ticket 3.7, DESIGN 7, ADR 0011): Liberation has no civilians there
if (COIN_enablePopulation) then {
    [] spawn COIN_fnc_populationLoop;
} else {
    diag_log "[COIN] init: population off";
};

// Aid tasks of the elders (tickets 5.9b and 5.10, DESIGN 8.2): town -> running task, town -> time until it waits. Not saved
if (COIN_enableAidTasks) then {
    COIN_aidActive = createHashMap;
    COIN_aidCooldown = createHashMap;
    COIN_aidNextId = 0;
    diag_log format ["[COIN] init: aid tasks on, at most %1 at the same time, %2 min limit, %3 min wait per town", COIN_aidTaskMaxActive, COIN_aidTaskTimeoutMin, COIN_aidTaskCooldownMin];
} else {
    diag_log "[COIN] init: aid tasks off";
};

// Strike tasks (tickets 5.13 and 5.14, DESIGN 8.2): the running ones [task id, kind], the offers per player UID [kind, valid until]. Not saved
if (COIN_enableStrikeTasks) then {
    COIN_strikeActive = [];
    COIN_strikeOffers = createHashMap;
    COIN_strikeNextId = 0;
    diag_log format ["[COIN] init: strike tasks on, chance %1 from reputation %2, at most %3 at the same time, %4 kinds", COIN_strikeTaskChance, COIN_strikeTaskMinRep, COIN_strikeTaskMaxActive, count COIN_strikeKinds];
} else {
    diag_log "[COIN] init: strike tasks off";
};

// Site of the aid tasks (ticket 5.20, ADR 0024): only chosen and written to the RPT, nothing plays there yet
if (COIN_enableAidSites) then {
    [] call COIN_fnc_logSites;
} else {
    diag_log "[COIN] init: aid sites off";
};

// Messages to all players when a nest is destroyed or a camp cleared (ticket 2.14)
[] call COIN_fnc_initMessages;

// Colored shemag per faction (ticket #9): runs as long as COIN_enableFactionMarkers is true
if (COIN_enableFactionMarkers) then {
    diag_log format ["[COIN] init: faction markers militia=%1 resistanceHostile=%2 resistanceFriendly=%3 interval=%4", COIN_markerMilitia, COIN_markerResistanceHostile, COIN_markerResistanceFriendly, COIN_markerInterval];
    [] spawn COIN_fnc_markFactions;
};

// Armor mix of the militia field squads (ADR 0014): the mixing itself runs on demand from Liberation's squad composition (hooks 9 and 10)
if (COIN_enableSquadMix) then {
    private _added = [] call COIN_fnc_registerSquadTwins;
    diag_log format ["[COIN] init: squad mix on, %1 twin classes registered, share %2 at readiness %3 to %4 at readiness %5", _added, COIN_squadMixShare select 0, COIN_squadMixReadiness select 0, COIN_squadMixShare select 1, COIN_squadMixReadiness select 1];
};
