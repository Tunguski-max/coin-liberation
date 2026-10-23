/*
    File: fn_createIED.sqf
    Author: COIN Liberation

    Description:
        Lays one IED for a workshop (ticket 4.1a, DESIGN 6, ADR 0022): a real mine object (one of COIN_iedTypes,
        createMine, so ACE mine detectors find it and ACE can defuse it) at a place from COIN_fnc_findIEDSpot. Not saved.
        The IED belongs to the workshop that laid it. Added to Zeus. Refused while COIN_maxActiveIEDs IEDs exist.
        IED = [id, nest id, object, position, variant, trigger]; appended to COIN_ieds. Variant is "buried",
        "decoy" (chance COIN_iedDecoyChance, ticket 4.2a): same object, ACE finds and defuses it, but it is invulnerable
        and has no trigger, so it never goes off, or "remote" (chance COIN_iedRemoteChance, ticket 4.2b): the army
        does not set it off, its triggerman does (COIN_fnc_triggermanLoop). A decoy has no trigger (objNull).
        Server only.

    Parameter(s):
        _nestId  - Id of the workshop [NUMBER]
        _variant - "buried", "decoy" or "remote" to lay exactly that one (a replacement is like for like), "" rolls it with the chances above [STRING]

    Returns:
        The IED, [] if the global cap is reached, the workshop is unknown or no place was found [ARRAY]
*/

params [
    ["_nestId", -1, [0]],
    ["_variant", "", [""]]
];

if (!isServer) exitWith {[]};

if (count COIN_ieds >= COIN_maxActiveIEDs) exitWith {
    diag_log format ["[COIN] ieds: cap of %1 IEDs reached, none laid for nest %2", COIN_maxActiveIEDs, _nestId];
    []
};

private _nestIndex = COIN_nests findIf {(_x select 0) isEqualTo _nestId};
if (_nestIndex < 0) exitWith {
    diag_log format ["[COIN] ieds: ERROR - nest %1 is unknown, no IED laid", _nestId];
    []
};
(COIN_nests select _nestIndex) params ["", "_nestType", "", "_nestPos"];

([_nestPos, [_nestType] call COIN_fnc_getNestRadius] call COIN_fnc_findIEDSpot) params ["_pos", "_rejected"];
if (_pos isEqualTo []) exitWith {
    diag_log format [
        "[COIN] ieds: ERROR - no place for an IED of nest %1 in %2 tries, rejected by: %3, IED left out",
        _nestId, COIN_iedPlaceAttempts, ((keys _rejected) apply {format ["%1 %2x", _x, _rejected get _x]}) joinString ", "
    ];
    []
};

private _object = createMine [selectRandom COIN_iedTypes, _pos, [], 0];
_object setDir random 360;
[[_object]] call COIN_fnc_addToCurators;

// A decoy looks the same but never goes off: no trigger below, and no damage (shots, blasts nearby) can set it off.
// A remote IED has no pressure fuse, its triggerman sets it off (COIN_fnc_triggermanLoop, COIN_fnc_iedWatch).
// The rest are buried. A switch that is off gives its share to the buried ones.
if (_variant isEqualTo "") then {
    private _decoyShare = [0, COIN_iedDecoyChance] select COIN_enableIEDDecoys;
    private _remoteShare = [0, COIN_iedRemoteChance] select COIN_enableIEDRemote;
    private _roll = random 1;
    _variant = switch (true) do {
        case (_roll < _decoyShare): {"decoy"};
        case (_roll < (_decoyShare + _remoteShare)): {"remote"};
        default {"buried"};
    };
};
if (_variant isEqualTo "decoy") then {
    _object allowDamage false;
};

private _id = COIN_iedNextId;
COIN_iedNextId = _id + 1;

// Engine trigger: BLUFOR within COIN_iedAlertDistance starts the exact check of this IED (COIN_fnc_iedWatch), nothing
// runs in script while nobody is near. The flag keeps one watch per trigger. A decoy has none.
private _trigger = objNull;
if (_variant isNotEqualTo "decoy") then {
    _trigger = createTrigger ["EmptyDetector", _pos, false];
    _trigger setTriggerArea [COIN_iedAlertDistance, COIN_iedAlertDistance, 0, false];
    _trigger setTriggerActivation [str GRLIB_side_friendly, "PRESENT", true];
    _trigger setTriggerInterval COIN_iedTriggerCheckInterval;
    _trigger setTriggerStatements [
        "this",
        "if !(thisTrigger getVariable ['COIN_watching', false]) then {thisTrigger setVariable ['COIN_watching', true]; [thisTrigger] spawn COIN_fnc_iedWatch}",
        ""
    ];
    _trigger setVariable ["COIN_iedId", _id];
};

// The IED is removed from the list whenever the object is deleted (ACE defusing, Zeus, after the blast)
_object setVariable ["COIN_iedId", _id];
_object addEventHandler ["Deleted", {
    params ["_entity"];
    [_entity getVariable ["COIN_iedId", -1]] call COIN_fnc_removeIED;
}];

private _ied = [_id, _nestId, _object, _pos, _variant, _trigger];
COIN_ieds pushBack _ied;

diag_log format [
    "[COIN] ieds: IED %1 (%2, %3) at %4 belongs to nest %5, %6 m away from it",
    _id, typeOf _object, _variant, _pos, _nestId, round (_pos distance2D _nestPos)
];

_ied
