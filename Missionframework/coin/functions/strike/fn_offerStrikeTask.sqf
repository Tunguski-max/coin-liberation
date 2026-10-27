/*
    File: fn_offerStrikeTask.sqf
    Author: COIN Liberation

    Description:
        Server: tells of a strike task that COIN_fnc_decideStrikeTask has offered (tickets 5.13 and 5.14, DESIGN 8.2). The one who
        spoke tells of it (a sentence "strike_<kind>" as a subtitle) and after COIN_strikeDialogDelay seconds the dialog of the
        elder opens for the interpreter with this one entry (COIN_fnc_openElderDialog, mode "strike"). Closing it without "Accept"
        loses the offer. Must be spawned. Server only.

    Parameter(s):
        _speaker - Civilian or prisoner who told the interpreter [OBJECT, defaults to objNull]
        _asker   - Interpreter [OBJECT, defaults to objNull]
        _kind    - Kind of strike task, a key of COIN_strikeKinds [STRING, defaults to ""]

    Returns:
        The dialog was sent [BOOL]
*/

params [
    ["_speaker", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_kind", "", [""]]
];

if (!isServer || {isNull _asker} || {_kind isEqualTo ""}) exitWith {false};

[_speaker, format ["strike_%1", _kind]] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];
sleep COIN_strikeDialogDelay;

// The dialog of the elder with this one entry: [id, section, can be accepted, reason key, reason value, place, site]
[_speaker, "", [[_kind, "strike", true, "", 0, "", []]], count COIN_strikeActive, "strike"] remoteExecCall ["COIN_fnc_openElderDialog", owner _asker];

true
