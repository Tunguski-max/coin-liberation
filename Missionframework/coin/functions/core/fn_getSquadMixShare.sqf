/*
    File: fn_getSquadMixShare.sqf
    Author: COIN Liberation

    Description:
        Returns the share of Islamic State twins (vest and helmet) in the militia field squads for the current
        combat readiness (ADR 0014): COIN_squadMixShare select 0 at COIN_squadMixReadiness select 0, rising linearly
        to COIN_squadMixShare select 1 at COIN_squadMixReadiness select 1, and 0 below the lower readiness bound.
        Logs when the share has moved by 0.1 or more since the last log line, so the RPT shows the progress.

    Parameter(s):
        NONE

    Returns:
        Share between 0 and 1 [NUMBER]
*/

private _share = 0;
if (combat_readiness >= (COIN_squadMixReadiness select 0)) then {
    _share = linearConversion [COIN_squadMixReadiness select 0, COIN_squadMixReadiness select 1, combat_readiness, COIN_squadMixShare select 0, COIN_squadMixShare select 1, true];
};

if (abs (_share - (missionNamespace getVariable ["COIN_lastLoggedMixShare", -1])) >= 0.1) then {
    COIN_lastLoggedMixShare = _share;
    diag_log format ["[COIN] squads: readiness %1, Islamic State share %2", round combat_readiness, _share toFixed 2];
};

_share
