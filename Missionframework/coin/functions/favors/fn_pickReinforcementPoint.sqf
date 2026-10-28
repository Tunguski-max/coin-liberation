/*
    File: fn_pickReinforcementPoint.sqf
    Author: COIN Liberation

    Description:
        Client: the interpreter picks the target point of the reinforcement on the map (ticket 5.6, DESIGN 8.1), after he accepted the
        favor in the dialog of the elder (COIN_fnc_openElderDialog). The map is COIN_fnc_pickMapPoint: it opens at the elder with a
        circle of COIN_reinforcementMaxDistance, a click outside the circle or in water is refused, Esc or walking away from the elder
        cancels it and costs nothing. A valid point is sent to the server (COIN_fnc_requestReinforcement), which checks everything
        again and takes the favor and the intel points. Must be spawned.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]

    Returns:
        A point was sent to the server [BOOL]
*/

params [
    ["_elder", objNull, [objNull]]
];

if (!hasInterface || {isNull _elder}) exitWith {false};
if (!canSuspend) exitWith {_this spawn COIN_fnc_pickReinforcementPoint; true};

private _target = [getPosATL _elder, COIN_reinforcementMaxDistance, _elder] call COIN_fnc_pickMapPoint;
if (_target isEqualTo []) exitWith {false};

[_elder, player, _target] remoteExecCall ["COIN_fnc_requestReinforcement", 2];

true
