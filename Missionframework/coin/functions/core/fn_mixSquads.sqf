/*
    File: fn_mixSquads.sqf
    Author: COIN Liberation

    Description:
        Server loop that mixes Islamic State fighters (vest and helmet) into the militia field squads, depending on the
        combat readiness. The militia preset uses Afghan Militia (no armor) for every role, Liberation builds the
        squad lists KPLIB_o_squad* once and a role has only one class, so a share per spawn is not possible in the preset.
        Instead this loop re-rolls the lists every COIN_squadMixInterval seconds from the original lists:
        each unit of a squad is swapped for its Islamic State twin (COIN_squadMixTwins) with the probability "share",
        which rises linearly with combat_readiness (COIN_squadMixReadiness -> COIN_squadMixShare).
        The garrison of sectors at low readiness and vehicle crews (militia_squad) stay Afghan Militia.
        Affected lists: KPLIB_o_squadStd, KPLIB_o_squadInf, KPLIB_o_squadTank, KPLIB_o_squadAir (sector squads)
        and KPLIB_o_inf_classes (infantry of battlegroups at readiness 50 or more).
        KPLIB_o_inf_classes is also used by Liberation to recognise enemy infantry, so it always contains the
        Afghan Militia class and its twin of every role at least once; the share only sets how often each is drawn.
        Clients and late joiners add the twins to their own list in init_client.sqf, because init_presets.sqf rebuilds it there.
        Runs as long as COIN_enableSquadMix is true. Must run on the server only.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

// Only twins that exist in the loaded modset
private _twins = COIN_squadMixTwins select {isClass (configFile >> "CfgVehicles" >> (_x select 1))};
if (_twins isEqualTo []) exitWith {
    diag_log "[COIN] squads: ERROR - no Islamic State twin class found, squads stay Afghan Militia";
    false
};

private _amClasses = _twins apply {toLower (_x select 0)};
private _twinOf = {
    params ["_class"];
    private _index = _amClasses find (toLower _class);
    if (_index < 0) then {""} else {(_twins select _index) select 1}
};

// Originals as built by init_presets.sqf (Afghan Militia), the loop always starts from these
private _squadVars = ["KPLIB_o_squadStd", "KPLIB_o_squadInf", "KPLIB_o_squadTank", "KPLIB_o_squadAir"];
private _templates = _squadVars apply {+(missionNamespace getVariable [_x, []])};
private _infBase = +KPLIB_o_inf_classes;

diag_log format ["[COIN] squads: mixing %1 role twins, share %2 at readiness %3 to %4 at readiness %5, every %6 s", count _twins, COIN_squadMixShare select 0, COIN_squadMixReadiness select 0, COIN_squadMixShare select 1, COIN_squadMixReadiness select 1, COIN_squadMixInterval];

private _lastShare = -1;

while {COIN_enableSquadMix} do {
    // Below the lower readiness bound the squads stay Afghan Militia
    private _share = 0;
    if (combat_readiness >= (COIN_squadMixReadiness select 0)) then {
        _share = linearConversion [COIN_squadMixReadiness select 0, COIN_squadMixReadiness select 1, combat_readiness, COIN_squadMixShare select 0, COIN_squadMixShare select 1, true];
    };

    // Squads of the sectors: every unit is swapped for its twin with the probability "share"
    {
        private _squad = _templates select _forEachIndex;
        missionNamespace setVariable [_x, _squad apply {
            private _twin = [_x] call _twinOf;
            if (_twin != "" && {random 1 < _share}) then {_twin} else {_x}
        }];
    } forEach _squadVars;

    // Battlegroup infantry: every role is listed as Afghan Militia and as twin, weighted by the share
    private _inf = [];
    {
        private _twin = [_x] call _twinOf;
        if (_twin == "") then {
            _inf pushBack _x;
        } else {
            private _twinCount = (round (_share * COIN_squadMixInfWeight)) max 1;
            private _amCount = (COIN_squadMixInfWeight - _twinCount) max 1;
            for "_i" from 1 to _amCount do {_inf pushBack _x};
            for "_i" from 1 to _twinCount do {_inf pushBack (toLower _twin)};
        };
    } forEach _infBase;
    KPLIB_o_inf_classes = _inf;

    if (abs (_share - _lastShare) >= 0.1) then {
        diag_log format ["[COIN] squads: readiness %1, Islamic State share %2, squadStd %3", round combat_readiness, _share toFixed 2, KPLIB_o_squadStd];
        _lastShare = _share;
    };

    sleep COIN_squadMixInterval;
};

true
