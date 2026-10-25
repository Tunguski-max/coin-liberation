/*
    File: fn_markElder.sqf
    Author: COIN Liberation

    Description:
        Marks an elder on the map for everybody for COIN_elderMarkerSeconds (ticket 5.9a, "Where do I find the elder?",
        COIN_fnc_askElder). Asking again while the marker is up starts the time anew. The marker goes early when the
        elder dies or is removed with his town. It is not the debug marker of the elder (COIN_debug), which stays.
        Server only; global marker, so late joiners see it too.

    Parameter(s):
        _elder - Elder [OBJECT, defaults to objNull]

    Returns:
        Marker is up [BOOL]
*/

params [
    ["_elder", objNull, [objNull]]
];

if (!isServer || {isNull _elder} || {!alive _elder}) exitWith {false};

private _marker = format ["COIN_elderHint_%1", netId _elder];
private _running = markerType _marker != "";
_elder setVariable ["COIN_hintEnd", time + COIN_elderMarkerSeconds];
if (_running) exitWith {true};

createMarker [_marker, getPosATL _elder];
_marker setMarkerType "mil_dot";
_marker setMarkerColor "ColorCIV";
_marker setMarkerSize [1, 1];
_marker setMarkerText name _elder;

[_elder, _marker] spawn {
    params ["_elder", "_marker"];
    waitUntil {
        sleep 2;
        !alive _elder || {time >= (_elder getVariable ["COIN_hintEnd", 0])}
    };
    deleteMarker _marker;
};

true
