/*
    File: init_client.sqf
    Author: COIN Liberation

    Description:
        Client part of the COIN module. Called by COIN_fnc_init on every machine with
        an interface (players, local host) after Liberation's init.sqf has finished there.
        Client features (ACE interactions, markers) are started here in later phases.
*/

diag_log "[COIN] init (client)";
