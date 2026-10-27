/*
    File: fn_loadAmmoCrates.sqf
    Author: COIN Liberation

    Description:
        Server: loads a truck with ammo crates as Liberation's convoy hijack mission does (ticket 5.16): as many Liberation ammo crates
        (COIN_convoyCrateValue each) as the truck takes by KPLIB_transportConfigs, each attached at the offset the config gives, with the
        loaded count in GRLIB_ammo_truck_load as Liberation's own loading keeps it. It does what Liberation's loading script
        (scripts\client\ammoboxes\do_load_box.sqf) does, but without its hints and waits, which are made for a player at the machine.
        Must be called where it may wait (scheduled).

    Parameter(s):
        _truck - The truck, standing [OBJECT, defaults to objNull]

    Returns:
        The crates [ARRAY of OBJECTs], [] if the truck takes none (no entry in KPLIB_transportConfigs)
*/

params [
    ["_truck", objNull, [objNull]]
];

if (!isServer || {isNull _truck}) exitWith {[]};

// An entry is [class, ?, offset of crate 1, offset of crate 2, ...]: the offsets start at the third place
private _config = KPLIB_transportConfigs select {(_x select 0) isEqualTo (typeOf _truck)};
if (_config isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: the truck %1 takes no ammo crates (no entry in KPLIB_transportConfigs)", typeOf _truck];
    []
};
private _offsets = (_config select 0) select [2, count (_config select 0)];

private _crates = [];
{
    // The pauses of Liberation's loop: before the crate is made, and before it is loaded
    sleep COIN_convoyCrateWait;
    private _crate = [KP_liberation_ammo_crate, COIN_convoyCrateValue, getPosATL _truck] call KPLIB_fnc_createCrate;
    sleep COIN_convoyCrateWait;
    if (!isNull _crate) then {
        _crate attachTo [_truck, _x];
        [_crate, false] remoteExec ["enableRopeAttach"];
        _crates pushBack _crate;
        _truck setVariable ["GRLIB_ammo_truck_load", count _crates, true];
    };
} forEach _offsets;

_crates
