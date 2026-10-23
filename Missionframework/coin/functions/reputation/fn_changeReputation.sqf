/*
    File: fn_changeReputation.sqf
    Author: COIN Liberation

    Description:
        The one way for the COIN layer to change the reputation (ticket 5.1, ADR 0009, DESIGN 8). Goes through
        Liberation's F_cr_changeCR, which clamps the value to -100 .. +100 and applies the standing of the resistance.
        Writes one log line with the reason, the amount and the new value. The reputation is hidden, so players get
        no message; with COIN_debug a system chat line with the same text goes to every player.
        An amount of 0 changes nothing and logs nothing: a config value of 0 switches that change off.
        Server only.

    Parameter(s):
        _amount - Change, positive or negative; 0 does nothing [NUMBER]
        _reason - Why, for the log and the debug chat, e.g. "nest 3 destroyed" [STRING]

    Returns:
        Reputation was changed [BOOL]
*/

params [
    ["_amount", 0, [0]],
    ["_reason", "", [""]]
];

if (!isServer || {_amount == 0}) exitWith {false};

if (isNil "F_cr_changeCR") exitWith {
    diag_log format ["[COIN] reputation: ERROR - %1 (%2), but Liberation's F_cr_changeCR is missing", _reason, _amount];
    false
};

[abs _amount, _amount < 0] call F_cr_changeCR;

private _text = format [
    "%1: reputation %2%3, now %4",
    _reason, ["", "+"] select (_amount > 0), _amount, KP_liberation_civ_rep
];
diag_log format ["[COIN] reputation: %1", _text];

if (COIN_debug) then {
    [format ["[COIN] %1", _text]] remoteExecCall ["systemChat", 0];
};

true
