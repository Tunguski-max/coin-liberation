/*
    File: fn_rollOutcome.sqf
    Author: COIN Liberation

    Description:
        Rolls the outcome of one question or one result of an interrogation by weights (tickets 3.4, 3.6, 3.8):
        [nothing, rumor, hint, tip, warning, lie]. Without a nest there is nothing to tell and nothing to lie about, so
        the outcome is "nothing"; so it is for a lie or a warning that is switched off (COIN_enableLies,
        COIN_enableWarnings). Server only.

    Parameter(s):
        _weights - Weights in the order above [ARRAY of NUMBERs, defaults to COIN_intelWeightsMid]
        _nest    - Nest a true level would be about, [] for none [ARRAY, defaults to []]

    Returns:
        "nothing", "rumor", "hint", "tip", "warning" or "lie" [STRING]
*/

params [
    ["_weights", COIN_intelWeightsMid, [[]]],
    ["_nest", [], [[]]]
];

private _outcome = ["nothing", "rumor", "hint", "tip", "warning", "lie"] selectRandomWeighted _weights;
if (
    _nest isEqualTo []
    || {_outcome isEqualTo "lie" && {!COIN_enableLies}}
    || {_outcome isEqualTo "warning" && {!COIN_enableWarnings}}
) then {_outcome = "nothing"};

_outcome
