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

        // Server: a warning, a circle around an active camp close to the civilian (ticket 3.6)
        class createWarning {};

        // Server loop: a warning disappears with its camp
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

        // Client: what a prisoner says, one sentence per result (ticket 3.8)
        class showInterrogation {};

        // Client: name and sentences as a subtitle
        class showSubtitle {};
    };

    class population {
        file = "coin\functions\population";

        // Server loop: the own civilians of liberated towns, spawn near players, budget, removal (ticket 3.7)
        class populationLoop {};

        // Server: spawns the civilians of one town, like Liberation's own, handed to Zeus
        class spawnPopulation {};
    };

    class persistence {
        file = "coin\functions\persistence";

        // Stores entry 22 of Liberation's save while it loads (hook in save_manager.sqf, ADR 0005)
        class receiveSaveBlock {};

        // Builds entry 22 of Liberation's save: [COIN_saveVersion, nests, intel] (hook in KPLIB_fnc_getSaveData)
        class getSaveBlock {};
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
    };
};
