/*
    File: init_client.sqf
    Author: COIN Liberation

    Description:
        Client part of the COIN module. Called by COIN_fnc_init on every machine with
        an interface (players, local host) after Liberation's init.sqf has finished there.
        Client features (ACE interactions, markers) are started here in later phases.
*/

diag_log "[COIN] init (client)";

// ACE abilities of the slot (EOD, medic), again after every respawn
if (COIN_enableRoleTraits) then {
    [player] call COIN_fnc_applyRoleTraits;
    player addEventHandler ["Respawn", {params ["_unit"]; [_unit] call COIN_fnc_applyRoleTraits;}];
};

// Player-readable explanations in the map diary (tab "COIN Liberation"), again after every respawn
if (COIN_enableFactionMarkers) then {
    [player] call COIN_fnc_createDiary;
    player addEventHandler ["Respawn", {params ["_unit"]; [_unit] call COIN_fnc_createDiary;}];
};

// Islamic State twins are enemy infantry too (Liberation's prisoner script checks KPLIB_o_inf_classes on the client).
// init_presets.sqf builds that list on every client, so the twins are added here as well, also for late joiners.
if (COIN_enableSquadMix) then {
    [] call COIN_fnc_registerSquadTwins;
};
