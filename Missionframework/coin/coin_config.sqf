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
COIN_saveVersion            = 2;        // Bump when the persisted data format changes (2: intel, ADR 0021)
COIN_loadableSaveVersions   = [1, 2];   // Versions that load; older ones are converted (1 -> 2: empty intel list)
COIN_initTimeout            = 300;      // s to wait for Liberation's init before giving up

// ---------------------------------------------------------------------------
// Feature switches (turn systems off to isolate bugs)
// ---------------------------------------------------------------------------
COIN_enableNests            = true;     // Phase 2
COIN_enableQuestioning      = true;     // Phase 3
COIN_enableLies             = true;     // Phase 3, ticket 3.4: off = the weight of the lie counts as "nothing"; lies already on the map stay
COIN_enableUnsafeRefusal    = true;     // Phase 3, ticket 3.4: off = a civilian answers even with armed enemies close
COIN_enableWarnings         = true;     // Phase 3, ticket 3.6: off = the weight of the warning counts as "nothing"; warnings already on the map stay until their camp is gone
COIN_enableInterrogation    = true;     // Phase 3, ticket 3.8: off = no entry "Interrogate" at prisoners (needs COIN_enableQuestioning, its loop finds the prisoner)
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

// ---------------------------------------------------------------------------
// Spawning near players (DESIGN 5, ticket 2.3), used by nests and later by camps
// Players count, and the drone (UAV) a player is connected to, below COIN_presenceMaxDroneHeight.
// Manned aircraft higher than COIN_presenceMaxAirHeight do not.
// ---------------------------------------------------------------------------
COIN_spawnDistance          = 1000;     // m: content spawns when the nearest player is this close
COIN_despawnDistance        = 1300;     // m: content is removed when no player was this close ...
COIN_despawnDelay           = 120;      // ... for this many seconds
COIN_spawnCheckInterval     = 10;       // s between two checks of all nests; spawn and removal distance differ by 300 m, a helicopter at 60 m/s covers 600 m in 10 s, so no more
COIN_presenceMaxAirHeight   = 100;      // m above ground: manned aircraft higher up do not spawn anything
COIN_presenceMaxDroneHeight = 500;      // m above ground: drones higher up do not either (as Liberation's sectors, fn_getUnitsCount.sqf)
COIN_curatorSyncInterval    = 10;       // s: objects given to Zeus are added again to curators created later, 0 = off

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
COIN_nestMinPerType         = 2;        // Nests of every type at least; the most frequent type of COIN_nestSetup gives nests away, the total stays
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
        "Land_Jbad_Ind_Garage01",       // From the catalog of 2026-10-20: 4 at town edges, 188 m², 4 building positions
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
COIN_enableOldVehicles      = true;     // Off: weapons caches get no old vehicles (ticket 2.9a)
COIN_oldVehicleDist         = [20, 40]; // [min, max] m from the nest position (beyond the house or the template)
COIN_oldVehicleTries        = 10;       // Spots tried per vehicle before it is left out
COIN_oldVehicleSearch       = 10;       // m around a tried spot searched for free room (findEmptyPosition)
COIN_oldVehicleMaxGradient  = COIN_nestTerrainMaxGradient; // Largest terrain gradient under a vehicle (isFlatEmpty)
COIN_oldVehicleFlatRadius   = 5;        // m around a vehicle spot that must have that gradient (isFlatEmpty)
COIN_nestGuardsMin          = 3;
COIN_nestGuardsMax          = 8;
// Content of a nest when players come near (ticket 2.3). Guards come from the preset's militia_squad.
// About half of the guards stay at the core object inside the house, the others patrol as a group.
COIN_enableNestSpawn        = true;     // Off: nests stay data only, nothing spawns
COIN_nestGuardsInHouseShare = 0.5;      // Share of the guards inside the house (at most as many as free building positions)
COIN_nestPatrolRadius       = 100;      // m around the nest the patrol walks, smaller near a sector (below)
COIN_nestPatrolSectorMargin = 25;       // m the patrol keeps outside Liberation's capture radius of the nearest sector
COIN_capitalCaptureFactor   = 1.4;      // Liberation's capture radius of the capital = GRLIB_capture_size x this (fn_getBluforRatio.sqf)
COIN_nestPatrolStart        = [10, 40]; // [min, max] m from the house or camp centre where the patrol starts
COIN_nestHouseTolerance     = 5;        // m between the saved nest position and the house when it is found again
COIN_nestPropSpacing        = [1.5, 3]; // [min, max] m from the core object for props without a free building position
// Clean placement (ticket #44): objects stand on the floor below their spot, need free space around them and keep doors free
COIN_floorProbe             = [0.5, 2]; // [up, down] m from a spot in which the floor is searched
COIN_spotCheckHeights       = [0.4, 1.2]; // m above the floor where walls are looked for around an object
COIN_spotSameFloor          = 2;        // m height difference up to which two objects count as on the same floor
COIN_spotFloorTolerance     = 0.5;      // m a spot next to the core object may differ from the core's floor (no edges, stairs)
COIN_nestDoorClearance      = 1.2;      // m props and vehicles keep from door points
COIN_doorSelectionNames     = ["door", "dvere"]; // Memory points of doors contain one of these (Arma 3 / Arma 2, CUP, Jbad)
COIN_nestPropTries          = 12;       // Spots next to the core object tried per prop when no building position is free
// Template objects stand exactly as placed in Eden (test 2026-10-20: setting them down lifted things on tables onto
// their neighbours). Vehicles are still set down, they need their wheels on the floor when their physics starts.
COIN_templateSnapMax        = 0;        // m a template prop is moved at most to stand on the floor, 0 = never
COIN_templateVehicleSnapMax = 0.3;      // m a template vehicle is moved at most to stand on the floor
COIN_spawnVehicleProtection = 5;        // s a spawned vehicle cannot be damaged, so a jolt when its physics starts cannot wreck it
COIN_enableNestMines        = true;     // Mines in templates spawn live (createMine, ACE can defuse them). Off: left out
// Terrain nests (ticket #31, ADR 0020): a terrain template is built around a direction arrow, the seed picks it and
// turns it around the nest position; objects keep their height above the terrain and tilt with the slope
COIN_terrainTemplateCentreClass  = "Sign_Arrow_Direction_F"; // Arrow that marks centre and front of a terrain template in Eden
COIN_terrainTemplateCentreSearch = 50;  // m around the player the export looks for the arrow (without variable name "centre")
COIN_enableTerrainNests     = true;     // Off: terrain nests stay data only, building nests still spawn
COIN_terrainTemplateRadius  = COIN_nestTerrainFlatRadius; // m around the arrow the export takes objects from
COIN_nestTerrainGuardShare  = 0.5;      // Share of the guards standing in a ring around the camp, the others patrol
COIN_nestTerrainGuardRing   = [6, 12];  // [min, max] m from the centre where they stand, looking outwards
COIN_nestTerrainGuardClearance = 1;     // m they keep from the outline of placed objects
COIN_nestTerrainGuardTries  = 8;        // Spots tried per guard before it patrols instead
// VBIED garage: a civilian vehicle as a prop (not the core object, decoration only, locked for players)
COIN_enableNestVehicle      = true;     // Off: VBIED garages without vehicle
COIN_vbiedGarageVehicles    = ["C_Offroad_01_F", "C_Hatchback_01_F", "C_SUV_01_F", "C_Van_01_transport_F"];
COIN_nestVehicleOutside     = 20;       // m beyond the house searched for a vehicle spot if there is no room inside
COIN_nestPropsCount         = [2, 4];   // [min, max] props next to the core object
// Core object per type: destroying it destroys the nest (Phase 2, ticket 2.4). Only classes Arma can destroy,
// checked on server start (destrType, armor); a class that fails is replaced by COIN_nestCoreFallback (one log line)
COIN_nestCores = [
    ["command",      "Box_East_AmmoOrd_F"],             // Explosives crate (satellite dish cannot be destroyed, test 2026-10-20); a template core wins
    ["iedWorkshop",  "Box_East_AmmoOrd_F"],             // Explosives crate
    ["cache",        "Box_East_Wps_F"],                 // Weapons crate
    ["vbiedGarage",  "Box_IED_Exp_F"],                  // IED crate
    ["recruitment",  "Box_East_Support_F"]              // Support crate
];
COIN_nestCoreFallback       = "Box_East_Ammo_F";
COIN_enableNetworkStrength  = true;     // Off: no network strength is calculated or published (ticket 2.6)
// Destruction (ticket 2.4): a destroyed core object or a collapsed house destroys the nest for good, saved at once,
// server event "COIN_nestDestroyed" [id, type, position]. Zeus deleting the core object is no destruction
COIN_enableNestDestruction = true;     // Off: destruction is not recognised, the nest spawns again next time
COIN_nestSaveRetryDelay     = 5;        // s until a destroyed nest is saved again when Liberation was saving already
// Messages to all players (ticket 2.14): a nest destroyed (names the type, no position), a camp cleared (nothing else)
COIN_enableNestMessage      = true;     // Off: no message when a nest is destroyed
COIN_enableCampMessage      = true;     // Off: no message when a camp is cleared
COIN_nestTypeNames = [                  // Nest type as the message names it: [type, [German, English]]
    ["command",      ["Kommandoposten",     "Command post"]],
    ["iedWorkshop",  ["IED-Werkstatt",      "IED workshop"]],
    ["cache",        ["Waffenlager",        "Weapons cache"]],
    ["vbiedGarage",  ["VBIED-Garage",       "VBIED garage"]],
    ["recruitment",  ["Rekrutierungsstelle", "Recruitment point"]]
];
// Props per type, may be indestructible (e.g. workbench). Missing classes are left out (one log line on server start)
COIN_nestProps = [
    ["command",      ["Land_CampingTable_F", "Land_CampingChair_V2_F", "Land_Laptop_unfolded_F", "Land_PortableLongRangeRadio_F", "Land_SatellitePhone_F", "Land_Map_unfolded_F"]],
    ["iedWorkshop",  ["Land_Workbench_01_F", "Land_ToolTrolley_01_F", "Land_MetalBarrel_F", "Land_CanisterPlastic_F", "Land_BarrelWater_F", "Land_Sack_F"]],
    ["cache",        ["Land_WoodenCrate_01_F", "Land_Sacks_heap_F", "Land_PaperBox_closed_F", "Box_East_Ammo_F", "Land_Sack_F"]],
    ["vbiedGarage",  ["Land_CanisterFuel_F", "Land_GasTank_01_blue_F", "Land_ToolTrolley_02_F", "Land_EngineCrane_01_F", "Land_WeldingTrolley_01_F", "Land_Workbench_01_F"]],
    ["recruitment",  ["Land_Sleeping_bag_F", "Land_Ground_sheet_F", "Land_WaterBottle_01_stack_F", "Land_Pallet_MilBoxes_F", "Land_CampingChair_V1_F", "Land_FoodSacks_01_cargo_brown_F"]]
];
COIN_documentDropChance     = 0.5;      // Chance a destroyed nest yields documents

// ---------------------------------------------------------------------------
// Camps (Phase 2) - not persisted, redistributed on every server start
// ---------------------------------------------------------------------------
COIN_enableCamps            = true;     // Off: no camps are created (ticket 2.7)
COIN_campMax                = 10;       // Hard cap of simultaneous camps
COIN_campSeedRange          = 1e6;      // Seeds of camps are below this (not saved, only for a repeatable look within one session)
// Weight per nest type: [type, weight]. It counts in the camp capacity (decision E8) and is the most camps one nest of the type supplies
COIN_campsPerNest = [
    ["command",      2],
    ["iedWorkshop",  1],
    ["cache",        1],
    ["vbiedGarage",  1],
    ["recruitment",  2]
];
// Placement rules (ticket 2.8, DESIGN 5.1); the open-ground rules are shared with the terrain nests
COIN_campMinDistStartBase   = 2000;     // m between camps and the start base
COIN_campMinDistMapEdge     = 1000;     // m between camps and the map edge
COIN_campMinDistSector      = COIN_nestMinDistSector; // m between camps and every sector centre (Liberation's 175 m evaluation)
COIN_campPlaceAttempts      = 1000;     // Random positions tried per camp (about 1 in 200 passes on Lythium, 500 left 2 of 7 camps out), fewer camps with an error line if none fits
COIN_campExclusionRadius    = 1000;     // m around captured sectors and FOBs without camps (also the search radius for roads in the log)
COIN_campMinDistRoad        = COIN_nestTerrainMinDistRoad; // m, the same rule as for terrain nests (COIN_fnc_checkTerrainSpot) ...
COIN_campMinDistTown        = COIN_nestTerrainMinDistTown; // m ... so the two cannot drift apart; give the camps their own number here if they should
COIN_campFlatRadius         = COIN_terrainTemplateRadius; // m around a camp that must be flat and free: room for a camp template ...
COIN_campMaxGradient        = COIN_nestTerrainMaxGradient; // ... with at most this terrain gradient (isFlatEmpty)
// Cover: at least COIN_campCoverMin terrain objects of these types within COIN_campCoverRadius (nearestTerrainObjects)
COIN_campCoverTypes         = ["TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS"];
COIN_campCoverRadius        = 40;       // m
COIN_campCoverMin           = 3;
COIN_campGuardsMin          = 3;
COIN_campGuardsMax          = 6;
COIN_campTechnicalChance    = 0.3;
COIN_enableCampSpawn        = true;     // Off: camps stay data (ticket 2.9), no content spawns
COIN_enableCampTechnical    = true;     // Off: no camp gets a technical
COIN_campTechnicalCrew      = 3;        // Fighters a technical counts for in the camp budget (KPLIB_fnc_spawnMilitiaCrew seats up to 3)
COIN_campTechnicalDist      = [8, 15];  // [min, max] m from the camp centre where the technical stands
COIN_campTechnicalClearance = 5;        // m it keeps from objects (BIS_fnc_findSafePos)
COIN_campTechnicalLeash     = 50;       // m: an empty technical farther from its camp than this was taken and is not deleted with the camp
// Life of the camps (ticket 2.10); for tests shorten the times in the debug console, e.g. COIN_campReplaceMinutes = [0.5, 1]
COIN_enableCampLifecycle    = true;     // Off: camps stay as created, no replacement, no moving, no retiring
COIN_campReplaceMinutes     = [30, 60]; // [min, max] minutes before a cleared camp is replaced (the lower value is also the delay before a failed try is repeated)
COIN_campRelocateMinutes    = [120, 180]; // [min, max] minutes after which an undiscovered camp moves (taken when the camp is created)
COIN_campFleeDistance       = 200;      // m: a fighter farther from its camp than this no longer counts, it fled (the patrol walks within COIN_nestPatrolRadius)
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
COIN_interpreterRole        = "Dolmetscher"; // Role description of the interpreter slots (Eden "Dolmetscher@Führungsgruppe"); the slot class is the riflemen's
COIN_talkRange              = 5;      // m between the interpreter and the civilian he looks at for "Ask about the militia"
COIN_talkRangeMargin        = 2;        // m more the server allows (the civilian may drift while he is held)
COIN_talkHoldSeconds        = 30;       // s a civilian waits for a question once the interpreter has him in his sights
COIN_talkScanInterval       = 0.3;      // s between two looks at what the interpreter is aiming at
COIN_talkActionPriority     = -690;     // Place of the entry in the action menu (higher = further up): just above Liberation's own player entries (-700 and below)
COIN_questionDelay          = [1, 2];   // [min, max] s between the question and the answer
COIN_answerReadSeconds      = 5;        // s the civilian stays after his answer, and the time it takes to read
COIN_answerShowSeconds      = 8;        // s the subtitle stays on screen
COIN_intelNestRange         = 4000;     // m: a civilian knows a random active nest within this range, else the nearest one
COIN_intelCenterOffset      = [0.2, 0.8]; // Share of the radius between the nest and the middle of its circle (so the nest is never in the middle, always inside)
COIN_intelMarkerColor       = "ColorOrange";
COIN_intelMarkerAlpha       = 0.35;
COIN_unsafeRadius           = 100;      // m: a civilian refuses to talk while an armed enemy is this close; he can be asked again later
COIN_enableCooldown         = true;     // Ticket 3.5: after a question that made a marker (also a lie) the interpreter has to wait
COIN_questionCooldown       = 300;      // s the interpreter waits after a marker; "I know nothing" starts no cooldown
// Entry in the action menu (mouse wheel / space bar): [German, English]
COIN_askMilitiaLabel = ["Nach der Miliz fragen", "Ask about the militia"];
COIN_interrogateLabel = ["Verhören", "Interrogate"];
// Answer sentences of a civilian (tickets 3.1 and 3.4): [result, [German sentences, English sentences]], one is picked at random.
// A civilian does not name the nest type: a hint or a tip knows the place better, not the word for it (see COIN_questionAnswersByType).
// "unsafe" is the refusal while enemies are close (COIN_enableUnsafeRefusal): no answer, no marker.
COIN_questionAnswers = [
    ["nothing", [
        [
            "Keine Ahnung, was ihr meint. Ich halte mich aus so was raus.",
            "Fragt mich nicht. Ich habe schon genug Ärger am Hals.",
            "Ich hab nichts mitbekommen. Wirklich nicht.",
            "Hier redet keiner gern über solche Dinge. Ich auch nicht.",
            "Wenn ich irgendwas wüsste, würde ich's mir gut überlegen, wem ich es erzähle.",
            "Tut mir leid. Ich kümmere mich um meine Familie, nicht um bewaffnete Männer.",
            "Ich bin die meiste Zeit zu Hause. Von mir erfahrt ihr nichts Neues.",
            "Lasst mich bitte einfach weitergehen. Ich weiß nichts, was euch hilft."
        ],
        [
            "No idea what you're talking about. I stay out of that stuff.",
            "Don't ask me. I've got enough trouble as it is.",
            "I haven't noticed anything. I mean it.",
            "Nobody around here likes talking about that sort of thing. Neither do I.",
            "If I knew anything, I'd think twice about who I told.",
            "Sorry. I look after my family, not armed men.",
            "I'm home most of the time. I can't tell you anything new.",
            "Please just let me go. I don't know anything that would help you."
        ]
    ]],
    ["unsafe", [
        [
            "Nicht hier. Die hören doch alles mit.",
            "Seid ihr verrückt? Die stehen doch gleich da drüben!",
            "Ich hab Familie. Bitte geht einfach weiter.",
            "Ihr könnt wieder gehen. Ich will nicht, dass die uns zusammen sehen.",
            "Psst! Nicht so laut. Wollt ihr, dass ich Ärger kriege?",
            "Ich sag kein Wort, solange die hier herumlaufen.",
            "Bitte. Wenn die merken, dass ich mit euch rede, bin ich dran.",
            "Lasst mich in Ruhe. Ich hab schon gesehen, was mit Leuten passiert, die reden."
        ],
        [
            "Not here. They can hear everything.",
            "Are you crazy? They're right over there!",
            "I've got a family. Please, just move along.",
            "You need to leave. I don't want them seeing us together.",
            "Shh! Keep your voice down. Are you trying to get me in trouble?",
            "I'm not saying a word while they're still around.",
            "Please. If they see me talking to you, I'm the one who'll pay for it.",
            "Leave me alone. I've seen what happens to people who talk."
        ]
    ]],
    ["rumor", [
        [
            "In der Gegend sollen nachts öfter fremde Männer unterwegs sein. Mehr hab ich nicht gehört.",
            "Ein paar Leute reden von bewaffneten Männern irgendwo hier draußen. Ob das stimmt? Keine Ahnung.",
            "In letzter Zeit ist hier irgendwas los. Sobald man nachfragt, werden die Leute still.",
            "Mein Nachbar meint, er hätte nachts Fahrzeuge gehört. Hier draußen fährt sonst kaum jemand um die Zeit.",
            "Man erzählt sich, dass einige Männer in der Gegend ein und aus gehen. Niemand will wissen, warum.",
            "Ich würde mich hier draußen nicht zu lange aufhalten. Es gibt Gerüchte über Leute mit Waffen.",
            "Seit ein paar Tagen sind manche Leute ziemlich nervös. Irgendetwas stimmt hier nicht.",
            "Ein Händler hat erzählt, er hätte fremde Männer gesehen. Er wollte aber nicht sagen, wo genau."
        ],
        [
            "They say strange men have been moving around here at night. That's all I've heard.",
            "Some people are talking about armed men somewhere around here. No idea if it's true.",
            "Something's been going on around here lately. Ask about it and people go quiet.",
            "My neighbor says he heard vehicles at night. Hardly anyone drives around here that late.",
            "Word is some men have been coming and going around here. Nobody wants to know why.",
            "I wouldn't hang around out here too long. There are rumors about people carrying guns.",
            "People have been on edge these past few days. Something isn't right around here.",
            "A trader said he'd seen some unfamiliar men. Wouldn't say exactly where, though."
        ]
    ]],
    // A warning of a camp close by (ticket 3.6): the civilian describes what he saw, he does not say "camp"
    ["warning", [
        [
            "Fahrt da draußen nicht einfach weiter. Seit ein paar Tagen sitzen dort Bewaffnete, die nicht von hier sind.",
            "Ich war gestern am Feldrand. Da stehen Zelte und Männer mit Gewehren. Haltet euch fern, wenn euch euer Leben lieb ist.",
            "Passt auf, wo ihr hintretet. Ganz in der Nähe hat sich eine Gruppe Bewaffneter eingerichtet.",
            "Keiner von uns geht mehr in die Richtung. Dort haben sich Männer mit Waffen festgesetzt.",
            "Nachts sieht man dort Feuer. Das sind keine Hirten, das sind Bewaffnete. Ich an eurer Stelle würde einen Bogen machen.",
            "Ich sag's euch nur einmal: Hier in der Nähe lagern bewaffnete Männer. Sie beobachten die Straße.",
            "Meine Ziegen traue ich da nicht mehr hin. Seit die Fremden dort lagern, kommt keiner mehr zurück, der zu nah ran ist.",
            "Ihr seid nicht die Ersten, die hier vorbeikommen. Wenn ihr in diese Richtung geht, wartet dort jemand auf euch."
        ],
        [
            "Don't just keep driving out there. Armed men who aren't from here have been sitting out there for a few days.",
            "I was at the edge of the fields yesterday. There are tents and men with rifles. Stay away if you value your life.",
            "Watch where you step. A group of armed men has settled in very close to here.",
            "None of us go that way anymore. Men with guns have dug in over there.",
            "You can see fires there at night. Those aren't shepherds, they're armed men. I'd steer clear if I were you.",
            "I'll only say this once: there are armed men camped near here. They're watching the road.",
            "I won't take my goats there anymore. Since the strangers set up camp, nobody who goes too close comes back.",
            "You're not the first to come through here. If you go that way, someone will be waiting for you."
        ]
    ]]
];

// Answer sentences of a hint and of a tip by nest type: [level, [[nest type, [German sentences, English sentences]], ...]].
// The type only picks the sentences, the civilian never says it. The map symbol still shows it (COIN_intelMarkerTypes)
COIN_questionAnswersByType = [
    ["hint", [
        ["command", [
            [
                "Da treffen sich immer wieder dieselben bewaffneten Männer. Einer gibt die Anweisungen, die anderen hören zu.",
                "Ich habe da Leute mit Funkgeräten gesehen. Ständig kommen welche, melden sich und verschwinden wieder."
            ],
            [
                "The same armed men keep meeting there. One gives the orders, the others listen.",
                "I've seen men with radios around there. People keep showing up, reporting in, then leaving again."
            ]
        ]],
        ["iedWorkshop", [
            [
                "Wenn ihr mich fragt, basteln die da irgendwas zusammen. Überall liegen Kabel und alte Metallteile herum.",
                "Von dort hört man manchmal Hämmern und Sägen. Komisch nur, dass keiner sagen kann, was die eigentlich bauen."
            ],
            [
                "If you ask me, they're putting something together over there. Cables and scrap metal all over the place.",
                "Sometimes you can hear hammering and sawing from there. Funny thing is, nobody knows what they're building."
            ]
        ]],
        ["cache", [
            [
                "Da stehen immer wieder Männer mit schwerem Geschütz herum. Viel mehr, als man zum Bewachen von ein paar Häusern braucht.",
                "Ich hab gesehen, wie sie schwere Kisten abgeladen haben. Als einer zu nah kam, haben sie ihn sofort weggeschickt."
            ],
            [
                "There are always men around there carrying some serious firepower. More than you'd need to guard a few houses.",
                "I saw them unloading heavy crates. When someone got too close, they sent him away straight off."
            ]
        ]],
        ["vbiedGarage", [
            [
                "Die schrauben dort ständig an alten Autos herum. Die Wagen sehen danach aber nicht gerade fahrtüchtiger aus.",
                "Da verschwinden Fahrzeuge für Stunden hinter verschlossenen Türen. Nachts hört man oft Motoren laufen."
            ],
            [
                "They're always working on old cars over there. Can't say the cars look any more roadworthy afterward.",
                "Vehicles disappear behind closed doors for hours. You can often hear engines running at night."
            ]
        ]],
        ["recruitment", [
            [
                "Da tauchen ständig junge Kerle auf, die man vorher noch nie gesehen hat. Ein paar Tage später tragen sie Waffen.",
                "Ein paar Männer versprechen den Jungs dort Geld und eine Aufgabe. Manche kommen danach tagelang nicht nach Hause."
            ],
            [
                "Young lads nobody's seen before keep turning up there. A few days later, they're carrying guns.",
                "Some men there promise the young lads money and something to do. Some don't come home for days afterward."
            ]
        ]]
    ]],
    ["tip", [
        ["command", [
            [
                "Ich weiß, wo die Männer ihre Besprechungen abhalten. Ich hab sie dort schon mehrmals mit Karten und Funkgeräten gesehen.",
                "Ich kann euch die Gegend zeigen, wo ständig Boten ein und aus gehen. Einer scheint dort das Sagen zu haben."
            ],
            [
                "I know where those men hold their meetings. I've seen them there more than once with maps and radios.",
                "I can point you to the area where messengers keep coming and going. One man seems to be in charge there."
            ]
        ]],
        ["iedWorkshop", [
            [
                "Ich kenne die Stelle. Da tragen sie regelmäßig Kabel, Kanister und Metallstücke hinein. Das ist keine normale Werkstatt.",
                "Ich hab den Ort selbst gesehen. Die arbeiten dort hinter verschlossenen Türen und lassen niemanden in die Nähe."
            ],
            [
                "I know the spot. They regularly carry wires, canisters and bits of metal inside. That's no ordinary workshop.",
                "I've seen the place myself. They work behind closed doors and won't let anyone get close."
            ]
        ]],
        ["cache", [
            [
                "Ich hab gesehen, wo sie die schweren Kisten hinbringen. Bewaffnete stehen dort Wache, selbst wenn sonst niemand da ist.",
                "Ich kann euch zeigen, in welcher Gegend sie nachts ihre Ladung abladen. Da wird mehr bewacht als nur Essen und Wasser."
            ],
            [
                "I've seen where they take those heavy crates. Armed men guard the place even when nobody else is around.",
                "I can show you the area where they unload their cargo at night. They're guarding more than food and water."
            ]
        ]],
        ["vbiedGarage", [
            [
                "Ich weiß, wo die Autos hingebracht werden. Da wird stundenlang daran gearbeitet, und hinterher fährt ein anderer damit weg.",
                "Die Stelle kenne ich. Erst fahren kaputte Wagen hinein, später kommen sie mit verhängten Scheiben wieder raus."
            ],
            [
                "I know where they take the cars. They work on them for hours, then someone else drives them away.",
                "I know the place. Battered cars go in, then come back out with their windows covered."
            ]
        ]],
        ["recruitment", [
            [
                "Ich kann euch zeigen, wo sich die jungen Männer versammeln. Dort werden sie von Bewaffneten abgeholt.",
                "Ich weiß, wo sie die Neuen hinbestellen. Wer dort auftaucht, ist ein paar Tage später oft mit einer Waffe unterwegs."
            ],
            [
                "I can show you where the young men gather. Armed men come to collect them there.",
                "I know where they tell the new lads to show up. A few days later, most of them are walking around with guns."
            ]
        ]]
    ]]
];

// What the civilian says when the interpreter asks while his cooldown runs (ticket 3.5): he puts the interpreter off, [German sentences, English sentences]
COIN_cooldownAnswers = [
    [
        "Ich hab gesehen, wie ihr die anderen ausfragt. Kommt später wieder, dann reden wir vielleicht.",
        "Nicht jetzt. Hier sind zu viele Augen. Wartet ein bisschen.",
        "Gerade geht das nicht. Die Leute tuscheln schon über euch. Versucht es in ein paar Minuten noch mal.",
        "Mit mir redet ihr später. Wenn man uns jetzt zusammen sieht, merken sich das die Falschen.",
        "Ich will nicht der Nächste sein, den ihr hier vor allen ausfragt. Kommt später wieder.",
        "Lasst mir etwas Zeit. Ich muss erst sehen, ob uns jemand beobachtet.",
        "Es hat sich herumgesprochen, dass ihr Fragen stellt. Gebt der Sache einen Moment, dann reden wir.",
        "Jetzt nicht. Geht erst mal weiter und fragt mich später noch mal."
    ],
    [
        "I saw you questioning the others. Come back later, then maybe we'll talk.",
        "Not now. There are too many eyes here. Wait a little.",
        "I can't right now. People are already whispering about you. Try again in a few minutes.",
        "Talk to me later. If we're seen together now, the wrong people will remember it.",
        "I don't want to be the next one you question in front of everybody. Come back later.",
        "Give me a little time. I need to see first whether anyone is watching us.",
        "Word has got around that you're asking questions. Give it a moment, then we'll talk.",
        "Not now. Move along for a bit and ask me again later."
    ]
];

// Interrogation of prisoners (ticket 3.8, ADR 0011)
// Weights [nothing, rumor, hint, tip, warning, lie] of the first and of the second result: they do not depend on the reputation.
// The first result is never "nothing" while there is a nest to tell of, so its weight for "nothing" is 0.
COIN_interrogationWeights = [
    [ 0, 15, 30, 40,  7,  8],
    [25, 20, 25, 20,  5,  5]
];
COIN_interrogationSecondChance = 0.5;   // Chance of a second result

// What a prisoner says: [result, [German sentences, English sentences]], one is picked at random per result.
// A prisoner never names the nest type. "nothing" is the first result that could not be made (no nest, no camp to warn of)
COIN_interrogationAnswers = [
    ["nothing", [
        [
            "Ich sage nichts. Da könnt ihr fragen, solange ihr wollt.",
            "Ich weiß nichts, was euch weiterhilft. Ich habe nur Befehle befolgt.",
            "Mich hat niemand eingeweiht. Ich bin nur mitgelaufen.",
            "Ihr verschwendet eure Zeit. Von mir erfahrt ihr nichts."
        ],
        [
            "I'm not saying anything. Ask as long as you like.",
            "I don't know anything that would help you. I only followed orders.",
            "Nobody told me anything. I just went along.",
            "You're wasting your time. You won't get anything out of me."
        ]
    ]],
    ["rumor", [
        [
            "Ich bin nur ein kleines Licht. Irgendwo hier in der Gegend gibt es einen Treffpunkt. Mehr weiß ich nicht.",
            "Man hat uns gesagt, wohin wir gehen, nicht warum. Irgendwo hier draußen ist ein Versteck.",
            "Die Befehle kamen immer von weiter weg. Ich kenne die Richtung, nicht den Ort.",
            "Fragt die anderen. Ich weiß nur, dass wir nachts manchmal in diese Gegend gefahren sind."
        ],
        [
            "I'm just a small fish. There's a meeting place somewhere around here. That's all I know.",
            "They told us where to go, not why. There's a hideout somewhere out here.",
            "The orders always came from further away. I know the direction, not the place.",
            "Ask the others. All I know is that we sometimes drove out to this area at night."
        ]
    ]],
    ["hint", [
        [
            "Wir haben dort Nachschub abgeholt. Ein Gebäude, ein paar Wachen. Mehr hab ich nicht gesehen.",
            "Da draußen gibt es einen Ort, an dem sich unsere Leute sammeln. Ich kann ungefähr sagen, wo.",
            "Wenn ihr mich ordentlich behandelt: Es ist nicht weit von hier. Sucht in dieser Richtung.",
            "Ich war zweimal dort. Ich habe nicht darauf geachtet, wie wir gefahren sind, aber es war in dieser Gegend."
        ],
        [
            "We picked up supplies there. A building, a few guards. That's all I saw.",
            "There's a place out there where our people gather. I can tell you roughly where.",
            "If you treat me properly: it isn't far from here. Look in that direction.",
            "I was there twice. I didn't pay attention to how we drove, but it was in this area."
        ]
    ]],
    ["tip", [
        [
            "Gut, ich zeig's euch auf der Karte. Genau dort, wo die Straße abknickt. Ich war oft genug da.",
            "Ich hatte dort letzte Woche Wache. Ich kann euch den Platz fast auf den Meter zeigen.",
            "Ihr habt gewonnen. Es liegt ganz in der Nähe, und ich war dort. Ich sag euch, wo.",
            "Ich hab diese Nacht schon zu viel gesehen. Dort ist es, ganz genau dort."
        ],
        [
            "Fine, I'll show you on the map. Right where the road bends. I've been there often enough.",
            "I stood guard there last week. I can show you the spot almost to the meter.",
            "You've won. It's very close, and I was there. I'll tell you where.",
            "I've seen too much tonight already. It's there, right there."
        ]
    ]],
    ["warning", [
        [
            "Passt auf, da draußen sitzt noch eine Gruppe von uns. Die warten nur darauf, dass jemand vorbeikommt.",
            "In der Nähe lagert noch eine Einheit. Ihr lauft ihnen in die Arme, wenn ihr dem Weg folgt.",
            "Ihr seid nicht die Ersten, die hier suchen. Die anderen sind nicht weit und bewaffnet.",
            "Eine Gruppe hat sich dort eingegraben. Geht nicht zu nah ran, die schießen zuerst."
        ],
        [
            "Watch out, another group of ours is sitting out there. They're just waiting for someone to come by.",
            "Another unit is camped nearby. You'll walk right into them if you follow the road.",
            "You're not the first to search around here. The others aren't far, and they're armed.",
            "A group has dug in over there. Don't get too close, they shoot first."
        ]
    ]]
];

// What the prisoner says when the interpreter asks while his cooldown runs (ticket 3.5): [German sentences, English sentences]
COIN_interrogationCooldownAnswers = [
    [
        "Nicht so schnell. Ich muss erst nachdenken.",
        "Zu viele Fragen auf einmal. Kommt später wieder.",
        "Gebt mir einen Moment. Ich rede, aber nicht jetzt.",
        "Mir fällt gerade nichts ein. Lasst mich in Ruhe, dann reden wir später."
    ],
    [
        "Not so fast. I need to think first.",
        "Too many questions at once. Come back later.",
        "Give me a moment. I'll talk, but not now.",
        "Nothing comes to mind right now. Leave me be, then we'll talk later."
    ]
];

// Marker radius per intel level in m
COIN_intelRadiusRumor       = 600;
COIN_intelRadiusHint        = 300;
COIN_intelRadiusTip         = 100;
COIN_triangulationFactor    = 0.5;      // Each further true intel multiplies radius by this
COIN_intelRadiusMin         = 50;
COIN_intelCenterTries       = 24;       // Tries to place the smaller circle of a further true hit inside the old one
// Map symbol per nest type from a hint on: [type, marker type]. A rumor shows the neutral symbol
COIN_intelMarkerTypes = [
    ["command",      "o_hq"],
    ["iedWorkshop",  "o_maint"],
    ["cache",        "o_installation"],
    ["vbiedGarage",  "o_motor_inf"],
    ["recruitment",  "o_inf"]
];
COIN_intelMarkerNeutral     = "hd_unknown";

// Documents as ACE Intel Items that must be brought to the interpreter (decision E13)
COIN_documentsAsAceItems    = false;

// Outcome weights per reputation band: [nothing, rumor, hint, tip, warning, lie]
// Bands: see COIN_repBandMid / COIN_repBandHigh below.
COIN_intelWeightsLow        = [40, 15,  5,  0,  5, 35];
COIN_intelWeightsMid        = [30, 25, 20,  5, 10, 10];
COIN_intelWeightsHigh       = [20, 20, 30, 15, 12,  3];
COIN_intelWeightsByBand     = [["low", COIN_intelWeightsLow], ["mid", COIN_intelWeightsMid], ["high", COIN_intelWeightsHigh]];

// Warning of a camp (ticket 3.6): circle around an active camp, not saved, gone with the camp
COIN_warningRange           = 1500;     // m: a civilian warns of a camp within this distance of him, else he knows nothing
COIN_warningRadius          = 150;      // m radius of the circle; the camp lies inside, not in the middle (COIN_intelCenterOffset)
COIN_warningCheckInterval   = 10;       // s between two checks whether the camp of a warning is still there
COIN_warningMarkerType      = "hd_warning";
COIN_warningMarkerColor     = "ColorRed";   // Not the orange of the intel circles

// Lies (ticket 3.4, ADR 0021): the circle is built around a hidden fake point, the lie goes when it has been searched on foot
COIN_lieTownShare           = 0.5;      // Share of the fake points at the edge of a town (COIN_nestBuildingRing), the rest is open ground
COIN_lieSpotTries           = 40;       // Tries to find a fake point; without one the civilian knows nothing
COIN_lieSearchDistance      = 50;       // m: a player on foot this close to the fake point has searched the area
COIN_lieSearchInterval      = 3;        // s between two checks for searchers

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
