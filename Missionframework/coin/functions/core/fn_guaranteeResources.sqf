/*
    File: fn_guaranteeResources.sqf
    Author: COIN Liberation

    Description:
        Balances the resource types (supplies, ammo, fuel) among the supply points (ticket 1.11, ADR 0017).
        Liberation draws the type of every supply point at random when a new campaign starts (hook 14 in
        synchronise_eco.sqf); with few supply points that gives lopsided results or a missing type.
        While the most frequent type has more than one supply point more than the least frequent one, a random
        supply point of the most frequent type is switched to the least frequent type. With 8 supply points
        the result is always 3-3-2 (which type gets only 2 stays random), so every type occurs at least twice.
        Must run on the server, once, right after the draw of a NEW campaign. A loaded save never gets here.

    Parameter(s):
        _markers - Liberation's production markers [marker, supplies, ammo, fuel, text] per supply point, changed in place
                   [ARRAY, defaults to KP_liberation_production_markers]

    Returns:
        Number of supply points that were changed [NUMBER]
*/

params [
    ["_markers", KP_liberation_production_markers, [[]]]
];

if (!isServer) exitWith {0};

// The config is loaded in postInit on every machine, but this runs early in the server start
private _timeout = diag_tickTime + (missionNamespace getVariable ["COIN_initTimeout", 300]);
if (canSuspend) then {
    waitUntil {sleep 0.5; !isNil "COIN_enableResourceGuarantee" || {diag_tickTime > _timeout}};
};
if (isNil "COIN_enableResourceGuarantee" || {!COIN_enableResourceGuarantee}) exitWith {
    diag_log "[COIN] resources: balancing is off or the config is missing, the draw stays as Liberation made it";
    0
};

private _names = ["supplies", "ammo", "fuel"];

// Type of a supply point: 0 supplies, 1 ammo, 2 fuel, -1 none
private _typeOf = {
    params ["_marker"];
    (_marker select [1, 3]) find true
};

private _counts = [0, 0, 0];
{
    private _type = [_x] call _typeOf;
    if (_type >= 0) then {_counts set [_type, (_counts select _type) + 1];};
} forEach _markers;

diag_log format ["[COIN] resources: draw gave supplies %1, ammo %2, fuel %3 of %4 supply points", _counts select 0, _counts select 1, _counts select 2, count _markers];

if (count _markers < count _names) exitWith {
    diag_log "[COIN] resources: ERROR - fewer supply points than resource types, not every type can be produced";
    0
};

private _changed = 0;
private _from = _counts find (selectMax _counts);
private _to = _counts find (selectMin _counts);

// Every step moves one supply point and brings the extremes closer, so the loop ends
while {(_counts select _from) - (_counts select _to) > 1} do {
    private _candidates = _markers select {([_x] call _typeOf) == _from};
    private _marker = selectRandom _candidates;

    _marker set [1 + _from, false];
    _marker set [1 + _to, true];
    _counts set [_from, (_counts select _from) - 1];
    _counts set [_to, (_counts select _to) + 1];
    _changed = _changed + 1;

    diag_log format ["[COIN] resources: %1 changed from %2 to %3", _marker select 0, _names select _from, _names select _to];

    _from = _counts find (selectMax _counts);
    _to = _counts find (selectMin _counts);
};

diag_log format ["[COIN] resources: now supplies %1, ammo %2, fuel %3, %4 supply points changed", _counts select 0, _counts select 1, _counts select 2, _changed];

_changed
