/*
    File: fn_markFactions.sqf
    Author: COIN Liberation

    Description:
        Server loop that gives every AI infantry unit of the militia and of the resistance a colored
        shemag, so players can tell them apart (ADR 0012, ADR 0014, ticket #9).
        - Militia (side OPFOR):                        red   (COIN_markerMilitia)
        - Resistance, hostile to the army (rep < -25): green (COIN_markerResistanceHostile)
        - Resistance, neutral or friendly:             blue  (COIN_markerResistanceFriendly)
        The color follows the live civil reputation with the same rule Liberation uses for the resistance standing
        (f_kp_cr_changeCR.sqf), so already living resistance fighters change their shemag when the reputation
        crosses the threshold. The rule is applied directly because Liberation calls setFriend only after the first
        reputation change or a save load, so getFriend is not reliable on a fresh campaign.
        Units are found by scanning allUnits, so no Liberation spawn script has to be touched. A unit that has left
        its faction (e.g. a captured militia fighter) loses the shemag again. Militia fighters that wear a helmet keep it.
        Runs as long as COIN_enableFactionMarkers is true. Must run on the server only.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

// A missing class would make addHeadgear fail silently, so say it once
{
    if !(isClass (configFile >> "CfgWeapons" >> _x)) then {
        diag_log format ["[COIN] markers: ERROR - class %1 not found, units will not get this shemag", _x];
    };
} forEach [COIN_markerMilitia, COIN_markerResistanceHostile, COIN_markerResistanceFriendly];

// addHeadgear and removeHeadgear need a local unit (headless clients own offloaded groups)
private _setHeadgear = {
    params ["_unit", "_class"];
    if (local _unit) then {
        if (_class isEqualTo "") then {removeHeadgear _unit} else {_unit addHeadgear _class};
    } else {
        if (_class isEqualTo "") then {
            [_unit] remoteExecCall ["removeHeadgear", _unit];
        } else {
            [_unit, _class] remoteExecCall ["addHeadgear", _unit];
        };
    };
};

private _lastState = "";

while {COIN_enableFactionMarkers} do {
    // Same rule as Liberation: the resistance turns hostile below -25
    private _hostile = KP_liberation_civ_rep < -25;
    private _resistanceMarker = [COIN_markerResistanceFriendly, COIN_markerResistanceHostile] select _hostile;
    private _state = ["friendly", "hostile"] select _hostile;

    if (_state != _lastState) then {
        diag_log format ["[COIN] markers: resistance %1 (reputation %2, getFriend %3), shemag %4", _state, KP_liberation_civ_rep, GRLIB_side_resistance getFriend GRLIB_side_friendly, _resistanceMarker];
        _lastState = _state;
    };

    {
        private _unit = _x;
        private _marker = switch (side group _unit) do {
            case GRLIB_side_enemy: {COIN_markerMilitia};
            case GRLIB_side_resistance: {_resistanceMarker};
            default {""};
        };
        private _previous = _unit getVariable ["COIN_marker", ""];

        if (_marker == "") then {
            // The unit left its faction (captured, switched side): take our shemag off again
            if (_previous != "") then {
                _unit setVariable ["COIN_marker", ""];
                if (_previous != "helmet" && {headgear _unit == _previous}) then {
                    [_unit, ""] call _setHeadgear;
                };
            };
        } else {
            // Militia fighters with a helmet (Islamic State twins, see COIN_fnc_mixClass) keep it: a helmet means militia anyway.
            // Resistance fighters always get their shemag. The decision is stored, so the config lookup runs once per unit.
            private _keepsHelmet = _previous == "helmet" && {_marker == COIN_markerMilitia};
            if (!_keepsHelmet && {_marker == COIN_markerMilitia} && {_previous == ""}) then {
                private _headArmor = getNumber (configFile >> "CfgWeapons" >> (headgear _unit) >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Head" >> "armor");
                if (_headArmor > 0) then {
                    _unit setVariable ["COIN_marker", "helmet"];
                    _keepsHelmet = true;
                };
            };

            // Also catches a shemag that was taken off or replaced later
            if (!_keepsHelmet && {headgear _unit != _marker}) then {
                _unit setVariable ["COIN_marker", _marker];
                [_unit, _marker] call _setHeadgear;
            };
        };
    } forEach (allUnits select {alive _x && {!isPlayer _x} && {_x isKindOf "CAManBase"}});

    sleep COIN_markerInterval;
};

true
