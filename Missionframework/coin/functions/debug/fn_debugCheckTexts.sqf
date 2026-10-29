/*
    File: fn_debugCheckTexts.sqf
    Author: COIN Liberation

    Description:
        Debug console (ticket 7.0c, #180, ADR 0026): checks that every key of the COIN package that a config variable names exists in
        the stringtable of this mission. Walks all variables COIN_* of the mission namespace (strings, arrays of strings, nested
        arrays), collects the strings that start with STR_COIN_ and asks isLocalized for each. A key that is missing would show itself
        as text in the game. One [COIN] line gives the numbers, one line per missing key and the variable it is in, and a system chat
        line the result. Works on every machine, the server has the stringtable as well.
        Call it with [] call COIN_fnc_debugCheckTexts.

    Parameter(s):
        None

    Returns:
        Number of missing keys [NUMBER]
*/

private _collect = {};
_collect = {
    params ["_value", "_variable", "_found"];
    if (_value isEqualType "") then {
        if ((_value select [0, 9]) isEqualTo "STR_COIN_") then {_found pushBack [_value, _variable]};
    } else {
        if (_value isEqualType []) then {
            {[_x, _variable, _found] call _collect} forEach _value;
        };
    };
};

private _found = [];
{
    [missionNamespace getVariable [_x, nil], _x, _found] call _collect;
} forEach ((allVariables missionNamespace) select {(_x select [0, 5]) isEqualTo "coin_"});

private _missing = _found select {!(isLocalized (_x select 0))};
{
    diag_log format ["[COIN] debug: check texts: key %1 of %2 is missing in the stringtable", _x select 0, _x select 1];
} forEach _missing;

private _result = format ["%1 keys named by the config, %2 missing", count _found, count _missing];
diag_log format ["[COIN] debug: check texts: %1", _result];
systemChat format ["[COIN] texts: %1", _result];

count _missing
