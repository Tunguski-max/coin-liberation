/*
    File: fn_holdCivilian.sqf
    Author: COIN Liberation

    Description:
        Makes a civilian stand still and watch the interpreter for a while, so he does not walk away during the
        conversation (ticket 3.1). Must run where the civilian is local, so callers use remoteExecCall with the civilian
        as target. The hold ends at its time, or at once with a duration of 0 or less. A second call extends it. Waypoints
        of the civilian's group are kept: only his path-finding is switched off, so he walks on afterwards.

    Parameter(s):
        _civ      - Civilian [OBJECT, defaults to objNull]
        _asker    - Unit he watches, objNull for nobody [OBJECT, defaults to objNull]
        _duration - Seconds to hold, 0 or less ends the hold [NUMBER, defaults to 0]

    Returns:
        Civilian is held [BOOL]
*/

params [
    ["_civ", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_duration", 0, [0]]
];

if (isNull _civ || {!alive _civ} || {!local _civ}) exitWith {false};

if (_duration <= 0) exitWith {
    // The watcher below notices the end and releases him
    _civ setVariable ["COIN_holdEnd", 0];
    false
};

private _active = (_civ getVariable ["COIN_holdEnd", 0]) > time;
_civ setVariable ["COIN_holdEnd", time + _duration];
if (!isNull _asker) then {
    _civ doWatch _asker;
};
if (_active) exitWith {true};

_civ disableAI "PATH";
[_civ] spawn {
    params ["_civ"];
    waitUntil {
        sleep 0.5;
        !alive _civ || {time >= (_civ getVariable ["COIN_holdEnd", 0])}
    };
    if (alive _civ) then {
        _civ enableAI "PATH";
        _civ doWatch objNull;
    };
    if (COIN_debug) then {
        diag_log format ["[COIN] intel: civilian %1 released", name _civ];
    };
};

true
