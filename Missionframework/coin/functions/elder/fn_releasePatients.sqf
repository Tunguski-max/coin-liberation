/*
    File: fn_releasePatients.sqf
    Author: COIN Liberation

    Description:
        Server: the end of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2), whatever the result: the circles go from the
        map, the patients who were not treated are healed (COIN_fnc_healPatient) and everybody stands up (no action any more). Then each one
        is removed as soon as no player within COIN_aidPatientSightDistance can see him, at the latest after
        COIN_aidPatientRemoveSeconds. Must be spawned.

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

// Away when nobody sees him, nobody who stands near and has a line of sight
private _seen = {
    params ["_patient"];
    (allPlayers - entities "HeadlessClient_F") findIf {
        alive _x
        && {(_x distance _patient) <= COIN_aidPatientSightDistance}
        && {(checkVisibility [eyePos _x, eyePos _patient]) > COIN_aidPatientSightMinVisibility}
    } >= 0
};

private _end = time + COIN_aidPatientRemoveSeconds;
private _left = _patients select {!isNull _x};
while {_left isNotEqualTo [] && {time < _end}} do {
    sleep COIN_aidCheckSeconds;
    {
        if (!isNull _x && {!([_x] call _seen)}) then {
            deleteVehicle _x;
        };
    } forEach _left;
    _left = _left select {!isNull _x};
};
{deleteVehicle _x} forEach _left;

diag_log format ["[COIN] aid: %1 patients removed", count _patients];
