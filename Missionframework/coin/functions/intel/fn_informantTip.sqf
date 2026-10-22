/*
    File: fn_informantTip.sqf
    Author: COIN Liberation

    Description:
        Liberation's informant brings a concrete tip when he is handed in at the FOB (ticket 3.10, DESIGN 7, ADR 0011).
        Called by the hook in civinfo_delivered.sqf, in addition to Liberation's reward, which stays as it is. The tip is
        never a lie and counts as a true hit (a nest that has a circle already gets a smaller one, COIN_fnc_createIntel).
        The nest is the active nest nearest to the town of the informant (his start position, kept by the hook in
        civinfo_loop.sqf as COIN_home) that has no circle yet; if every active nest has one, the nearest active nest.
        Announced to everybody like any new intel. Server only.

    Parameter(s):
        _informant - The informant who has been delivered [OBJECT, defaults to objNull]

    Returns:
        The intel record, [] if there was no nest or the feature is off [ARRAY]
*/

params [
    ["_informant", objNull, [objNull]]
];

if (!isServer || {!COIN_enableInformantTip} || {isNil "COIN_nests"} || {isNil "COIN_intel"}) exitWith {[]};

// Without the hook in civinfo_loop.sqf he has no home: his position (the FOB) is the best there is
private _home = _informant getVariable ["COIN_home", getPosATL _informant];

private _active = COIN_nests select {(_x select 5) isEqualTo "active"};
if (_active isEqualTo []) exitWith {
    diag_log "[COIN] intel: informant delivered, but no nest is active, no tip";
    []
};

private _marked = COIN_intel apply {_x select 1};
private _unmarked = _active select {!((_x select 0) in _marked)};
private _pool = [_active, _unmarked] select !(_unmarked isEqualTo []);
private _nest = ([_pool, [], {(_x select 3) distance2D _home}, "ASCEND"] call BIS_fnc_sortBy) select 0;

private _intel = [_nest, "tip"] call COIN_fnc_createIntel;
if (_intel isEqualTo []) exitWith {
    diag_log format ["[COIN] intel: ERROR - informant tip about nest %1 could not be made", _nest select 0];
    []
};

diag_log format [
    "[COIN] intel: informant tip about nest %1 (%2), %3 m from his town, %4, circle of %5 m at %6 (intel %7)",
    _nest select 0, _nest select 1, round ((_nest select 3) distance2D _home),
    ["nest without a circle", "all nests had a circle, the nearest one"] select (_unmarked isEqualTo []),
    _intel select 3, _intel select 2, _intel select 0
];
["intel"] remoteExecCall ["COIN_fnc_showNotification", 0];

_intel
