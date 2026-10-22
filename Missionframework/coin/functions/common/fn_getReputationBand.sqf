/*
    File: fn_getReputationBand.sqf
    Author: COIN Liberation

    Description:
        Reputation band of the population (ticket 3.4, ADR 0009): Liberation's civil reputation KP_liberation_civ_rep
        (-100 .. +100) against COIN_repBandMid and COIN_repBandHigh. Below the first it is "low", from the second "high".

    Parameter(s):
        NONE

    Returns:
        "low", "mid" or "high" [STRING]
*/

private _reputation = missionNamespace getVariable ["KP_liberation_civ_rep", 0];

if (_reputation >= COIN_repBandHigh) exitWith {"high"};
if (_reputation >= COIN_repBandMid) exitWith {"mid"};

"low"
