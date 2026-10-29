/*
    File: fn_setElderName.sqf
    Author: COIN Liberation

    Description:
        Client: gives the elder of a town his name in the game language of this machine (ticket 7.0c, #180, ADR 0026): the key
        STR_COIN_elder_name with the name of the town, e.g. "Elder of Kiffu" or "Ältester von Kiffu". setName has a local effect, so
        the server sends it to every machine with remoteExecCall and the elder as JIP key (COIN_fnc_spawnElder), and every
        player reads the name in his own language: in the subtitle of the elder and in the logs of this machine.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]
        _town  - Name of the town (a name of the map, not translated) [STRING, defaults to ""]

    Returns:
        The name was set [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_town", "", [""]]
];

if (isNull _elder) exitWith {false};

_elder setName format [localize "STR_COIN_elder_name", _town];

true
