/*
    File: fn_checkCampCleared.sqf
    Author: COIN Liberation

    Description:
        Has a spawned camp been cleared ("ausgehoben", ticket 2.10, DESIGN 5.1)? It is when none of its fighters, the
        crew of the technical included, can still fight: dead, captive (vanilla or ACE handcuffed or surrendering),
        no longer on the enemy side, or farther than COIN_campFleeDistance from the camp. Then the camp is set to
        "cleared" (it stays in COIN_camps until it is removed, COIN_fnc_manageCamps drops it then), one log line is
        written and a replacement is planned after COIN_campReplaceMinutes. Called by the spawn loop on every check
        of a spawned camp. Server only.

    Parameter(s):
        _camp  - Camp [ARRAY: id, nest id, position, discovered, seed, technical gone, state, relocate at]
        _entry - What the spawn loop kept: [spawned objects and units, last time a player was near, technical] [ARRAY]

    Returns:
        Camp was cleared by this call [BOOL]
*/

params [
    ["_camp", [], [[]]],
    ["_entry", [], [[]]]
];

_camp params ["_id", "_nestId", "_pos", "", "", "", "_state"];
_entry params ["_objects"];

// A cleared or retired camp is already on its way out
if !(_state in ["active", "moving"]) exitWith {false};

private _capable = (_objects select {_x isKindOf "CAManBase"}) select {
    alive _x
    && {!captive _x}
    && {!(_x getVariable ["ace_captives_isHandcuffed", false])}
    && {!(_x getVariable ["ace_captives_isSurrendering", false])}
    && {(side group _x) isEqualTo GRLIB_side_enemy}
    && {(_x distance2D _pos) <= COIN_campFleeDistance}
};
if !(_capable isEqualTo []) exitWith {false};

_camp set [6, "cleared"];
COIN_campReplaceMinutes params ["_replaceMin", "_replaceMax"];
private _delay = (_replaceMin + random (_replaceMax - _replaceMin)) * 60;
COIN_campReplacements pushBack (time + _delay);

diag_log format [
    "[COIN] camps: camp %1 (nest %2) at %3 cleared (ausgehoben), a replacement follows in %4 min",
    _id, _nestId, _pos, (round (_delay / 6)) / 10
];
if (COIN_debug) then {
    [] call COIN_fnc_drawCampMarkers;
};

true
