/*
    File: fn_healPatient.sqf
    Author: COIN Liberation

    Description:
        Server: heals a patient of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2): he no longer waits for treatment
        (COIN_patientOpen is public, so the action disappears), his circle is removed from the map, the protection
        against damage is lifted for the moment of healing and put back, and he kneels like Liberation's treated
        civilians and stands up after COIN_aidMedicalStandUpSeconds (the AI for the animation is switched on, he stays
        where he is). Used when a player treated him (COIN_fnc_treatPatient) and for those nobody treated at the end
        of the task (COIN_fnc_releasePatients).

    Parameter(s):
        _patient - The patient [OBJECT, defaults to objNull]

    Returns:
        The patient was healed [BOOL]
*/

params [
    ["_patient", objNull, [objNull]]
];

if (!isServer || {isNull _patient}) exitWith {false};

_patient setVariable ["COIN_patientOpen", false, true];
deleteMarker (_patient getVariable ["COIN_patientMarker", ""]);

_patient allowDamage true;
_patient setDamage 0;
_patient allowDamage false;

[_patient, COIN_aidMedicalTreatedAnim] remoteExec ["switchMove"];
[_patient] spawn {
    params ["_patient"];
    sleep COIN_aidMedicalStandUpSeconds;
    if (!isNull _patient) then {
        _patient enableAI "ANIM";
    };
};

true
