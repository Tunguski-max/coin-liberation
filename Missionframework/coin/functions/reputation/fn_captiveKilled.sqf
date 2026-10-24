/*
    File: fn_captiveKilled.sqf
    Author: COIN Liberation

    Description:
        Reputation for a prisoner killed by the army (ticket 5.1, DESIGN 8, ADR 0023). Called from Liberation's kill
        manager (hook in kill_manager.sqf) with the killer it has worked out, ACE included. A prisoner is a militia
        fighter who is handcuffed, has surrendered or was taken along with Liberation's CAPTURE (COIN_fnc_isPrisoner), a
        fighter in civilian clothes never is.
        Only the army counts as killer (side of the killer, like Liberation's own rules); a prisoner shot by the militia
        costs nothing. The total is always COIN_repCaptiveKilled: a prisoner of Liberation's surrender script is in a
        civilian group and Liberation takes KP_liberation_cr_kill_penalty for him already, we take the rest. One that is
        only handcuffed or surrendered with ACE (militia group) costs the whole amount from us, and so does one taken
        along into the squad (BLUFOR group, Liberation takes nothing for a squad member).
        Needs ACE (without it Liberation's prisoners carry no ACE state and only Liberation's part is taken).
        Config value 0 switches it off. Server only.

    Parameter(s):
        _unit   - Unit that died [OBJECT, defaults to objNull]
        _killer - Its killer as Liberation's kill manager has worked it out [OBJECT, defaults to objNull]

    Returns:
        Reputation was changed [BOOL]
*/

params [
    ["_unit", objNull, [objNull]],
    ["_killer", objNull, [objNull]]
];

// The kill manager can run before the COIN config is loaded
if (!isServer || {isNil "COIN_repCaptiveKilled"} || {COIN_repCaptiveKilled == 0}) exitWith {false};
if (isNull _unit) exitWith {false};
if (COIN_debug && {_unit isKindOf "CAManBase"}) then {
    diag_log format [
        "[COIN] reputation: kill check %1, killer %2 (side %3), group side %4, handcuffed %5, surrendering %6, remembered %7 -> prisoner %8",
        typeOf _unit, typeOf _killer, side _killer, side group _unit, _unit getVariable ["ace_captives_isHandcuffed", false], _unit getVariable ["ace_captives_isSurrendering", false],
        _unit getVariable ["COIN_prisonerState", false], [_unit] call COIN_fnc_isPrisoner
    ];
};
if (isNull _killer || {!((side _killer) isEqualTo GRLIB_side_friendly)}) exitWith {false};
if !([_unit] call COIN_fnc_isPrisoner) exitWith {false};

// Liberation's penalty for a unit in a civilian group (kill_manager.sqf), a positive number
private _libPenalty = [0, KP_liberation_cr_kill_penalty] select ((side group _unit) isEqualTo GRLIB_side_civilian);
private _amount = COIN_repCaptiveKilled + _libPenalty;
private _reason = format ["prisoner %1 killed (Liberation already takes %2, total %3)", typeOf _unit, _libPenalty, COIN_repCaptiveKilled];

if (_amount >= 0) exitWith {
    if (COIN_debug) then {diag_log format ["[COIN] reputation: %1, nothing left for us", _reason]};
    false
};

[_amount, _reason] call COIN_fnc_changeReputation
