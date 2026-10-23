/*
    File: fn_checkDefused.sqf
    Author: COIN Liberation

    Description:
        Was the IED that is gone defused? (ticket 4.2a, 4.1b, DESIGN 6 and 8) A defusing leaves an item on the ground
        (a ground holder with nothing but IED magazines, class name starts with "IED"), a blast or a deletion does not.
        Looks twice (COIN_iedLootDelays, the item appears a moment after the defusing) within COIN_iedLootRadius of
        the IED. Finding the item means "defused":
        - a real IED gives COIN_repIEDDefused reputation (COIN_fnc_changeReputation), once per IED,
        - a decoy gives nothing,
        - the item is deleted (the army does not collect explosives), unless COIN_enableIEDLootRemoval is off.
        A holder with anything else in it is left alone. One log line per defusing and per deleted holder.
        Must be spawned. Server only.

    Parameter(s):
        _pos     - Position of the IED that is gone [ARRAY]
        _id      - IED id, for the log [NUMBER]
        _nestId  - Id of the workshop, for the log [NUMBER]
        _variant - "buried", "decoy" or "remote" [STRING]

    Returns:
        Nothing
*/

params [
    ["_pos", [], [[]]],
    ["_id", -1, [0]],
    ["_nestId", -1, [0]],
    ["_variant", "buried", [""]]
];

if (!isServer) exitWith {};

private _defused = false;
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
            if (!_defused) then {
                _defused = true;
                private _reward = [COIN_repIEDDefused, 0] select (_variant isEqualTo "decoy");
                if (_reward == 0) then {
                    diag_log format ["[COIN] ieds: IED %1 (%2, nest %3) defused, no reputation", _id, _variant, _nestId];
                } else {
                    [_reward, format ["IED %1 (%2, nest %3) defused", _id, _variant, _nestId]] call COIN_fnc_changeReputation;
                };
            };

            if (COIN_enableIEDLootRemoval) then {
                diag_log format ["[COIN] ieds: item of IED %1 removed (%2)", _id, _mags joinString ", "];
                deleteVehicle _holder;
            };
        };
    } forEach (nearestObjects [_pos, ["WeaponHolder", "WeaponHolderSimulated"], COIN_iedLootRadius]);
} forEach COIN_iedLootDelays;

if (!_defused) then {
    diag_log format ["[COIN] ieds: IED %1 (%2, nest %3) was not defused (no item found): blast or deletion", _id, _variant, _nestId];
};
