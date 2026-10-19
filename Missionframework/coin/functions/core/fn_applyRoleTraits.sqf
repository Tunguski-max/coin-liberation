/*
    File: fn_applyRoleTraits.sqf
    Author: COIN Liberation

    Description:
        Gives a player unit the ACE abilities of its slot (EOD: repair, medic: ACE medic class).
        The abilities are read from COIN_roleTraits by unit class. Variables set in the Eden
        init field are lost when the player respawns, so this runs at start and after each respawn.

    Parameter(s):
        _unit - Player unit [OBJECT, defaults to objNull]

    Returns:
        Number of variables set [NUMBER]
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!COIN_enableRoleTraits}) exitWith {0};

private _traits = [];
{
    _x params ["_class", "_variables"];
    if (typeOf _unit == _class) exitWith {_traits = _variables};
} forEach COIN_roleTraits;

{
    _x params ["_name", "_value"];
    _unit setVariable [_name, _value, true];
} forEach _traits;

diag_log format ["[COIN] roles: %1 (%2) got %3 trait(s)", typeOf _unit, name _unit, count _traits];

count _traits
