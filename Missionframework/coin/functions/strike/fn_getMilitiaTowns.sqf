/*
    File: fn_getMilitiaTowns.sqf
    Author: COIN Liberation

    Description:
        The towns the militia holds (tickets 5.14, 5.16 and 5.18): the sectors of sectors_capture that are not in blufor_sectors, with
        _capital also the capital (sectors_bigtown, a list of its own in Liberation). Server only.

    Parameter(s):
        _capital - The capital counts as a town [BOOL, defaults to false]

    Returns:
        Marker names of the sectors [ARRAY of STRINGs]
*/

params [
    ["_capital", false, [false]]
];

if (isNil "sectors_capture") exitWith {[]};

private _towns = +sectors_capture;
if (_capital && {!isNil "sectors_bigtown"}) then {_towns append sectors_bigtown};

_towns select {!(_x in (missionNamespace getVariable ["blufor_sectors", []]))}
