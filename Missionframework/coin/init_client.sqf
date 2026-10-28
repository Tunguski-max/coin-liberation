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

// Interpreter (ticket 3.1, DESIGN 7): ACE "Talk" at civilians, only for the interpreter slots
if (COIN_enableQuestioning) then {
    [] call COIN_fnc_initQuestioning;
};

// Aid tasks (tickets 5.9b and 5.10) belong to the unit: after a respawn the new unit gets the ones this machine has (COIN_fnc_clientTask)
player addEventHandler ["Respawn", {
    {_x spawn COIN_fnc_clientTask} forEach values (missionNamespace getVariable ["COIN_clientTasks", createHashMap]);
}];

// Player-readable explanations in the map diary (tab "COIN Liberation"), again after every respawn
if (COIN_enableFactionMarkers) then {
    [player] call COIN_fnc_createDiary;
    player addEventHandler ["Respawn", {params ["_unit"]; [_unit] call COIN_fnc_createDiary;}];
};

// AI budget (ticket 2.13, ADR 0015): Liberation's caps on this client follow the server. A late joiner's own
// kp_liberation_config.sqf has just set Liberation's original values, so the published ones are taken here again
if (COIN_enableAIBudget && {!isServer}) then {
    "COIN_enemyAICaps" addPublicVariableEventHandler {[_this select 1] call COIN_fnc_applyEnemyAICaps;};
    if (!isNil "COIN_enemyAICaps") then {[COIN_enemyAICaps] call COIN_fnc_applyEnemyAICaps;};
};

// Network strength (ticket 2.6): debug record in the map diary, follows the value the server publishes. A local host
// gets no published value from itself, COIN_fnc_updateNetworkStrength updates its record directly
if (COIN_enableNetworkStrength && {COIN_debug}) then {
    [player, true] call COIN_fnc_showNetworkStrength;
    player addEventHandler ["Respawn", {params ["_unit"]; [_unit, true] call COIN_fnc_showNetworkStrength;}];
    if (!isServer) then {
        "COIN_networkStrength" addPublicVariableEventHandler {[player] call COIN_fnc_showNetworkStrength;};
        // A late joiner may get the value after this point without the handler firing
        [] spawn {
            private _timeout = diag_tickTime + COIN_initTimeout;
            waitUntil {
                sleep 1;
                (!isNil "COIN_networkStrength" && {!isNil "COIN_networkCounts"}) || {diag_tickTime > _timeout}
            };
            [player] call COIN_fnc_showNetworkStrength;
        };
    };
};

// Favors (ticket 5.4): debug record in the map diary (tab "COIN Debug"), follows the state the server publishes. A local host gets no
// published value from itself, COIN_fnc_publishFavors updates its record directly
if (COIN_enableFavors && {COIN_debug}) then {
    [player, true] call COIN_fnc_showFavors;
    player addEventHandler ["Respawn", {params ["_unit"]; [_unit, true] call COIN_fnc_showFavors;}];
    if (!isServer) then {
        "COIN_favorState" addPublicVariableEventHandler {[player] call COIN_fnc_showFavors;};
        // A late joiner may get the value after this point without the handler firing
        [] spawn {
            private _timeout = diag_tickTime + COIN_initTimeout;
            waitUntil {
                sleep 1;
                !isNil "COIN_favorState" || {diag_tickTime > _timeout}
            };
            [player] call COIN_fnc_showFavors;
        };
    };
};

// Radio orders for the reinforcement (ticket 5.19): the menu and the briefing follow COIN_reinforcementOn, which the server publishes. A
// local host gets no published value from itself, COIN_fnc_publishReinforcement updates it directly. The items belong to the unit, so
// a respawn starts again
if (COIN_enableFavors && {COIN_enableReinforcement} && {COIN_enableRadio}) then {
    player addEventHandler ["Respawn", {
        COIN_radioMenuIds = [];
        COIN_radioBriefingRecord = nil;
        params ["_unit"];
        [_unit] call COIN_fnc_updateRadio;
    }];
    if (!isServer) then {
        "COIN_reinforcementOn" addPublicVariableEventHandler {[] call COIN_fnc_updateRadio;};
        // A late joiner gets the value after this point, perhaps without the handler firing
        [] spawn {
            private _timeout = diag_tickTime + COIN_initTimeout;
            waitUntil {
                sleep 1;
                (!isNil "COIN_reinforcementOn" && {!isNull player}) || {diag_tickTime > _timeout}
            };
            [] call COIN_fnc_updateRadio;
        };
    };
};

// Islamic State twins are enemy infantry too (Liberation's prisoner script checks KPLIB_o_inf_classes on the client).
// init_presets.sqf builds that list on every client, so the twins are added here as well, also for late joiners.
if (COIN_enableSquadMix) then {
    [] call COIN_fnc_registerSquadTwins;
};

// Civilian vehicles (ticket 5.1): getting in seizes the vehicle, for COIN_repCivVehicleSeized reputation. Liberation's own
// handler calls a function name that does not exist, so without this nothing is ever seized
if (COIN_enableVehicleSeizure) then {
    [] call COIN_fnc_initVehicleSeizure;
};
