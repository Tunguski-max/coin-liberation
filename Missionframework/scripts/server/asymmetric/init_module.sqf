// Scripts
// Logistic convoy ambush
logistic_convoy_ambush = compileFinal preprocessFileLineNumbers "scripts\server\asymmetric\convoy\logistic_convoy_ambush.sqf";
// IED spawner for blufor sectors
manage_asymIED = compileFinal preprocessFileLineNumbers "scripts\server\asymmetric\ied\manage_asymIED.sqf";
// Spawner for guerilla ambushes in blufor sectors
asym_sector_ambush = compileFinal preprocessFileLineNumbers "scripts\server\asymmetric\random\asym_sector_ambush.sqf";
// Spawner for guerilla forces who join a fight at an opfor sector
sector_guerilla = compileFinal preprocessFileLineNumbers "scripts\server\asymmetric\random\sector_guerilla.sqf";

// Globals
// List sectors which are just liberated. Preventing direct ambush spawn.
asymm_blocked_sectors = [];
publicVariable "asymm_blocked_sectors";

// Start module loop
// COIN: the loop only spawns IEDs and guerilla ambushes in liberated towns; replaced by the nest-fed threats (ticket 4.7, ADR 0008).
// Convoy ambush and sector guerilla above are not started by the loop and stay.
if !([] call COIN_fnc_replacesLiberationThreats) then {
    execVM "scripts\server\asymmetric\asymmetric_loop.sqf";
};
