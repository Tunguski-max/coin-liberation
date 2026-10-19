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

        // Server loop: swaps militia squad members for armored Islamic State twins by combat readiness
        class mixSquads {};

        // Client: diary tab "COIN Liberation" with the player-readable explanations
        class createDiary {};

        // Entry point of the COIN module, runs on every machine at mission start
        class init {
            postInit = 1;
        };
    };
};
