/*
    COIN Liberation - central configuration

    All gameplay and balancing values of the COIN layer live here.
    No magic numbers in code: add a variable here and reference it.

    Values are starting points for local testing and will be tuned
    during playtests (Roadmap phase 7).

    Loaded on every machine by COIN_fnc_init (coin\functions\core\fn_init.sqf)
    before the server and client parts of the module start.
*/

// ---------------------------------------------------------------------------
// General
// ---------------------------------------------------------------------------
COIN_debug                  = false;    // Show nests, radii, IEDs on map; verbose [COIN] logs
COIN_saveVersion            = 1;        // Bump when the persisted data format changes
COIN_initTimeout            = 300;      // s to wait for Liberation's init before giving up

// ---------------------------------------------------------------------------
// Feature switches (turn systems off to isolate bugs)
// ---------------------------------------------------------------------------
COIN_enableNests            = true;     // Phase 2
COIN_enableQuestioning      = true;     // Phase 3
COIN_enableIEDs             = true;     // Phase 4
COIN_enableVBIEDs           = true;     // Phase 4
COIN_enableSuicideBombers   = true;     // Phase 4
COIN_enableAmbushes         = true;     // Phase 4
COIN_enableNestRebuild      = false;    // Phase 6, decision E5
COIN_enableRoleTraits       = true;     // Phase 1, ticket 1.5: ACE abilities per slot class, also after respawn

// Changes to Liberation behaviour (each one is a hook or overrides a Liberation global)
COIN_disableFobHunting      = true;     // Phase 2, ADR 0011: no enemy bases besides nests
COIN_replaceLiberationThreats = true;   // Phase 4, ADR 0008: Liberation IEDs and town ambushes off
COIN_capReadinessByNetwork  = true;     // Phase 6, ADR 0013: active nests cap combat_readiness
COIN_hideReputationNumber   = true;     // Phase 5, ADR 0009: no reputation number in the Liberation overlay

// ---------------------------------------------------------------------------
// Slot roles (Phase 1, ticket 1.5)
// ACE abilities a slot gets beyond its class config: [unit class, [[variable, value], ...]]
// The classes already bring most of it (B_medic_F is an ACE medic, B_soldier_exp_F an explosive specialist);
// the table sets the ACE variables explicitly, at start and after every respawn.
// ---------------------------------------------------------------------------
COIN_roleTraits = [
    ["B_soldier_exp_F", [["ACE_isEngineer", 1]]],               // EOD: repair (ACE engineer)
    ["B_medic_F",       [["ace_medical_medicClass", 1]]],       // Medic: ACE medic
    ["B_officer_F",     [["ace_medical_medicClass", 1], ["ACE_isEngineer", 1]]]  // Commander (as in his Eden init), kept after respawn
];

// ---------------------------------------------------------------------------
// Performance budgets (no headless client), ADR 0015 (changed 2026-10-19)
// Enemy AI: Liberation's three caps (GRLIB_sector_cap, GRLIB_battlegroup_cap, GRLIB_patrol_cap) get one value,
// COIN_maxEnemyAI times the Unitcap factor of the lobby. COIN units come on top: a server loop adds their
// current number to Liberation's caps, because Liberation counts every OPFOR unit. Nests always spawn complete,
// camps only while all COIN units together stay within COIN_maxCampAI.
// ---------------------------------------------------------------------------
COIN_enableAIBudget         = true;     // Phase 2, ticket 2.13. Off: Liberation keeps its original caps, camps are not limited
COIN_maxEnemyAI             = 100;      // Liberation's caps at Unitcap "normal" (original 180/150/150)
COIN_maxCampAI              = 30;       // A camp spawns if afterwards at most this many COIN units live (nest guards and crews included)
COIN_aiBudgetInterval       = 5;        // s between two updates of Liberation's caps
COIN_maxCivilians           = 30;       // All civilians on the map
COIN_maxActiveIEDs          = 25;       // COIN IEDs at the same time
COIN_spawnRadius            = 1500;     // m around players in which COIN content spawns

// ---------------------------------------------------------------------------
// Militia network (Phase 2) - whole map is the area of operations (ADR 0016)
// [type, count, influence radius in m]
// ---------------------------------------------------------------------------
COIN_nestSetup = [
    ["command",      2, 2500],
    ["iedWorkshop",  3, 2000],
    ["cache",        3, 1500],
    ["vbiedGarage",  1, 2500],
    ["recruitment",  2, 2000]
];
// Placement at campaign start (ticket 2.2, DESIGN 5, ADR 0018)
COIN_nestMinDistStartBase   = 4000;     // m between nests and the start base
COIN_nestMinDistCapital     = 1000;     // m between nests and the capital (Liberation's sectors_bigtown)
COIN_nestMinDistSector      = 250;      // m between nests and every sector centre (Liberation evaluates 175 m around it)
COIN_nestMinDistMapEdge     = 1000;     // m between nests and the map edge
COIN_nestMinDistNests       = 2500;     // m between two nests ...
COIN_nestMinDistNestsStep   = 250;      // ... lowered by this per step if a nest finds no place (one log line per step) ...
COIN_nestMinDistNestsMin    = 1000;     // ... but never below this, then the nest is left out
COIN_nestCandidates         = 30;       // Valid places drawn per nest, the one farthest from the other nests wins ("best candidate")
COIN_nestPlaceAttempts      = 1000;     // Random positions tried per nest and step to find these terrain candidates
// Share of building nests per type, the rest are terrain nests (on average about 7 building and 4 terrain nests)
COIN_nestBuildingShare = [
    ["command",      0.5],
    ["iedWorkshop",  0.7],
    ["cache",        0.3],
    ["vbiedGarage",  1.0],
    ["recruitment",  1.0]
];
COIN_nestBuildingRing       = [250, 600]; // [min, max] m between the house of a building nest and its town's centre (not the capital)
// Building positions a house needs per type: core object, 2-4 props and part of the guards.
// The VBIED garage only holds core object and props, its guards stand outside (garages have 2-7 positions)
COIN_nestBuildingMinPositions = [
    ["command",      8],
    ["iedWorkshop",  8],
    ["cache",        8],
    ["vbiedGarage",  2],
    ["recruitment",  8]
];
// Footprint a house needs per type in m² (from boundingBoxReal), 0 = any size. Measuring run 2026-10-20 on Lythium
// (287 houses, 102 / 266 / 2766 m² min / median / max): recruitment houses of 275 and 667 m² are the reference,
// IED workshops of 134 and 157 m² fit, an industrial shed of 619 m² is the ideal VBIED garage
COIN_nestBuildingMinArea = [
    ["command",      250],
    ["iedWorkshop",  130],
    ["cache",        0],
    ["vbiedGarage",  0],      // Chosen by class instead (COIN_nestBuildingClasses): large houses of 667 m² did not fit
    ["recruitment",  250]
];
// Allowed house classes per type, a type without a row takes any class (then only the footprint counts).
// Case does not matter. With COIN_debug, the RPT lists every house class at the town edges (catalog) to choose from.
// VBIED garage chosen in Zeus on 2026-10-20 (Land_i_Shed_Ind_F is the reference, small Altis garages left out)
COIN_nestBuildingClasses = [
    ["vbiedGarage", [
        "Land_i_Shed_Ind_F",
        "Land_jbad_hangar_2",
        "Land_ffaa_casa_hangar_2",
        "Land_CarService_F",
        "jbad_opx2_garage1",
        "Land_GarageRow_01_large_F",
        "Land_Shed_Big_F",
        "Land_Warehouse_01_F",
        "Land_Warehouse_02_F",
        "Land_Warehouse_03_F"
    ]]
];
// Classes that count as "House" and have building positions but are no houses (case does not matter)
COIN_nestBuildingExcludedClasses = ["Land_Pier_F", "Land_Airport_left_F", "Land_Airport_right_F", "Land_Airport_center_F"];
COIN_nestTerrainMinDistTown = 500;      // m between terrain nests and towns, as for camps (DESIGN 5.1)
COIN_nestTerrainMinDistRoad = 150;      // m between terrain nests and roads, as for camps
COIN_nestTerrainFlatRadius  = 15;       // m around a terrain nest that must be free of objects and flat ...
COIN_nestTerrainMaxGradient = 0.15;     // ... with at most this terrain gradient (isFlatEmpty, as BIS_fnc_findSafePos uses it)
// Debug map (lobby parameter "COIN Debug"): marker color per nest type, destroyed nests are grey
COIN_nestDebugColors = [
    ["command",      "ColorRed"],
    ["iedWorkshop",  "ColorOrange"],
    ["cache",        "ColorYellow"],
    ["vbiedGarage",  "ColorPink"],
    ["recruitment",  "ColorBrown"]
];
// Immediate combat_readiness drop when a nest is destroyed: [type, drop] (Phase 6, ADR 0013)
COIN_nestReadinessDrop = [
    ["command",      20],
    ["iedWorkshop",  10],
    ["cache",        10],
    ["vbiedGarage",  10],
    ["recruitment",  10]
];
COIN_cacheOldVehicles       = [1, 2];   // [min, max] old vehicles guarded by a weapons cache
COIN_oldVehicleClasses      = ["LOP_AM_OPF_BTR60", "LOP_AM_OPF_M113_W"];
COIN_nestGuardsMin          = 3;
COIN_nestGuardsMax          = 8;
COIN_documentDropChance     = 0.5;      // Chance a destroyed nest yields documents

// ---------------------------------------------------------------------------
// Camps (Phase 2) - not persisted, redistributed on every server start
// ---------------------------------------------------------------------------
COIN_enableCamps            = true;
COIN_campMax                = 10;       // Hard cap of simultaneous camps
// Camps supported per active nest type: [type, camps]
COIN_campsPerNest = [
    ["command",      2],
    ["iedWorkshop",  1],
    ["cache",        1],
    ["vbiedGarage",  1],
    ["recruitment",  2]
];
COIN_campExclusionRadius    = 1000;     // m around captured sectors and FOBs without camps
COIN_campMinDistRoad        = 150;      // m
COIN_campMinDistTown        = 500;      // m
COIN_campGuardsMin          = 3;
COIN_campGuardsMax          = 6;
COIN_campTechnicalChance    = 0.3;
COIN_campReplaceMinutes     = [30, 60]; // Delay before a destroyed camp is replaced
COIN_campRelocateMinutes    = [120, 180]; // Undiscovered camps move after this time
COIN_campIntelChance        = 0.4;      // Chance a cleared camp yields intel on its nest

// Capital garrison = base * (1 + factor * active nests) - Phase 6
COIN_capitalGarrisonBase    = 1.0;
COIN_capitalGarrisonFactor  = 0.15;
// Fixed heavy equipment of the capital, independent of caches (ADR 0014)
COIN_capitalHeavyVehicles   = ["LOP_AM_OPF_T72BA", "LOP_AM_OPF_T72BA", "LOP_ISTS_OPF_ZSU234"];
COIN_capitalAAInfantry      = 3;        // Igla gunners in the capital garrison

// ---------------------------------------------------------------------------
// Army equipment limits (Phase 1, ticket 1.9, ADR 0007)
// [classname, max alive at the same time, lock in minutes after each purchase]
// Locks are not persisted and restart with the server.
// ---------------------------------------------------------------------------
COIN_enableVehicleLimits    = true;
COIN_vehicleLimits = [
    ["RHS_AH1Z",       1, 30],
    ["RHS_MELB_AH6M",  1, 30]
];

// ---------------------------------------------------------------------------
// Resource economy (Phase 1, ticket 1.11, ADR 0017)
// ---------------------------------------------------------------------------
// New campaign only: after Liberation draws what each supply point produces, balance supplies,
// ammo and fuel so that their counts differ by 1 at most (8 supply points: always 3-3-2).
// Loaded saves are never touched.
COIN_enableResourceGuarantee = true;

// ---------------------------------------------------------------------------
// Interpreter and intel (Phase 3)
// ---------------------------------------------------------------------------
COIN_interpreterRange       = 5;        // m between asking player and interpreter

// Marker radius per intel level in m
COIN_intelRadiusRumor       = 600;
COIN_intelRadiusHint        = 300;
COIN_intelRadiusTip         = 100;
COIN_triangulationFactor    = 0.5;      // Each further true intel multiplies radius by this
COIN_intelRadiusMin         = 50;

// Documents as ACE Intel Items that must be brought to the interpreter (decision E13)
COIN_documentsAsAceItems    = false;

// Outcome weights per reputation band: [nothing, rumor, hint, tip, warning, lie]
// Bands: see COIN_repBandMid / COIN_repBandHigh below.
COIN_intelWeightsLow        = [40, 15,  5,  0,  5, 35];
COIN_intelWeightsMid        = [30, 25, 20,  5, 10, 10];
COIN_intelWeightsHigh       = [20, 20, 30, 15, 12,  3];

// ---------------------------------------------------------------------------
// Asymmetric threats (Phase 4)
// ---------------------------------------------------------------------------
COIN_iedBudgetPerWorkshop   = 6;        // IEDs a workshop can keep active in its radius
COIN_iedBudgetRegenMinutes  = 30;       // Minutes per regenerated IED
COIN_iedDecoyChance         = 0.3;
COIN_iedRemoteChance        = 0.25;     // Share of remote-triggered IEDs (with triggerman)

COIN_vbiedIntervalMinutes   = [45, 90]; // Random interval [min, max] per active garage
COIN_suicideBomberChanceLow = 0.05;     // Per eligible civilian spawn at low reputation
COIN_suicideBomberChanceHigh= 0.01;     // ... at high reputation
COIN_ambushIntervalMinutes  = [30, 60];

// ---------------------------------------------------------------------------
// Reputation (Phase 5), ADR 0009
// Uses Liberation's civil reputation KP_liberation_civ_rep, scale -100 .. +100.
// Changes go through Liberation's F_cr_changeCR.
// Liberation already handles: civilian killed (-5), civilian vehicle seized (-2),
// friendly resistance killed (-3), sector liberated (+5 / capital +10),
// wounded civilian treated (+2), informant delivered (+2),
// buildings destroyed at the moment of capture (-3 each).
// ---------------------------------------------------------------------------
COIN_reputationStart        = -20;      // Value for a new campaign
COIN_repBandMid             = 0;        // Band "mid" starts here (below: "low")
COIN_repBandHigh            = 25;       // Band "high" starts here (= Liberation informants, friendly resistance)

COIN_repIEDDefused          = 2;
COIN_repNestDestroyed       = 5;
COIN_repCivilianHelped      = 1;
COIN_repCaptiveKilled       = -10;
COIN_repShootingNearCivs    = -1;
COIN_repBuildingDestroyed   = -3;       // Per building destroyed by BLUFOR in a liberated town

// ---------------------------------------------------------------------------
// Favors at very high reputation (Phase 5, decision E12)
// ---------------------------------------------------------------------------
COIN_enableFavors           = true;
COIN_favorRepThreshold      = 50;       // Provisional, final value in the phase 5 spec
COIN_favorGainMinutes       = 120;      // One favor per this many minutes above threshold
COIN_favorMaxStored         = 2;
COIN_favorLossCooldownMin   = 60;       // Extra wait if local fighters were wiped out

COIN_diversionDurationMin   = [15, 20]; // Militia pulled toward diversion target
COIN_diversionPullRadius    = 2000;     // m around target from which militia groups are pulled
COIN_diversionFighters      = [6, 10];

COIN_reinforcementSize      = [4, 6];
COIN_reinforcementMaxMin    = 60;       // Group leaves after this time

// ---------------------------------------------------------------------------
// Tasks (Phase 5, DESIGN 8.2) - not persisted, abort or failure costs nothing
// ---------------------------------------------------------------------------
COIN_enableAidTasks         = true;
COIN_enableReconTasks       = true;

// Aid tasks, offered by the elder of a liberated town (any reputation band)
COIN_aidTaskMaxActive       = 2;        // Aid tasks active at the same time
COIN_aidTaskCooldownMin     = 60;       // Minutes before a town offers its next aid task
COIN_aidTaskTimeoutMin      = 60;       // Minutes to complete an accepted aid task
COIN_repAidSupplies         = 4;        // Reputation for delivering a supply crate
COIN_repAidPatient          = 1;        // Reputation per treated patient
COIN_repAidMedicalBonus     = 2;        // Bonus when all patients are treated in time
COIN_aidMedicalPatients     = [3, 5];   // [min, max] patients in a medical task
COIN_repAidRepair           = 3;        // Reputation for repairing infrastructure

// Recon tasks, created as a result of questioning or interrogation
COIN_reconTaskChance        = 0.15;     // Chance per questioning/interrogation result
COIN_reconTaskMaxActive     = 1;
COIN_reconTaskWindowMin     = [30, 60]; // Time window in minutes
COIN_reconReadinessFactor   = 0.9;      // combat_readiness multiplier for leader capture and arms transport

// ---------------------------------------------------------------------------
// Faction markers (Phase 1, ticket 1.6 / #9, ADR 0012, ADR 0014)
// ---------------------------------------------------------------------------
COIN_enableFactionMarkers       = true;                     // Colored shemag per faction, see COIN_fnc_markFactions
COIN_markerInterval             = 3;                        // s between two scans for new units or a changed reputation
COIN_markerMilitia              = "LOP_H_Shemag_RED1";      // Militia: red
COIN_markerResistanceHostile    = "H_Shemag_olive";         // Resistance, hostile to the army (reputation < -25): green (vanilla olive shemag)
COIN_markerResistanceFriendly   = "LOP_H_Shemag_BLU";       // Resistance, neutral or friendly: blue

// ---------------------------------------------------------------------------
// Militia armor mix (Phase 1, ADR 0014): Islamic State twins (vest 16, helmet 6) in the field squads
// ---------------------------------------------------------------------------
COIN_enableSquadMix         = true;         // Hooks 9 and 10 call COIN_fnc_mixSquad / COIN_fnc_mixClass. Off: squads stay Afghan Militia without armor
COIN_squadMixReadiness      = [30, 100];    // combat_readiness range the share is scaled over
COIN_squadMixShare          = [0.25, 0.75]; // Share of Islamic State twins at the lower / upper readiness
// Afghan Militia class -> Islamic State twin of the same role
COIN_squadMixTwins = [
    ["LOP_AM_OPF_Infantry_SL",          "LOP_ISTS_OPF_Infantry_SL"],
    ["LOP_AM_OPF_Infantry_TL",          "LOP_ISTS_OPF_Infantry_TL"],
    ["LOP_AM_OPF_Infantry_Rifleman",    "LOP_ISTS_OPF_Infantry_Rifleman"],
    ["LOP_AM_OPF_Infantry_Rifleman_5",  "LOP_ISTS_OPF_Infantry_Rifleman_5"],
    ["LOP_AM_OPF_Infantry_Rifleman_3",  "LOP_ISTS_OPF_Infantry_Rifleman_2"],    // Marksman (Lee Enfield)
    ["LOP_AM_OPF_Infantry_AT",          "LOP_ISTS_OPF_Infantry_AT"],
    ["LOP_AM_OPF_Infantry_GL",          "LOP_ISTS_OPF_Infantry_GL"],
    ["LOP_AM_OPF_Infantry_AR_Asst",     "LOP_ISTS_OPF_Infantry_AR_Asst"],
    ["LOP_AM_OPF_Infantry_AR",          "LOP_ISTS_OPF_Infantry_AR"],
    ["LOP_AM_OPF_Infantry_Marksman",    "LOP_ISTS_OPF_Infantry_Marksman"],
    ["LOP_AM_OPF_Infantry_Corpsman",    "LOP_ISTS_OPF_Infantry_Corpsman"],
    ["LOP_AM_OPF_Infantry_Engineer",    "LOP_ISTS_OPF_Infantry_Engineer"]
];
