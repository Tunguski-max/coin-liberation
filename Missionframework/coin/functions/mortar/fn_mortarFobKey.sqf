/*
    File: fn_mortarFobKey.sqf
    Author: COIN Liberation

    Description:
        Key of a FOB in COIN_mortarCooldowns (ticket 6.7a, #158): its rounded position as text. A FOB does not move,
        a rebuilt one at the same spot has the same key (the cooldown is not saved anyway).

    Parameter(s):
        _fob - Position of the FOB [ARRAY]

    Returns:
        Key [STRING]
*/

params [
    ["_fob", [], [[]], [2, 3]]
];

format ["%1", [round (_fob select 0), round (_fob select 1)]]
