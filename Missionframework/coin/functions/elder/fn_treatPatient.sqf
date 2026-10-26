/*
    File: fn_treatPatient.sqf
    Author: COIN Liberation

    Description:
        Server: a player treated a patient of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2). Called with
        remoteExecCall by the action of COIN_fnc_addPatientAction, which has taken the bandage. Only a patient still
        waiting for treatment counts (COIN_patientOpen), so two players at once treat him once. The patient is healed
        (COIN_fnc_healPatient) and COIN_repAidPatient reputation is given. The task (COIN_fnc_runAidTask) sees that all
        patients are treated and gives the bonus.

    Parameter(s):
        _patient - The patient [OBJECT, defaults to objNull]
        _by      - Name of the player, for the log [STRING, defaults to ""]

    Returns:
        The patient was treated [BOOL]
*/

params [
    ["_patient", objNull, [objNull]],
    ["_by", "", [""]]
];

if (!isServer || {isNull _patient} || {!(_patient getVariable ["COIN_patientOpen", false])}) exitWith {false};

[_patient] call COIN_fnc_healPatient;

private _town = _patient getVariable ["COIN_patientTown", ""];
[COIN_repAidPatient, format ["aid task medical aid: patient treated in %1 by %2", _town, _by]] call COIN_fnc_changeReputation;
diag_log format ["[COIN] aid: a patient in %1 was treated by %2", _town, _by];

true
