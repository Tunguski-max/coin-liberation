/*
    File: fn_spawnPatients.sqf
    Author: COIN Liberation

    Description:
        Server: makes the patients of an aid task "Medical aid" (ticket 5.11, DESIGN 8.2): COIN_aidMedicalPatients civilians
        (rolled), each at a free spot COIN_aidMedicalRadius from the elder's place, or the centre of the village (BIS_fnc_findSafePos, at least
        COIN_aidMedicalSpacing from each other if the tries allow it). They are made like Liberation's wounded civilians
        after a town was taken (civrep_wounded_civs.sqf): preset list civilians, damaged, Liberation's wounded animation
        (F_cr_woundedAnim), AI switched off, and a circle on the map near each. Unlike those they cannot be hurt (allowDamage
        false), they are not part of the town's population (no budget) and cannot be questioned (COIN_patient, see
        COIN_fnc_canQuestion). Every client gets the action "Treat" (COIN_fnc_addPatientAction) with the patient as JIP key,
        so a late joiner gets it too. Handed to Zeus. The patients are treated through COIN_fnc_treatPatient and handed back
        by COIN_fnc_releasePatients.

    Parameter(s):
        _taskId - Id of the Arma task, for the names of the markers [STRING, defaults to ""]
        _town   - Name of the town or village, for the log [STRING, defaults to ""]
        _pos    - Where the elder stands, or with a site (ticket 5.21) the village centre [ARRAY, defaults to [0, 0, 0]]

    Returns:
        [patients, markers] [ARRAY of ARRAYs]
*/

params [
    ["_taskId", "", [""]],
    ["_town", "", [""]],
    ["_pos", [0, 0, 0], [[]]]
];

if (!isServer || {_taskId isEqualTo ""}) exitWith {[[], []]};

if (isNil "F_cr_woundedAnim") then {
    diag_log "[COIN] aid: ERROR - Liberation's F_cr_woundedAnim is missing, the patients stand";
};

COIN_aidMedicalPatients params ["_min", "_max"];
COIN_aidMedicalRadius params ["_minRadius", "_maxRadius"];
private _count = _min + floor (random ((_max - _min) + 1));

private _group = createGroup [GRLIB_side_civilian, true];
private _patients = [];
private _markers = [];
private _spots = [];

for "_i" from 1 to _count do {
    // A free spot away from the other patients; after the tries the last one is taken
    private _spot = _pos;
    for "_try" from 1 to COIN_aidMedicalSpotTries do {
        _spot = [_pos, _minRadius, _maxRadius, COIN_aidMedicalSpotClearance, 0, COIN_aidMedicalMaxGradient, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
        if ((_spots findIf {(_x distance2D _spot) < COIN_aidMedicalSpacing}) < 0) exitWith {};
    };
    _spots pushBack _spot;

    private _patient = [selectRandom civilians, _spot, _group] call KPLIB_fnc_createManagedUnit;
    if (isNull _patient) then {
        diag_log format ["[COIN] aid: ERROR - patient %1 in %2 could not be created", _i, _town];
        continue;
    };

    _patient setDir (random 360);
    _patient setPosATL [_spot select 0, _spot select 1, 0];
    {_patient disableAI _x} forEach ["ANIM", "TARGET", "AUTOTARGET", "MOVE"];
    removeAllItems _patient;
    // Hurt first, invulnerable after (an unhurt unit shows no wounded look)
    _patient setDamage COIN_aidMedicalHurtDamage;
    if (!isNil "F_cr_woundedAnim") then {
        _patient call F_cr_woundedAnim;
    };
    _patient allowDamage false;

    private _marker = createMarker [
        format ["COIN_patient_%1_%2", _taskId, _i],
        [
            (_spot select 0) - COIN_aidMedicalCircleOffset + (random (2 * COIN_aidMedicalCircleOffset)),
            (_spot select 1) - COIN_aidMedicalCircleOffset + (random (2 * COIN_aidMedicalCircleOffset))
        ]
    ];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [COIN_aidMedicalCircleSize, COIN_aidMedicalCircleSize];
    _marker setMarkerColor "ColorCIV";
    _marker setMarkerAlpha COIN_aidMedicalCircleAlpha;

    // COIN_patient (the clients leave him out of the questioning) and COIN_patientOpen (the action shows) are public.
    // The rest is the server's
    _patient setVariable ["COIN_patient", true, true];
    _patient setVariable ["COIN_patientOpen", true, true];
    _patient setVariable ["COIN_patientMarker", _marker];
    _patient setVariable ["COIN_patientTown", _town];

    [_patient] remoteExec ["COIN_fnc_addPatientAction", 0, _patient];

    _patients pushBack _patient;
    _markers pushBack _marker;
};

[_patients] call COIN_fnc_addToCurators;

diag_log format [
    "[COIN] aid: %1 patients in %2 around %3 (%4 to %5 m from the centre)",
    count _patients, _town, _pos apply {round _x}, _minRadius, _maxRadius
];

[_patients, _markers]
