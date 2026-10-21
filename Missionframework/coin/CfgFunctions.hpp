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
    };

    class persistence {
        file = "coin\functions\persistence";

        // Stores entry 22 of Liberation's save while it loads (hook in save_manager.sqf, ADR 0005)
        class receiveSaveBlock {};

        // Builds entry 22 of Liberation's save: [COIN_saveVersion, nests] (hook in KPLIB_fnc_getSaveData)
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

        // Server: global debug markers for all nests (lobby parameter "COIN Debug")
        class drawNestMarkers {};

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

        // Server loop: spawns nests near players and removes them again (ticket 2.3)
        class nestSpawnLoop {};
    };
};
