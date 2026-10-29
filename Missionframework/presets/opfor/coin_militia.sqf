/*
    COIN Liberation: OPFOR preset "militia" (ADR 0014, DESIGN section 10).
    Based on Project OPFOR "Afghan Militia" (LOP_AM_OPF_*), derived from islamic_state.sqf.

    - Infantry: Afghan Militia. Roles without a confirmed AM class fall back to a confirmed one (see _pick),
      so a wrong or missing classname never produces an invalid unit.
    - Sector defenders and patrols (militia_vehicles, opfor_vehicles*): technicals only.
    - Counterattacks (opfor_battlegroup_vehicles*): technicals and troop transports (Ural), rarely one old vehicle
      (BTR-60, also a troop transport) via list weighting. Two BTR-60 at once would be too much (hard limit: COIN_fnc_limitOldVehicles, hook 34).
    - No tanks, no anti-aircraft tank, no helicopters, no planes (empty lists). The capital's heavy equipment is
      spawned by COIN code later (ticket 6.3), not through these lists.
    - Lists that Liberation picks from with selectRandom must never be empty (selectRandom [] returns nil).

    Needed Mods:
    - RHS USAF
    - RHS AFRF
    - Project OPFOR

    Optional Mods:
    - None
*/

// Returns _wanted if the class exists in the loaded modset, otherwise _fallback (confirmed class)
private _pick = {
    params ["_wanted", "_fallback"];
    if (isClass (configFile >> "CfgVehicles" >> _wanted)) then {_wanted} else {_fallback};
};

// Enemy infantry classes
opfor_officer = ["LOP_AM_OPF_Infantry_SL", "LOP_AM_OPF_Infantry_Rifleman"] call _pick;               // Officer (Warlord)
opfor_squad_leader = ["LOP_AM_OPF_Infantry_SL", "LOP_AM_OPF_Infantry_Rifleman"] call _pick;          // Squad Leader (Warlord)
opfor_team_leader = ["LOP_AM_OPF_Infantry_TL", "LOP_AM_OPF_Infantry_Rifleman_5"] call _pick;         // Team Leader (Chief)
opfor_sentry = "LOP_AM_OPF_Infantry_Rifleman";                          // Rifleman (AKM)
opfor_rifleman = "LOP_AM_OPF_Infantry_Rifleman_5";                      // Rifleman (AK-74)
opfor_rpg = "LOP_AM_OPF_Infantry_AT";                                   // Rifleman (RPG-7)
opfor_grenadier = ["LOP_AM_OPF_Infantry_GL", "LOP_AM_OPF_Infantry_Rifleman"] call _pick;             // Grenadier (AKM GP-25)
opfor_machinegunner = ["LOP_AM_OPF_Infantry_AR_Asst", "LOP_AM_OPF_Infantry_AR"] call _pick;          // Autorifleman (AR_Asst)
opfor_heavygunner = "LOP_AM_OPF_Infantry_AR";                           // Heavy Gunner (PKM)
opfor_marksman = "LOP_AM_OPF_Infantry_Rifleman_3";                      // Marksman (Lee Enfield)
opfor_sharpshooter = ["LOP_AM_OPF_Infantry_Marksman", "LOP_AM_OPF_Infantry_Rifleman_3"] call _pick;  // Sharpshooter
opfor_sniper = ["LOP_AM_OPF_Infantry_Marksman", "LOP_AM_OPF_Infantry_Rifleman_3"] call _pick;        // Sniper
opfor_at = "LOP_AM_OPF_Infantry_AT";                                    // AT Specialist (RPG-7)
opfor_aa = "LOP_AM_OPF_Infantry_AT";                                    // AA Specialist (RPG-7)
opfor_medic = "LOP_AM_OPF_Infantry_Corpsman";                           // Combat Life Saver (Bonesetter)
opfor_engineer = "LOP_AM_OPF_Infantry_Engineer";                        // Engineer (Bomber)
opfor_paratrooper = "LOP_AM_OPF_Infantry_Rifleman_5";                   // Paratrooper (unused: no helicopters)

// Enemy vehicles used by secondary objectives.
opfor_mrap = ["LOP_AM_OPF_Offroad", "LOP_AM_OPF_UAZ_DshKM"] call _pick;                              // Offroad
opfor_mrap_armed = ["LOP_AM_OPF_Offroad_M2", "LOP_AM_OPF_UAZ_DshKM"] call _pick;                     // Offroad (M2)
opfor_transport_helo = "LOP_TKA_Mi8MT_Cargo";                        // Mi-8MT (Cargo) -> COIN: only parked as an empty prop by enemy FOB template 5, never flies (opfor_choppers is empty)
opfor_transport_truck = "LOP_TKA_Ural";                                 // Ural-4320 (Covered)
opfor_ammobox_transport = "LOP_TKA_Ural_open";                          // Ural-4320 (Open) -> Has to be able to transport resource crates!
opfor_fuel_truck = "RHS_Ural_Fuel_MSV_01";                              // Ural-4320 (Fuel)
opfor_ammo_truck = "rhs_gaz66_ammo_msv";                                // GAZ-66 (Ammo)
opfor_fuel_container = "Land_Pod_Heli_Transport_04_fuel_F";             // Taru Fuel Pod
opfor_ammo_container = "Land_Pod_Heli_Transport_04_ammo_F";             // Taru Ammo Pod
opfor_flag = "lop_Flag_tak_F";                                          // Flag

/* Adding a value to these arrays below will add them to a one out of however many in the array, random pick chance.
Therefore, adding the same value twice or three times means they are more likely to be chosen more often. */

/* Militia infantry. Lightweight soldier classnames the game will pick from randomly as sector defenders.
Think of them like garrison or military police forces, which are more meant to control the local population instead of fighting enemy armies. */
militia_squad = [
    "LOP_AM_OPF_Infantry_Rifleman",                                     // Rifleman (AKM)
    "LOP_AM_OPF_Infantry_Rifleman",                                     // Rifleman (AKM)
    "LOP_AM_OPF_Infantry_Rifleman_5",                                   // Rifleman (AK-74)
    "LOP_AM_OPF_Infantry_Rifleman_5",                                   // Rifleman (AK-74)
    "LOP_AM_OPF_Infantry_AT",                                           // Rifleman (RPG-7)
    "LOP_AM_OPF_Infantry_AR",                                           // Autorifleman (PKM)
    "LOP_AM_OPF_Infantry_Rifleman_3",                                   // Marksman (Lee Enfield)
    "LOP_AM_OPF_Infantry_Corpsman",                                     // Medic (Bonesetter)
    "LOP_AM_OPF_Infantry_Engineer"                                      // Engineer (Bomber)
];

/* Militia vehicles (sector defenders). Technicals only.
   COIN: LOP_AM_OPF_UAZ_DshKM is confirmed (upstream preset), it keeps the list non-empty if the other AM technicals do not exist.
   Classes not found in the modset are dropped by init_presets.sqf. */
militia_vehicles = [
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Offroad_M2"                                             // Offroad (M2)
];

// Vehicles for sector defenders and patrols at high readiness. Technicals only.
opfor_vehicles = [
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Offroad_M2"                                             // Offroad (M2)
];

// Vehicles for sector defenders and patrols at low readiness. Technicals only.
opfor_vehicles_low_intensity = [
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM"                                             // Nissan (PKM)
];

/* Counterattacks (battlegroups) at high readiness: technicals, troop transports, rarely one old vehicle.
   COIN: LOP_ISTS_OPF_BTR60 is confirmed (upstream preset). One entry of 40 keeps it rare (about 6 percent for two or more in a group of 16); the hard limit of 1 is COIN_fnc_limitOldVehicles (hook 34, ADR 0014). */
opfor_battlegroup_vehicles = [
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_AM_OPF_Offroad_M2",                                            // Offroad (M2)
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_ISTS_OPF_BTR60"                                                // BTR-60PB (old vehicle, rare, also a troop transport)
];

// Counterattacks (battlegroups) at low readiness: technicals and troop transports, no old vehicle.
opfor_battlegroup_vehicles_low_intensity = [
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_UAZ_DshKM",                                             // UAZ-3151 (DShKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_AM_OPF_Nissan_PKM",                                            // Nissan (PKM)
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered), troop transport
    "LOP_TKA_Ural"                                                      // Ural-4320 (Covered), troop transport
];

/* Vehicles of battlegroups that carry 8 soldiers as passengers (they unload a squad near the objective).
   COIN: the covered Ural and the rare BTR-60. Technicals cannot hold 8 soldiers and stay out of this list. */
opfor_troup_transports = [
    "LOP_TKA_Ural",                                                     // Ural-4320 (Covered)
    "LOP_ISTS_OPF_BTR60"                                                // BTR-60PB
];

// COIN: no rotary-wings (empty, see send_paratroopers.sqf: a non-empty list without a transporter hangs forever).
opfor_choppers = [];

// COIN: no fixed-wings (empty, spawn_air.sqf exits on an empty list).
opfor_air = [];
