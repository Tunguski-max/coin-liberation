/*
    File: fn_loadFighterWeapons.sqf
    Author: COIN Liberation

    Description:
        Arms the local fighters of a reinforcement (ticket 5.6, switch COIN_reinforcementLoadWeapons). Liberation's
        KPLIB_fnc_spawnGuerillaGroup gives a fighter his rifle with addWeapon and puts the magazines with addItemToVest, which does
        nothing when they do not fit (the small vests of tier 1), so the weapon starts empty and the fighter often has no magazine at all.
        For every fighter this function
        - loads the rifle (addPrimaryWeaponItem, needs no room in the inventory) with the magazine of the preset row of his weapon
          (KP_liberation_guerilla_weapons_<tier>, the same row Liberation took), else the first compatible magazine,
        - adds the reserve magazines up to the count of that row (COIN_reinforcementMagazines without a row), and when the vest and uniform
          have no room for them a backpack (COIN_reinforcementBackpack) as Liberation gives for the RPG,
        - loads a launcher without a rocket with the first compatible one.
        A weapon that is loaded already stays as it is. Called by COIN_fnc_requestReinforcement right after the fighters are made.
        Server only.

    Parameter(s):
        _group - Group of the fighters [GROUP, defaults to grpNull]

    Returns:
        [rifles loaded, fighters with a new backpack, launchers loaded, fighters] [ARRAY of NUMBERs]
*/

params [
    ["_group", grpNull, [grpNull]]
];

if (!isServer || {!COIN_reinforcementLoadWeapons} || {isNull _group}) exitWith {[0, 0, 0, 0]};

private _tier = [] call KPLIB_fnc_getResistanceTier;
private _rows = missionNamespace getVariable ["KP_liberation_guerilla_weapons_" + str _tier, []];

private _rifles = 0;
private _backpacks = 0;
private _launchers = 0;
private _units = (units _group) select {alive _x};
{
    private _unit = _x;
    private _weapon = primaryWeapon _unit;
    if (_weapon isNotEqualTo "") then {
        private _row = _rows select {(toLower (_x select 0)) isEqualTo (toLower _weapon)};
        private _magazine = "";
        private _wanted = COIN_reinforcementMagazines;
        if (_row isNotEqualTo []) then {
            _magazine = (_row select 0) select 1;
            _wanted = (_row select 0) select 2;
        } else {
            _magazine = (compatibleMagazines _weapon) param [0, ""];
        };

        if (_magazine isNotEqualTo "") then {
            if (primaryWeaponMagazine _unit isEqualTo []) then {
                _unit addPrimaryWeaponItem _magazine;
                _rifles = _rifles + 1;
            };
            private _have = {(toLower _x) isEqualTo (toLower _magazine)} count (magazines _unit);
            if (_have < _wanted) then {
                _unit addMagazines [_magazine, _wanted - _have];
                _have = {(toLower _x) isEqualTo (toLower _magazine)} count (magazines _unit);
                // No room in the uniform and vest: a backpack for the rest
                if (_have < _wanted && {backpack _unit isEqualTo ""} && {isClass (configFile >> "CfgVehicles" >> COIN_reinforcementBackpack)}) then {
                    _unit addBackpack COIN_reinforcementBackpack;
                    _unit addMagazines [_magazine, _wanted - _have];
                    _backpacks = _backpacks + 1;
                };
            };
        };
    };

    private _launcher = secondaryWeapon _unit;
    if (_launcher isNotEqualTo "" && {secondaryWeaponMagazine _unit isEqualTo []}) then {
        private _compatible = (compatibleMagazines _launcher) apply {toLower _x};
        private _inventory = (magazines _unit) findIf {(toLower _x) in _compatible};
        private _rocket = if (_inventory >= 0) then {(magazines _unit) select _inventory} else {(compatibleMagazines _launcher) param [0, ""]};
        if (_rocket isNotEqualTo "") then {
            if (_inventory >= 0) then {_unit removeMagazine _rocket};
            _unit addSecondaryWeaponItem _rocket;
            _launchers = _launchers + 1;
        };
    };
} forEach _units;

[_rifles, _backpacks, _launchers, count _units]
