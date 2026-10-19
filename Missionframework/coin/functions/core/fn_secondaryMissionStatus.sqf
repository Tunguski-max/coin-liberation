/*
    File: fn_secondaryMissionStatus.sqf
    Author: COIN Liberation

    Description:
        Tells whether one of Liberation's secondary missions may be started (ticket 2.12, ADR 0011).
        FOB hunting builds an enemy base, the very "OPFOR FOB" that nests replace. With COIN_disableFobHunting
        it cannot be started; convoy ambush and search and rescue stay. Runs on clients (secondary mission
        dialog, hook 16) and on the server (start request, hook 15), both read the config loaded on every machine.

    Parameter(s):
        _index - Liberation's secondary mission index (0 FOB hunting, 1 convoy ambush, 2 search and rescue) [NUMBER]

    Returns:
        [allowed, reason shown to the player] [ARRAY]
*/

params [
    ["_index", -1, [0]]
];

// Index of FOB hunting in Liberation's GRLIB_secondary_missions_costs and start_secondary_remote_call
private _fobHuntingIndex = 0;

if (_index == _fobHuntingIndex && {COIN_disableFobHunting}) exitWith {
    [false, "Abgeschaltet: Die Miliz hat keine Basen, sie versteckt sich in Nestern."]
};

[true, ""]
