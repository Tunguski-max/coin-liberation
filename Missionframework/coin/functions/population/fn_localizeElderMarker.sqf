/*
    File: fn_localizeElderMarker.sqf
    Author: COIN Liberation

    Description:
        Client: the text of the marker of an elder (COIN_fnc_markElder) in the game language of this machine (ticket 7.0c, #180,
        ADR 0026). The server makes the global marker with the name of the town as text, which nobody needs to translate;
        setMarkerTextLocal changes it on this machine to the name of the elder, e.g. "Elder of Kiffu" or "Ältester von Kiffu".
        Sent with remoteExec (scheduled) and the marker as JIP key, so a late joiner gets it as well; a marker that has not arrived yet is waited for up to 10 s.

    Parameter(s):
        _marker - Name of the global marker [STRING, defaults to ""]
        _town   - Name of the town [STRING, defaults to ""]

    Returns:
        The text was set [BOOL]
*/

params [
    ["_marker", "", [""]],
    ["_town", "", [""]]
];

if (!hasInterface || {_marker isEqualTo ""}) exitWith {false};

// A late joiner runs this before the markers have arrived; wait a short while for it (the call is scheduled, remoteExec)
if (markerType _marker isEqualTo "" && {canSuspend}) then {
    private _until = time + 10;
    waitUntil {sleep 0.5; markerType _marker isNotEqualTo "" || {time > _until}};
};
if (markerType _marker isEqualTo "") exitWith {false};

_marker setMarkerTextLocal format [localize "STR_COIN_elder_name", _town];

true
