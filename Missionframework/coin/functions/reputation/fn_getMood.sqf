/*
    File: fn_getMood.sqf
    Author: COIN Liberation

    Description:
        Mood of the population (ticket 5.3, DESIGN 8, CONTEXT "Stimmung"): the civil reputation KP_liberation_civ_rep
        in five steps by COIN_moodThresholds, the rows of COIN_moodAnswers from "hostile" (below the first value) to
        "veryFriendly" (from the last one). Always the true state, never a lie.

    Parameter(s):
        NONE

    Returns:
        Mood key, the first column of COIN_moodAnswers, e.g. "suspicious" [STRING]
*/

private _reputation = missionNamespace getVariable ["KP_liberation_civ_rep", 0];

// Every threshold the reputation has reached is one step up
private _step = count (COIN_moodThresholds select {_reputation >= _x});

(COIN_moodAnswers select (_step min ((count COIN_moodAnswers) - 1))) select 0
