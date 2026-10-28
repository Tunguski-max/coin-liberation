/*
    File: fn_pickReinforcementPoint.sqf
    Author: COIN Liberation

    Description:
        Client: the interpreter picks the target point of the reinforcement on the map (ticket 5.6, DESIGN 8.1), after he accepted the
        favor in the dialog of the elder (COIN_fnc_openElderDialog), like the point of Liberation's HALO jump. The map opens at the
        elder with a circle of COIN_reinforcementMaxDistance. A click outside the circle or in water is refused with a hint and the
        map stays open. A valid click closes the map and sends the request to the server (COIN_fnc_requestReinforcement), which
        checks everything again and takes the favor and the intel points. Closing the map (Esc), walking away from the elder or dying
        cancels it and costs nothing. Must be spawned.

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

private _index = [1, 0] select (language isEqualTo "German");
private _say = {
    params ["_key"];
    private _row = [COIN_reinforcementPickTexts, _key] call COIN_fnc_findByType;
    hint ((_row param [1, ["", ""]]) select _index);
};

private _centre = getPosATL _elder;
private _marker = createMarkerLocal ["COIN_reinforcementRange", _centre];
_marker setMarkerShapeLocal "ELLIPSE";
_marker setMarkerSizeLocal [COIN_reinforcementMaxDistance, COIN_reinforcementMaxDistance];
_marker setMarkerBrushLocal "Border";
_marker setMarkerColorLocal "ColorBlue";

// The click only stores the point, the loop below judges it
COIN_reinforcementPick = [];
private _handler = addMissionEventHandler ["MapSingleClick", {
    params ["", "_pos"];
    COIN_reinforcementPick = _pos;
}];

openMap [true, false];
mapAnimAdd [0.3, COIN_reinforcementMapZoom, _centre];
mapAnimCommit;
// The map may need a moment to open
private _opened = time + 2;
waitUntil {visibleMap || time > _opened};

private _target = [];
if (visibleMap) then {
    ["start"] call _say;
    private _range = COIN_talkRange + COIN_talkRangeMargin;
    private _away = false;
    while {visibleMap && {alive player} && {_target isEqualTo []} && {!_away}} do {
        if (COIN_reinforcementPick isNotEqualTo []) then {
            private _pos = COIN_reinforcementPick;
            COIN_reinforcementPick = [];
            if (surfaceIsWater _pos) then {
                ["water"] call _say;
            } else {
                if ((_pos distance2D _centre) > COIN_reinforcementMaxDistance) then {
                    ["far"] call _say;
                } else {
                    _target = +_pos;
                };
            };
        };
        if (!alive _elder || {(player distance _elder) > _range}) then {
            _away = true;
            ["away"] call _say;
        };
        sleep 0.1;
    };
};

removeMissionEventHandler ["MapSingleClick", _handler];
deleteMarkerLocal _marker;
COIN_reinforcementPick = [];
if (visibleMap) then {openMap [false, false]};

if (_target isEqualTo []) exitWith {false};

hint "";
[_elder, player, _target] remoteExecCall ["COIN_fnc_requestReinforcement", 2];

true
