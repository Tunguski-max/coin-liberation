/*
    File: fn_mixClass.sqf
    Author: COIN Liberation

    Description:
        Decides for one militia infantry class whether it is spawned as the Afghan Militia class (no armor) or as its
        Islamic State twin (vest 16, helmet 6), with the probability of COIN_fnc_getSquadMixShare (ADR 0014).
        The class is first normalised to the Afghan Militia class of its role, so it does not matter whether Liberation
        picked the Afghan Militia class or the twin (the twins are also listed in KPLIB_o_inf_classes).
        Classes without a twin (COIN_squadMixTwins) and an unavailable twin class stay unchanged.
        Called from Liberation's squad composition (hooks 9 and 10, docs/hooks.md). Server only.

    Parameter(s):
        _class - Infantry class of a militia role   [STRING, defaults to ""]
        _apply - Mix at all, false returns _class   [BOOL, defaults to true]

    Returns:
        Class to spawn [STRING]
*/

params [
    ["_class", "", [""]],
    ["_apply", true, [true]]
];

if (!_apply || {!(missionNamespace getVariable ["COIN_enableSquadMix", false])}) exitWith {_class};

// Twins that exist in the modset, prepared once: [[amClassLower, amClass, twin], ...]
if (isNil "COIN_squadTwins") then {
    COIN_squadTwins = (COIN_squadMixTwins select {isClass (configFile >> "CfgVehicles" >> (_x select 1))}) apply {
        [toLower (_x select 0), _x select 0, _x select 1]
    };
    COIN_squadTwinsLower = COIN_squadTwins apply {toLower (_x select 2)};
    diag_log format ["[COIN] squads: %1 of %2 Islamic State twins found", count COIN_squadTwins, count COIN_squadMixTwins];
};

// A twin class is normalised to the Afghan Militia class of its role
private _lower = toLower _class;
private _twinIndex = COIN_squadTwinsLower find _lower;
private _amIndex = [COIN_squadTwins findIf {(_x select 0) == _lower}, _twinIndex] select (_twinIndex >= 0);
if (_amIndex < 0) exitWith {_class};

private _entry = COIN_squadTwins select _amIndex;
if (random 1 < ([] call COIN_fnc_getSquadMixShare)) then {_entry select 2} else {_entry select 1}
