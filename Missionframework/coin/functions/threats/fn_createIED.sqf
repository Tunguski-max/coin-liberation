/*
    File: fn_createIED.sqf
    Author: COIN Liberation

    Description:
        Lays one IED for a workshop (ticket 4.1a, DESIGN 6, ADR 0022): a real mine object (one of COIN_iedTypes,
        createMine, so ACE mine detectors find it and ACE can defuse it) at a place from COIN_fnc_findIEDSpot. Not saved.
        The IED belongs to the workshop that laid it. Added to Zeus. Refused while COIN_maxActiveIEDs IEDs exist.
        IED = [id, nest id, object, position, variant]; appended to COIN_ieds. Variant is "buried" for now, the
        remote-triggered one and the decoy come with tickets 4.2a and 4.2b. Server only.

    Parameter(s):
        _nestId - Id of the workshop [NUMBER]

    Returns:
        The IED, [] if the global cap is reached, the workshop is unknown or no place was found [ARRAY]
*/

params [
    ["_nestId", -1, [0]]
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

private _id = COIN_iedNextId;
COIN_iedNextId = _id + 1;
private _ied = [_id, _nestId, _object, _pos, "buried"];
COIN_ieds pushBack _ied;

diag_log format [
    "[COIN] ieds: IED %1 (%2) at %3 belongs to nest %4, %5 m away from it",
    _id, typeOf _object, _pos, _nestId, round (_pos distance2D _nestPos)
];

_ied
