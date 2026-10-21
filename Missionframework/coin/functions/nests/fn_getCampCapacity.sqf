/*
    File: fn_getCampCapacity.sqf
    Author: COIN Liberation

    Description:
        Camp capacity from the nests (ticket 2.7, DESIGN 5.1, decision E8):
        floor(COIN_campMax x weight of the active nests / weight of all nests), at least 1 while a nest is active,
        at most COIN_campMax. The weight of a nest is COIN_fnc_getCampWeight. Reads COIN_nests, changes nothing.
        Server only.

    Parameter(s):
        NONE

    Returns:
        [capacity, weight of the active nests, weight of all nests] [ARRAY of NUMBERs]
*/

if (!isServer || {isNil "COIN_nests"}) exitWith {[0, 0, 0]};

private _active = 0;
private _total = 0;
{
    private _weight = [_x select 1] call COIN_fnc_getCampWeight;
    _total = _total + _weight;
    if ((_x select 5) isEqualTo "active") then {
        _active = _active + _weight;
    };
} forEach COIN_nests;

// Whole numbers divided first, so 15 of 15 gives exactly 10
private _capacity = 0;
if (_active > 0) then {
    _capacity = (floor ((COIN_campMax * _active) / _total)) max 1;
};

[_capacity min COIN_campMax, _active, _total]
