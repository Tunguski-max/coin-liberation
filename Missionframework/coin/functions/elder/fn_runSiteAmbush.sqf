/*
    File: fn_runSiteAmbush.sqf
    Author: COIN Liberation

    Description:
        Life of the ambush at the site of an aid task (ticket 5.22, ADR 0024, DESIGN 8.2), after the plan of
        COIN_fnc_planSiteAmbush. Started by COIN_fnc_runAidTask when the task starts. Every COIN_ambushWatchInterval seconds:
        - spawned: until they have opened fire, when the army (BLUFOR, a vehicle counts by its crew) is within
          COIN_ambushFireDistance of the ambush, or one of the fighters (also those in houses) is hurt or dead, all of them open
          fire (COIN_ambushFireMode, combat behaviour, any stance), like the ambush of a camp (COIN_fnc_ambushWatch). When no fighter can fight
          any more (COIN_fnc_getCapableFighters) the ambush is cleared (ausgehoben) and does not spawn again,
        - every COIN_spawnCheckInterval seconds: not spawned and the task is running, the nearest player or drone
          (COIN_fnc_getPresence) is within COIN_spawnDistance of the ambush: if all fighters (those in houses too) fit the camp
          budget (COIN_fnc_campFitsBudget, ADR 0015) they spawn (COIN_fnc_spawnSiteAmbush), else the danger is given up for good
          (RPT "no room"); spawned: nobody within COIN_despawnDistance for COIN_despawnDelay seconds, the content is deleted,
          alive or dead (no player is near). They come back at the next visit while the task runs.
        The run ends when the content is gone and the task is over or the ambush was cleared, when there was no room, or when
        COIN_enableAidAmbush goes off. When the task ends (success, failure, anything) the fighters stay until nobody is near.
        Must be spawned. Server only.

    Parameter(s):
        _plan   - Result of COIN_fnc_planSiteAmbush [ARRAY]
        _centre - Centre of the village [ARRAY]
        _place  - Name of the village, for the log [STRING]
        _sector - Sector marker of the town of the elder, the key of the task in COIN_aidActive [STRING]
        _taskId - Id of the aid task [STRING]

    Returns:
        Nothing
*/

params [
    ["_plan", [], [[]]],
    ["_centre", [], [[]]],
    ["_place", "", [""]],
    ["_sector", "", [""]],
    ["_taskId", "", [""]]
];

if (!isServer || {_plan isEqualTo []}) exitWith {};

_plan params ["_nestId", "_pos", "", "", "_fighterCount", "", "_houseCount"];

private _content = [];
private _fighters = [];
private _fired = false;
private _cleared = false;
private _lastNear = time;
private _nextCheck = 0;
private _result = "";

// Deletes what is spawned, alive or dead
private _remove = {
    params ["_reason"];
    private _alive = {alive _x} count _fighters;
    {deleteVehicle _x} forEach _content;
    // Groups are created with deleteWhenEmpty, they go with their last unit
    diag_log format ["[COIN] danger: ambush at %1 removed (%2), %3 of %4 fighters were alive", _place, _reason, _alive, count _fighters];
    _content = [];
    _fighters = [];
    _fired = false;
};

while {_result isEqualTo ""} do {
    sleep COIN_ambushWatchInterval;

    private _running = ((COIN_aidActive getOrDefault [_sector, []]) param [1, ""]) isEqualTo _taskId;

    if (GRLIB_endgame != 0 || {!COIN_enableAidAmbush}) then {
        if (_content isNotEqualTo []) then {["switched off"] call _remove};
        _result = "switched off";
    } else {
        if (_content isNotEqualTo []) then {
            if (!_fired) then {
                private _army = (_pos nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], COIN_ambushFireDistance]) select {
                    alive _x && {(side _x) isEqualTo GRLIB_side_friendly}
                };
                private _hurt = _fighters findIf {!alive _x || {damage _x > 0}};
                if (_army isNotEqualTo [] || {_hurt >= 0}) then {
                    _fired = true;
                    private _groups = [];
                    {
                        _groups pushBackUnique (group _x);
                        _x setUnitPos COIN_ambushFireStance;
                    } forEach (_fighters select {alive _x});
                    {
                        _x setBehaviour COIN_ambushFireBehaviour;
                        _x setCombatMode COIN_ambushFireMode;
                    } forEach _groups;
                    diag_log format [
                        "[COIN] danger: ambush at %1 opens fire (%2)", _place,
                        if (_army isNotEqualTo []) then {format ["%1 within %2 m", typeOf (_army select 0), round ((_army select 0) distance2D _pos)]} else {"a fighter was hit"}
                    ];
                };
            };
            if (!_cleared && {([_fighters, _pos] call COIN_fnc_getCapableFighters) isEqualTo []}) then {
                _cleared = true;
                diag_log format ["[COIN] danger: ambush at %1 cleared (ausgehoben), %2 of %3 fighters dead", _place, {!alive _x} count _fighters, count _fighters];
            };
        };

        if (time >= _nextCheck) then {
            _nextCheck = time + COIN_spawnCheckInterval;
            private _present = [] call COIN_fnc_getPresence;
            private _distance = if (_present isEqualTo []) then {-1} else {selectMin (_present apply {_x distance2D _pos})};

            if (_content isEqualTo []) then {
                if (!_running || {_cleared}) then {
                    _result = "over";
                } else {
                    if (_distance >= 0 && {_distance <= COIN_spawnDistance}) then {
                        private _total = _fighterCount + _houseCount;
                        if ([_total] call COIN_fnc_campFitsBudget) then {
                            ([_plan, _centre, _place, _distance] call COIN_fnc_spawnSiteAmbush) params ["_made", "_fighting"];
                            _content = _made;
                            _fighters = _fighting;
                            _lastNear = time;
                        } else {
                            diag_log format [
                                "[COIN] danger: no room for the ambush at %1, budget: %2 COIN units + %3 fighters > %4, the task stays safe",
                                _place, [] call COIN_fnc_countCoinUnits, _total, COIN_maxCampAI
                            ];
                            _result = "no room";
                        };
                    };
                };
            } else {
                if (_distance >= 0 && {_distance <= COIN_despawnDistance}) then {
                    _lastNear = time;
                } else {
                    if ((time - _lastNear) >= COIN_despawnDelay) then {
                        [format ["no player within %1 m for %2 s", COIN_despawnDistance, COIN_despawnDelay]] call _remove;
                    };
                };
            };
        };
    };
};

diag_log format ["[COIN] danger: ambush at %1 (nest %2) is over: %3", _place, _nestId, _result];
