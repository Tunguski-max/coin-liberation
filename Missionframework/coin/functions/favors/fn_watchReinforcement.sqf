/*
    File: fn_watchReinforcement.sqf
    Author: COIN Liberation

    Description:
        Server: reports to those who may give radio orders what happens to the reinforcement (ticket 5.19, DESIGN 8.1), every
        COIN_reinforcementCheckSeconds, until the reinforcement is over:
        - "contact": a fighter knows an enemy within COIN_radioContactRange (seen in the last COIN_radioContactAge s),
        - "firefight": a fighter has fired or been hit in the last COIN_radioFightSeconds,
        - "casualties": no more than COIN_radioCasualtyShare of the fighters are able to fight (dead, or unconscious: ACE or the
          game's incapacitated state), once.
        Contact and firefight are reported once per fight: they come again only after COIN_radioQuietSeconds without an enemy and
        without a shot. The message names the grid of the group (COIN_fnc_showRadioReply, keys "contact", "firefight",
        "casualties"). Needs COIN_enableRadio. Must be spawned. Server only.

    Parameter(s):
        _group - The group of the reinforcement, the state is COIN_reinforcement [GROUP, defaults to grpNull]

    Returns:
        NONE
*/

params [
    ["_group", grpNull, [grpNull]]
];

if (!isServer || {isNull _group} || {!COIN_enableRadio}) exitWith {};

// Shots and hits of the fighters are what the loop cannot see by looking
{
    _x addEventHandler ["Fired", {params ["_unit"]; (group _unit) setVariable ["COIN_lastCombat", time]}];
    _x addEventHandler ["Hit", {params ["_unit"]; (group _unit) setVariable ["COIN_lastCombat", time]}];
} forEach (units _group);

// The ones who have the orders hear it
private _tell = {
    params ["_key", "_args"];
    {
        [_key, _args] remoteExecCall ["COIN_fnc_showRadioReply", owner _x];
    } forEach (allPlayers select {[_x] call COIN_fnc_canGiveRadioOrder});
};

private _size = count (units _group);
private _contact = false;
private _fight = false;
private _casualties = false;
// "Never": long before any time the loop sees
private _never = -1e6;
private _lastActive = _never;

while {[_group] call COIN_fnc_isReinforcement} do {
    sleep COIN_reinforcementCheckSeconds;
    private _alive = [_group] call COIN_fnc_getFighters;
    if (_alive isEqualTo []) exitWith {};

    private _enemy = _alive findIf {(_x targets [true, COIN_radioContactRange, [], COIN_radioContactAge]) isNotEqualTo []} >= 0;
    private _shooting = (time - (_group getVariable ["COIN_lastCombat", _never])) <= COIN_radioFightSeconds;
    if (_enemy || _shooting) then {_lastActive = time};
    if ((time - _lastActive) > COIN_radioQuietSeconds) then {
        _contact = false;
        _fight = false;
    };

    private _grid = mapGridPosition (_alive select 0);
    // Shots say more than a sighting: with both in one step only the firefight is reported
    if (_shooting && !_fight) then {
        _fight = true;
        _contact = true;
        ["firefight", [_grid]] call _tell;
        diag_log format ["[COIN] radio: the reinforcement reports a firefight at %1", _grid];
    } else {
        if (_enemy && !_contact) then {
            _contact = true;
            ["contact", [_grid]] call _tell;
            diag_log format ["[COIN] radio: the reinforcement reports enemy contact at %1", _grid];
        };
    };

    private _able = {!(_x getVariable ["ACE_isUnconscious", false]) && {lifeState _x isNotEqualTo "INCAPACITATED"}} count _alive;
    if (!_casualties && {_able <= (_size * COIN_radioCasualtyShare)}) then {
        _casualties = true;
        ["casualties", [_able, _size]] call _tell;
        diag_log format ["[COIN] radio: the reinforcement reports casualties, %1 of %2 able to fight", _able, _size];
    };
};
