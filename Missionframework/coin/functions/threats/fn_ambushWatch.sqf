/*
    File: fn_ambushWatch.sqf
    Author: COIN Liberation

    Description:
        Life of one spawned ambush (ticket 4.5, DESIGN 6). Every COIN_ambushWatchInterval seconds:
        - until they have opened fire: when the army (BLUFOR, a vehicle counts by its crew) is within
          COIN_ambushFireDistance of the ambush, or one of the fighters is hurt or dead, the group opens fire
          (COIN_ambushFireMode, combat behaviour, any stance),
        - when no fighter can fight any more (COIN_fnc_getCapableFighters) the ambush is cleared (ausgehoben): it is
          marked so in its camp (it does not spawn again, a civilian no longer warns of it) and the debug map is drawn
          again. What is left is removed like a camp when nobody is near.
        The run ends when the ambush is cleared, when its content was removed (the spawn loop takes it out of
        COIN_spawnedAmbushes first, so this is no clearing) or when COIN_enableAmbushes goes off. Must be spawned. Server only.

    Parameter(s):
        _campId   - Id of the camp the ambush belongs to [NUMBER]
        _fighters - The fighters of the ambush [ARRAY of OBJECTs]
        _pos      - Position of the ambush [ARRAY]

    Returns:
        Nothing
*/

params [
    ["_campId", -1, [0]],
    ["_fighters", [], [[]]],
    ["_pos", [0, 0, 0], [[]]]
];

if (!isServer) exitWith {};

private _fired = false;
private _outcome = "";

while {_outcome isEqualTo ""} do {
    sleep COIN_ambushWatchInterval;

    switch (true) do {
        case (GRLIB_endgame != 0 || {!COIN_enableAmbushes}): {_outcome = "switched off"};
        case (!(_campId in COIN_spawnedAmbushes) || {(_fighters findIf {!isNull _x}) < 0}): {_outcome = "removed"};
    };
    if (_outcome isNotEqualTo "") exitWith {};

    if (!_fired) then {
        private _army = (_pos nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], COIN_ambushFireDistance]) select {
            alive _x && {(side _x) isEqualTo GRLIB_side_friendly}
        };
        private _hurt = _fighters findIf {!alive _x || {damage _x > 0}};
        if (_army isNotEqualTo [] || {_hurt >= 0}) then {
            _fired = true;
            private _alive = _fighters select {alive _x};
            private _groups = [];
            {
                _groups pushBackUnique (group _x);
                _x setUnitPos COIN_ambushFireStance;
            } forEach _alive;
            {
                _x setBehaviour COIN_ambushFireBehaviour;
                _x setCombatMode COIN_ambushFireMode;
            } forEach _groups;
            diag_log format [
                "[COIN] ambushes: ambush of camp %1 opens fire (%2)", _campId,
                if (_army isNotEqualTo []) then {format ["%1 within %2 m", typeOf (_army select 0), round ((_army select 0) distance2D _pos)]} else {"a fighter was hit"}
            ];
        };
    };

    if (([_fighters, _pos] call COIN_fnc_getCapableFighters) isEqualTo []) then {
        _outcome = "cleared";
        private _index = COIN_camps findIf {(_x select 0) isEqualTo _campId};
        if (_index >= 0) then {
            ((COIN_camps select _index) select 8) set [2, true];
        };
        diag_log format ["[COIN] ambushes: ambush of camp %1 at %2 cleared (ausgehoben), %3 of %4 fighters dead", _campId, _pos, {!alive _x} count _fighters, count _fighters];
        if (COIN_debug) then {
            [] call COIN_fnc_drawCampMarkers;
        };
    };
};
