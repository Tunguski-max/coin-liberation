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

// Changes to Liberation behaviour (each one is a hook or overrides a Liberation global)
COIN_disableFobHunting      = true;     // Phase 2, ADR 0011: no enemy bases besides nests
COIN_replaceLiberationThreats = true;   // Phase 4, ADR 0008: Liberation IEDs and town ambushes off
COIN_capReadinessByNetwork  = true;     // Phase 6, ADR 0013: active nests cap combat_readiness

// ---------------------------------------------------------------------------
// Performance budgets (no headless client), ADR 0015
// Totals for Liberation AND COIN together. Liberation's own caps
// (GRLIB_sector_cap, GRLIB_battlegroup_cap, GRLIB_patrol_cap) are derived from these.
// ---------------------------------------------------------------------------
COIN_maxEnemyAI             = 80;       // All OPFOR units on the map
COIN_maxCivilians           = 30;       // All civilians on the map
COIN_maxActiveIEDs          = 25;       // COIN IEDs at the same time
COIN_spawnRadius            = 1500;     // m around players in which COIN content spawns

// ---------------------------------------------------------------------------
// Militia network (Phase 2)
// [type, count, influence radius in m]
// ---------------------------------------------------------------------------
COIN_nestSetup = [
    ["command",      2, 1500],
    ["iedWorkshop",  3, 1200],
    ["cache",        3, 1000],
    ["vbiedGarage",  1, 1500],
    ["recruitment",  2, 1200]
];
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
COIN_campBorderZone         = 1500;     // m beyond the play area where camps may appear
COIN_campExclusionRadius    = 1000;     // m around captured sectors and FOBs without camps
COIN_campMinDistRoad        = 150;      // m
COIN_campMinDistTown        = 500;      // m
COIN_campGuardsMin          = 3;
COIN_campGuardsMax          = 6;
COIN_campTechnicalChance    = 0.3;
COIN_campReplaceMinutes     = [30, 60]; // Delay before a destroyed camp is replaced
COIN_campRelocateMinutes    = [120, 180]; // Undiscovered camps move after this time
COIN_campIntelChance        = 0.4;      // Chance a cleared camp yields intel on its nest

// Capital garrison = base * (1 + factor * active nests)
COIN_capitalGarrisonBase    = 1.0;
COIN_capitalGarrisonFactor  = 0.15;

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
