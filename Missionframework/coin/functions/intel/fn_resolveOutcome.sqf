/*
    File: fn_resolveOutcome.sqf
    Author: COIN Liberation

    Description:
        Turns one rolled outcome of a question or an interrogation into its intel (tickets 3.1, 3.4, 3.6, 3.8, 4.8): a
        true level (rumor, hint, tip) about the nest, a lie (COIN_fnc_createLie) or a warning of a threat close to the
        one who speaks (COIN_fnc_createWarning: a camp, an IED). The outcome "nothing" makes nothing, and so does one
        that cannot be made (no threat without a warning in range, no fake point): he then knows nothing. The caller
        announces the intel and starts the cooldown. A lie is shown with the level and type it was made with, so it
        reads like a true answer. A warning is shown with the answer key of its kind (COIN_warningKinds: "warning" for a
        camp, "warningIED" for an IED, "warningAmbush" for an ambush), so the sentences differ by kind. Server only.

    Parameter(s):
        _outcome - "nothing", "rumor", "hint", "tip", "warning" or "lie" [STRING, defaults to "nothing"]
        _nest    - Nest for a true level [ARRAY, defaults to []]
        _source  - Civilian or prisoner who speaks [OBJECT, defaults to objNull]

    Returns:
        [level shown, nest type shown, kind of notification "intel", "warning" or "" if nothing was made] [ARRAY]
*/

params [
    ["_outcome", "nothing", [""]],
    ["_nest", [], [[]]],
    ["_source", objNull, [objNull]]
];

if (!isServer) exitWith {["nothing", "", ""]};

private _intel = [];
switch (_outcome) do {
    case "lie": {_intel = [getPosATL _source] call COIN_fnc_createLie;};
    case "warning": {_intel = [getPosATL _source] call COIN_fnc_createWarning;};
    case "rumor";
    case "hint";
    case "tip": {_intel = [_nest, _outcome] call COIN_fnc_createIntel;};
};

if (_intel isEqualTo []) exitWith {
    if (_outcome isEqualTo "warning") then {
        diag_log format ["[COIN] intel: %1 has no new threat to warn of, he knows nothing", name _source];
    };
    ["nothing", "", ""]
};

if (_outcome isEqualTo "warning") exitWith {
    // [id, kind, threat id, center, radius]: no type
    _intel params ["_warningId", "_kind", "_threatId", "_center", "_radius"];
    diag_log format [
        "[COIN] intel: warning about %1 %2, circle of %3 m at %4 (warning %5)",
        _kind, _threatId, _radius, _center, _warningId
    ];
    [(([COIN_warningKinds, _kind] call COIN_fnc_findByType) param [3, "warning"]), "", "warning"]
};

private _level = [_outcome, _intel select 4] select (_outcome isEqualTo "lie");
private _type = _intel select 5;
if (_outcome isEqualTo "lie") then {
    diag_log format [
        "[COIN] intel: LIE shown as %1 %2, circle of %3 m at %4, fake point %5 (intel %6)",
        _level, _type, _intel select 3, _intel select 2, _intel select 6, _intel select 0
    ];
} else {
    diag_log format [
        "[COIN] intel: %1 about nest %2 (%3), %4 m away, circle of %5 m at %6 (intel %7)",
        _level, _nest select 0, _nest select 1,
        round ((_nest select 3) distance2D _source), _intel select 3, _intel select 2, _intel select 0
    ];
};

[_level, _type, "intel"]
