/*
    File: fn_mixSquad.sqf
    Author: COIN Liberation

    Description:
        Swaps the members of a militia field squad for their armored Islamic State twins, see COIN_fnc_mixClass.
        Called from Liberation's KPLIB_fnc_getSquadComp for army squads (hook 9, docs/hooks.md). Server only.

    Parameter(s):
        _squad - Classnames of the squad  [ARRAY, defaults to []]

    Returns:
        New array of classnames, the given array stays unchanged [ARRAY]
*/

params [
    ["_squad", [], [[]]]
];

_squad apply {[_x] call COIN_fnc_mixClass}
