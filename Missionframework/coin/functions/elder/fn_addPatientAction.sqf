/*
    File: fn_addPatientAction.sqf
    Author: COIN Liberation

    Description:
        Client: adds the action "Treat" to a patient of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2). Sent by
        COIN_fnc_spawnPatients to all machines with the patient as JIP key. It is Liberation's action for a wounded civilian
        (KPLIB_fnc_crAddAceAction: same text, from 3 m, uses up one of the ACE bandages of COIN_aidMedicalItems) with two
        differences: it shows while the patient waits for treatment (COIN_patientOpen) and the healing is done by the
        server (COIN_fnc_treatPatient). A patient cannot be hurt, and a unit that cannot be hurt may not take the
        setDamage 0 of Liberation's action under ACE (not tried in the game yet), so the server lifts the protection for
        that moment. Any player with a bandage can treat, no medic needed. Without a bandage the player gets Liberation's
        message. If somebody else treated him in the same moment the bandage is lost, as the server decides after it.

    Parameter(s):
        _patient - The patient [OBJECT, defaults to objNull]

    Returns:
        The action was added [BOOL]
*/

params [
    ["_patient", objNull, [objNull]]
];

if (!hasInterface || {isNull _patient}) exitWith {false};

_patient addAction [
    "<t color='#FF0000'>" + localize "STR_CR_ACE_ACTION" + "</t>",
    {
        params ["_target", "_caller"];

        private _items = COIN_aidMedicalItems arrayIntersect (vestItems _caller + uniformItems _caller + backpackItems _caller);

        if (_items isNotEqualTo []) then {
            _caller removeItem (selectRandom _items);
            [_target, name _caller] remoteExecCall ["COIN_fnc_treatPatient", 2];
        } else {
            hint localize "STR_CR_ACE_ACTION_FAIL";
            sleep COIN_aidMedicalHintSeconds;
            hintSilent "";
        };
    },
    nil,
    1.5,
    true,
    true,
    "",
    "alive _target && {_target getVariable ['COIN_patientOpen', false]}",
    3
];

true
