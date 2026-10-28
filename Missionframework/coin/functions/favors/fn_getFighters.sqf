/*
    File: fn_getFighters.sqf
    Author: COIN Liberation

    Description:
        The fighters of a group of the reinforcement who are alive (tickets 5.6 and 5.19). A unit that was deleted (Zeus) or killed
        is not in the list; an unconscious one is.

    Parameter(s):
        _group - The group [GROUP, defaults to grpNull]

    Returns:
        The units that are alive [ARRAY of OBJECTs]
*/

params [
    ["_group", grpNull, [grpNull]]
];

(units _group) select {alive _x}
