/*
    File: fn_removeIEDLoot.sqf
    Author: COIN Liberation

    Description:
        Removes the item the game leaves when an IED is defused (ticket 4.1b, DESIGN 6: the army does not collect
        explosives). Looks twice (COIN_iedLootDelays, the item appears a moment after the defusing) within
        COIN_iedLootRadius of the IED for ground holders and deletes those that hold only IED magazines (class name
        starts with "IED"). A holder with anything else in it stays. After a blast there is nothing to find. One log
        line per deleted holder. Switched off by COIN_enableIEDLootRemoval. Must be spawned. Server only.

    Parameter(s):
        _pos - Position of the IED that is gone [ARRAY]
        _id  - IED id, for the log [NUMBER]

    Returns:
        Nothing
*/

params [
    ["_pos", [], [[]]],
    ["_id", -1, [0]]
];

if (!isServer || {!COIN_enableIEDLootRemoval}) exitWith {};

private _waited = 0;
{
    sleep (_x - _waited);
    _waited = _x;

    {
        private _holder = _x;
        private _mags = magazineCargo _holder;
        if (
            _mags isNotEqualTo [] &&
            {(weaponCargo _holder) isEqualTo []} &&
            {(itemCargo _holder) isEqualTo []} &&
            {(backpackCargo _holder) isEqualTo []} &&
            {(_mags findIf {((toLower _x) find "ied") != 0}) < 0}
        ) then {
            diag_log format ["[COIN] ieds: item of IED %1 removed (%2)", _id, _mags joinString ", "];
            deleteVehicle _holder;
        };
    } forEach (nearestObjects [_pos, ["WeaponHolder", "WeaponHolderSimulated"], COIN_iedLootRadius]);
} forEach COIN_iedLootDelays;
