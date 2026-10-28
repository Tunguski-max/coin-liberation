/*
    File: fn_getMilitiaTowns.sqf
    Author: COIN Liberation

    Description:
        The places the militia holds (tickets 5.14, 5.16 and 5.18): the sectors of sectors_capture that are not in blufor_sectors, with
        _capital also the capital (sectors_bigtown, a list of its own in Liberation), with _military also the military posts
        (sectors_military). Server only.

    Parameter(s):
        _capital  - The capital counts [BOOL, defaults to false]
        _military - The military posts count [BOOL, defaults to false]

    Returns:
        Marker names of the sectors [ARRAY of STRINGs]
*/

params [
    ["_capital", false, [false]],
    ["_military", false, [false]]
];

if (isNil "sectors_capture") exitWith {[]};

private _places = +sectors_capture;
if (_capital && {!isNil "sectors_bigtown"}) then {_places append sectors_bigtown};
if (_military && {!isNil "sectors_military"}) then {_places append sectors_military};

_places select {!(_x in (missionNamespace getVariable ["blufor_sectors", []]))}
