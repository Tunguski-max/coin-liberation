/*
    File: fn_createCivilianFighter.sqf
    Author: COIN Liberation

    Description:
        Creates a fighter in civilian clothes (ticket 4.2b, DESIGN 6, ADR 0022): the triggerman, later the VBIED driver
        and the assassin. Technically a civilian (civilian side, a class of Liberation's civilian preset, so ACE shows
        "Get Down!" and "Go Away!" at him like at every civilian) in a group of his own, but
        - made without Liberation's kill manager, so his death costs no reputation,
        - unarmed,
        - marked COIN_civilianFighter (the interpreter does not question him; the population counts only the civilians it spawned itself) and
          as a COIN unit (COIN_fnc_markCoinUnits; the budget counts COIN units on the enemy side only, so he does not
          touch it, and he spawns whatever the budget says),
        - standing still, facing the given direction, careless (the AI does not run from shots),
        - handed to Zeus.
        Server only.

    Parameter(s):
        _role - What he is, kept in COIN_role ("triggerman") [STRING]
        _pos  - Where he stands, ATL [ARRAY]
        _dir  - Direction he faces [NUMBER]

    Returns:
        The fighter, objNull if not on the server [OBJECT]
*/

params [
    ["_role", "", [""]],
    ["_pos", [0, 0, 0], [[]]],
    ["_dir", 0, [0]]
];

if (!isServer) exitWith {objNull};

private _group = createGroup [GRLIB_side_civilian, true];
private _unit = _group createUnit [selectRandom civilians, _pos, [], 0, "NONE"];
_unit setPosATL _pos;
_unit setDir _dir;
removeAllWeapons _unit;

_unit setVariable ["COIN_civilianFighter", true, true];
_unit setVariable ["COIN_role", _role, true];
[[_unit]] call COIN_fnc_markCoinUnits;

_unit disableAI "PATH";
_unit allowFleeing 0;
_unit setBehaviour "CARELESS";
_unit setUnitPos "UP";

[[_unit]] call COIN_fnc_addToCurators;

_unit
