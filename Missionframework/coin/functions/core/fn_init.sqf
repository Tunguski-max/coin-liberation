/*
    File: fn_init.sqf
    Author: COIN Liberation

    Description:
        Entry point of the COIN module (CfgFunctions postInit, runs on every machine).
        Loads the COIN config, waits until Liberation's init.sqf has finished on this
        machine and then starts the server and/or client part of the COIN module.
        On a local host both parts run.

    Parameter(s):
        NONE (postInit arguments are ignored)

    Returns:
        Function reached the end [BOOL]
*/

[] call compileFinal preprocessFileLineNumbers "coin\coin_config.sqf";

if (COIN_debug) then {
    diag_log format ["[COIN] init: config loaded (saveVersion %1)", COIN_saveVersion];
};

// Spawned, so waiting is allowed regardless of how postInit is executed
[] spawn {
    private _timeout = diag_tickTime + COIN_initTimeout;

    // KPLIB_init is set to true at the end of Liberation's init.sqf
    waitUntil {
        sleep 1;
        (missionNamespace getVariable ["KPLIB_init", false]) || {diag_tickTime > _timeout}
    };

    if !(missionNamespace getVariable ["KPLIB_init", false]) exitWith {
        diag_log format ["[COIN] init: ERROR - Liberation init not finished after %1 s, COIN module not started", COIN_initTimeout];
    };

    if (isServer) then {
        [] call compileFinal preprocessFileLineNumbers "coin\init_server.sqf";
    };

    if (hasInterface) then {
        [] call compileFinal preprocessFileLineNumbers "coin\init_client.sqf";
    };
};

true
