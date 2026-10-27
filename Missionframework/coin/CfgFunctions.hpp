/*
    File: CfgFunctions.hpp
    Author: COIN Liberation

    Description:
        Registers all COIN_fnc_* functions.
        Included in description.ext inside class CfgFunctions (hook, see docs/hooks.md).
        File naming: coin\functions\<category>\fn_<name>.sqf -> COIN_fnc_<name>
*/

class COIN {
    class core {
        file = "coin\functions\core";

        // Gives a player unit the ACE abilities of its slot class (EOD repair, ACE medic)
        class applyRoleTraits {};

        // Server loop: colored shemag per faction (militia red, resistance green or blue)
        class markFactions {};

        // Share of armored Islamic State twins in militia squads by combat readiness (ADR 0014)
        class getSquadMixShare {};

        // Swaps one militia class for its Islamic State twin (hook 10 in spawn_battlegroup.sqf)
        class mixClass {};

        // Swaps a whole squad (hook 9 in KPLIB_fnc_getSquadComp)
        class mixSquad {};

        // Adds the twin classes to KPLIB_o_inf_classes on every machine
        class registerSquadTwins {};

        // Client: diary tab "COIN Liberation" with the player-readable explanations
        class createDiary {};

        // May this class be bought now? Maximum alive and lock after purchase (ticket 1.9, ADR 0007)
        class vehicleLimitStatus {};

        // Server: purchase check, starts the lock or sends the buyer's placement back (hook 12 in build_remote_call.sqf)
        class vehicleLimitPurchase {};

        // Server: lifts the lock of a cancelled placement
        class vehicleLimitRelease {};

        // Client: cancels the placement after a denied purchase
        class vehicleLimitDeny {};

        // Client: reports a cancelled placement to the server (hook 13 in do_build.sqf)
        class vehicleLimitCancel {};

        // Server: balances the resource types among the supply points of a new campaign (hook 14 in synchronise_eco.sqf)
        class guaranteeResources {};

        // May this secondary mission be started? FOB hunting is switched off (ticket 2.12, hooks 15 and 16)
        class secondaryMissionStatus {};

        // Are Liberation's IEDs and town ambushes switched off? (ticket 4.7, hooks 22 and 23)
        class replacesLiberationThreats {};

        // Server loop: Liberation's enemy AI caps = COIN_maxEnemyAI x Unitcap + COIN units (ticket 2.13, ADR 0015)
        class aiBudget {};

        // Sets Liberation's three enemy AI caps on this machine (server loop and clients)
        class applyEnemyAICaps {};

        // Marks units spawned by COIN so the AI budget counts them
        class markCoinUnits {};

        // Number of living COIN units on the enemy side
        class countCoinUnits {};

        // May a camp with N fighters spawn now? All or nothing within COIN_maxCampAI
        class campFitsBudget {};

        // Entry point of the COIN module, runs on every machine at mission start
        class init {
            postInit = 1;
        };
    };

    class common {
        file = "coin\functions\common";

        // Row of a config table keyed by nest type (COIN_nestSetup, COIN_nestBuildingShare, ...)
        class findByType {};

        // Fighters among given objects who can still fight (tickets 2.10, 4.5): a camp or an ambush is cleared when none is left
        class getCapableFighters {};

        // Is this unit a prisoner (militia fighter, handcuffed or surrendered)? (tickets 3.8, 5.1)
        class isPrisoner {};

        // Reputation band of the population: "low", "mid" or "high" (ticket 3.4, ADR 0009)
        class getReputationBand {};

        // Server: makes COIN objects and units editable for every curator (Zeus)
        class addToCurators {};

        // Server loop: adds them again to curators created later
        class curatorSync {};

        // Repeatable random number from a saved seed (a nest looks the same on every visit)
        class seededRandom {};

        // Players and drones that make COIN content spawn nearby
        class getPresence {};

        // Half width and half length of an object (bounding box)
        class halfSize {};

        // Can Arma destroy objects of this class (core objects)?
        class isDestructible {};

        // Height of the floor below a spot (building floor or terrain)
        class getFloorASL {};

        // Sets an object down on the floor below it
        class snapToFloor {};

        // Is there room for an object at a spot (walls, placed objects, doors)?
        class isSpotFree {};
    };

    class debug {
        file = "coin\functions\debug";

        // Debug console: core object, props and vehicles of a nest type in a row, for tuning
        class debugNestContent {};

        // Debug console: building template of the house the player looks at, to the clipboard
        class exportNestTemplate {};

        // Debug console: terrain template around the centre arrow, to the clipboard (ADR 0020)
        class exportTerrainTemplate {};

        // Debug console: terrain nest of a type in front of the player, as a real one spawns
        class debugTerrainNest {};
    };

    class intel {
        file = "coin\functions\intel";

        // Client: finds out whether this player started in an interpreter slot, adds the action menu entry "Ask about the militia" (ticket 3.1)
        class initQuestioning {};

        // Client: the action menu entry "Ask about the militia", again after every respawn
        class addTalkAction {};

        // Client loop: the civilian the interpreter looks at and may question, stops him for a while
        class talkTargetLoop {};

        // Marks a player unit as interpreter from its slot, at start and after every respawn
        class applyInterpreter {};

        // May this interpreter question this civilian now? Client menu and server check
        class canQuestion {};

        // Where the civilian is local: stands still and watches the interpreter for a while
        class holdCivilian {};

        // Server: an interpreter asks a civilian about the militia (called by the client)
        class questionCivilian {};

        // Server: the active nest a civilian knows something about
        class pickIntelNest {};

        // Server: makes the intel record and its circle for a nest
        class createIntel {};

        // Server: a further true hit on a nest makes its circle smaller, sets the type symbol (ticket 3.3)
        class shrinkIntel {};

        // Server: draws the global map markers of one intel
        class drawIntelMarker {};

        // Server: takes the intel from the save (version 1 gets an empty list), draws it again (ticket 3.2)
        class loadIntel {};

        // Server: a true intel disappears with its destroyed nest (ticket 3.2)
        class removeIntelOfNest {};

        // Server: removes one intel and its map markers
        class removeIntel {};

        // Server: armed enemies close to a civilian, so he refuses to talk (ticket 3.4)
        class isUnsafe {};

        // Server: makes a lie, a circle around a hidden fake point that looks like a true one (ticket 3.4)
        class createLie {};

        // Server: a place where a nest could plausibly be, for a lie
        class findFakeSpot {};

        // Server loop: a lie disappears when a player on foot has searched its fake point
        class intelSearchLoop {};

        // Server: everything a civilian can warn of: active camps, laid IEDs (ticket 4.8)
        class getWarnableThreats {};

        // Server: a warning, a circle around a threat close to the civilian: a camp or an IED (tickets 3.6, 4.8)
        class createWarning {};

        // Server loop: a warning disappears with its threat
        class warningLoop {};

        // Server: the concrete tip of Liberation's informant at the FOB (ticket 3.10, hook in civinfo_delivered.sqf)
        class informantTip {};

        // Server: an interpreter interrogates a prisoner (called by the client, ticket 3.8)
        class interrogatePrisoner {};

        // May this interpreter interrogate this prisoner now?
        class canInterrogate {};

        // Server: the nest a prisoner names, by where he comes from
        class pickInterrogationNest {};

        // Server: rolls one outcome by weights, with the gates for no nest and switched off lies and warnings
        class rollOutcome {};

        // Server: makes the intel of one outcome (true level, lie or warning)
        class resolveOutcome {};

        // Server: checks the cooldown of the interpreter and reserves his busy time before an answer
        class reserveAsking {};

        // Server: starts the cooldown after a marker, or ends the busy time
        class finishAsking {};

        // Start radius of an intel circle by its level
        class getIntelRadius {};

        // Middle of an intel circle around a nest or a fake point, never the point itself
        class offsetCenter {};

        // Client: the civilian's answer as a subtitle for the interpreter
        class showAnswer {};

        // Server: an interpreter asks a civilian "How do you feel about us?", the true mood goes to him (called by the client, ticket 5.3)
        class askMood {};

        // Client: the mood as a subtitle for the interpreter (ticket 5.3)
        class showMood {};

        // Server: an interpreter asks a civilian where the elder is, the elder is marked on the map for a while (ticket 5.9a)
        class askElder {};

        // Client: the answer to that as a subtitle for the interpreter (ticket 5.9a)
        class showElderLocation {};

        // Client: what a prisoner says, one sentence per result (ticket 3.8)
        class showInterrogation {};

        // Client: name and sentences as a subtitle
        class showSubtitle {};
    };

    class elder {
        file = "coin\functions\elder";

        // Server: an interpreter asks the elder "Can we help?", the offers go to him and open the dialog (ticket 5.9b)
        class askElderHelp {};

        // Server: what the elder offers now and why an offer is not possible, for the dialog and the check on accepting (ticket 5.9b)
        class getAidOffers {};

        // Client: the dialog of the elder, list, explanation, "Accept" (ticket 5.9b)
        class openElderDialog {};

        // Server: an interpreter accepts an offer, the aid task starts (tickets 5.9b and 5.10)
        class acceptElderOffer {};

        // Server: one aid task from start to end, success, time limit, reputation (ticket 5.10)
        class runAidTask {};

        // Server: the patients of the aid task "Medical aid", wounded, invulnerable, with a circle each (ticket 5.11)
        class spawnPatients {};

        // Client: the action "Treat" at a patient, like Liberation's (ticket 5.11)
        class addPatientAction {};

        // Server: heals a patient, ends his wait for treatment (ticket 5.11)
        class healPatient {};

        // Server: a patient is treated, healed, reputation (ticket 5.11)
        class treatPatient {};

        // Server: end of "Medical aid", patients stand up and go when nobody sees them (ticket 5.11)
        class releasePatients {};

        // Server: the devices of the aid task "Repair infrastructure", smoking, in the town (ticket 5.12)
        class spawnInfrastructure {};

        // Client: the action "Repair" at a device, ACE progress bar (ticket 5.12)
        class addRepairAction {};

        // Client and server: may this unit repair, ACE engineer with a tool kit (ticket 5.12)
        class canRepairInfrastructure {};

        // Server: a device was repaired by a player (ticket 5.12)
        class repairInfrastructure {};

        // Server: a device no longer waits for a repair, smoke off (ticket 5.12)
        class closeInfrastructure {};

        // Server: removes what an aid task made when nobody sees it (tickets 5.11, 5.12)
        class removeWhenUnseen {};

        // Client and server: do the elders offer Liberation's secondary missions instead of a FOB? Hook 30 asks it (ticket 5.17)
        class secondaryAtElder {};

        // Server: starts a secondary mission of Liberation that an interpreter accepted at the elder (ticket 5.17)
        class startSecondary {};

        // Server: the villages near a town with the reason each cannot be the site of an aid task (ticket 5.20)
        class rateSites {};

        // Server: the site of an aid task, the nearest village outside the sectors (ticket 5.20)
        class findSite {};

        // Server: writes the villages and the site of every town to the RPT (ticket 5.20)
        class logSites {};

        // Server: place for the ambush at the site, beside a road or on free ground on the side of the elder's town (ticket 5.22)
        class findSiteAmbushSpot {};

        // Server: is there an ambush at the site? Nest in range, chance, place, numbers (ticket 5.22)
        class planSiteAmbush {};

        // Server: spawns the fighters in cover and in houses, with cover objects (ticket 5.22)
        class spawnSiteAmbush {};

        // Server: life of the ambush at the site, spawn near players, budget, fire, removal (ticket 5.22)
        class runSiteAmbush {};

        // Client: the Arma task of an aid task, in the language of the player (tickets 5.9b and 5.10)
        class clientTask {};

        // Client: a sentence of the elder as a subtitle (ticket 5.9b)
        class showElderSentence {};
    };

    class strike {
        file = "coin\functions\strike";

        // Server: decides whether a strike task arises from a questioning or an interrogation, keeps the offer (ticket 5.13)
        class decideStrikeTask {};

        // Server: the one who spoke tells of the strike task, the dialog opens (ticket 5.13)
        class offerStrikeTask {};

        // Server: the interpreter accepts the offered strike task, it is planned and starts (ticket 5.13)
        class acceptStrikeTask {};

        // Server: one accepted strike task from start to end, task, markers, the event of its kind (ticket 5.13)
        class runStrikeTask {};

        // Server and client: time of day on the game clock some seconds from now, "HH:MM" (ticket 5.13)
        class clockText {};

        // Server: can the kind "Intercept courier" be offered now? An active nest (ticket 5.14)
        class canStrikeCourier {};

        // Server: two towns and the roads between them for the courier, made when accepted (ticket 5.14)
        class planStrikeCourier {};

        // Server: the event of the courier: car and driver, the drive, stopped, searched, arrived (ticket 5.14)
        class runStrikeCourier {};

        // Client: the action "Search documents" at the courier's car (ticket 5.14)
        class addSearchAction {};

        // Server: a player searches the stopped courier's car (ticket 5.14)
        class searchDocuments {};

        // Client: the subtitle after the search (ticket 5.14)
        class showDocumentsFound {};

        // Server: can the kind "Arrest leader" be offered now? An active command post (ticket 5.15)
        class canStrikeLeader {};

        // Server: the village and the house for the leader, made when accepted (ticket 5.15)
        class planStrikeLeader {};

        // Server: the event of the leader: him, his guards, arrested, brought to a FOB (ticket 5.15)
        class runStrikeLeader {};

        // Server: can the kind "Intercept arms transport" be offered now? An active weapons cache (ticket 5.16)
        class canStrikeConvoy {};

        // Server: cache, route, two points with time windows, vehicles at the start, made when accepted (ticket 5.16)
        class planStrikeConvoy {};

        // Server: the event of the convoy: vehicles, the drive along the route, destroyed, arrived (ticket 5.16)
        class runStrikeConvoy {};

        // Server: protects a vehicle of the arms transport from damage that does not come from the players (ticket 5.16)
        class guardConvoyVehicle {};

        // Server: loads a truck with ammo crates as Liberation's convoy hijack mission does (ticket 5.16)
        class loadAmmoCrates {};

        // Server: makes a vehicle of a strike task searchable for documents (tickets 5.14, 5.16)
        class makeSearchable {};

        // Server: what the documents of a search tell: the tip to a nest, notification, subtitle (tickets 5.14, 5.16)
        class giveDocumentsTip {};

        // Server: the times of day of the time windows for the text of the arms transport (ticket 5.16)
        class strikeExtraConvoy {};

        // Server: the road piece a car of a strike task starts or ends on (tickets 5.14, 5.16)
        class findRoadNear {};

        // Server: the route a car finds between two positions (tickets 5.14, 5.16)
        class calcRoute {};

        // Length of a path in m (tickets 5.14, 5.16)
        class pathLength {};

        // Server: a militia infantry class with vest and helmet for a fighter of a strike task (tickets 5.15, 5.16)
        class pickArmoredClass {};
    };

    class population {
        file = "coin\functions\population";

        // Server loop: the own civilians of liberated towns, spawn near players, budget, removal (ticket 3.7)
        class populationLoop {};

        // Server: spawns the civilians of one town, like Liberation's own, handed to Zeus
        class spawnPopulation {};

        // Server: the place where the elder of a town stands, at a mosque or the largest house near the centre (ticket 5.9a)
        class findElderSpot {};

        // Server: the elder of a town, dressed, named, standing at his place, handed to Zeus (ticket 5.9a)
        class spawnElder {};

        // Server: marks an elder on the map for COIN_elderMarkerSeconds (ticket 5.9a)
        class markElder {};
    };

    class persistence {
        file = "coin\functions\persistence";

        // Stores entry 22 of Liberation's save while it loads (hook in save_manager.sqf, ADR 0005)
        class receiveSaveBlock {};

        // Builds entry 22 of Liberation's save: [COIN_saveVersion, nests, intel] (hook in KPLIB_fnc_getSaveData)
        class getSaveBlock {};

        // Notes a new campaign while Liberation loads (hook in save_manager.sqf, branch without a save)
        class markNewCampaign {};
    };

    class reputation {
        file = "coin\functions\reputation";

        // Server: start reputation of a new campaign, after Liberation has loaded its save (ticket 5.7, ADR 0009)
        class initReputation {};

        // Server: the one way to change the reputation, goes through F_cr_changeCR, logs reason, amount and new value (ticket 5.1)
        class changeReputation {};

        // The mood of the population in five steps from the reputation, a key of COIN_moodAnswers (ticket 5.3)
        class getMood {};

        // Server loop: sets how often Liberation's informant shows up by the reputation, via KP_liberation_civinfo_* (ticket 5.2)
        class informantFrequencyLoop {};

        // Server: registers the reputation changes that follow a COIN event, e.g. nest destroyed (ticket 5.1)
        class initReputationEvents {};

        // Server: reputation for a prisoner killed by the army, called from the kill manager (hook, ticket 5.1)
        class captiveKilled {};

        // Server: reputation for a civilian vehicle destroyed by the army, called from the kill manager (hook, ticket 5.1)
        class civVehicleDestroyed {};

        // Client: getting into a civilian vehicle seizes it, for COIN_repCivVehicleSeized (Liberation's own handler has a typo, ticket 5.1)
        class initVehicleSeizure {};

        // Client: hides the reputation number and icon in Liberation's overlay, except with COIN_debug (hook, ticket 5.3)
        class hideReputationDisplay {};
    };

    class nests {
        file = "coin\functions\nests";

        // Server: nests from the save or new ones for a new campaign, debug map (tickets 2.1 and 2.5, ADR 0018)
        class initNests {};

        // Server: nests of a new campaign as data, placement rules and "best candidate" (ticket 2.2)
        class createNests {};

        // Placement rules every nest has to keep (map edge, start base, capital, sector centres)
        class isNestSpotAllowed {};

        // Houses at the edge of the towns that can hold a building nest
        class collectNestHouses {};

        // Candidate places for a terrain nest (away from towns and roads, flat and free)
        class findTerrainNestSpots {};

        // Influence radius of a nest type from COIN_nestSetup
        class getNestRadius {};

        // Server: manned, player-locked old vehicles of a weapons cache (ticket 2.9a, ADR 0014)
        class spawnOldVehicles {};

        // Server: global debug markers for all nests (lobby parameter "COIN Debug")
        class drawNestMarkers {};

        // Server: listens to COIN_nestDestroyed and COIN_campCleared and messages all players (ticket 2.14)
        class initMessages {};

        // Client: shows one of these messages as a notification, in the game language (ticket 2.14)
        class showNotification {};

        // Server: network strength = active / all nests, published to the clients (ticket 2.6)
        class updateNetworkStrength {};

        // Client: debug record "Netzwerkstärke" in the map diary (ticket 2.6)
        class showNetworkStrength {};

        // Server: checks core and prop classes once (core objects must be destructible)
        class validateNestContent {};

        // Server: core object, props and guards of a building nest
        class spawnBuildingNest {};

        // Server: core object, props and guards of a terrain nest after a terrain template (ADR 0020)
        class spawnTerrainNest {};

        // Server: stationary and patrolling guards of a nest
        class spawnNestGuards {};

        // Server: core object, props and vehicle after a building or terrain template (ADR 0019, ADR 0020)
        class placeNestTemplate {};

        // Server: free placement for houses without a template
        class placeNestFree {};

        // Server: civilian vehicle of a VBIED garage (free placement), inside the hall or next to it
        class placeNestVehicle {};

        // Server: camps as data after the nests are known, capacity and owner nest (ticket 2.7, decision E8)
        class initCamps {};

        // Camp capacity from the weight of the active nests (decision E8)
        class getCampCapacity {};

        // Weight of a nest type for the camps (COIN_campsPerNest)
        class getCampWeight {};

        // Place for a camp that keeps the placement rules (ticket 2.8)
        class findCampSpot {};

        // Open-ground rules terrain nests and camps share: away from towns and roads, flat and free
        class checkTerrainSpot {};

        // Cover objects (trees, bushes, rocks) around a camp spot
        class getCampCover {};

        // Server: distances of a camp for the RPT line (road, town, FOB, captured sector, start base, cover)
        class describeCampSpot {};

        // Server: global debug markers for the camps, with a line to their nest (ticket 2.11)
        class drawCampMarkers {};

        // Server: one camp as data, place and owner nest (tickets 2.7, 2.8 and 2.10)
        class createCamp {};

        // Server, once per check: replaces, moves and retires camps (ticket 2.10)
        class manageCamps {};

        // Server: is a spawned camp cleared (ausgehoben)? Plans its replacement (ticket 2.10)
        class checkCampCleared {};

        // Camps that count against the capacity: active and moving
        class getActiveCamps {};

        // Centres of the exclusion zones: captured sectors and FOBs
        class getCampExclusion {};

        // What a camp looks like when it spawns: template, direction, fighters, technical (ticket 2.9)
        class planCamp {};

        // Server: template objects, guards and perhaps a technical of a camp (ticket 2.9)
        class spawnCamp {};

        // Server: deletes a camp's content, a technical a player took stays (ticket 2.9)
        class removeCamp {};

        // Server: spots of the stationary guards in a ring around a terrain nest or a camp
        class findGuardRingSpots {};

        // Server loop: spawns nests and camps near players and removes them again (ticket 2.3 and 2.9)
        class nestSpawnLoop {};

        // Server: nest destroyed for good, saved at once, event COIN_nestDestroyed (ticket 2.4)
        class destroyNest {};
    };

    class threats {
        file = "coin\functions\threats";

        // Server: every active IED workshop lays its budget, starts the IED loop (ticket 4.1a)
        class initIEDs {};

        // Server: lays one IED for a workshop (mine object, Zeus, COIN_ieds)
        class createIED {};

        // Server: place on a road in the radius of the workshop, away from towns, bases and other IEDs
        class findIEDSpot {};

        // Server: does the army set an IED off here? (BLUFOR vehicle, or two BLUFOR soldiers on foot, close by)
        class iedTriggered {};

        // Server: exact check of one IED while BLUFOR is within 300 m, spawned by the IED's engine trigger
        class iedWatch {};

        // Server: takes an IED out of COIN_ieds and deletes its trigger (object deleted, defused, blown up)
        class removeIED {};

        // Server: a used IED is replaced by its workshop after a wait, a destroyed workshop lays nothing (ticket 4.1b)
        class replaceIED {};

        // Server: was the IED defused? Reputation for a real one, deletes the item a defusing leaves (ticket 4.2a, 4.1b)
        class checkDefused {};

        // Server: global debug markers of the IEDs
        class drawIEDMarkers {};

        // Server: free, down or out? Can a fighter in civilian clothes still act (ticket 4.2b)
        class getFighterState {};

        // Server: creates a fighter in civilian clothes: civilian side, no kill manager, unarmed, marked, Zeus (ticket 4.2b)
        class createCivilianFighter {};

        // Server: place for the triggerman of a remote IED, 60-150 m away with line of sight, beside a house or elevated
        class findTriggermanSpot {};

        // Server: puts the triggerman of a remote IED in place with a phone and a debug marker
        class createTriggerman {};

        // Server loop: triggermen appear at 800 m, leave like nest guards, note who is out (ticket 4.2b)
        class triggermanLoop {};

        // Server: FOBs and players within the radius of a VBIED garage (ticket 4.3)
        class getVBIEDTargets {};

        // Server: spawn point of a VBIED on a road, 800-1200 m from the target, out of sight
        class findVBIEDSpot {};

        // Server: sends one VBIED (civilian vehicle with a lone driver) from a garage to a target
        class createVBIED {};

        // Server: the run of one VBIED, spawned by createVBIED
        class vbiedDrive {};

        // Server: sets the charge of a VBIED off, once
        class explodeVBIED {};

        // Server loop: every ready garage rolls for a VBIED (ticket 4.3)
        class vbiedLoop {};

        // Server: players on foot within the radius of an IED workshop (ticket 4.4)
        class getSuicideBomberTargets {};

        // Server: spawn point of a suicide bomber, 100-200 m from the target, out of sight
        class findSuicideBomberSpot {};

        // Server: sends one suicide bomber (fighter in civilian clothes) from a workshop to a player
        class createSuicideBomber {};

        // Server: the run of one suicide bomber, spawned by createSuicideBomber
        class suicideBomberDrive {};

        // Server: sets the vest of a suicide bomber off, once
        class explodeSuicideBomber {};

        // Server loop: every ready workshop rolls for a suicide bomber by reputation band (ticket 4.4)
        class suicideBomberLoop {};

        // Server: place for the ambush of a camp, beside the nearest road 200-800 m away (ticket 4.5)
        class findAmbushSpot {};

        // What an ambush looks like when it spawns: fighters and cover objects from the seed of its camp
        class planAmbush {};

        // Server: spawns the fighters and cover objects of an ambush beside the road
        class spawnAmbush {};

        // Server: removes the content of an ambush that nobody is near
        class removeAmbush {};

        // Server: life of a spawned ambush, opens fire at 150 m, notes when it is cleared
        class ambushWatch {};

        // Server: global debug markers of the ambushes with a line to their camp
        class drawAmbushMarkers {};
    };
};
