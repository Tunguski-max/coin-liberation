/*
    File: fn_rollStrikeTask.sqf
    Author: COIN Liberation

    Description:
        Server: after a questioning with a result or an interrogation, a strike task may arise (ticket 5.13, DESIGN 7 and 8.2,
        ADR 0023). Only from the reputation COIN_strikeTaskMinRep on, only while fewer than COIN_strikeTaskMaxActive run, with
        the chance COIN_strikeTaskChance, and only a kind whose requirement holds (COIN_strikeKinds, one at random). Then the
        one who spoke tells of it (a sentence "strike_<kind>" as a subtitle) and after COIN_strikeDialogDelay seconds the dialog of
        the elder opens for the interpreter with this one entry (COIN_fnc_openElderDialog, mode "strike"). The offer is kept per
        player (COIN_strikeOffers) for COIN_strikeOfferSeconds; closing the dialog without "Accept" loses it. The roll is
        written to the RPT. Switch COIN_enableStrikeTasks. Must be spawned. Server only.

    Parameter(s):
        _speaker - Civilian or prisoner who told the interpreter [OBJECT, defaults to objNull]
        _asker   - Interpreter [OBJECT, defaults to objNull]

    Returns:
        A strike task was offered [BOOL]
*/

params [
    ["_speaker", objNull, [objNull]],
    ["_asker", objNull, [objNull]]
];

if (!isServer || {!COIN_enableStrikeTasks} || {isNull _asker} || {isNull _speaker}) exitWith {false};

private _reputation = missionNamespace getVariable ["KP_liberation_civ_rep", 0];
if (_reputation < COIN_strikeTaskMinRep) exitWith {
    if (COIN_debug) then {
        diag_log format ["[COIN] strike: no roll for %1, reputation %2 < %3", name _asker, _reputation, COIN_strikeTaskMinRep];
    };
    false
};

if (count COIN_strikeActive >= COIN_strikeTaskMaxActive) exitWith {
    if (COIN_debug) then {
        diag_log format ["[COIN] strike: no roll for %1, %2 strike task(s) run already", name _asker, count COIN_strikeActive];
    };
    false
};

private _roll = random 1;
// Two decimals for the RPT
private _rolled = (round (_roll * 100)) / 100;
if (_roll >= COIN_strikeTaskChance) exitWith {
    diag_log format ["[COIN] strike: roll %1 >= chance %2 for %3, no strike task (reputation %4)", _rolled, COIN_strikeTaskChance, name _asker, _reputation];
    false
};

// The kinds whose requirement holds now
private _kinds = COIN_strikeKinds select {[] call (missionNamespace getVariable [_x select 1, {false}])};
if (_kinds isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: roll %1 < chance %2 for %3, but no kind of strike task can be offered now", _rolled, COIN_strikeTaskChance, name _asker];
    false
};

private _kind = (selectRandom _kinds) select 0;
COIN_strikeOffers set [getPlayerUID _asker, [_kind, time + COIN_strikeOfferSeconds]];
diag_log format [
    "[COIN] strike: roll %1 < chance %2 for %3 (reputation %4): %5 offered by %6 (%7 kinds possible)",
    _rolled, COIN_strikeTaskChance, name _asker, _reputation, _kind, name _speaker, count _kinds
];

[_speaker, format ["strike_%1", _kind]] remoteExecCall ["COIN_fnc_showElderSentence", owner _asker];
sleep COIN_strikeDialogDelay;

// The dialog of the elder with this one entry: [id, section, can be accepted, reason key, reason value, place, site]
[_speaker, "", [[_kind, "strike", true, "", 0, "", []]], count COIN_strikeActive, "strike"] remoteExecCall ["COIN_fnc_openElderDialog", owner _asker];

true
