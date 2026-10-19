/*
    File: fn_markFactions.sqf
    Author: COIN Liberation

    Description:
        Server loop that gives every AI infantry unit of the militia and of the resistance a colored
        shemag, so players can tell them apart (ADR 0012, ADR 0014, ticket #9).
        - Militia (side OPFOR):                       red   (COIN_markerMilitia)
        - Resistance, hostile to the army (rep < -25): green (COIN_markerResistanceHostile)
        - Resistance, neutral or friendly:            blue  (COIN_markerResistanceFriendly)
        The color follows the live standing of the resistance (setFriend, set by Liberation's civil reputation),
        so already living resistance fighters change their shemag when the reputation crosses a threshold.
        Units are found by scanning allUnits, so no Liberation spawn script has to be touched.
        Runs as long as COIN_enableFactionMarkers is true. Must run on the server only.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!isServer) exitWith {false};

private _wasHostile = nil;

while {COIN_enableFactionMarkers} do {
    // Liberation sets this to 0 (hostile) if the civil reputation is below -25
    private _hostile = (GRLIB_side_resistance getFriend GRLIB_side_friendly) < 0.5;

    if (isNil "_wasHostile" || {!(_wasHostile isEqualTo _hostile)}) then {
        diag_log format ["[COIN] markers: resistance is %1, shemag %2", ["neutral or friendly", "hostile"] select _hostile, [COIN_markerResistanceFriendly, COIN_markerResistanceHostile] select _hostile];
        _wasHostile = _hostile;
    };

    private _resistanceMarker = [COIN_markerResistanceFriendly, COIN_markerResistanceHostile] select _hostile;

    {
        private _unit = _x;
        private _marker = switch (side group _unit) do {
            case GRLIB_side_enemy: {COIN_markerMilitia};
            case GRLIB_side_resistance: {_resistanceMarker};
            default {""};
        };

        if (_marker != "" && {alive _unit} && {(_unit getVariable ["COIN_marker", ""]) != _marker}) then {
            _unit setVariable ["COIN_marker", _marker];

            // addHeadgear needs a local unit (headless clients own offloaded groups)
            if (local _unit) then {
                _unit addHeadgear _marker;
            } else {
                [_unit, _marker] remoteExecCall ["addHeadgear", _unit];
            };
        };
    } forEach (allUnits select {!isPlayer _x && {_x isKindOf "CAManBase"}});

    sleep COIN_markerInterval;
};

true
