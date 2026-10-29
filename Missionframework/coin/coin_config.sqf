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
COIN_saveVersion            = 3;        // Bump when the persisted data format changes (2: intel, ADR 0021; 3: favors, ADR 0023)
COIN_loadableSaveVersions   = [1, 2, 3]; // Versions that load; older ones are converted (1 -> 2: empty intel list; 2 -> 3: no favors, stock 0 and counter 0)
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
COIN_capReadinessByNetwork  = true;     // Phase 6, ticket 6.6a (#152), ADR 0013, ADR 0025: active nests cap combat_readiness (server loop, no hook); off at runtime ends the loop
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
// Immediate combat_readiness drop when a nest is destroyed: [type, drop] (Phase 6, ticket 6.6b, #153, ADR 0013)
COIN_enableNestReadinessDrop = true;    // Off: a destroyed nest does not lower the readiness (the strike tasks still do)
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

// Old vehicles in counterattacks (ticket 6.2, #157, ADR 0014, E10, hook 34): every one beyond the limit becomes a technical of the list
COIN_enableOldVehicleLimit  = true;     // Off: no limit, only the weighting of the preset list decides
COIN_battlegroupOldVehicleMax = 1;      // Old vehicles per counterattack
COIN_battlegroupOldVehicleClasses = COIN_oldVehicleClasses + ["LOP_ISTS_OPF_BTR60"]; // The BTR-60 of the preset list is the ISTS twin of the nests' one
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
COIN_nestTypeNames = [                  // Nest type as the message names it: [type, key of the COIN package in stringtable.xml] (ADR 0026)
    ["command",      "STR_COIN_nestType_command"],
    ["iedWorkshop",  "STR_COIN_nestType_iedWorkshop"],
    ["cache",        "STR_COIN_nestType_cache"],
    ["vbiedGarage",  "STR_COIN_nestType_vbiedGarage"],
    ["recruitment",  "STR_COIN_nestType_recruitment"]
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

// Readiness cap by the network (ticket 6.6a, #152, ADR 0013, ADR 0025): cap = floor + (100 - floor) x network strength,
// switch COIN_capReadinessByNetwork. Full network 100 (no effect), 6 of 11 nests about 68, no nest left the floor
COIN_readinessCapFloor      = 30;       // Cap with no active nest left (25 until 2026-10-29). 30 is the lower bound of the armor mix (COIN_squadMixReadiness) and of the army squad type of the capital: below it Liberation sends only weak militia squads without armored twins
COIN_readinessCapSeconds    = 60;       // s between two checks of the server loop; Liberation's raises are pulled back within this time
COIN_readinessCapLogDrop    = 1;        // Points: smaller pull-backs (Liberation's 0.25 steps over time) are logged only with COIN_debug

// Staging areas (ticket 6.1a, #154, ADR 0025, CONTEXT.md: Aufmarschraum): where counterattacks, relief and mortar attacks
// come from: the influence radius of an active command post (COIN_nestSetup) and the surroundings of a military post the militia holds
COIN_enableStagingAreas     = true;     // Off: no staging areas; the callers of tickets 6.1b, 6.1c and 6.7a then leave Liberation's behaviour alone
COIN_stagingRadiusMilitary  = 3000;     // m around a military post held by the militia (a command post uses its influence radius)
COIN_enableStagingCounterattacks = true; // Ticket 6.1b, #155: counterattacks and random battlegroups start only at a spawn point in a staging area (hooks 31, 32); off = Liberation's spawn point choice
COIN_enableStagingRelief    = true;     // Ticket 6.1c, #156: relief for a militia sector under attack comes from the nearest staging area containing it, no paratroopers (hook 33); off = Liberation's radio towers (none on the map, so no relief)
COIN_stagingCheckSeconds    = 5;        // s between two checks for a change (nest destroyed, military post captured or lost)
COIN_stagingDebugColor      = "ColorKhaki"; // Debug map: circle and label of a staging area

// Mortar attack (ticket 6.7a, #158, DESIGN 9, CONTEXT.md: Mörserangriff): a small militia squad shells a FOB in a staging area
// while a player is there. Chance and cooldown are checked per FOB, at most one attack runs on the map. Cooldowns are not saved
COIN_enableMortarAttacks    = true;     // Off: no mortar attacks
COIN_mortarChance           = 0.15;     // Chance per check and eligible FOB
COIN_mortarCheckSeconds     = 600;      // s between two checks
COIN_mortarCooldownSeconds  = 2700;     // s a FOB is left alone after an attack
COIN_mortarFobPlayerRadius  = 300;      // m: a player this near the FOB is needed
// Light mortar: the first class that exists. Project OPFOR has no mortar for the Afghan Militia (OPFOR side classes), its M252
// of the Iraqi and Syrian army and the vanilla Mk6 serve as fallback
COIN_mortarClasses          = ["LOP_AA_Static_M252", "LOP_IA_Static_M252", "O_Mortar_01_F"];
COIN_mortarCrew             = 3;        // Militia fighters, the first one is the gunner
COIN_mortarDistance         = [1500, 2500]; // [min, max] m of the squad from the FOB
COIN_mortarSpotTries        = 80;       // Random points per pass (first only inside a staging area, then anywhere)
COIN_mortarMinNormalZ       = 0.97;     // Flat ground: z of the surface normal at least this (0.97 is about 14 degrees)
COIN_mortarMinDistPlayer    = 1000;     // m: no player nearer than this to the spot
COIN_mortarSightDistance    = 2500;     // m: no player within this with a line of sight to the spot
COIN_mortarClearRadius      = 10;       // m: no wall, house, fence or tree this close around the mortar (checked in 8 directions)
COIN_mortarClearHeights     = [0.5, 1.5, 3]; // m above the ground the clearance rays run at
COIN_mortarClearArc         = 40;       // m: length of the rays along the firing arc towards the FOB
COIN_mortarClearElevations  = [45, 60, 75]; // Degrees above the horizon of those rays (a mortar fires between 45 and 80)
COIN_mortarMinDistSector    = 300;      // m from a sector centre
COIN_mortarMinDistBase      = 500;      // m from the start base and every FOB
COIN_mortarSpread           = [150, 100, 50]; // One salvo per entry: radius in m around the FOB (the squad ranges in)
COIN_mortarRounds           = 4;        // Rounds per salvo
COIN_mortarStartDelay       = 20;       // s from the spawn to the first round
COIN_mortarRoundGap         = 5;        // s after a round before the next one
COIN_mortarSalvoGap         = 40;       // s between two salvos (time to take cover)
COIN_mortarFireTimeout      = 40;       // s to wait for a round before the salvo stops
COIN_mortarHoldSeconds      = 600;      // s the squad stays in position after the last salvo
COIN_mortarRemoveDistance   = 800;      // m: the squad is taken down when no player is nearer than this
COIN_mortarRemoveSeconds    = 30;       // s between two checks for players near the squad
COIN_mortarMarkerColor      = "ColorRed"; // Debug map: marker at the squad
// Getaway: after the hold time a squad that is still alive leaves in an unarmed car that stood behind the mortar. The gunner gets
// out, the squad drives away from the FOB and is taken down afterwards. Hold time 0 = it leaves right after the last salvo
COIN_enableMortarGetaway    = true;     // Off: no car, the squad is taken down in position
COIN_mortarCarClasses       = ["LOP_TKA_UAZ", "LOP_TKA_UAZ_Open", "O_G_Offroad_01_F"]; // First that exists, has no turret and enough seats; Takistan preset UAZ-3151
COIN_mortarCarDistance      = [8, 20];  // [min, max] m the car stands behind the mortar, seen from the FOB
COIN_mortarBoardSeconds     = 60;       // s the squad has to get into the car, then the rest is put in
COIN_mortarGetawayDistance  = 800;      // m from the mortar the car drives, away from the FOB
COIN_mortarDriveSeconds     = 300;      // s the drive may take at most
COIN_mortarGetawayOvershoot = 50;       // m the drive target lies beyond the distance, so the car passes it
COIN_mortarGetawayRoadRadius = 250;     // m around the target a road is looked for
COIN_mortarGetawaySafeRadius = 300;     // m around a target in water a dry spot is looked for
COIN_mortarCarFreeRadius    = 6;        // m around the chosen spot the car needs to be free
COIN_mortarCarAngles        = [0, 25, -25, 50, -50, 75, -75]; // Degrees off "straight behind" that are tried in turn
COIN_mortarCarHeadingJitter = 20;       // Degrees the heading of the car may differ from "away from the FOB"
COIN_mortarFobRadius        = 50;       // m: a FOB this near the remembered position is still that FOB
COIN_mortarClearDirections  = 8;        // Rays of the wall check around the mortar
COIN_mortarClearArcStart    = 1;        // m above the ground where the firing-arc rays start
COIN_mortarClearMaxHits     = 5;        // Surfaces a wall ray looks at (a terrain hit uses a slot)
COIN_mortarFailCooldownSeconds = 600;   // s a FOB is left alone after a failed attempt (no spot, no squad)
COIN_mortarActiveMaxSeconds = 2400;     // s after which the loop treats a running attack as stuck and frees the flag

// Message and circle after the first salvo (ticket 6.7b, #159): the squad lies in the circle, not in its middle (COIN_intelCenterOffset)
COIN_enableMortarMessage    = true;     // Off: no message "Mortar fire on FOB ..."
COIN_enableMortarCircle     = true;     // Off: no circle on the map
COIN_mortarCircleRadius     = 400;      // m
COIN_mortarCircleMarkerType = "hd_destroy"; // Own symbol, not the warning triangle
COIN_mortarCircleColor      = "ColorRed";

// Additional garrison of the capital (ticket 6.3a, #160, DESIGN 9): round (Liberation's infantry squads of the capital x factor x active nests)
// more squads when the capital is activated: 3 squads and 11 nests give 5, 5 nests give 2, no nest none. Liberation's own garrison is the minimum
COIN_enableCapitalGarrison  = true;     // Off: Liberation's garrison alone
COIN_capitalGarrisonFactor  = 0.15;
// Fixed heavy equipment of the capital, independent of caches (ticket 6.3b, #161, ADR 0014): manned like Liberation's sector vehicles,
// locked for players. Every activation spawns all of them again, destroyed or not: whoever lets the sector respawn pays the price
COIN_enableCapitalHeavy     = true;     // Off: no heavy equipment and no Igla gunners
COIN_capitalHeavyVehicles   = ["LOP_AM_OPF_T72BA", "LOP_AM_OPF_T72BA", "LOP_ISTS_OPF_ZSU234"];
COIN_capitalAAInfantry      = 3;        // Igla gunners on the highest building spots of the capital
COIN_capitalAAClasses       = ["LOP_AM_OPF_Infantry_AA", "LOP_TKA_Infantry_AA", "LOP_SLA_Infantry_AA"]; // First one that exists is used
COIN_capitalAARadius        = 150;      // m around the middle in which buildings are searched
COIN_capitalAASpacing       = 30;       // m the gunners keep apart

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
// Entry in the action menu (mouse wheel / space bar): key of the COIN package in stringtable.xml (ADR 0026)
COIN_askMilitiaLabel = "STR_COIN_talk_askMilitia";
COIN_interrogateLabel = "STR_COIN_talk_interrogate";
COIN_moodLabel = "STR_COIN_talk_mood";
COIN_elderLocateLabel = "STR_COIN_talk_elderLocate";
// Answers to "Where do I find the elder?" (ticket 5.9a): [found or none, [keys of the sentences]], one is picked at random.
// "found" while the elder is marked on the map, "none" if the town has no elder for now or he is too far away
COIN_elderLocateAnswers = [
    ["found", [
        "STR_COIN_locate_found_1",
        "STR_COIN_locate_found_2",
        "STR_COIN_locate_found_3"
    ]],
    ["none", [
        "STR_COIN_locate_none_1",
        "STR_COIN_locate_none_2",
        "STR_COIN_locate_none_3"
    ]]
];
// Answer sentences of a civilian (tickets 3.1 and 3.4): [result, [keys of the sentences]], one is picked at random.
// A civilian does not name the nest type: a hint or a tip knows the place better, not the word for it (see COIN_questionAnswersByType).
// "unsafe" is the refusal while enemies are close (COIN_enableUnsafeRefusal): no answer, no marker.
COIN_questionAnswers = [
    ["nothing", [
        "STR_COIN_answer_nothing_1",
        "STR_COIN_answer_nothing_2",
        "STR_COIN_answer_nothing_3",
        "STR_COIN_answer_nothing_4",
        "STR_COIN_answer_nothing_5",
        "STR_COIN_answer_nothing_6",
        "STR_COIN_answer_nothing_7",
        "STR_COIN_answer_nothing_8"
    ]],
    ["unsafe", [
        "STR_COIN_answer_unsafe_1",
        "STR_COIN_answer_unsafe_2",
        "STR_COIN_answer_unsafe_3",
        "STR_COIN_answer_unsafe_4",
        "STR_COIN_answer_unsafe_5",
        "STR_COIN_answer_unsafe_6",
        "STR_COIN_answer_unsafe_7",
        "STR_COIN_answer_unsafe_8"
    ]],
    ["rumor", [
        "STR_COIN_answer_rumor_1",
        "STR_COIN_answer_rumor_2",
        "STR_COIN_answer_rumor_3",
        "STR_COIN_answer_rumor_4",
        "STR_COIN_answer_rumor_5",
        "STR_COIN_answer_rumor_6",
        "STR_COIN_answer_rumor_7",
        "STR_COIN_answer_rumor_8"
    ]],
    // A warning of a camp close by (ticket 3.6): the civilian describes what he saw, he does not say "camp"
    ["warning", [
        "STR_COIN_answer_warning_1",
        "STR_COIN_answer_warning_2",
        "STR_COIN_answer_warning_3",
        "STR_COIN_answer_warning_4",
        "STR_COIN_answer_warning_5",
        "STR_COIN_answer_warning_6",
        "STR_COIN_answer_warning_7",
        "STR_COIN_answer_warning_8"
    ]],
    // A warning of an IED close by (ticket 4.8): he saw men dig by the road or heard a blast, he does not say "bomb" or "IED".
    // The same sentences for a real IED and a decoy, he cannot tell them apart. Texts to be agreed with Niklas
    ["warningIED", [
        "STR_COIN_answer_warningIED_1",
        "STR_COIN_answer_warningIED_2",
        "STR_COIN_answer_warningIED_3",
        "STR_COIN_answer_warningIED_4",
        "STR_COIN_answer_warningIED_5",
        "STR_COIN_answer_warningIED_6"
    ]],
    // A warning of an ambush (ticket 4.5): he saw armed men lie down by the road, he does not say "ambush". Texts to be agreed with Niklas
    ["warningAmbush", [
        "STR_COIN_answer_warningAmbush_1",
        "STR_COIN_answer_warningAmbush_2",
        "STR_COIN_answer_warningAmbush_3",
        "STR_COIN_answer_warningAmbush_4",
        "STR_COIN_answer_warningAmbush_5",
        "STR_COIN_answer_warningAmbush_6"
    ]]
];

// Answer sentences of a hint and of a tip by nest type: [level, [[nest type, [keys of the sentences]], ...]].
// The type only picks the sentences, the civilian never says it. The map symbol still shows it (COIN_intelMarkerTypes)
COIN_questionAnswersByType = [
    ["hint", [
        ["command", [
            "STR_COIN_answerType_hint_command_1",
            "STR_COIN_answerType_hint_command_2"
        ]],
        ["iedWorkshop", [
            "STR_COIN_answerType_hint_iedWorkshop_1",
            "STR_COIN_answerType_hint_iedWorkshop_2"
        ]],
        ["cache", [
            "STR_COIN_answerType_hint_cache_1",
            "STR_COIN_answerType_hint_cache_2"
        ]],
        ["vbiedGarage", [
            "STR_COIN_answerType_hint_vbiedGarage_1",
            "STR_COIN_answerType_hint_vbiedGarage_2"
        ]],
        ["recruitment", [
            "STR_COIN_answerType_hint_recruitment_1",
            "STR_COIN_answerType_hint_recruitment_2"
        ]]
    ]],
    ["tip", [
        ["command", [
            "STR_COIN_answerType_tip_command_1",
            "STR_COIN_answerType_tip_command_2"
        ]],
        ["iedWorkshop", [
            "STR_COIN_answerType_tip_iedWorkshop_1",
            "STR_COIN_answerType_tip_iedWorkshop_2"
        ]],
        ["cache", [
            "STR_COIN_answerType_tip_cache_1",
            "STR_COIN_answerType_tip_cache_2"
        ]],
        ["vbiedGarage", [
            "STR_COIN_answerType_tip_vbiedGarage_1",
            "STR_COIN_answerType_tip_vbiedGarage_2"
        ]],
        ["recruitment", [
            "STR_COIN_answerType_tip_recruitment_1",
            "STR_COIN_answerType_tip_recruitment_2"
        ]]
    ]]
];

// What the civilian says when the interpreter asks while his cooldown runs (ticket 3.5): he puts the interpreter off, a list of keys of the sentences
COIN_cooldownAnswers = [
    "STR_COIN_answer_cooldown_1",
    "STR_COIN_answer_cooldown_2",
    "STR_COIN_answer_cooldown_3",
    "STR_COIN_answer_cooldown_4",
    "STR_COIN_answer_cooldown_5",
    "STR_COIN_answer_cooldown_6",
    "STR_COIN_answer_cooldown_7",
    "STR_COIN_answer_cooldown_8"
];

// Interrogation of prisoners (ticket 3.8, ADR 0011)
// Weights [nothing, rumor, hint, tip, warning, lie] of the first and of the second result: they do not depend on the reputation.
// The first result is never "nothing" while there is a nest to tell of, so its weight for "nothing" is 0.
COIN_interrogationWeights = [
    [ 0, 15, 30, 40,  7,  8],
    [25, 20, 25, 20,  5,  5]
];
COIN_interrogationSecondChance = 0;     // Chance of a second result. 0 = exactly one result per interrogation (no double reward, decided 2026-10-29); the weights of the second result stay for a later change

// What a prisoner says: [result, [keys of the sentences]], one is picked at random per result.
// A prisoner never names the nest type. "nothing" is the first result that could not be made (no nest, no camp to warn of)
COIN_interrogationAnswers = [
    ["nothing", [
        "STR_COIN_interrogation_nothing_1",
        "STR_COIN_interrogation_nothing_2",
        "STR_COIN_interrogation_nothing_3",
        "STR_COIN_interrogation_nothing_4"
    ]],
    ["rumor", [
        "STR_COIN_interrogation_rumor_1",
        "STR_COIN_interrogation_rumor_2",
        "STR_COIN_interrogation_rumor_3",
        "STR_COIN_interrogation_rumor_4"
    ]],
    ["hint", [
        "STR_COIN_interrogation_hint_1",
        "STR_COIN_interrogation_hint_2",
        "STR_COIN_interrogation_hint_3",
        "STR_COIN_interrogation_hint_4"
    ]],
    ["tip", [
        "STR_COIN_interrogation_tip_1",
        "STR_COIN_interrogation_tip_2",
        "STR_COIN_interrogation_tip_3",
        "STR_COIN_interrogation_tip_4"
    ]],
    ["warning", [
        "STR_COIN_interrogation_warning_1",
        "STR_COIN_interrogation_warning_2",
        "STR_COIN_interrogation_warning_3",
        "STR_COIN_interrogation_warning_4"
    ]],
    // A warning of an IED (ticket 4.8): a prisoner of the militia knows about the roads. Texts to be agreed with Niklas
    ["warningIED", [
        "STR_COIN_interrogation_warningIED_1",
        "STR_COIN_interrogation_warningIED_2",
        "STR_COIN_interrogation_warningIED_3",
        "STR_COIN_interrogation_warningIED_4"
    ]],
    // A warning of an ambush (ticket 4.5): a prisoner of the militia was there or knows the plan. Texts to be agreed with Niklas
    ["warningAmbush", [
        "STR_COIN_interrogation_warningAmbush_1",
        "STR_COIN_interrogation_warningAmbush_2",
        "STR_COIN_interrogation_warningAmbush_3",
        "STR_COIN_interrogation_warningAmbush_4"
    ]]
];

// What the prisoner says when the interpreter asks while his cooldown runs (ticket 3.5): a list of keys of the sentences
COIN_interrogationCooldownAnswers = [
    "STR_COIN_interrogation_cooldown_1",
    "STR_COIN_interrogation_cooldown_2",
    "STR_COIN_interrogation_cooldown_3",
    "STR_COIN_interrogation_cooldown_4"
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
// [mood, [keys of the sentences]], one is picked at random. The rows are in the order of COIN_moodThresholds
// (hostile, suspicious, waiting, friendly, veryFriendly). They tell the mood, never a number and never the reason.
COIN_moodAnswers = [
    ["hostile", [
        "STR_COIN_mood_hostile_1",
        "STR_COIN_mood_hostile_2",
        "STR_COIN_mood_hostile_3",
        "STR_COIN_mood_hostile_4"
    ]],
    ["suspicious", [
        "STR_COIN_mood_suspicious_1",
        "STR_COIN_mood_suspicious_2",
        "STR_COIN_mood_suspicious_3",
        "STR_COIN_mood_suspicious_4"
    ]],
    ["waiting", [
        "STR_COIN_mood_waiting_1",
        "STR_COIN_mood_waiting_2",
        "STR_COIN_mood_waiting_3",
        "STR_COIN_mood_waiting_4"
    ]],
    ["friendly", [
        "STR_COIN_mood_friendly_1",
        "STR_COIN_mood_friendly_2",
        "STR_COIN_mood_friendly_3",
        "STR_COIN_mood_friendly_4"
    ]],
    ["veryFriendly", [
        "STR_COIN_mood_veryFriendly_1",
        "STR_COIN_mood_veryFriendly_2",
        "STR_COIN_mood_veryFriendly_3",
        "STR_COIN_mood_veryFriendly_4"
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
COIN_enableFavors           = true;     // Ticket 5.4: off = the counter does not run (stock and counter are kept and saved as they are). The favors are saved in the COIN block with the nests: with COIN_enableNests off they are not saved
COIN_favorRepThreshold      = 50;       // Favors grow from here on
COIN_favorGainMinutes       = 120;      // One favor per this many minutes of the counter (it runs above the threshold with at least one player online)
COIN_favorMaxStored         = 2;        // Most favors in stock (a full stock does not collect)
COIN_favorLossCooldownMin   = 60;       // Minutes the counter is thrown back if local fighters were wiped out (COIN_fnc_delayFavor)
COIN_favorTickSeconds       = 30;       // s between two steps of the counter (ticket 5.4)
COIN_favorIntelCost         = 10;       // Liberation intel points to redeem a favor (on top of the favor itself)
COIN_favorMinRep            = 25;       // A stored favor can be redeemed from here on (friendly resistance)

// The reinforcement (ticket 5.6, ADR 0012, ADR 0023): local fighters, Liberation's resistance in a group of their own
COIN_enableReinforcement    = true;     // Off: the elder offers no reinforcement (the favors still count up)
COIN_reinforcementSize      = 10;       // Local fighters per reinforcement
COIN_reinforcementLoadWeapons = true;   // Off: the fighters keep what Liberation gives them (empty weapons, often no magazines, its small vests)
COIN_reinforcementMagazines = 4;        // Reserve magazines of a fighter whose weapon is not in the preset rows of Liberation
COIN_reinforcementBackpack  = "B_FieldPack_cbr"; // Backpack for the magazines that do not fit into the uniform and vest (the one Liberation gives for the RPG)
COIN_reinforcementMaxMin    = 30;       // Group leaves after this time, counted from the moment the fighters appear (the walk counts)
COIN_reinforcementMaxDistance = 2500;   // m: the point the interpreter clicks is at most this far from the elder (the map shows it as a circle)
COIN_reinforcementArriveRadius = 50;    // m: the group has arrived when one fighter is this close to the point
COIN_reinforcementCheckSeconds = 5;     // s between two looks at a reinforcement (arrived, time, reputation, wiped out)
COIN_reinforcementHomeRadius = 40;      // m: the fighters that walk home have arrived this close to the elder's place
COIN_reinforcementReturnSeconds = 300;  // s the fighters get to walk home; then they go when nobody sees them, wherever they are
COIN_reinforcementMapZoom   = 0.3;      // Zoom of the map when the interpreter picks the point (the circle of COIN_reinforcementMaxDistance should fit)
COIN_reinforcementMapWaitSeconds = 2;   // s the map gets to open before the pick is given up

// Radio orders for the reinforcement (ticket 5.19, DESIGN 8.1, ADR 0023): items of the communication menu (0-8) while one is on its way
COIN_enableRadio            = true;     // Off: the reinforcement gets no orders, it walks to its point and holds it
COIN_radioRoles             = ["Kommandant", "Truppführer"]; // Role descriptions (start of it) that may give orders, the interpreters may too (for a test in another slot: player setVariable ["COIN_radioOrders", true, true])
COIN_radioFollowSeconds     = 10;       // s between two looks of a group that follows
COIN_radioFollowDistance    = 15;       // m behind the player the group that follows stops
COIN_radioFollowMove        = 5;        // m the point behind the player must have moved before the group gets a new waypoint
COIN_radioFollowRadius      = 5;        // m: completion radius of that waypoint
COIN_radioFollowRunDistance = 45;       // m: farther than this from the player the group that follows runs, closer it walks
COIN_radioAttackRadius      = 150;      // m: "Attack" searches and destroys in this radius around the middle of the town
COIN_radioAttackModes       = ["FULL", "AWARE", "RED", "COMBAT"]; // "Attack": speed and behaviour on the way, combat mode, behaviour of the search
COIN_radioContactRange       = 400;      // m: a fighter who knows an enemy this near reports contact
COIN_radioContactAge         = 30;       // s: an enemy seen this long ago still counts
COIN_radioFightSeconds      = 10;       // s: a fighter who fired or was hit this long ago means a firefight
COIN_radioQuietSeconds      = 60;       // s without an enemy and without a shot until contact and firefight are reported again
COIN_radioCasualtyShare     = 0.5;      // The reinforcement reports its losses when this share of the fighters or fewer are able to fight
COIN_radioCallsign = "STR_COIN_radio_callsign"; // How the answers of the radio start
// Answers to the one who gave the order: [key, key of the text]; %1 = point or town (grid), %2 = distance in m ("attack"); "arrived": the group has reached the point of "go there"; "contact", "firefight", "casualties" (%1 = grid, for the losses %1 = able to fight, %2 = fighters at the start) go to all who may give orders
COIN_radioReplyTexts = [
    ["follow", "STR_COIN_radio_follow"],
    ["goto", "STR_COIN_radio_goto"],
    ["attack", "STR_COIN_radio_attack"],
    ["arrived", "STR_COIN_radio_arrived"],
    ["contact", "STR_COIN_radio_contact"],
    ["firefight", "STR_COIN_radio_firefight"],
    ["casualties", "STR_COIN_radio_casualties"],
    ["no_target", "STR_COIN_radio_no_target"],
    ["refused", "STR_COIN_radio_refused"]
];
// The briefing in the map diary of the ones who may give orders, tab "COIN Liberation" : [key of the title, key of the text]
COIN_radioBriefing = ["STR_COIN_radio_briefingTitle", "STR_COIN_radio_briefingText"];

// Texts of the favor offer in the dialog of the elder, like COIN_aidTaskTexts: [id, key of the title, key of the explanation]
// Explanation: %1 = fighters, %2 = minutes, %3 = intel points, %4 = most distance from the elder in m, %5 = favors in stock, %6 = most in stock
COIN_favorOfferTexts = [
    ["reinforcement", "STR_COIN_favor_reinforcement_title", "STR_COIN_favor_reinforcement_explanation"]
];
// Hints while the interpreter picks the point on the map (ticket 5.6): [key, key of the text]
COIN_reinforcementPickTexts = [
    ["start", "STR_COIN_radioPick_start"],
    ["water", "STR_COIN_radioPick_water"],
    ["far", "STR_COIN_radioPick_far"],
    ["start_radio", "STR_COIN_radioPick_start_radio"],
    ["away", "STR_COIN_radioPick_away"]
];
// Messages to everybody (ticket 5.6): the classes coin_reinforcement_<key>_<en|de> of CfgNotifications.hpp, keys arrived, left_time, left_reputation, left_wiped

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

// Texts of the elder and the aid tasks are keys of the COIN package in stringtable.xml (ADR 0026, ticket 7.0b, #179), read on the client
// Entry in the action menu at the elder: key
COIN_helpLabel = "STR_COIN_elder_helpLabel";

// Dialog of the elder (ticket 5.9b): keys of the header, the accept button and the tasks line ("%1 of %2" = running, limit)
COIN_elderDialogTexts = [
    "STR_COIN_elder_dialogHeader",
    "STR_COIN_elder_dialogAccept",
    "STR_COIN_elder_dialogTasks"
];
// Sections of the list, in this order: [id, key of the title]. An offer belongs to one section (more come with later tickets)
COIN_elderSections = [
    ["aid", "STR_COIN_elder_section_aid"],
    ["secondary", "STR_COIN_elder_section_secondary"],
    ["favor", "STR_COIN_elder_section_favor"]
];
// Aid tasks: [id, key of the title, key of the explanation, key of the task text]
// Explanation in the dialog: %1 = time limit in minutes, %2 = distance in m, %3 = supplies of the crate, %4 = seconds of a repair, %5 = least distance of a device from the elder in m (no text uses it since ticket 5.21), %6 = place of the task: the village, else the town.
// Task text: %1 = town, %2 = minutes, %3 = distance in m, %4 = supplies, %5 = seconds of a repair, %6 = least distance in m.
// (A text may leave out what it does not need: "medical" uses only the time limit and the town.)
// The reward is named roughly, without a number (the reputation is hidden).
COIN_aidTaskTexts = [
    ["supplies", "STR_COIN_aid_supplies_title", "STR_COIN_aid_supplies_explanation", "STR_COIN_aid_supplies_task"],
    ["medical",  "STR_COIN_aid_medical_title",  "STR_COIN_aid_medical_explanation",  "STR_COIN_aid_medical_task"],
    ["repair",   "STR_COIN_aid_repair_title",   "STR_COIN_aid_repair_explanation",   "STR_COIN_aid_repair_task"]
];
// Why an offer is grey: [key, key of the text], %1 is the value named in the comment
COIN_aidReasonTexts = [
    ["town_running", "STR_COIN_aidReason_town_running"],   // no value
    ["town_wait",    "STR_COIN_aidReason_town_wait"],      // %1 = minutes left
    ["limit",        "STR_COIN_aidReason_limit"],          // %1 = limit
    ["no_ace",       "STR_COIN_aidReason_no_ace"],         // no value
    ["no_site",      "STR_COIN_aidReason_no_site"],        // no value (ticket 5.21)
    ["secondary_running", "STR_COIN_aidReason_secondary_running"], // no value (ticket 5.17)
    ["no_intel",     "STR_COIN_aidReason_no_intel"],       // %1 = cost (ticket 5.17)
    ["no_territory", "STR_COIN_aidReason_no_territory"],   // no value (ticket 5.17)
    ["reinforcement_running", "STR_COIN_aidReason_reinforcement_running"], // no value (ticket 5.6)
    ["reinforcement_rep",     "STR_COIN_aidReason_reinforcement_rep"],     // no value (ticket 5.6)
    ["no_favor",              "STR_COIN_aidReason_no_favor"]               // no value (ticket 5.6)
];
// What the elder says, one of the sentences is picked at random: [key, [keys of the sentences]]
COIN_elderSentences = [
    ["busy", ["STR_COIN_elderSay_busy_1", "STR_COIN_elderSay_busy_2"]],
    ["accepted", ["STR_COIN_elderSay_accepted_1", "STR_COIN_elderSay_accepted_2"]],
    // The reinforcement was sent (ticket 5.6). Texts to be agreed with Niklas
    ["reinforcement", ["STR_COIN_elderSay_reinforcement_1", "STR_COIN_elderSay_reinforcement_2"]],
    // Where an aid task plays (ticket 5.21), %1 = the village
    ["site", ["STR_COIN_elderSay_site_1", "STR_COIN_elderSay_site_2"]],
    // A warning after the "site" sentence when an ambush waits there (ticket 5.22): vague, no place, no kind of danger. Texts to be agreed with Niklas
    ["danger", ["STR_COIN_elderSay_danger_1", "STR_COIN_elderSay_danger_2"]],
    // What the one who tells of a strike task says (ticket 5.13, 5.14): the story of the offer, then the thanks after accepting. Texts to be agreed with Niklas
    ["strike_courier", ["STR_COIN_elderSay_strike_courier_1", "STR_COIN_elderSay_strike_courier_2"]],
    ["strike_leader", ["STR_COIN_elderSay_strike_leader_1", "STR_COIN_elderSay_strike_leader_2"]],
    ["strike_convoy", ["STR_COIN_elderSay_strike_convoy_1", "STR_COIN_elderSay_strike_convoy_2"]],
    ["strike_export", ["STR_COIN_elderSay_strike_export_1", "STR_COIN_elderSay_strike_export_2"]],
    ["strike_accepted", ["STR_COIN_elderSay_strike_accepted_1", "STR_COIN_elderSay_strike_accepted_2"]],
    ["refused", ["STR_COIN_elderSay_refused_1", "STR_COIN_elderSay_refused_2"]]
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
COIN_aidRepairLabel         = "STR_COIN_aid_repairLabel"; // Action at the device: key
COIN_aidRepairBarText       = "STR_COIN_aid_repairBar"; // Text of the progress bar: key

// Site of "Medical aid" and "Repair infrastructure" (ticket 5.20, ADR 0024): a village outside Liberation's sectors. The tasks play
// there (ticket 5.21); the choice of every town is written to the RPT at the start (ticket 5.20)
COIN_enableAidSites         = true;     // Off: no site is chosen, nothing is written to the RPT, the tasks play in the town as before
COIN_aidNoSitePlace         = "STR_COIN_aid_noSitePlace"; // Named in the explanation of an offer that is grey because no village is free (%6)
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
COIN_secondaryCostText = "STR_COIN_elder_secondaryCost";

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
            "Ein Kurier der Miliz fährt in einem Auto von einer Ortschaft zu einer anderen, mehrere Kilometer weit. Dort wartet er zwei Minuten und fährt zurück. Er hat Dokumente bei sich.<br/><br/>Stoppt das Auto (Fahrer ausschalten, gefangen nehmen oder das Auto fahrunfähig schießen), aber zerstört es nicht. Rechnet mit Widerstand. Durchsucht dann das Auto nach Dokumenten.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Das Auto kommt zurück zum Start oder brennt aus. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Dokumente nennen euch das Nest des Kuriers.</t>",
            "A courier of the militia drives a car from one town to another, several kilometres away. He waits there for two minutes and drives back. He carries documents.<br/><br/>Stop the car (kill the driver, capture him or shoot the car immobile), but do not destroy it. Expect resistance. Then search the car for documents.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: The car gets back to its start or burns out. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The documents name the courier's nest.</t>"
        ],
        [
            "Fangt den Kurier der Miliz ab: Er fährt von %1 nach %2, wartet dort kurz und fährt zurück. Beginn um %3 Uhr, spätestens bis %4 Uhr. Stoppt das Auto, zerstört es nicht und durchsucht es nach Dokumenten.",
            "Intercept the militia courier: he drives from %1 to %2, waits there for a while and drives back. Start at %3, no later than %4. Stop the car, do not destroy it and search it for documents."
        ]
    ],
    // A kind without a destination (the leader) names only the start: the village. %2 is not used
    ["leader",
        ["Anführer festnehmen", "Arrest leader"],
        [
            "Ein Anführer der Miliz hält sich in Zivilkleidung und unbewaffnet an einem Haus in einem Dorf auf. Er läuft nicht weg.<br/><br/>Rechnet mit Widerstand. Nehmt den Anführer lebend fest (Fesseln) und bringt ihn zu einer FOB. Stirbt er, ist der Auftrag verloren.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Der Anführer stirbt oder das Zeitfenster endet. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Miliz verliert an Schlagkraft, und sein Verhör nennt euch den Kommandoposten, zu dem er gehört.</t>",
            "A militia leader is staying at a house in a village, in civilian clothes and unarmed. He does not run away.<br/><br/>Expect resistance. Arrest the leader alive (handcuffs) and bring him to a FOB. If he dies, the task is lost.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: The leader dies or the time window ends. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The militia loses strength, and his interrogation names the command post he belongs to.</t>"
        ],
        [
            "Nehmt den Anführer der Miliz fest: Er hält sich in %1 an einem Haus auf, in Zivilkleidung. Beginn um %3 Uhr, spätestens bis %4 Uhr. Nehmt ihn lebend fest und bringt ihn zu einer FOB.",
            "Arrest the militia leader: he stays at a house in %1, in civilian clothes. Start at %3, no later than %4. Arrest him alive and bring him to a FOB."
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
            "Die Miliz will ein Flugzeug außer Landes bringen. Ein Zivilflugzeug steht auf der Piste eines Flugplatzes in der Nähe einer Ortschaft, die die Miliz hält. Es hebt nicht ab, aber ihr müsst es zerstören, bevor das Zeitfenster endet. Rechnet mit Widerstand.<br/><br/><t size='1.15' color='#00a0ff'>Beginn: %1 bis %2 Minuten nach dem Annehmen. Das Zeitfenster dauert insgesamt %3 bis %4 Minuten.</t><br/><t size='1.15' color='#ffa000'>Fehlschlag: Das Zeitfenster endet. Das Flugzeug verschwindet. Das kostet nichts.</t><br/><t size='1.15' color='#ffa000'>Belohnung: Die Miliz verliert an Schlagkraft.</t>",
            "The militia wants to get a plane out of the country. A civilian plane stands on the runway of an airfield near a town the militia holds. It does not take off, but you have to destroy it before the time window ends. Expect resistance.<br/><br/><t size='1.15' color='#00a0ff'>Start: %1 to %2 minutes after accepting. The time window lasts %3 to %4 minutes in all.</t><br/><t size='1.15' color='#ffa000'>Failure: The time window ends. The plane disappears. That costs nothing.</t><br/><t size='1.15' color='#ffa000'>Reward: The militia loses strength.</t>"
        ],
        [
            "Verhindert den Export der Miliz: Zerstört das Flugzeug auf dem Flugplatz %1. Beginn um %3 Uhr, spätestens bis %4 Uhr.",
            "Stop the militia export: destroy the plane at the airfield %1. Start at %3, no later than %4."
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
