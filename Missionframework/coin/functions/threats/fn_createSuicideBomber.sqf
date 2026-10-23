/*
    File: fn_createSuicideBomber.sqf
    Author: COIN Liberation

    Description:
        Sends one suicide bomber from an IED workshop to a player (ticket 4.4, DESIGN 6, ADR 0022): a fighter in civilian
        clothes (COIN_fnc_createCivilianFighter, role "suicideBomber") in clothing of the list COIN_suicideBomberClasses,
        unarmed and without visible charges, at a spawn point 100-200 m from the target, out of sight
        (COIN_fnc_findSuicideBomberSpot). He walks to the nearest player, ignores everything else and sets his vest off
        (COIN_fnc_suicideBomberDrive). Killed, the vest goes off with the chance COIN_suicideBomberShotChance
        (Killed event handler). Added to Zeus by the fighter. Not saved.
        Bomber = [id, workshop id, unit]; appended to COIN_suicideBombers. Server only.

    Parameter(s):
        _workshopId - Id of the workshop [NUMBER]
        _target     - The player he starts towards [OBJECT]

    Returns:
        The bomber, [] if there was no spawn point [ARRAY]
*/

params [
    ["_workshopId", -1, [0]],
    ["_target", objNull, [objNull]]
];

if (!isServer || {isNull _target}) exitWith {[]};

private _targetPos = getPosATL _target;
([_targetPos] call COIN_fnc_findSuicideBomberSpot) params [["_spot", []], ["_dir", 0]];
if (_spot isEqualTo []) exitWith {[]};

private _unit = ["suicideBomber", _spot, _dir, COIN_suicideBomberClasses] call COIN_fnc_createCivilianFighter;
// Standing still is the default of a fighter in civilian clothes; he walks, with a purpose
_unit enableAI "PATH";
_unit setBehaviour COIN_suicideBomberBehaviour;
(group _unit) setSpeedMode COIN_suicideBomberSpeedMode;

private _id = COIN_suicideBomberNextId;
COIN_suicideBomberNextId = _id + 1;
_unit setVariable ["COIN_suicideBomberId", _id];
// Shot dead, the vest goes off sometimes (and he may have been killed by something else after it went off: then it is done)
_unit addEventHandler ["Killed", {
    params ["_unit"];
    if (_unit getVariable ["COIN_suicideBomberDone", false]) exitWith {};
    private _roll = random 1;
    diag_log format [
        "[COIN] suicideBombers: suicide bomber %1 is dead, roll %2 (the vest goes off below %3)",
        _unit getVariable ["COIN_suicideBomberId", -1], (round (_roll * 100)) / 100, COIN_suicideBomberShotChance
    ];
    if (_roll < COIN_suicideBomberShotChance) then {
        [_unit, "shot dead"] call COIN_fnc_explodeSuicideBomber;
    };
}];

private _bomber = [_id, _workshopId, _unit];
COIN_suicideBombers pushBack _bomber;

diag_log format [
    "[COIN] suicideBombers: suicide bomber %1 (%2) of workshop %3 starts at %4, %5 m from %6",
    _id, typeOf _unit, _workshopId, _spot, round (_spot distance2D _targetPos), name _target
];

[_id] spawn COIN_fnc_suicideBomberDrive;

_bomber
