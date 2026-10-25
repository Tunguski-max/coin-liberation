/*
    File: fn_initReputation.sqf
    Author: COIN Liberation

    Description:
        Server start of the reputation (ticket 5.7, ADR 0009, DESIGN 8). Waits until Liberation has loaded its save
        and compiled F_cr_changeCR. A new campaign (COIN_newCampaign, hook in save_manager.sqf) starts at
        COIN_reputationStart instead of Liberation's 0. A loaded save keeps its value.
        The value is set directly, then F_cr_changeCR with 0 clamps it and applies Liberation's resistance standing
        (hostile below -25, friendly from +25, neutral between), which Liberation otherwise sets only on a save load
        or the first change.
        Switch COIN_enableReputationStart: off = a new campaign starts at 0 as in Liberation.
        Also switches off Liberation's penalty for houses that are gone when a town is taken (COIN_disableBuildingPenalty).
        Must be spawned (waits for save_is_loaded).

    Parameter(s):
        NONE

    Returns:
        Start value was set [BOOL]
*/

if (!isServer) exitWith {false};

// Liberation charges 3 reputation per house that is gone when the army takes a town (f_kp_cr_liberatedSector.sqf, compared
// with the count at the server start). The fight destroys houses and the AI is often to blame, so the penalty is off. The gain
// for the capture stays, a message about destroyed buildings is not shown (Liberation sends it only for a penalty above 0)
if (COIN_disableBuildingPenalty) then {
    KP_liberation_cr_building_penalty = 0;
    diag_log "[COIN] reputation: building penalty at the capture of a town is off (Liberation: 3 per house)";
};

private _timeout = diag_tickTime + COIN_initTimeout;
waitUntil {
    sleep 1;
    ((missionNamespace getVariable ["save_is_loaded", false]) && {!isNil "F_cr_changeCR"}) || {diag_tickTime > _timeout}
};

if !(missionNamespace getVariable ["save_is_loaded", false]) exitWith {
    diag_log format ["[COIN] reputation: ERROR - Liberation's save not loaded after %1 s, start value not set", COIN_initTimeout];
    false
};

if (isNil "F_cr_changeCR") exitWith {
    diag_log format ["[COIN] reputation: ERROR - Liberation's F_cr_changeCR missing after %1 s, start value not set", COIN_initTimeout];
    false
};

if !(missionNamespace getVariable ["COIN_newCampaign", false]) exitWith {
    diag_log format ["[COIN] reputation: save loaded, reputation stays %1", KP_liberation_civ_rep];
    false
};

if !(COIN_enableReputationStart) exitWith {
    diag_log format ["[COIN] reputation: new campaign, start value off, reputation stays %1 (Liberation)", KP_liberation_civ_rep];
    false
};

KP_liberation_civ_rep = COIN_reputationStart;
[0] call F_cr_changeCR;

diag_log format [
    "[COIN] reputation: new campaign, start value %1, resistance getFriend army=%2 militia=%3 (1 = friendly, 0 = hostile)",
    KP_liberation_civ_rep,
    GRLIB_side_resistance getFriend GRLIB_side_friendly,
    GRLIB_side_resistance getFriend GRLIB_side_enemy
];

true
