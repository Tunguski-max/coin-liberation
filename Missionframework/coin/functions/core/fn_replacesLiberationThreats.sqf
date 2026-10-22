/*
    File: fn_replacesLiberationThreats.sqf
    Author: COIN Liberation

    Description:
        Tells whether Liberation's own IEDs and town ambushes are switched off (ticket 4.7, ADR 0008).
        Replaced are the IEDs in enemy sectors (reputation < 0, hook 22 in manage_one_sector.sqf) and the IEDs
        and guerilla ambush in liberated towns (reputation <= -25, hook 23 in asymmetric\init_module.sqf).
        Not touched: Liberation's raid on AI logistic convoys and the guerilla at sector fights (resistance).
        Runs on the server while Liberation initialises, so the flag has a default in case the config is not loaded yet.

    Returns:
        true when Liberation's threats are replaced by the nest-fed ones [BOOL]
*/

missionNamespace getVariable ["COIN_replaceLiberationThreats", false]
