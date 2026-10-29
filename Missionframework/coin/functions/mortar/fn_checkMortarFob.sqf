/*
    File: fn_checkMortarFob.sqf
    Author: COIN Liberation

    Description:
        May a mortar attack hit this FOB? (ticket 6.7a, #158, DESIGN 9, ADR 0025) The FOB must lie in a staging area
        (COIN_fnc_getStagingAreasAt), must not be in its cooldown (COIN_mortarCooldowns, not saved) and at least one
        player must be at the FOB (COIN_mortarFobPlayerRadius). The chance and "one attack at a time" are the
        caller's business. Server only.

    Parameter(s):
        _fob            - Position of the FOB [ARRAY]
        _needPlayer     - A player at the FOB is required [BOOL, defaults to true]
        _ignoreCooldown - The cooldown does not count [BOOL, defaults to false]

    Returns:
        "" if the FOB may be hit, otherwise the reason it may not (for the log) [STRING]
*/

params [
    ["_fob", [], [[]], [2, 3]],
    ["_needPlayer", true, [true]],
    ["_ignoreCooldown", false, [false]]
];

if (!isServer) exitWith {"not on the server"};

if (([_fob] call COIN_fnc_getStagingAreasAt) isEqualTo []) exitWith {"not in a staging area"};

private _left = (COIN_mortarCooldowns getOrDefault [[_fob] call COIN_fnc_mortarFobKey, 0]) - time;
if (!_ignoreCooldown && {_left > 0}) exitWith {format ["cooldown, %1 s left", round _left]};

private _players = (allPlayers - entities "HeadlessClient_F") select {alive _x && {(_x distance2D _fob) <= COIN_mortarFobPlayerRadius}};
if (_needPlayer && {_players isEqualTo []}) exitWith {"no player at the FOB"};

""
