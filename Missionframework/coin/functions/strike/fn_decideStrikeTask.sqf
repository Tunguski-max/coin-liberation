/*
    File: fn_decideStrikeTask.sqf
    Author: COIN Liberation

    Description:
        Server: decides whether a strike task arises from a questioning or an interrogation (ticket 5.13, DESIGN 7 and 8.2,
        ADR 0023). Only from the reputation COIN_strikeTaskMinRep on, only while fewer than COIN_strikeTaskMaxActive run, with the
        chance COIN_strikeTaskChance, and only a kind whose requirement holds and that can make a plan (COIN_strikeKinds, one at
        random; the plan is made near the one who spoke and kept with the offer). If so, the offer is kept per player
        (COIN_strikeOffers) for COIN_strikeOfferSeconds, and the caller lets COIN_fnc_offerStrikeTask tell of it. The roll is
        written to the RPT. Switch COIN_enableStrikeTasks.
        A questioning decides before it gives its intel: a strike task takes the place of the intel (no double reward), and its
        beginning comes sooner (COIN_strikeTaskDelayMinFast). An interrogation gives its results besides.

    Parameter(s):
        _speaker - Civilian or prisoner who told the interpreter [OBJECT, defaults to objNull]
        _asker   - Interpreter [OBJECT, defaults to objNull]
        _fast    - The strike task replaces the intel of a questioning, so it begins sooner [BOOL, defaults to false]

    Returns:
        The kind that was offered, "" if there is none [STRING]
*/

params [
    ["_speaker", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_fast", false, [false]]
];

if (!isServer || {!COIN_enableStrikeTasks} || {isNull _asker} || {isNull _speaker}) exitWith {""};

private _reputation = missionNamespace getVariable ["KP_liberation_civ_rep", 0];
if (_reputation < COIN_strikeTaskMinRep) exitWith {
    if (COIN_debug) then {
        diag_log format ["[COIN] strike: no roll for %1, reputation %2 < %3", name _asker, _reputation, COIN_strikeTaskMinRep];
    };
    ""
};

// A task that should have ended long ago (its run broke off) does not block the limit for ever
COIN_strikeActive = COIN_strikeActive select {time <= (_x select 2) + COIN_aidTaskEndShowSeconds};
if (count COIN_strikeActive >= COIN_strikeTaskMaxActive) exitWith {
    if (COIN_debug) then {
        diag_log format ["[COIN] strike: no roll for %1, %2 strike task(s) run already", name _asker, count COIN_strikeActive];
    };
    ""
};

private _roll = random 1;
// Two decimals for the RPT
private _rolled = (round (_roll * 100)) / 100;
if (_roll >= COIN_strikeTaskChance) exitWith {
    diag_log format ["[COIN] strike: roll %1 >= chance %2 for %3, no strike task (reputation %4)", _rolled, COIN_strikeTaskChance, name _asker, _reputation];
    ""
};

// The kinds whose requirement holds now and that can make a plan (a kind that cannot is not offered), one at random
private _kinds = COIN_strikeKinds select {[] call (missionNamespace getVariable [_x select 1, {false}])};
private _kind = "";
private _plan = [];
private _possible = count _kinds;
while {_plan isEqualTo [] && {_kinds isNotEqualTo []}} do {
    private _row = _kinds deleteAt (floor random count _kinds);
    _plan = [getPosATL _speaker] call (missionNamespace getVariable [_row select 2, {[]}]);
    if (_plan isNotEqualTo []) then {_kind = _row select 0};
};
if (_plan isEqualTo []) exitWith {
    diag_log format ["[COIN] strike: roll %1 < chance %2 for %3, but no kind of strike task can be offered now (%4 met their requirement)", _rolled, COIN_strikeTaskChance, name _asker, _possible];
    ""
};

// The plan is kept with the offer and used when it is accepted
COIN_strikeOffers set [getPlayerUID _asker, [_kind, time + COIN_strikeOfferSeconds, _plan, _fast]];
diag_log format [
    "[COIN] strike: roll %1 < chance %2 for %3 (reputation %4): %5 offered by %6 (%7 kinds met their requirement)%8",
    _rolled, COIN_strikeTaskChance, name _asker, _reputation, _kind, name _speaker, _possible,
    ["", ", it replaces the intel of the questioning"] select _fast
];

_kind
