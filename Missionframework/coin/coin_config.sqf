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
COIN_enableWarnings         = true;     // Phase 3, ticket 3.6: off = the weight of the warning counts as "nothing"; warnings already on the map stay until their threat is gone
COIN_enableVehicleSeizure    = true;     // Phase 5, ticket 5.1: getting into a civilian vehicle seizes it (Liberation's handler has a typo and never does); off = nothing is seized, as in Liberation
COIN_enableInformantTip     = true;     // Phase 3, ticket 3.10: off = Liberation's informant gives only his own reward, no tip (needs COIN_enableNests and COIN_enableQuestioning)
COIN_enableInterrogation    = true;     // Phase 3, ticket 3.8: off = no entry "Interrogate" at prisoners (needs COIN_enableQuestioning, its loop finds the prisoner)
COIN_enableMood             = true;     // Phase 5, ticket 5.3: off = no entry "How do you feel about us?" (needs COIN_enableQuestioning, its loop finds the civilian)
COIN_enableElderLocate      = true;     // Phase 5, ticket 5.9a: off = no entry "Where do I find the elder?" (needs COIN_enableQuestioning, COIN_enableMood and the elders)
COIN_enableInformantFrequency = true;   // Phase 5, ticket 5.2: off = Liberation's informant values stay (90-180 min, 75 %), whatever the reputation
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
COIN_enableReputationStart  = true;     // Phase 5, ADR 0009: a new campaign starts at COIN_reputationStart; off = 0 as in Liberation
COIN_disableBuildingPenalty  = true;     // Phase 5, ADR 0009, default of the lobby parameter "Disable Building Destruction penalty" (it wins): Liberation takes no reputation for houses that are gone when a town is taken (KP_liberation_cr_building_penalty = 0, the AI often destroys them); the gain for the capture stays
COIN_hideReputationNumber   = true;     // Phase 5, ADR 0009: no reputation display (number and icon) in the Liberation overlay
COIN_secondaryAtElder       = true;     // Phase 5, ADR 0023: Liberation's secondary missions start at the elder, not at a FOB

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
COIN_maxCivilians           = 30;       // Own civilians of the liberated towns (ticket 3.7): a town gets its population complete or not at all. Liberation's civilians do not count
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
// Own population of liberated towns (Phase 3, ticket 3.7, ADR 0011): Liberation has no civilians where the army holds
// the town. Spawn and removal use the distances above; the budget is COIN_maxCivilians
// ---------------------------------------------------------------------------
COIN_enablePopulation       = true;     // Off: no own civilians in liberated towns, the loop removes those that exist
COIN_populationCount        = [4, 8];   // [min, max] civilians per town, rolled at every spawn
COIN_populationRadius       = 80;       // m around the centre of the town (sector marker) where they appear
COIN_populationSpotClearance = 2;       // m a civilian keeps from objects when he is placed (BIS_fnc_findSafePos)
COIN_populationMaxGradient  = 0.5;      // Steepest ground he is placed on (BIS_fnc_findSafePos)

// ---------------------------------------------------------------------------
// The elder of a liberated town (Phase 5, ticket 5.9a, DESIGN 8): one per town, part of the own population above
// (spawns and goes with it, counts against COIN_maxCivilians), stands at a building near the centre
// ---------------------------------------------------------------------------
COIN_enableElder            = true;     // Off: no elders (and nothing for them to offer later)
COIN_elderAbsenceMinutes    = 60;       // min a town has no elder after his death; the first visit after that brings a new one (not saved)
COIN_elderSearchRadius      = 150;      // m around the centre of the town where his building is searched
COIN_elderBuildingKeywords  = ["mosque", "masjid"]; // A building whose class name contains one of these is preferred, else the house with the largest ground area
COIN_elderLocateRange       = 600;      // m: a civilian knows the elder of his town if he is within this distance of him
COIN_elderMarkerSeconds     = 300;      // s the elder is marked on the map for everybody after "Where do I find the elder?", asking again starts the time anew
COIN_elderMinBuildingArea   = 30;       // m2: smaller buildings (sheds, wall pieces) do not count
COIN_elderMinBuildingHeight = 2.5;      // m: lower ones do not either
COIN_elderSpotDistance      = [2, 6];   // [min, max] m he stands beyond half the longer side of the building (about from its wall)
COIN_elderNameFormat        = "Ältester von %1"; // %1 is the name of the town
// Clothes, one of each is picked; a class of a mod that is not loaded is left out (no error, he keeps his civilian look)
COIN_elderUniforms          = ["LOP_U_TAK_Civ_Fatigue_01", "LOP_U_TAK_Civ_Fatigue_02"];
COIN_elderHeadgear          = ["LOP_H_Turban"];

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
COIN_vbiedGarageVehicles    = ["CUP_C_Lada_GreenTK_CIV", "CUP_C_Lada_TK2_CIV", "CUP_C_LR_Transport_CTK", "CUP_C_SUV_TK", "CUP_C_UAZ_Unarmed_TK_CIV", "CUP_C_UAZ_Open_TK_CIV", "CUP_C_Volha_Blue_TKCIV", "CUP_C_Volha_Gray_TKCIV", "CUP_C_Volha_Limo_TKCIV", "CUP_C_S1203_CIV"]; // Cars of the civilian preset "Civilian Takistanis" (CUP): also the VBIED fleet (ticket 4.3)
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
COIN_moodLabel = ["Wie steht ihr zu uns?", "How do you feel about us?"];
COIN_elderLocateLabel = ["Wo finde ich den Ältesten?", "Where do I find the elder?"];
// Answers to "Where do I find the elder?" (ticket 5.9a): [found or none, [German sentences, English sentences]], one is picked at random.
// "found" while the elder is marked on the map, "none" if the town has no elder for now or he is too far away
COIN_elderLocateAnswers = [
    ["found", [
        [
            "Der Älteste? Ich zeige ihn euch, seht auf eure Karte.",
            "Ihr sucht den Ältesten? Er wartet an seinem Haus, ihr findet ihn.",
            "Den Ältesten kennt hier jeder. Ich habe euch den Weg eingezeichnet."
        ],
        [
            "The elder? I'll show you, look at your map.",
            "You're looking for the elder? He waits at his house, you'll find him.",
            "Everybody here knows the elder. I've marked the way for you."
        ]
    ]],
    ["none", [
        [
            "Einen Ältesten haben wir gerade nicht.",
            "Der Älteste? Der ist nicht mehr da. Fragt später noch einmal.",
            "Dazu kann ich euch nichts sagen. Hier gibt es im Moment keinen."
        ],
        [
            "We don't have an elder right now.",
            "The elder? He's gone. Ask again later.",
            "I can't tell you anything about that. There is none here at the moment."
        ]
    ]]
];
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
    ]],
    // A warning of an IED close by (ticket 4.8): he saw men dig by the road or heard a blast, he does not say "bomb" or "IED".
    // The same sentences for a real IED and a decoy, he cannot tell them apart. Texts to be agreed with Niklas
    ["warningIED", [
        [
            "Ich würde die Straße da vorn nicht nehmen. Letzte Nacht haben dort Männer etwas im Boden vergraben.",
            "Fahrt da nicht blind lang. Ich habe gesehen, wie jemand am Straßenrand gegraben hat, mitten in der Nacht.",
            "Seit ein paar Tagen ist die Erde an der Straße dort aufgewühlt. Mich bringt keiner mehr dorthin.",
            "Passt auf, wo ihr hinfahrt. Dort an der Straße ist etwas versteckt, das nicht für uns gedacht ist.",
            "Mein Cousin ist dort langgefahren und hat es gerade so überlebt. Sucht die Straße ab, bevor ihr weiterfahrt.",
            "Haltet die Augen offen. An der Straße ganz in der Nähe liegt etwas, und die Männer, die es gelegt haben, schauen zu."
        ],
        [
            "I wouldn't take the road up ahead. Men buried something in the ground there last night.",
            "Don't drive down there blind. I saw someone digging by the roadside in the middle of the night.",
            "The earth by the road over there has been churned up for a few days. Nobody gets me to go there anymore.",
            "Watch where you drive. Something is hidden by the road there, and it wasn't meant for us.",
            "My cousin drove down there and barely survived. Search the road before you go on.",
            "Keep your eyes open. There is something by the road very close to here, and the men who put it there are watching."
        ]
    ]],
    // A warning of an ambush (ticket 4.5): he saw armed men lie down by the road, he does not say "ambush". Texts to be agreed with Niklas
    ["warningAmbush", [
        [
            "Nehmt diese Straße nicht. Gestern Abend sind Bewaffnete dort in den Graben gekrochen und nicht wieder herausgekommen.",
            "Auf der Straße da vorn liegen Männer mit Gewehren am Rand. Ich habe sie gesehen, als ich meine Ziegen zurückgetrieben habe.",
            "Fahrt da nicht einfach durch. Am Straßenrand haben sich Männer eingegraben, und sie warten auf jemanden.",
            "Seit zwei Tagen bleibt jeder von uns von dieser Straße fern. Dort lauern Bewaffnete hinter Sandsäcken.",
            "Ich würde mich dort nicht blicken lassen. Wer die Straße entlangfährt, wird beschossen, hat mein Bruder gesagt.",
            "Dort an der Straße sitzen Männer und schauen jedem nach, der vorbeikommt. Ich weiß, was die vorhaben."
        ],
        [
            "Don't take that road. Armed men crawled into the ditch there yesterday evening and never came out.",
            "There are men with rifles lying by the side of the road up ahead. I saw them when I was driving my goats back.",
            "Don't just drive through. Men have dug in beside the road, and they're waiting for someone.",
            "For two days none of us has gone near that road. Armed men are lurking behind sandbags there.",
            "I wouldn't show my face there. My brother says anyone driving down that road gets shot at.",
            "Men are sitting by the road there, watching everyone who passes. I know what they're up to."
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
    ]],
    // A warning of an IED (ticket 4.8): a prisoner of the militia knows about the roads. Texts to be agreed with Niklas
    ["warningIED", [
        [
            "Fahrt nicht über die Straße da vorn. Wir haben dort etwas für euch hinterlassen.",
            "Auf dem Weg liegt eine Überraschung. Ich sage nicht, wo genau, aber seid vorsichtig.",
            "Bleibt von der Straße weg. Es ist nicht sicher, dort liegt etwas im Boden.",
            "Wenn ihr dem Weg folgt, geht es nicht lange gut. Die Straße ist vorbereitet."
        ],
        [
            "Don't drive down the road up ahead. We left something there for you.",
            "There's a surprise on the way. I won't say where exactly, but be careful.",
            "Stay off that road. It isn't safe, there's something in the ground.",
            "If you follow the road, it won't end well. It has been prepared."
        ]
    ]],
    // A warning of an ambush (ticket 4.5): a prisoner of the militia was there or knows the plan. Texts to be agreed with Niklas
    ["warningAmbush", [
        [
            "Fahrt nicht die Straße entlang. Dort liegen Männer im Graben und warten auf euch.",
            "Wir haben die Straße im Auge. Wer dort langkommt, läuft uns direkt vor die Gewehre.",
            "Bleibt von der Straße weg. Dort liegt eine Gruppe in Deckung, und sie schießen, sobald ihr nah genug seid.",
            "Ich war letzte Nacht dabei, als wir uns an der Straße eingegraben haben. Es wird kein Spaziergang."
        ],
        [
            "Don't drive along that road. Men are lying in the ditch there, waiting for you.",
            "We have the road covered. Anyone coming along it walks straight into our rifles.",
            "Stay off the road. A group is waiting in cover there, and they open fire as soon as you're close enough.",
            "I was there last night when we dug in by the road. It won't be a walk in the park."
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

// Outcome weights per reputation band: [nothing, rumor, hint, tip, warning, lie]
// Bands: see COIN_repBandMid / COIN_repBandHigh below.
COIN_intelWeightsLow        = [40, 15,  5,  0,  5, 35];
COIN_intelWeightsMid        = [30, 25, 20,  5, 10, 10];
COIN_intelWeightsHigh       = [20, 20, 30, 15, 12,  3];
COIN_intelWeightsByBand     = [["low", COIN_intelWeightsLow], ["mid", COIN_intelWeightsMid], ["high", COIN_intelWeightsHigh]];

// Warning of a threat (tickets 3.6, 4.8): [kind, range m, radius m, key of the answer sentences]. A civilian warns of a threat of this kind
// within the range of him (else he knows nothing); the circle has the radius, the threat lies inside, not in the middle
// (COIN_intelCenterOffset). Among all threats in range without a circle chance decides
COIN_warningKinds = [
    ["camp",   1500, 150, "warning"],
    ["ied",    1000, 100, "warningIED"],
    ["ambush", 1000, 150, "warningAmbush"]
];
COIN_enableIEDWarnings      = true;     // Phase 4, ticket 4.8: off = no warning of an IED is made, those on the map go at the next check
COIN_warningCheckInterval   = 10;       // s between two checks whether the threat of a warning is still there
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
COIN_iedTypes               = ["IEDLandBig_F", "IEDLandSmall_F", "IEDUrbanBig_F", "IEDUrbanSmall_F"]; // Vanilla IEDs, one at random (no "ultra strong" Bomb_04_F)
COIN_iedMaxRoadOffset       = 4;        // m: an IED lies on the road or at most this far beside it
COIN_iedRoadSearchRadius    = 50;       // m around a random point in the workshop's radius in which a road is looked for
COIN_iedPlaceAttempts       = 300;      // Random points tried per IED, none fits: error line, the IED is left out
COIN_iedMinDistBase         = 500;      // m between an IED and the start base or a FOB
COIN_iedMinDistSector       = COIN_nestMinDistSector; // m between an IED and every sector centre (the town core, Liberation's 175 m evaluation)
COIN_iedMinDistIED          = 300;      // m between two IEDs (of all workshops)
COIN_iedTriggerVehicleRadius = 8;       // m: a ground vehicle with a BLUFOR crew member this close sets an IED off
COIN_iedTriggerFootRadius   = 6;        // m: BLUFOR soldiers on foot this close set it off, if there are COIN_iedTriggerFootCount of them (civilians, militia, resistance and aircraft never do)
COIN_iedTriggerFootCount    = 2;        // Soldiers on foot needed within the radius. As in Liberation (2 or 3 there): a lone defuser can step up to a IED, a group cannot. ACE defusing needs a few metres, one soldier alone must stay safe
COIN_iedAlertDistance       = 300;      // m: an engine trigger around every IED; BLUFOR inside starts the exact check of this IED, nothing runs while there is none (as Liberation checks its IEDs only in active sectors)
COIN_iedTriggerCheckInterval = 2;       // s between two evaluations of that trigger by the engine (a vehicle at 100 km/h covers 56 m meanwhile, the radius is 300 m)
COIN_iedAlertInterval       = 0.2;      // s between two exact checks while the army is within the alert distance. A vehicle at 100 km/h (28 m/s) needs about 0.5 s through the trigger area of one IED, 1 s let fast ones pass (first test)
COIN_iedDebugColors         = [         // Debug map: icon colour per IED variant
    ["buried",       "ColorRed"],
    ["decoy",        "ColorYellow"],
    ["remote",       "ColorPink"]
];
COIN_enableIEDRegen         = true;     // Off: a used IED is not replaced
COIN_iedBudgetRegenMinutes  = 20;       // Minutes until a used IED (blown up, defused, deleted) is replaced by its workshop elsewhere. Not saved. No place or the cap reached: one more try after the same time
COIN_enableIEDLootRemoval   = true;     // Off: the item the game leaves when an IED is defused stays (a defusing is still recognised by it)
COIN_iedLootRadius          = 5;        // m around the IED in which that item is looked for
COIN_iedLootDelays          = [1, 4];   // s after the IED is gone (ascending): when the item is looked for, it appears a moment after the defusing. Runs after every removal, a blast leaves nothing to find (no item = not defused = no reputation)
COIN_enableIEDDecoys        = true;     // Off: all IEDs are real
COIN_iedDecoyChance         = 0.15;     // Share of decoys among all IEDs (DESIGN 6: 60 % buried, 25 % remote, 15 % decoy). A decoy counts to the budget, looks and is found like a real one, never goes off, defusing it gives no reputation
COIN_enableIEDRemote        = true;     // Off: no remote IEDs are laid (their share becomes buried IEDs), no triggermen. Ticket 4.2b
COIN_iedRemoteChance        = 0.25;     // Share of remote-triggered IEDs (with triggerman) among all IEDs, the rest of the 100 % is buried
COIN_iedRemoteRadius        = 15;       // m: the triggerman sets his IED off when BLUFOR (a vehicle or even a single soldier on foot) is this close to it
COIN_iedRemoteCount         = 1;        // BLUFOR soldiers on foot within that radius needed (one is enough: defusing a remote IED means dealing with its triggerman first)
COIN_triggermanSpawnDistance = 800;     // m: his triggerman appears when the nearest player is this close to a remote IED; he leaves like a nest guard (COIN_despawnDistance, COIN_despawnDelay)
COIN_triggermanDistance     = [60, 150]; // [min, max] m between the triggerman and his IED
COIN_triggermanSpotTries    = 60;       // Points tried for his place; none fits: error line, that IED has no triggerman (until the players were away)
COIN_triggermanTargetHeight = 0.5;      // m above the ground: where the line of sight to the IED ends
COIN_triggermanEyeHeight    = 1.6;      // m above the ground: where it starts (standing)
COIN_triggermanHouseShare   = 0.5;      // Share of the tries that look beside a house (he prefers one: DESIGN 6)
COIN_triggermanHouseOffset  = 3;        // m from the wall of the house (house taken as a circle) where such a try stands
COIN_triggermanHouseRadius  = 8;        // m from the wall: a spot this close counts as "beside a house" (a house or higher ground is worth more than open ground)
COIN_triggermanHeightGain   = 3;        // m higher than the IED counts as "elevated"
COIN_triggermanRoadClearance = 5;       // m he keeps from roads
COIN_triggermanHeadroom     = 6;        // m above him that must be free (no roof, no building over the spot)
COIN_triggermanGroundClearance = 0.3; // m above the ground where the check for a roof over his spot starts
COIN_triggermanPhone        = "Land_MobilePhone_smart_F"; // Held in his hand ("" or a class that does not exist: none)
COIN_triggermanIdleRadius   = 4;        // m: he walks around his spot within this radius, so he does not stand like a pillar (0 = stands still)
COIN_triggermanLeaveDistance = 250;     // m: once his IED is gone (blast, defused) a free triggerman walks this far away, then goes with the usual removal (0 = stays)
COIN_triggermanPhonePoint   = "righthand"; // Memory point of his body the phone is attached to
COIN_triggermanMarkerType   = "mil_dot"; // Debug map: him and a line to his IED
COIN_triggermanMarkerColor  = "ColorPink";

// VBIED (ticket 4.3, DESIGN 6): a civilian vehicle with a lone driver (fighter in civilian clothes) of an active garage
COIN_vbiedBudgetPerGarage   = 1;        // VBIEDs one garage has under way at the same time
COIN_vbiedCooldownMinutes   = 30;       // Minutes after a VBIED is used up (blown up, driver out, vehicle disabled, gone) until its garage sends the next. Not saved
COIN_vbiedCheckInterval     = 300;      // s between two rolls of a garage that is ready (target in its influence radius: a FOB or a player on foot or in a vehicle)
COIN_vbiedChance            = 0.25;     // Chance of a VBIED per roll (100 % for tests)
COIN_vbiedSpawnDistance     = [800, 1200]; // [min, max] m between the spawn point on a road and the target
COIN_vbiedSpawnTries        = 60;       // Points tried for the spawn point; none fits: log line, the garage tries again at the next roll
COIN_vbiedRoadSearchRadius  = 100;      // m around a tried point in which a road is looked for
COIN_vbiedMinPlayerDistance = 500;      // m: no player closer than this to the spawn point
COIN_vbiedSightDistance     = 1500;     // m: a player within this distance with a clear line of sight to the spawn point sees it (rejected)
COIN_vbiedSightHeight       = 1.5;      // m above the road where that line of sight ends (roof of a car)
COIN_vbiedTriggerDistance   = 10;       // m: the driver sets the charge off when his vehicle is this close to the target
COIN_vbiedYellSound         = "dmpYell2"; // CfgSounds class the driver shouts shortly before the blast: "Allahu Akbar" of Drongos Map Population ("dmpYell1" is the generic yell; without the mod or a class that does not exist he stays silent, no error)
COIN_vbiedYellDistance      = 60;       // m from the target at which he shouts, once (a car at 100 km/h covers that in about two seconds)
COIN_vbiedYellChance        = 1;        // Chance that he shouts at all (the suicide bomber of DESIGN 6 does so at 50 %)
COIN_vbiedYellRange         = 300;      // m: how far the shout can be heard
COIN_vbiedCharge            = "Bomb_03_F"; // Ammo class of the charge (stronger than a COIN_iedTypes IED), created at the vehicle when it goes off
COIN_vbiedCargo             = [["IEDLandBig_Remote_Mag", 1]]; // [magazine class, count] in the cargo of every VBIED: whoever searches it sees what it was (a class that does not exist is skipped)
COIN_vbiedTimeoutMinutes    = 15;       // Minutes after which a driver who has not reached the target disappears; he counts as used up
COIN_vbiedWatchInterval     = 0.25;     // s between two checks of a VBIED under way (a car at 100 km/h covers 7 m meanwhile, the trigger distance is 10 m)
COIN_vbiedRetargetDistance  = 30;       // m the target must have moved from the last destination before the driver is sent to its new position
COIN_vbiedMarkerInterval    = 2;        // s between two moves of its debug marker
COIN_vbiedProgressInterval  = 20;       // s between two log lines of a VBIED under way (position, distance, speed, engine): shows a car that does not drive
COIN_vbiedMarkerType        = "mil_triangle"; // Debug map: the VBIED under way
COIN_vbiedMarkerColor       = "ColorRed";

// Suicide bomber (ticket 4.4, DESIGN 6): a fighter in civilian clothes of an active IED workshop, who walks up to the nearest player
COIN_suicideBomberBudgetPerWorkshop = 1; // Bombers one workshop has under way at the same time
COIN_suicideBomberCooldownMinutes = 30; // Minutes after a bomber is used up (blown up, shot, captured, gone) until his workshop sends the next. Not saved
COIN_suicideBomberCheckInterval = 300;  // s between two rolls of a workshop that is ready (players on foot in its influence radius)
COIN_suicideBomberChances   = [         // Chance of a bomber per roll by reputation band (COIN_repBandMid, COIN_repBandHigh); 1 for tests
    ["low",  0.15],
    ["mid",  0.07],
    ["high", 0.02]
];
COIN_suicideBomberClasses   = [         // Clothing: coat and waistcoat variants of the Takistani civilians (CUP_TakiCivs); one at random, a class that does not exist is skipped
    "CUP_C_TK_Man_01_Coat", "CUP_C_TK_Man_03_Coat", "CUP_C_TK_Man_05_Coat", "CUP_C_TK_Man_06_Coat", "CUP_C_TK_Man_07_Coat",
    "CUP_C_TK_Man_01_Waist", "CUP_C_TK_Man_02_Waist", "CUP_C_TK_Man_03_Waist", "CUP_C_TK_Man_04_Waist",
    "CUP_C_TK_Man_05_Waist", "CUP_C_TK_Man_06_Waist", "CUP_C_TK_Man_07_Waist", "CUP_C_TK_Man_08_Waist"
];
COIN_suicideBomberSpawnDistance = [100, 200]; // [min, max] m between the spawn point and the target
COIN_suicideBomberSpawnTries = 60;      // Points tried for the spawn point; none fits: log line, the workshop tries again at the next roll
COIN_suicideBomberMinPlayerDistance = 80; // m: no player closer than this to the spawn point
COIN_suicideBomberSightDistance = 300;  // m: a player within this distance with a clear line of sight to the spawn point sees it (rejected)
COIN_suicideBomberSightHeight = 1.7;    // m above the ground where that line of sight ends (head of a man)
COIN_suicideBomberMaxSlope  = 0.9;      // Spawn point: z of the surface normal at least this (1 = flat)
COIN_suicideBomberHeadroom  = 6;        // m above the spawn point that must be free (no roof, no building over it)
COIN_suicideBomberGroundClearance = 0.3; // m above the ground where the check for a roof over the spawn point starts
COIN_suicideBomberBehaviour = "AWARE";  // Behaviour on his way (a "CARELESS" civilian only strolls)
COIN_suicideBomberSpeedMode = "FULL";   // Speed mode on his way
COIN_suicideBomberTriggerDistance = 5;  // m: the vest goes off when the nearest player is this close
COIN_suicideBomberShotChance = 0.3;     // Chance that the vest goes off when he is killed (0 and 1 for tests)
COIN_suicideBomberCharge    = "SatchelCharge_Remote_Ammo"; // Ammo class of the vest, created at the man when it goes off
COIN_suicideBomberYellSound = "dmpYell2"; // CfgSounds class he shouts shortly before the blast: "Allahu Akbar" of Drongos Map Population ("dmpYell1" is the generic yell; without the mod or a class that does not exist he stays silent, no error)
COIN_suicideBomberYellDistance = 20;    // m from the nearest player at which he shouts, once
COIN_suicideBomberYellChance = 0.5;     // Chance that he shouts at all
COIN_suicideBomberYellRange = 150;      // m: how far the shout can be heard
COIN_suicideBomberTimeoutMinutes = 10;  // Minutes after which a bomber who has not reached a player disappears; he counts as used up
COIN_suicideBomberWatchInterval = 0.25; // s between two checks of a bomber under way (a man at 7 m/s covers 1.75 m meanwhile, the trigger distance is 5 m)
COIN_suicideBomberRetargetDistance = 10; // m the nearest player must have moved from the last destination before the bomber is sent to the new position (a doMove every second keeps an AI from starting to walk)
COIN_suicideBomberMarkerInterval = 2;   // s between two moves of his debug marker
COIN_suicideBomberProgressInterval = 10; // s between two log lines of a bomber under way (position, distance, speed)
COIN_suicideBomberMarkerType = "mil_dot"; // Debug map: the bomber under way
COIN_suicideBomberMarkerColor = "ColorRed";

// Ambushes (ticket 4.5, DESIGN 6, ADR 0022): a camp can have one on the nearest road, fixed when the camp is created.
// Not saved, like the camps. The ambush spawns like a camp when a player comes near and its fighters count to the camp budget, all or none.
COIN_ambushChance           = 0.5;      // Chance that a new camp has an ambush
COIN_ambushDistance         = [200, 800]; // [min, max] m between the camp and its ambush (distance of the road segment to the camp)
COIN_ambushMinDistSector    = COIN_nestMinDistSector; // m between an ambush and every sector centre (not in the town core)
COIN_ambushMinDistBase      = 500;      // m between an ambush and the start base or a FOB
COIN_ambushMinDistAmbush    = 300;      // m between two ambushes
COIN_ambushRoadOffset       = [6, 12];  // [min, max] m between the edge of the road and the middle of the ambush
COIN_ambushMaxSlope         = 0.9;      // Z of the surface normal at least (1 = flat)
COIN_ambushFighters         = [4, 6];   // [min, max] fighters, fixed by the seed of the camp
COIN_ambushSpacing          = 4;        // m between two fighters along the road
COIN_ambushDepthJitter      = 3;        // m a fighter may stand nearer to or farther from the road than the middle line
COIN_ambushCoverCount       = [2, 4];   // [min, max] cover objects, each in front of a fighter (the road side), fixed by the seed
COIN_ambushCoverDistance    = 2;        // m between a fighter and the cover object in front of him
COIN_ambushCoverClasses     = [         // Cover objects, one at random each; a class that does not exist is left out (one log line)
    "Land_BagFence_Long_F", "Land_BagFence_Short_F", "Land_BagFence_Round_F", "Land_CncBarrierMedium_F", "Land_Tyres_F", "Land_WoodenBox_F"
];
COIN_ambushFireDistance     = 150;      // m: the fighters open fire when the army (BLUFOR, a vehicle counts by its crew) is this close
COIN_ambushWatchInterval    = 1;        // s between two checks of a spawned ambush (a vehicle at 100 km/h covers 28 m meanwhile)
COIN_ambushHoldFire         = "GREEN";  // Combat mode until they open fire: only defend themselves (a man shot at fires back at once)
COIN_ambushHideBehaviour    = "STEALTH"; // Behaviour of the group until they open fire
COIN_ambushHideStance       = "MIDDLE"; // Stance of a fighter until then (kneeling)
COIN_ambushFireBehaviour    = "COMBAT"; // Behaviour of the group after
COIN_ambushFireStance       = "AUTO";   // Stance of a fighter after (he chooses)
COIN_ambushFireMode         = "RED";    // Combat mode after: open fire at will
COIN_ambushMarkerType       = "mil_ambush"; // Debug map: the ambush (a line leads to its camp)
COIN_ambushMarkerSize       = 0.7;      // Size of the icon
COIN_ambushMarkerColor      = "ColorRed";
COIN_enableAmbushWarnings   = true;     // Off: no warning of an ambush is made, those on the map go at the next check

// ---------------------------------------------------------------------------
// Reputation (Phase 5), ADR 0009, ADR 0023, DESIGN 8
// Uses Liberation's civil reputation KP_liberation_civ_rep, scale -100 .. +100.
// Changes go through Liberation's F_cr_changeCR, without a message (in debug mode: system chat).
// Liberation already handles: civilian killed (-5),
// friendly resistance killed (-3), sector liberated (+5 / capital +10),
// wounded civilian treated (+2), informant delivered (+2),
// buildings destroyed at the moment of capture (-3 each).
// ---------------------------------------------------------------------------
COIN_reputationStart        = -20;      // Value for a new campaign (while COIN_enableReputationStart), a loaded save keeps its value
COIN_repBandMid             = 0;        // Band "mid" starts here (below: "low")
COIN_repBandHigh            = 25;       // Band "high" starts here (= Liberation informants, friendly resistance)
COIN_moodThresholds         = [-25, 0, 25, 50]; // Mood (ticket 5.3): below the first hostile, then suspicious, waiting, friendly, from the last very friendly

// What a civilian says when the interpreter asks "How do you feel about us?" (ticket 5.3, always true):
// [mood, [German sentences, English sentences]], one is picked at random. The rows are in the order of COIN_moodThresholds
// (hostile, suspicious, waiting, friendly, veryFriendly). They tell the mood, never a number and never the reason.
COIN_moodAnswers = [
    ["hostile", [
        [
            "Ehrlich? Die meisten hier wünschen euch weit weg. Ihr bringt nur Ärger.",
            "Wir haben euch nicht gerufen. Viele hier stehen lieber auf der Seite der Miliz.",
            "Geht besser, bevor jemand etwas Dummes tut. Hier traut euch keiner.",
            "Ihr habt zu viel kaputt gemacht. Von uns bekommt ihr nichts."
        ],
        [
            "Honestly? Most people here wish you were far away. You only bring trouble.",
            "We didn't call you. Many here would rather stand with the militia.",
            "You'd better leave before somebody does something stupid. Nobody here trusts you.",
            "You've broken too much. You'll get nothing from us."
        ]
    ]],
    ["suspicious", [
        [
            "Wir wissen noch nicht, was wir von euch halten sollen. Die Leute sind vorsichtig.",
            "Manche reden gut über euch, andere nicht. Glaubt nicht jedem, der euch etwas erzählt.",
            "Man beobachtet euch hier genau. Wer mit euch spricht, überlegt sich jedes Wort.",
            "Das Vertrauen ist dünn. Ein Fehler, und es ist weg."
        ],
        [
            "We don't know yet what to make of you. People are careful.",
            "Some speak well of you, others don't. Don't believe everyone who tells you something.",
            "You're watched closely here. Whoever talks to you weighs every word.",
            "Trust is thin. One mistake, and it's gone."
        ]
    ]],
    ["waiting", [
        [
            "Wir warten ab. Wenn ihr bleibt und euer Wort haltet, ändert sich vielleicht etwas.",
            "Niemand ist gegen euch, aber begeistert ist auch keiner. Zeigt, was ihr könnt.",
            "Es ist ruhiger geworden. Ob das bleibt, hängt von euch ab.",
            "Wir haben schon viele Soldaten kommen und gehen sehen. Beweist, dass ihr anders seid."
        ],
        [
            "We're waiting to see. If you stay and keep your word, maybe things will change.",
            "Nobody is against you, but nobody is thrilled either. Show what you can do.",
            "It has become calmer. Whether it stays that way is up to you.",
            "We've seen many soldiers come and go. Prove that you're different."
        ]
    ]],
    ["friendly", [
        [
            "Die meisten hier sind froh, dass ihr da seid. Man hilft euch, wo man kann.",
            "Ihr habt euch Respekt verdient. Die Leute reden gut über euch.",
            "Wir sind auf eurer Seite, so gut es geht. Sagt, wenn ihr etwas braucht.",
            "Seit ihr hier seid, geht es bergauf. Das merkt man."
        ],
        [
            "Most people here are glad you're here. They help you where they can.",
            "You've earned respect. People speak well of you.",
            "We're on your side as far as we can be. Tell us if you need something.",
            "Things have been looking up since you came. You can tell."
        ]
    ]],
    ["veryFriendly", [
        [
            "Ihr seid hier willkommen. Die Leute würden für euch ein Risiko eingehen.",
            "Für uns seid ihr keine Besatzer mehr, sondern Verbündete. Sagt, was ihr braucht.",
            "Wenn ihr ruft, kommen die Leute. So viel Vertrauen hatten wir lange nicht.",
            "Ihr habt unser Vertrauen. Jeder hier würde euch helfen."
        ],
        [
            "You're welcome here. People would take a risk for you.",
            "To us you're no longer occupiers but allies. Tell us what you need.",
            "When you call, people come. We haven't had this much trust in a long time.",
            "You have our trust. Everyone here would help you."
        ]
    ]]
];

COIN_repIEDDefused          = 2;        // Ticket 4.2a: a real IED defused (not a decoy, not one blown up), 0 = off
COIN_repNestDestroyed       = 5;        // Any nest type, once per nest (ticket 5.1), 0 = off
COIN_repCaptiveKilled       = -10;      // Ticket 5.1, 0 = off. Total for a prisoner; for Liberation's prisoners (civilian group) Liberation already takes -5, we take the rest
COIN_repCivVehicleSeized    = 0;        // Ticket 5.1: reputation for seizing a civilian vehicle (getting into it). Liberation means -2 (KP_liberation_cr_vehicle_penalty), COIN sets it to this value. A seized vehicle is ours: destroying it costs nothing
COIN_repCivVehicleDestroyed = -2;       // Ticket 5.1, 0 = off. Destroyed by the army; vehicles COIN made (COIN_isCoinVehicle: VBIED, garage vehicle, later task vehicles) and seized ones do not count

// Informants (ticket 5.2): Liberation's KP_liberation_civinfo_* by reputation; below COIN_repBandHigh Liberation sends none, from COIN_repBandHigh its values, from COIN_informantHighRep the faster ones
COIN_informantHighRep       = 50;       // From here the faster values apply
COIN_informantFastMinMax    = [2700, 5400]; // [min, max] s between two tries from COIN_informantHighRep (Liberation: 5400, 10800)
COIN_informantFastChance    = 100;      // Chance 0-100 from COIN_informantHighRep (Liberation: 75)
COIN_informantCheckSeconds  = 15;       // s between two looks at the reputation to pick the stage

// ---------------------------------------------------------------------------
// Favors at very high reputation (Phase 5, E12, ADR 0023): the only favor is the reinforcement
// ---------------------------------------------------------------------------
COIN_enableFavors           = true;
COIN_favorRepThreshold      = 50;       // Favors grow from here on
COIN_favorGainMinutes       = 120;      // One favor per this many minutes above the threshold, with at least one player online
COIN_favorMaxStored         = 2;
COIN_favorLossCooldownMin   = 60;       // Extra wait if local fighters were wiped out
COIN_favorIntelCost         = 10;       // Liberation intel points to redeem a favor (on top of the favor itself)
COIN_favorMinRep            = 25;       // A stored favor can be redeemed from here on (friendly resistance)

COIN_reinforcementSize      = 10;       // Local fighters per reinforcement
COIN_reinforcementMaxMin    = 30;       // Group leaves after this time

// ---------------------------------------------------------------------------
// Elder and tasks (Phase 5, DESIGN 8, 8.2) - not persisted; an aid task that fails (time over, elder dead) costs its reward
// ---------------------------------------------------------------------------
// COIN_elderAbsenceMinutes, COIN_enableElder and the rest of the elder: see the population section above (ticket 5.9a)

COIN_enableAidTasks         = true;
COIN_enableStrikeTasks      = true;

// Aid tasks, from the elder's dialog of a liberated town (any reputation band)
COIN_aidTaskMaxActive       = 2;        // Aid tasks active at the same time
COIN_aidTaskCooldownMin     = 60;       // Minutes a town waits after its aid task has ended
COIN_aidTaskTimeoutMin      = 60;       // Minutes to complete an accepted aid task
COIN_repAidSupplies         = 5;        // Reputation for delivering a supply crate
COIN_aidSupplyDistance      = 20;       // m from the elder the crate has to stand
COIN_aidSupplyMinValue      = 100;      // Supplies a crate holds to count (a Liberation supply crate from a FOB holds 100)
COIN_aidSupplyMaxHeight     = 1.5;      // m: the crate counts as standing on the ground up to this height above it (not carried, not hanging below a helicopter)
COIN_aidCheckSeconds        = 5;        // s between two looks at a running aid task
COIN_aidTaskEndShowSeconds  = 120;      // s a finished aid task stays in the task list
COIN_aidFailurePenaltyFactor = 1;       // An aid task that fails because the time is over or the elder died takes back this share of the reputation it could have given (1 = all of it, 0 = nothing); no penalty if the task was switched off, a device or patient was lost or none could be placed
COIN_aidTaskType            = "help";   // Icon of the task in the task list and on the map (BIS_fnc_taskCreate type)
COIN_aidImagePath           = "coin\res\secondary\%1.jpg"; // Picture of an aid task in the elder's dialog, %1 = its id (see coin/res/secondary/README.md); no file, no picture

// Entry in the action menu at the elder: [German, English]
COIN_helpLabel = ["Können wir helfen?", "Can we help?"];

// Dialog of the elder (ticket 5.9b): header, accept button, tasks line ("%1 of %2" = running, limit) as [German, English]
COIN_elderDialogTexts = [
    ["Ältester", "Elder"],
    ["Annehmen", "Accept"],
    ["Hilfsaufträge: %1 von %2", "Aid tasks: %1 of %2"]
];
// Sections of the list, in this order: [id, [German, English]]. An offer belongs to one section (more come with later tickets)
COIN_elderSections = [
    ["aid", ["Hilfsaufträge", "Aid tasks"]],
    ["secondary", ["Nebenmissionen", "Secondary missions"]]
];
// Aid tasks: [id, [title German, English], [explanation German, English], [task text German, English]]
// Explanation in the dialog: %1 = time limit in minutes, %2 = distance in m, %3 = supplies of the crate, %4 = seconds of a repair, %5 = least distance of a device from the elder in m (no text uses it since ticket 5.21), %6 = place of the task: the village, else the town.
// Task text: %1 = town, %2 = minutes, %3 = distance in m, %4 = supplies, %5 = seconds of a repair, %6 = least distance in m.
// (A text may leave out what it does not need: "medical" uses only the time limit and the town.)
// The reward is named roughly, without a number (the reputation is hidden).
COIN_aidTaskTexts = [
    ["supplies",
        ["Hilfsgüter liefern", "Deliver supplies"],
        [
            "Die Ortschaft braucht Nachschub.<br/><br/>Stellt eine Supply-Kiste mit %3 Supplies aus einer FOB am Boden ab, höchstens %2 m vom Ältesten entfernt. Die Kiste verschwindet dann. Jeder Spieler kann sie bringen.<br/><br/><t size='1.15' color='#00a0ff'>Zeitlimit: %1 Minuten. Läuft die Zeit ab, ist der Auftrag gescheitert.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Die Bevölkerung merkt sich, dass ihr euer Versprechen nicht gehalten habt.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Bevölkerung wird es euch danken.</t>",
            "The town needs supplies.<br/><br/>Put a supply crate with %3 supplies from a FOB on the ground, at most %2 m from the elder. The crate is then removed. Any player can bring it.<br/><br/><t size='1.15' color='#00a0ff'>Time limit: %1 minutes. If the time runs out the task has failed.</t><br/><t size='1.15' color='#ffa000'>Failure: The population will remember that you did not keep your promise.</t><br/><t size='1.15' color='#ffa000'>Reward: The population will be grateful.</t>"
        ],
        [
            "Stellt in %1 eine Supply-Kiste mit %4 Supplies am Boden ab, höchstens %3 m vom Ältesten entfernt. Zeitlimit: %2 Minuten.",
            "Put a supply crate with %4 supplies on the ground in %1, at most %3 m from the elder. Time limit: %2 minutes."
        ]
    ],
    ["medical",
        ["Arzt-Einsatz", "Medical aid"],
        [
            "In %6 gibt es Verletzte.<br/><br/>Behandelt die Patienten, sie liegen in den Kreisen auf der Karte. Jeder Spieler mit einer ACE-Bandage kann helfen, ein Sanitäter ist nicht nötig. Pro Patient wird eine Bandage verbraucht.<br/><br/><t size='1.15' color='#00a0ff'>Zeitlimit: %1 Minuten. Läuft die Zeit ab, ist der Auftrag gescheitert.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Die Bevölkerung merkt sich, dass ihr euer Versprechen nicht gehalten habt.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Bevölkerung wird es euch danken.</t>",
            "There are wounded in %6.<br/><br/>Treat the patients, they lie in the circles on the map. Any player with an ACE bandage can help, no medic needed. One bandage is used up per patient.<br/><br/><t size='1.15' color='#00a0ff'>Time limit: %1 minutes. If the time runs out the task has failed.</t><br/><t size='1.15' color='#ffa000'>Failure: The population will remember that you did not keep your promise.</t><br/><t size='1.15' color='#ffa000'>Reward: The population will be grateful.</t>"
        ],
        [
            "Behandelt die Verletzten in %1, sie liegen in den Kreisen auf der Karte. Pro Patient eine ACE-Bandage. Zeitlimit: %2 Minuten.",
            "Treat the wounded in %1, they lie in the circles on the map. One ACE bandage per patient. Time limit: %2 minutes."
        ]
    ],
    ["repair",
        ["Infrastruktur reparieren", "Repair infrastructure"],
        [
            "In %6 sind Generatoren beschädigt, sie rauchen.<br/><br/>Reparieren muss sie ein ACE-Pionier (Slot EOD) mit einem Werkzeugkasten. Eine Reparatur dauert %4 Sekunden, ihr könnt sie abbrechen und später neu beginnen.<br/><br/><t size='1.15' color='#00a0ff'>Zeitlimit: %1 Minuten. Läuft die Zeit ab, ist der Auftrag gescheitert.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Die Bevölkerung merkt sich, dass ihr euer Versprechen nicht gehalten habt.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Bevölkerung wird es euch danken.</t>",
            "Generators in %6 are damaged, they are smoking.<br/><br/>They can only be repaired by an ACE engineer (EOD slot) with a tool kit. A repair takes %4 seconds, you can cancel it and start again later.<br/><br/><t size='1.15' color='#00a0ff'>Time limit: %1 minutes. If the time runs out the task has failed.</t><br/><t size='1.15' color='#ffa000'>Failure: The population will remember that you did not keep your promise.</t><br/><t size='1.15' color='#ffa000'>Reward: The population will be grateful.</t>"
        ],
        [
            "Repariert die rauchenden Generatoren in %1 (ACE-Pionier mit Werkzeugkasten, %5 Sekunden je Gerät). Zeitlimit: %2 Minuten.",
            "Repair the smoking generators in %1 (ACE engineer with a tool kit, %5 seconds each). Time limit: %2 minutes."
        ]
    ]
];
// Why an offer is grey: [key, [German, English]], %1 is the value named in the comment
COIN_aidReasonTexts = [
    ["town_running", ["In dieser Ortschaft läuft schon ein Hilfsauftrag.", "This town has an aid task running already."]],   // no value
    ["town_wait",    ["Die Ortschaft braucht erst in etwa %1 Minuten wieder Hilfe.", "The town needs help again in about %1 minutes."]], // %1 = minutes left
    ["limit",        ["Es laufen schon %1 Hilfsaufträge.", "%1 aid tasks are running already."]],                                        // %1 = limit
    ["no_ace",       ["Dieser Auftrag braucht ACE.", "This task needs ACE."]],                                                           // no value
    ["no_site",      ["Kein Dorf in der Nähe, das Hilfe braucht.", "No village nearby needs help."]],                                    // no value (ticket 5.21)
    ["secondary_running", ["Es läuft schon eine Nebenmission.", "A secondary mission is running already."]],                            // no value (ticket 5.17)
    ["no_intel",     ["Dafür fehlen Intel-Punkte (%1 nötig).", "Not enough intel points (%1 needed)."]],                                // %1 = cost (ticket 5.17)
    ["no_territory", ["Es ist nicht genug Feindgebiet für eine Nebenmission übrig.", "There is not enough enemy territory left for a mission."]] // no value (ticket 5.17)
];
// What the elder says, one is picked at random: [key, [German sentences, English sentences]]
COIN_elderSentences = [
    ["busy", [
        ["Wir brauchen gerade nichts. Kommt später wieder.", "Im Moment fehlt uns nichts. Kommt später noch einmal vorbei."],
        ["We don't need anything right now. Come back later.", "Nothing is missing at the moment. Come by again later."]
    ]],
    ["accepted", [
        ["Ich danke euch. Wir warten auf eure Hilfe.", "Das wird vielen hier helfen. Ich danke euch."],
        ["Thank you. We will wait for your help.", "This will help many people here. Thank you."]
    ]],
    // Where an aid task plays (ticket 5.21), %1 = the village
    ["site", [
        ["Im Nachbardorf %1 brauchen sie Hilfe.", "Im Nachbardorf %1 wartet man auf Hilfe."],
        ["In the neighbouring village %1 they need help.", "In the neighbouring village %1 they are waiting for help."]
    ]],
    // A warning after the "site" sentence when an ambush waits there (ticket 5.22): vague, no place, no kind of danger. Texts to be agreed with Niklas
    ["danger", [
        ["Seid vorsichtig. In letzter Zeit hat man dort Fremde gesehen.", "Gebt auf euch acht. Dort treiben sich neuerdings Leute herum, die niemand kennt."],
        ["Be careful. Strangers have been seen there lately.", "Watch yourselves. Lately people nobody knows have been hanging around there."]
    ]],
    // What the one who tells of a strike task says (ticket 5.13, 5.14): the story of the offer, then the thanks after accepting. Texts to be agreed with Niklas
    ["strike_courier", [
        ["Ich habe gehört, dass bald ein Kurier der Miliz mit ein paar bewaffneten Männern im Auto unterwegs ist. Er hat Papiere bei sich.", "Man erzählt sich, ein Bote der Miliz fahre bald mit Begleitschutz von Ort zu Ort. Er soll Dokumente tragen."],
        ["I heard a militia courier will soon be on the road in a car with a few armed men. He carries papers.", "People say a messenger of the militia will soon drive down the road with an escort. He is said to carry documents."]
    ]],
    ["strike_leader", [
        ["Einer von den Anführern der Miliz soll sich bald in einem Dorf in der Nähe aufhalten. Er trägt keine Uniform, aber er ist nie allein.", "Ich habe gehört, dass bald einer von ihren Anführern in einem Dorf übernachtet. Er ist wie wir gekleidet, aber ihm folgen viele Bewaffnete."],
        ["I heard one of the militia leaders will soon stay in a village nearby. He wears no uniform, but he is never alone.", "People say one of their leaders will soon spend a night in a village. He dresses like us, but a crowd of armed men follows him."]
    ]],
    ["strike_convoy", [
        ["Ich habe von zwei Punkten erfahren, die ein Waffentransport der Miliz bald passiert. Es sind ein Lastwagen und bewaffnete Wagen, und sie fahren nicht ohne Schutz.", "Man erzählt sich, dass ein Konvoi der Miliz mit Waffen bald an zwei Stellen vorbeikommt. Viele Männer fahren mit ihm."],
        ["I learned of two points that a militia arms transport will soon pass. They are a truck and armed vehicles, and they do not drive without protection.", "People say a militia convoy with weapons will soon pass two places. Many men travel with it."]
    ]],
    ["strike_export", [
        ["Ich habe gehört, dass die Miliz bald auf einem Flugplatz ein Flugzeug bereitstellt, um etwas außer Landes zu bringen. Es steht auf der Piste und wird bewacht.", "Man erzählt sich, die Miliz wolle bald von einem Flugplatz aus etwas ausfliegen. Das Flugzeug steht bereit, und Bewaffnete passen darauf auf."],
        ["I heard the militia will soon have a plane ready at an airfield to get something out of the country. It stands on the runway and is guarded.", "People say the militia wants to fly something out from an airfield soon. The plane is ready, and armed men watch over it."]
    ]],
    ["strike_accepted", [
        ["Seid vorsichtig. Wenn ihr schnell seid, erwischt ihr ihn.", "Gut. Passt auf euch auf. Er wird nicht lange auf sich warten lassen."],
        ["Be careful. If you are quick, you will catch him.", "Good. Take care. He will not keep you waiting long."]
    ]],
    ["refused", [
        ["Das geht gerade nicht. Fragt später noch einmal.", "Jetzt nicht. Kommt bitte später wieder."],
        ["Not right now. Please ask again later.", "Not now. Please come back later."]
    ]]
];

// Aid task "Medical aid" (ticket 5.11): patients around the elder, wounded like Liberation's civilians after a town was taken
COIN_repAidPatient          = 1;        // Reputation per treated patient
COIN_repAidMedicalBonus     = 2;        // Bonus when all patients are treated in time
COIN_aidMedicalPatients     = [3, 5];   // [min, max] patients in a medical task
COIN_aidMedicalHurtDamage   = 0.5;      // Damage a patient gets (0-1); Liberation's wounded civilians have the same
COIN_aidMedicalTreatedAnim  = "AinjPpneMstpSnonWnonDnon_kneel"; // Animation of a healed patient before he stands up (as Liberation's)
COIN_aidMedicalStandUpSeconds = 2;      // s he kneels before the AI lets him stand up
COIN_aidMedicalHintSeconds  = 3;        // s the message "no bandage" stays
COIN_aidMedicalRadius       = [10, 40]; // [min, max] m from the centre of the village (without a site: from the elder's place) where a patient lies
COIN_aidMedicalSpacing      = 12;       // m the patients keep from each other (if the tries find room)
COIN_aidMedicalSpotTries    = 10;       // Tries to find a spot with that spacing for one patient
COIN_aidMedicalSpotClearance = 3;       // m a patient keeps from objects, so not inside a building (BIS_fnc_findSafePos)
COIN_aidMedicalMaxGradient  = 0.3;      // Steepest ground a patient lies on (BIS_fnc_findSafePos)
COIN_aidMedicalItems        = ["ACE_elasticBandage", "ACE_fieldDressing", "ACE_packingBandage", "ACE_quikclot"]; // One of them is used up per patient (the list of Liberation's action)
COIN_aidMedicalCircleSize   = 25;       // m radius of the circle on the map near a patient (as Liberation's)
COIN_aidMedicalCircleOffset = 20;       // m the circle's centre is off the patient, so the circle does not give his spot away
COIN_aidMedicalCircleAlpha  = 0.35;     // Transparency of the circle
COIN_aidSightDistance       = 150;      // m: at the end of a task what it made (patients, devices) goes when no player within this distance can see it
COIN_aidRemoveSeconds       = 600;      // s after which it goes even if somebody still sees it
COIN_aidSightHeight         = 1;        // m above its position the line of sight is checked to

// Aid task "Repair infrastructure" (ticket 5.12): smoking devices in the town, repaired by an ACE engineer with a tool kit
COIN_repAidRepair           = 4;        // Reputation when all devices are repaired (once, for all together)
COIN_aidRepairSeconds       = 30;       // s of the progress bar of one repair
COIN_aidRepairObjects       = [2, 3];   // [min, max] devices in a repair task
COIN_aidRepairSiteRadius    = [20, 100]; // [min, max] m from the centre of the village where a device stands (ticket 5.21, COIN_enableAidSites)
COIN_aidRepairRadius        = [50, 100]; // [min, max] m from the elder's place where a device stands (without a site) (the town; min = at least that far from the elder)
COIN_aidRepairSpacing       = 20;       // m the devices keep from each other
COIN_aidRepairSpotTries     = 10;       // Tries to find a spot for one device; none found, no device
COIN_aidRepairSpotClearance = 4;        // m a device keeps from other objects, so not in a house or against a wall (BIS_fnc_findSafePos)
COIN_aidRepairMaxGradient   = 0.3;      // Steepest ground a device stands on (BIS_fnc_findSafePos)
COIN_aidRepairRange         = 3;        // m from which the action "Repair" shows
COIN_aidRepairRangeMargin   = 1;        // m a player may be further away while the bar runs, and when the server checks the repair (walking, lag)
COIN_aidRepairClasses       = ["Land_Portable_generator_F", "Land_PortableGenerator_01_F"]; // Portable generators (a class that does not exist is left out); the windmill pump and the large generator were left out, the tall windmill could not be repaired in the test
COIN_aidRepairTools         = ["ToolKit"]; // One of these must be in the player's inventory (not used up)
COIN_aidRepairSmokeClass    = "test_EmptyObjectForSmoke"; // Smoke of a device, a global object (deleted when the device is repaired)
COIN_aidRepairSmokeHeight   = 0.5;      // m above the ground at the device where the smoke object stands
COIN_aidRepairLabel         = ["Reparieren", "Repair"]; // Action at the device: [German, English]
COIN_aidRepairBarText       = ["Repariere ...", "Repairing ..."]; // Text of the progress bar: [German, English]

// Site of "Medical aid" and "Repair infrastructure" (ticket 5.20, ADR 0024): a village outside Liberation's sectors. The tasks play
// there (ticket 5.21); the choice of every town is written to the RPT at the start (ticket 5.20)
COIN_enableAidSites         = true;     // Off: no site is chosen, nothing is written to the RPT, the tasks play in the town as before
COIN_aidNoSitePlace         = ["einem Nachbardorf", "a neighbouring village"]; // Named in the explanation of an offer that is grey because no village is free (%6)
COIN_siteTypes              = ["NameVillage", "NameLocal"]; // Map location types a site can be
COIN_siteMinHouses          = 6;        // Houses within COIN_siteHouseRadius, fewer is no village (a camp, a lone farm)
COIN_siteHouseRadius        = 150;      // m around the map label in which houses are counted; their middle is the village centre
COIN_siteHouseTypes         = ["BUILDING", "HOUSE", "CHURCH", "CHAPEL", "HOSPITAL"]; // Map object types (nearestTerrainObjects) that count as a house
COIN_siteExcludedLocations  = ["GreenCampBase", "IbanCampBase", "PelotonCampBase", "MartinFob", "MikisFob", "KindufFactory", "MozaratDeath", "FabianoCampBase", "BushlurkerCampBase", "Regimiento44base", "Reg44Norte", "PuestoCrow", "PuestoVulcan", "PuestoMate", "KindufHospital", "KalaenoowiHospital"]; // Names (the map label, not case sensitive) that are camps, military posts, hospitals, FOBs or factories the house filter does not catch; the RPT lists every label with its houses
COIN_siteMinSectorDistance  = 500;      // m from every town sector (Liberation's capture radius is 175 m); below about 300 m the liberated town itself would be chosen
COIN_siteMinOtherSectorDistance = 150;  // m from every factory, military post and tower (a village next to a factory is a village of its own)
COIN_siteMinEnemySectorDistance = 1200; // m from every sector the army has not liberated (Liberation activates a sector at 1000 m)
COIN_siteMaxDistance        = 3000;     // m from the town of the elder

// Ambush at the site (ticket 5.22, ADR 0024, DESIGN 8.2): "Medical aid" and "Repair infrastructure" in a village can meet the militia.
// Decided when the task is accepted: a nest (any type, state active) has the village in its influence radius, then the chance.
// Fighters in cover on the side of the elder's town, a few more hidden in houses of the village. Spawn, budget (camp budget,
// all or none), fire distance and the look of the ambush follow the ambushes of camps (COIN_ambush* above); not saved
COIN_enableAidAmbush        = true;     // Off: no danger at the site, the tasks stay safe
COIN_aidAmbushChance        = 0.75;     // Chance of the ambush when a nest has the village in range
COIN_aidAmbushDistance      = [100, 250]; // [min, max] m from the village centre to the ambush, towards the elder's town
COIN_aidAmbushArc           = 45;       // Degrees to either side of the direction of the elder's town
COIN_aidAmbushSpotTries     = 40;       // Tries to find a free place when no road gives one
COIN_aidAmbushHouseClearance = 15;      // m a free place keeps from houses
COIN_aidAmbushViewDistance  = 400;      // m from the village centre towards the town: a place is preferred that terrain hides from there
COIN_aidAmbushLookoutHeight = 2;        // m above the ground of the man out there ...
COIN_aidAmbushEyeHeight     = 1.5;      // ... and of a fighter in cover, for the line between them
COIN_aidAmbushFighters      = [4, 6];   // [min, max] fighters in cover
COIN_aidAmbushCoverCount    = [2, 4];   // [min, max] cover objects (COIN_ambushCoverClasses), at most one per fighter
COIN_aidAmbushHouseFighters = [2, 3];   // [min, max] fighters hidden in houses of the village (fewer if there are not enough houses)
COIN_aidAmbushHouseStance   = "UP";     // Stance of a fighter in a house until they open fire

// Liberation's secondary missions at the elder (ticket 5.17, ADR 0023, hooks 30): the interpreter starts them in the dialog of the
// elder, section "Secondary missions", with Liberation's cost in intel points and its rule of one at a time. Liberation's missions
// and server call stay as they are. FOB hunting stays off (COIN_disableFobHunting)
COIN_secondaryAtElder       = true;     // Off: Liberation's entry "Secondary missions" at a FOB and the start base as before, the elder offers none. Needs COIN_enableAidTasks and COIN_enableElder (the dialog)
// Offers: [id, Liberation's index (GRLIB_secondary_missions_costs, start_secondary_remote_call), stringtable key of the title, of the briefing, picture]
COIN_secondaryOffers = [
    ["convoy_hijack",    1, "STR_SECONDARY_MISSION1", "STR_SECONDARY_BRIEFING1", "res\secondary\convoy_hijack.jpg"],
    ["search_and_rescue", 2, "STR_SECONDARY_MISSION2", "STR_SECONDARY_BRIEFING2", "res\secondary\sar.jpg"]
];
// [min, max] m from the sectors and FOBs of the army in which an enemy spawn point must exist for a mission to start (Liberation's dialog: 2000, 999999)
COIN_secondaryTerritoryRange = [2000, 999999];
// Under the briefing (which names the cost itself): %1 = cost in intel points, %2 = intel points the army has
COIN_secondaryCostText = ["Ihr habt %2 Intel-Punkte.", "You have %2 intel points."];

// Strike tasks, created as a result of questioning or interrogation
COIN_strikeTaskChance       = 0.15;     // Chance per questioning (result other than "nothing") or interrogation
COIN_strikeTaskMinRep       = 25;       // No strike task below this reputation, interrogation too
COIN_strikeTaskMaxActive    = 1;
COIN_strikeTaskDelayMin     = [15, 25]; // Minutes from accepting until the event starts
COIN_strikeTaskDelayMinFast = [2, 5];   // The same when the strike task replaced the intel of a questioning (the window opens sooner)
COIN_strikeTaskWindowMin    = [45, 75]; // Time window in minutes, from accepting (the courier needs 30-40 min for the way there, the wait and the way back, the arms transport the same for its drive)
COIN_strikeReadinessLoss    = 10;       // Points of combat_readiness (0-100) for leader and export
COIN_strikeReadinessLossConvoy = 20;    // The same for the arms transport: a convoy hurts the militia more
COIN_strikeOfferSeconds     = 300;      // s the offer of a strike task can be accepted after the one who told of it has spoken
COIN_strikeDialogDelay      = 3;        // s between what he says and the dialog opens
COIN_strikeTaskType         = "search"; // Icon of the strike task in the task list and on the map (BIS_fnc_taskCreate type)
COIN_strikeMarkerStart      = ["mil_start", "ColorOrange"]; // Marker at the start of the route: [type, colour]
COIN_strikeMarkerEnd        = ["mil_end", "ColorOrange"];   // Marker at the destination
COIN_strikeCheckSeconds     = 2;        // s between two looks at a running strike task

// Kinds of strike task: [id, requirement, plan, run, extra, markers]. The requirement (a function, []) tells whether the kind can be offered now.
// The plan (called with []) is made when the task is accepted and returns [start position, start name, destination position,
// destination name, anything the run needs] or [] if there is none. The run (called with [plan, end time, task id, by]) starts at
// the beginning of the event and returns "succeeded" or the reason it failed ("time over", ...). Further kinds are added here.
// Optional: extra = a function (called with [plan, time of the beginning]) that returns texts added after the four every task text has;
// markers = [look of the start marker, look of the end marker] as [type, colour], else COIN_strikeMarkerStart and COIN_strikeMarkerEnd
COIN_strikeKinds = [
    ["courier", "COIN_fnc_canStrikeCourier", "COIN_fnc_planStrikeCourier", "COIN_fnc_runStrikeCourier"],
    ["leader", "COIN_fnc_canStrikeLeader", "COIN_fnc_planStrikeLeader", "COIN_fnc_runStrikeLeader"],
    ["convoy", "COIN_fnc_canStrikeConvoy", "COIN_fnc_planStrikeConvoy", "COIN_fnc_runStrikeConvoy", "COIN_fnc_strikeExtraConvoy", [["mil_ambush", "ColorRed"], ["mil_ambush", "ColorRed"]]],
    ["export", "COIN_fnc_canStrikeExport", "COIN_fnc_planStrikeExport", "COIN_fnc_runStrikeExport"]
];

// Dialog of a strike task (the one of the elder, ticket 5.9b): header, accept button, line "%1 of %2" = running, limit
COIN_strikeDialogTexts = [
    ["Gelegenheit", "Opportunity"],
    ["Annehmen", "Accept"],
    ["Zugriffsaufträge: %1 von %2", "Strike tasks: %1 of %2"]
];
COIN_strikeSections = [
    ["strike", ["Zugriffsauftrag", "Strike task"]]
];
// Strike tasks: [id, [title German, English], [explanation German, English], [task text German, English]]
// Explanation in the dialog: %1 = least minutes until the event starts, %2 = most, %3 = least minutes of the whole window, %4 = most.
// Task text: %1 = start, %2 = destination, %3 = time of day (game clock) of the beginning, %4 = time of day of the end.
// No reward is named in numbers; the reputation is hidden, and a strike task that fails or runs out costs nothing
COIN_strikeTaskTexts = [
    ["courier",
        ["Kurier abfangen", "Intercept courier"],
        [
            "Ein Kurier der Miliz fährt mit zwei bis drei bewaffneten Wachen in einem Auto von einer Ortschaft zu einer anderen, mehrere Kilometer weit. Dort wartet er zwei Minuten und fährt zurück. Er hat Dokumente bei sich.<br/><br/>Stoppt das Auto (Fahrer ausschalten, gefangen nehmen oder das Auto fahrunfähig schießen), aber zerstört es nicht. Rechnet mit Gegenwehr. Durchsucht dann das Auto nach Dokumenten.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Das Auto kommt zurück zum Start oder brennt aus. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Dokumente nennen euch das Nest des Kuriers.</t>",
            "A courier of the militia drives a car with two or three armed guards from one town to another, several kilometres away. He waits there for two minutes and drives back. He carries documents.<br/><br/>Stop the car (kill the driver, capture him or shoot the car immobile), but do not destroy it. Expect resistance. Then search the car for documents.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: The car gets back to its start or burns out. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The documents name the courier's nest.</t>"
        ],
        [
            "Fangt den Kurier der Miliz ab: Er fährt mit Wachen von %1 nach %2, wartet dort kurz und fährt zurück. Beginn um %3 Uhr, spätestens bis %4 Uhr. Stoppt das Auto, zerstört es nicht und durchsucht es nach Dokumenten.",
            "Intercept the militia courier: he drives with guards from %1 to %2, waits there for a while and drives back. Start at %3, no later than %4. Stop the car, do not destroy it and search it for documents."
        ]
    ],
    // A kind without a destination (the leader) names only the start: the village. %2 is not used
    ["leader",
        ["Anführer festnehmen", "Arrest leader"],
        [
            "Ein Anführer der Miliz hält sich in Zivilkleidung und unbewaffnet an einem Haus in einem Dorf auf. Er wird von acht bis zehn Männern bewacht, viele davon mit Weste und Helm. Er läuft nicht weg.<br/><br/>Schaltet die Wachen aus, nehmt den Anführer lebend fest (Fesseln) und bringt ihn zu einer FOB. Stirbt er, ist der Auftrag verloren.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Der Anführer stirbt oder das Zeitfenster endet. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Miliz verliert an Schlagkraft, und sein Verhör nennt euch den Kommandoposten, zu dem er gehört.</t>",
            "A militia leader is staying at a house in a village, in civilian clothes and unarmed. Eight to ten men guard him, many of them in vest and helmet. He does not run away.<br/><br/>Take out the guards, arrest the leader alive (handcuffs) and bring him to a FOB. If he dies, the task is lost.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: The leader dies or the time window ends. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The militia loses strength, and his interrogation names the command post he belongs to.</t>"
        ],
        [
            "Nehmt den Anführer der Miliz fest: Er hält sich in %1 an einem Haus auf, schwer bewacht, in Zivilkleidung. Beginn um %3 Uhr, spätestens bis %4 Uhr. Nehmt ihn lebend fest und bringt ihn zu einer FOB.",
            "Arrest the militia leader: he stays at a house in %1, heavily guarded, in civilian clothes. Start at %3, no later than %4. Arrest him alive and bring him to a FOB."
        ]
    ],
    // The arms transport names two points on its route, no start and no destination: %1 and %2 are the points (German and English), %3 and
    // %4 the beginning and the end as for every task, %5 to %8 the times of day in which the convoy passes point 1 (from, to) and point 2
    ["convoy",
        ["Waffentransport abfangen", "Intercept arms transport"],
        [
            "Ein Waffentransport der Miliz fährt über die Straße zu einem Waffenlager: zwei Technicals, ein Lastwagen und ein Wagen mit schwer gepanzerten Kämpfern. Ihr wisst nicht, woher er kommt und wohin er fährt, nur an welchen zwei Punkten und ungefähr wann er vorbeikommt.<br/><br/>Legt dort einen Hinterhalt, bevor ein Fahrzeug das Lager erreicht. Durchsucht den Laster nach den Lieferdokumenten. Zerstört anschließend alles und hinterlasst nur Wracks: Die Fahrzeuge müssen komplett zerstört werden, ein Fahrzeug, das nur steht, ausgeschaltet oder liegengeblieben ist, zählt nicht. Rechnet mit starker Gegenwehr.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Ein Fahrzeug erreicht das Lager, oder das Zeitfenster endet. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Miliz verliert stark an Schlagkraft. Nur wenn ihr vorher die Lieferdokumente findet, erfahrt ihr, wohin der Transport fuhr.</t>",
            "A militia arms transport drives along the road to a weapons cache: two technicals, a truck and a car with heavily armored fighters. You do not know where it comes from or where it goes, only the two points it passes and about when.<br/><br/>Set an ambush there before a vehicle reaches the cache. Search the truck for the delivery documents. Then destroy everything and leave nothing but wrecks: the vehicles must be destroyed completely, a vehicle that only stands, is disabled or broke down does not count. Expect strong resistance.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: A vehicle reaches the cache, or the time window ends. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The militia loses much strength. Only if you find the delivery documents first do you learn where the transport was going.</t>"
        ],
        [
            "Fangt den Waffentransport der Miliz ab: Er passiert Punkt 1 (%1) zwischen %5 und %6 Uhr und Punkt 2 (%2) zwischen %7 und %8 Uhr. Durchsucht den Laster nach den Lieferdokumenten. Zerstört anschließend alles und hinterlasst nur Wracks. Beginn um %3 Uhr, spätestens bis %4 Uhr.",
            "Intercept the militia arms transport: it passes point 1 (%1) between %5 and %6 and point 2 (%2) between %7 and %8. Search the truck for the delivery documents. Then destroy everything and leave nothing but wrecks. Start at %3, no later than %4."
        ]
    ],
    // A kind without a destination (the leader, the export) names only the start: here the airfield. %2 is not used
    ["export",
        ["Export verhindern", "Stop export"],
        [
            "Die Miliz will ein Flugzeug außer Landes bringen. Ein Zivilflugzeug steht auf der Piste eines Flugplatzes in der Nähe einer Ortschaft, die die Miliz hält, bewacht von acht bis zwölf Kämpfern, die zum Teil Streife gehen. Daneben stehen ein leerer Lastwagen und ein Technical: teure Ware. Es hebt nicht ab, aber ihr müsst es zerstören, bevor das Zeitfenster endet. Rechnet mit Gegenwehr.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Das Zeitfenster endet. Das Flugzeug verschwindet. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Miliz verliert an Schlagkraft.</t>",
            "The militia wants to get a plane out of the country. A civilian plane stands on the runway of an airfield near a town the militia holds, guarded by eight to twelve fighters, some of them on patrol. Beside it stand an empty truck and a technical: expensive goods. It does not take off, but you have to destroy it before the time window ends. Expect resistance.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: The time window ends. The plane disappears. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The militia loses strength.</t>"
        ],
        [
            "Verhindert den Export der Miliz: Zerstört das Flugzeug auf dem Flugplatz %1. Beginn um %3 Uhr, spätestens bis %4 Uhr. Das Flugzeug wird bewacht.",
            "Stop the militia export: destroy the plane at the airfield %1. Start at %3, no later than %4. The plane is guarded."
        ]
    ]
];

// Leader (ticket 5.15): in civilian clothes and unarmed beside a house of a village near his command post, guards around him. Arrested
// (handcuffed, ACE) and brought to a FOB alive, the readiness falls (COIN_strikeReadinessLoss) and his interrogation names the command post
COIN_leaderGuards           = [8, 10];  // [min, max] guards in the ring around him
COIN_leaderGuardArmorShare  = 0.5;      // At least this share of the guards are Islamic State twins (vest and helmet, ADR 0014); more at a high readiness (COIN_squadMixShare)
COIN_leaderGuardRing        = [6, 16];  // [min, max] m from the leader where a guard stands
COIN_leaderPatrolShare      = 0.4;      // Share of the guards that walk a patrol round the leader instead of standing in the ring
COIN_leaderPatrolRadius     = 75;       // m round the leader within which the patrol walks
COIN_strikePatrolPoints     = 5;        // Waypoints of the loop of a patrol of guards (COIN_fnc_startGuardPatrol: leader, export)
COIN_strikePatrolArrive     = 6;        // m from a waypoint at which a patrol goes on to the next
COIN_leaderBehaviour        = "AWARE";  // Behaviour of the guards; they stay where they stand until the group is in combat, then they fight as every group
COIN_leaderClasses          = [];       // Unit classes of the leader (his clothes), one at random; empty = a civilian of Liberation's preset like every civilian. Agreed with Niklas: first any civilian
COIN_leaderMinNestDistance  = 1000;     // m his village is at least from the command post he belongs to (so both are not on the same trip)
COIN_leaderVillageChoices   = 3;        // The village is one of this many nearest villages beyond that distance, at random
COIN_leaderSpotRadius       = 6;        // m beyond the wall of the house in which he stands (BIS_fnc_findSafePos)
COIN_leaderSpotClearance    = 2;        // m his spot keeps from other objects
COIN_leaderSpotGradient     = 0.3;      // Steepest ground for his spot
COIN_leaderSpotTries        = 10;       // Tries for a spot
COIN_strikeGuardTries      = 10;       // Tries for the place of a guard of a strike task (COIN_fnc_findGuardSpot: leader, export)
COIN_strikeGuardClearance  = 1.5;      // m a guard keeps from other objects (BIS_fnc_findSafePos)
COIN_strikeGuardGradient   = 0.3;      // Steepest ground for a guard
COIN_strikeGuardSpacing    = 3;        // m the guards keep from each other
COIN_strikeArmoredTries     = 10;       // Roles tried for a fighter in vest and helmet (a role without an Islamic State twin is picked again), leader guards and convoy
COIN_leaderFobRange         = 30;       // m from a FOB (Liberation's own distance for handing in a prisoner) at which a captive leader counts as brought
COIN_leaderKeepSeconds      = 900;      // s a captive leader stays after the task, so he can be interrogated

// Arms transport (ticket 5.16): a convoy drives from a town to a weapons cache on the road, starting wherever it is, whatever the players
// do. The task names two points on the route (not the start, not the cache) with the time in which the convoy passes; the players set
// an ambush. Success: every vehicle destroyed; failure: one vehicle reaches the cache, or the time window ends
COIN_convoyOrder            = ["technical", "car", "truck", "technical"]; // The convoy from front to back: technical (militia vehicle of the preset, with its crew), car (armored infantry), truck (the open ammo truck of the preset, loaded with ammo crates)
COIN_convoyCarPassengers    = 3;        // Armored fighters in the car besides the driver (fewer if the car has not so many seats); the cars are those of the courier
COIN_convoyBehaviour        = "SAFE";   // Behaviour of the group on the road; shot at, it fights as every group
COIN_convoyCombatMode       = "YELLOW"; // Combat mode of the group on the road
COIN_convoyFormation        = "FILE";   // Formation of the convoy (as in Liberation convoy hijack)
COIN_convoyFleeWhenAttacked = true;    // As in Liberation convoy hijack: a vehicle lost, damaged or without its driver, and the whole convoy flees
COIN_convoyAttackDamage    = 0.3;      // Damage (0 to 1) of a vehicle from which the convoy counts as attacked
COIN_convoyFleeBehaviour   = "COMBAT"; // Behaviour of the group on the flight
COIN_convoyFleeSpeed       = "FULL";   // Speed mode of the group on the flight
COIN_convoySettleSeconds   = 0.5;      // s the group has to settle after the crews joined it, before the leader and the waypoints are set
COIN_convoyBlockOtherDamage = true;    // As in Liberation convoy hijack: the vehicles take only damage of the players (civilian cars ram the convoy full speed otherwise)
COIN_convoyBlockedLogDamage = 0.1;     // Debug (COIN_debug): a blocked hit that would add more damage than this is written to the RPT
COIN_convoyBlockedLogMax   = 5;        // Debug: at most this many such lines per vehicle
COIN_convoyLoadCrates      = true;     // As in Liberation convoy hijack: the open truck is loaded with ammo crates (as many as it takes)
COIN_convoyCrateValue      = 100;      // Ammo in each crate (Liberation: 100)
COIN_convoyCrateWait       = 0.5;      // s Liberation waits before a crate is made and again before it is loaded (hijack mission)
COIN_convoySpawnWait       = 0.5;      // s after each vehicle of the convoy is made (Liberation hijack mission)
COIN_convoySpeedMode       = "LIMITED"; // Speed mode of the group on the road (until it flees: COIN_convoyFleeSpeed)
COIN_convoySearchSpeed     = 3;        // km/h below which a truck that is alive counts as standing: it can be searched for the delivery documents
COIN_convoySearchLabel     = ["Lieferdokumente suchen", "Search delivery documents"]; // Action at the truck: [German, English]
COIN_convoySearchBarText   = ["Suche Lieferdokumente ...", "Searching delivery documents ..."]; // Text of the progress bar: [German, English]
COIN_convoyFoundSpeaker    = ["Lieferdokumente", "Delivery documents"]; // Subtitle after the search: who, then the line
COIN_convoyFoundText       = ["Die Papiere nennen das Ziel des Transports. Ihr wisst jetzt, wohin er fuhr.", "The papers name where the transport was going. Now you know."];
COIN_convoySpacing          = 30;       // m between the vehicles at the start
COIN_convoyDistance         = [4000, 8000]; // [min, max] m in a straight line from the start town to the road end next to the cache
COIN_convoyRouteLength      = [6000, 10000]; // [min, max] m the route a car finds is long
COIN_convoyMaxDetour        = 1.8;      // The road may be this many times longer than the straight line
COIN_convoyPathTries        = 5;        // Routes tried at most (each takes up to COIN_strikePathTimeout s, the one who told of it waits for it)
COIN_convoyCacheRoadSearch  = 500;      // m around the cache in which the road for the end of the route is looked for (none: another cache)
COIN_convoyPointFractions   = [0.33, 0.66]; // Where on the route the two points of the task are, as a share of its length
COIN_convoyPointSearch      = 0.08;     // Share of the route round such a fraction in which a bridge or junction is looked for for the point
COIN_convoyPointMinCache    = 2000;     // m (straight line) the second point is at least from the cache, so the task does not give the cache away
COIN_convoyPointMinGap      = 1000;     // m along the route the two points are at least apart
COIN_convoyNameRadius       = 1500;     // m around a point in which the nearest place is looked for for its name
COIN_convoyPointNames       = [         // Name of a point by its kind (road, junction, bridge): [German, English], %1 = the nearest place
    ["Straße bei %1", "Road near %1"],
    ["Kreuzung bei %1", "Junction near %1"],
    ["Brücke bei %1", "Bridge near %1"]
];
COIN_convoyAverageKmh       = 30;       // km/h the convoy averages on the road, for the time windows (it drives slower than its limit; measured with the courier)
COIN_convoyWindowShare      = 0.3;      // Share of the time to a point that the window reaches to either side
COIN_convoyWindowMin        = 180;      // s the window reaches at least to either side
COIN_convoyWaypointSpacing  = 600;      // m between the waypoints along the route (few and far apart like Liberation convoy hijack, the cars find the road between them)
COIN_convoyWaypointRadius   = 50;       // m from a waypoint at which the convoy goes on to the next
COIN_convoyArriveDistance   = 150;      // m from the end of the route at which a vehicle has reached the cache
COIN_convoyPointNear        = 200;      // m from a point at which a vehicle counts as passing it (for the RPT)
COIN_convoyProgressSeconds  = 30;       // s between two lines in the RPT about the convoy (with COIN_debug)
COIN_convoyStuckSeconds     = 60;       // s the first vehicle with a driver has to stand (below COIN_convoyStuckSpeed) without a fight to count as stuck
COIN_convoyStuckSpeed       = 2;        // km/h
COIN_convoyStuckLimit       = 3;        // The convoy is sent on this many times; stuck once more, the task fails ("stuck")
COIN_convoyDebugMarker      = ["mil_triangle", "ColorRed"]; // Debug map (COIN_debug): the first vehicle of the convoy, follows it: [type, colour]

// Strike task "Export" (ticket 5.18): the airfields are listed by hand, the plane stands on the runway
COIN_exportAirfields        = [         // [name, position of the runway where the plane stands (ATL, [] = not set: the airfield is left out), direction of the plane]
    ["Kinduf Airport", [11032.1, 2871.17, 0], 225],
    ["Kinduf Airfield", [], 0],
    ["Kalae Airport", [12461.6, 17739.2, 0], 311]
];
COIN_exportTownRange        = 3000;     // m (straight line): the militia has to hold a town, the capital or a military post this near the airfield
COIN_exportPlaneClasses     = ["CUP_C_Cessna_CIV", "C_Plane_Civil_01_F"]; // The plane: the first class that exists
COIN_exportLockPlane        = true;     // The plane is locked: nobody can get in and fly away (it is to be destroyed)
COIN_exportGuards           = [8, 12];  // [min, max] guards at the plane (a share of them patrols)
COIN_exportGuardRing        = [8, 20];  // [min, max] m from the plane where a guard stands
COIN_exportPatrolShare     = 0.5;      // Share of the guards that walk a patrol round the plane instead of standing in the ring
COIN_exportPatrolRadius    = 60;       // m round the plane within which the patrol walks
COIN_exportVehicleDistance = 25;       // m from the plane (to the side of it) where the empty truck and the technical stand
COIN_exportVehicleSearch   = 20;       // m round that place in which a free place is looked for
COIN_exportBehaviour        = "AWARE";  // Behaviour of the guards; they stand until the group is in combat, then they fight as every group

// Courier (ticket 5.14): a car with the courier as driver and a few guards (the militia in uniform, no technical) drives like the convoy
// of Liberation's secondary mission, and starts anywhere on the map whatever the players do: from a town (one the militia holds if it
// can) to another town, held or not, waits there and drives back. Back at the start the task has failed
COIN_courierDistance        = [3000, 6000]; // [min, max] m in a straight line from the start town to the destination town
COIN_courierWaitSeconds     = 120;      // s the car waits at the destination before it drives back
COIN_courierMaxDetour       = 2;        // The road may be this many times longer than the straight line
COIN_courierPathTries       = 8;        // Pairs of towns tried for a route at most
COIN_strikePathTimeout       = 5;        // s the search for a route (courier, arms transport) may take
COIN_strikePathEndTolerance = 150;      // m the end of a route may be from the destination (else there is no route)
COIN_courierGuards          = [2, 3];   // [min, max] guards in the car besides the courier (fewer if the car has not so many seats)
COIN_courierBehaviour       = "SAFE";   // Behaviour of the group on the road; shot at, it fights as every group
COIN_strikeCarClasses        = COIN_vbiedGarageVehicles; // Cars he drives, one at random (a class that does not exist or has too few seats is left out)
COIN_courierSpeed           = 70;       // km/h he drives at most (on the winding roads he averages about half of it)
COIN_strikeRoadSearch      = 300;      // m around a town centre in which the road for the start and the end is looked for
COIN_strikeRoadClearance      = 8;        // m around the road piece of the start (and the destination) of a car that are free of other vehicles (a parked car blocks it)
COIN_courierMarker        = ["mil_triangle", "ColorOrange"]; // Debug map (COIN_debug): the courier's car, follows it: [type, colour]
COIN_strikeMarkerSeconds    = 2;        // s between two moves of that marker
COIN_courierStoppedSpeed    = 1;        // km/h below which the car with an unconscious driver counts as stopped
COIN_courierArriveDistance  = 120;      // m from the destination (or the start, on the way back) at which he has arrived
COIN_strikeRoadTypes          = ["MAIN ROAD", "ROAD", "TRACK", "TRAIL"]; // Road types for the start and the destination of a car, the first that is near wins (getRoadInfo)
COIN_courierProgressSeconds = 30;       // s between two lines in the RPT about the car (position, speed, distance to its goal)
COIN_courierStuckSeconds    = 45;       // s a car with a free courier has to stand (below COIN_courierStuckSpeed) to count as stuck
COIN_courierStuckSpeed      = 2;        // km/h
COIN_courierStuckDistance   = 500;      // m: a car that is stuck this close to its goal has arrived, farther away it is sent on again
COIN_courierStuckLimit      = 3;        // The car is sent on this many times; stuck once more, the task fails ("stuck")
COIN_strikePathWait          = 0.6;      // s the search for a route waits for further parts of the route after the first
COIN_courierRepathSeconds   = 30;       // s after which the order to drive to the destination is given again
COIN_searchRange     = 3;        // m from the car or truck (arms transport) from which the action "Search documents" shows
COIN_searchRangeMargin = 1;      // m a player may be further away when the server checks the search
COIN_searchSeconds   = 30;       // s of the progress bar of the search (ACE)
COIN_searchBarText   = ["Durchsuche ...", "Searching ..."]; // Text of the progress bar: [German, English]
COIN_searchLabel     = ["Dokumente durchsuchen", "Search documents"]; // Action at the car: [German, English]
COIN_courierFoundSpeaker    = ["Dokumente", "Documents"]; // Subtitle after the search: who, then the line
COIN_courierFoundText       = ["Die Papiere nennen Orte und Namen. Ihr wisst jetzt, woher der Kurier kam.", "The papers name places and people. Now you know where the courier came from."];

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
