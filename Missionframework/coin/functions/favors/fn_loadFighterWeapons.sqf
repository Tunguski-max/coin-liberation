/*
    File: fn_loadFighterWeapons.sqf
    Author: COIN Liberation

    Description:
        Loads the weapons of the local fighters of a reinforcement (ticket 5.6, switch COIN_reinforcementLoadWeapons). Liberation's
        KPLIB_fnc_spawnGuerillaGroup gives a fighter his rifle with addWeapon and puts the magazines only into the vest
        (addItemToVest), so every weapon starts empty and the fighter has to reload first. Here a fighter whose rifle or launcher has
        no magazine takes a compatible one from his inventory and loads it into the weapon (the magazine is moved, not added: the
        vest has one less). A weapon that is loaded already, or without a compatible magazine in the inventory, is left alone.
        Called by COIN_fnc_requestReinforcement right after the fighters are made. Server only.

    Parameter(s):
        _group - Group of the fighters [GROUP, defaults to grpNull]

    Returns:
        [rifles loaded, launchers loaded, fighters] [ARRAY of NUMBERs]
*/

params [
    ["_group", grpNull, [grpNull]]
];

if (!isServer || {!COIN_reinforcementLoadWeapons} || {isNull _group}) exitWith {[0, 0, 0]};

// Moves a compatible magazine of the inventory into the weapon; true if one was loaded
private _load = {
    params ["_unit", "_weapon", "_loadedMagazines", "_slot"];
    if (_weapon isEqualTo "" || {_loadedMagazines isNotEqualTo []}) exitWith {false};
    private _compatible = (compatibleMagazines _weapon) apply {toLower _x};
    private _index = (magazines _unit) findIf {(toLower _x) in _compatible};
    if (_index < 0) exitWith {false};
    private _class = (magazines _unit) select _index;
    _unit removeMagazine _class;
    if (_slot isEqualTo "primary") then {_unit addPrimaryWeaponItem _class} else {_unit addSecondaryWeaponItem _class};
    true
};

private _rifles = 0;
private _launchers = 0;
private _units = (units _group) select {alive _x};
{
    if ([_x, primaryWeapon _x, primaryWeaponMagazine _x, "primary"] call _load) then {_rifles = _rifles + 1};
    if ([_x, secondaryWeapon _x, secondaryWeaponMagazine _x, "secondary"] call _load) then {_launchers = _launchers + 1};
} forEach _units;

[_rifles, _launchers, count _units]
