/*
    File: fn_releasePatients.sqf
    Author: COIN Liberation

    Description:
        Server: the end of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2), whatever the result: the circles go from the
        map, the patients who were not treated are healed (COIN_fnc_healPatient) and everybody stands up (no action
        any more). Then the patients are removed when nobody sees them (COIN_fnc_removeWhenUnseen). Must be spawned.

    Parameter(s):
        _patients - The patients [ARRAY of OBJECTs, defaults to []]
        _markers  - Their circles [ARRAY of STRINGs, defaults to []]

    Returns:
        NONE
*/

params [
    ["_patients", [], [[]]],
    ["_markers", [], [[]]]
];

if (!isServer) exitWith {};

{deleteMarker _x} forEach _markers;

{
    if (!isNull _x && {_x getVariable ["COIN_patientOpen", false]}) then {
        [_x] call COIN_fnc_healPatient;
    };
} forEach _patients;

[_patients, "patients"] call COIN_fnc_removeWhenUnseen;
