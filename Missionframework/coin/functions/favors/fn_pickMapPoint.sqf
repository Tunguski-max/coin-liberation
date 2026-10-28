/*
    File: fn_pickMapPoint.sqf
    Author: COIN Liberation

    Description:
        Client: the player picks a point on the map (tickets 5.6 and 5.19), like the point of Liberation's HALO jump. The map opens
        at _centre; with _range above 0 a circle of that radius shows the reach, and a click outside it is refused with a hint. A click
        in water is refused too. The map stays open after a refusal. Closing the map (Esc), dying, and with an elder
        walking away from him cancels it. Texts: COIN_reinforcementPickTexts. Must be called from a script that can sleep (spawned).

    Parameter(s):
        _centre   - Where the map opens, and the middle of the circle [POSITION, defaults to [0, 0, 0]]
        _range    - Radius of the reach in m, 0 = no circle and no limit [NUMBER, defaults to 0]
        _elder    - The elder the player must stay near (the dialog of the elder, ticket 5.6), objNull = none [OBJECT, defaults to objNull]
        _startKey - Key of the hint when the map opens, in COIN_reinforcementPickTexts [STRING, defaults to "start"]

    Returns:
        The picked point, [] if it was cancelled [ARRAY]
*/

params [
    ["_centre", [0, 0, 0], [[]]],
    ["_range", 0, [0]],
    ["_elder", objNull, [objNull]],
    ["_startKey", "start", [""]]
];

if (!hasInterface || {!canSuspend}) exitWith {[]};

private _index = [1, 0] select (language isEqualTo "German");
private _say = {
    params ["_key"];
    private _row = [COIN_reinforcementPickTexts, _key] call COIN_fnc_findByType;
    hint ((_row param [1, ["", ""]]) select _index);
};

private _marker = "";
if (_range > 0) then {
    _marker = createMarkerLocal ["COIN_reinforcementRange", _centre];
    _marker setMarkerShapeLocal "ELLIPSE";
    _marker setMarkerSizeLocal [_range, _range];
    _marker setMarkerBrushLocal "Border";
    _marker setMarkerColorLocal "ColorBlue";
};

// The click only stores the point, the loop below judges it
COIN_reinforcementPick = [];
private _handler = addMissionEventHandler ["MapSingleClick", {
    params ["", "_pos"];
    COIN_reinforcementPick = _pos;
}];

openMap [true, false];
mapAnimAdd [0, COIN_reinforcementMapZoom, _centre];
mapAnimCommit;
// The map may need a moment to open
private _opened = time + COIN_reinforcementMapWaitSeconds;
waitUntil {visibleMap || time > _opened};

private _target = [];
if (visibleMap) then {
    [_startKey] call _say;
    private _near = COIN_talkRange + COIN_talkRangeMargin;
    private _away = false;
    while {visibleMap && {alive player} && {_target isEqualTo []} && {!_away}} do {
        if (COIN_reinforcementPick isNotEqualTo []) then {
            private _pos = COIN_reinforcementPick;
            COIN_reinforcementPick = [];
            if (surfaceIsWater _pos) then {
                ["water"] call _say;
            } else {
                if (_range > 0 && {(_pos distance2D _centre) > _range}) then {
                    ["far"] call _say;
                } else {
                    _target = +_pos;
                };
            };
        };
        if (!isNull _elder && {!alive _elder || {(player distance _elder) > _near}}) then {
            _away = true;
            ["away"] call _say;
        };
        sleep 0.1;
    };
};

removeMissionEventHandler ["MapSingleClick", _handler];
if (_marker isNotEqualTo "") then {deleteMarkerLocal _marker};
COIN_reinforcementPick = [];
if (visibleMap) then {openMap [false, false]};
hint "";

_target
