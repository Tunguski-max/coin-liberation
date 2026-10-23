/*
    File: fn_getCapableFighters.sqf
    Author: COIN Liberation

    Description:
        The fighters among the given objects who can still fight (tickets 2.10 and 4.5, DESIGN 5.1): alive, not captive
        (vanilla or ACE handcuffed or surrendering), on the enemy side and not farther than COIN_campFleeDistance from the
        given position (farther away he fled). An unconscious fighter still counts, he may wake up. A camp is cleared
        (COIN_fnc_checkCampCleared) and an ambush is cleared (COIN_fnc_ambushWatch) when none is left.

    Parameter(s):
        _objects - Objects a camp or an ambush spawned [ARRAY of OBJECTs]
        _pos     - Position of the camp or the ambush [ARRAY]

    Returns:
        Fighters who can still fight [ARRAY of OBJECTs]
*/

params [
    ["_objects", [], [[]]],
    ["_pos", [0, 0, 0], [[]]]
];

(_objects select {_x isKindOf "CAManBase"}) select {
    alive _x
    && {!captive _x}
    && {!(_x getVariable ["ace_captives_isHandcuffed", false])}
    && {!(_x getVariable ["ace_captives_isSurrendering", false])}
    && {(side group _x) isEqualTo GRLIB_side_enemy}
    && {(_x distance2D _pos) <= COIN_campFleeDistance}
}
