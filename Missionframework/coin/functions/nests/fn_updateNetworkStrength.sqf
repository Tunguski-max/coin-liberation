/*
    File: fn_updateNetworkStrength.sqf
    Author: COIN Liberation

    Description:
        Network strength (ticket 2.6, DESIGN 5, CONTEXT.md): active nests / all nests of the campaign, 0 to 1, every
        nest type counts the same. Calculated from COIN_nests at the server start (COIN_fnc_initNests) and after every
        destruction (event COIN_nestDestroyed). Sets and publishes
        - COIN_networkCounts   [active nests, all nests]
        - COIN_networkStrength the share, published last so a client handler finds the counts up to date,
        so later phases (capital garrison, readiness cap) and every client, late joiners included, can read them.
        One [COIN] line on every change. Without any nest the strength is 0. Nothing is saved: the value follows from the
        saved nests. A local host shows its own debug diary here, because it gets no published value from itself.
        Switched off by COIN_enableNetworkStrength. Server only.

    Parameter(s):
        NONE

    Returns:
        Network strength [NUMBER]
*/

if (!isServer || {isNil "COIN_nests"} || {!COIN_enableNetworkStrength}) exitWith {0};

private _total = count COIN_nests;
private _active = {(_x select 5) isEqualTo "active"} count COIN_nests;
private _strength = if (_total > 0) then {_active / _total} else {0};

private _previous = missionNamespace getVariable ["COIN_networkCounts", []];
COIN_networkCounts = [_active, _total];
COIN_networkStrength = _strength;
publicVariable "COIN_networkCounts";
publicVariable "COIN_networkStrength";

if !(_previous isEqualTo COIN_networkCounts) then {
    diag_log format [
        "[COIN] network: strength %1 (%2 of %3 nests active)",
        _strength toFixed 2, _active, _total
    ];
};

if (hasInterface && {COIN_debug}) then {
    [player] call COIN_fnc_showNetworkStrength;
};

_strength
