/*
    File: fn_treatPatient.sqf
    Author: COIN Liberation

    Description:
        Server: a player treated a patient of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2). Called with
        remoteExecCall by the action of COIN_fnc_addPatientAction, which has taken the bandage. Only a patient still
        waiting for treatment counts (COIN_patientOpen), so two players at once treat him once. The patient is healed
        (the protection against damage is lifted for that moment and back), kneels like Liberation's treated civilians
        and then stands up (the AI for the animation is switched on again, he stays where he is), his circle is
        removed from the map and COIN_repAidPatient reputation is given. The task (COIN_fnc_runAidTask) sees that all
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

if (!isServer) exitWith {false};
// remoteExecCall runs unscheduled, the animation needs to wait
if (!canSuspend) exitWith {_this spawn COIN_fnc_treatPatient; true};

if (
    isNull _patient
    || {!(_patient getVariable ["COIN_patientOpen", false])}
    || {(damage _patient) < 0.5}
) exitWith {false};

_patient setVariable ["COIN_patientOpen", false];

_patient allowDamage true;
_patient setDamage 0;
_patient allowDamage false;

deleteMarker (_patient getVariable ["COIN_patientMarker", ""]);

private _town = _patient getVariable ["COIN_patientTown", ""];
[COIN_repAidPatient, format ["aid task medical aid: patient treated in %1 by %2", _town, _by]] call COIN_fnc_changeReputation;
diag_log format ["[COIN] aid: a patient in %1 was treated by %2", _town, _by];

[_patient, "AinjPpneMstpSnonWnonDnon_kneel"] remoteExec ["switchMove"];
sleep 2;
if (!isNull _patient) then {
    _patient enableAI "ANIM";
};

true
