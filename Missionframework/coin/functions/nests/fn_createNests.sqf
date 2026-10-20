/*
    File: fn_createNests.sqf
    Author: COIN Liberation

    Description:
        Creates the nests of a new campaign as data, as many of each type as COIN_nestSetup says (ticket 2.1).
        Simple placement for now: random land positions, at least COIN_nestMinDistStartBase from the start base
        and COIN_nestMinDistCapital from the capital. All nests are terrain nests until the placement rules
        of ticket 2.2 (building nests at the edge of a town, distances between nests) replace this.
        A nest without a valid position after COIN_nestPlaceAttempts tries is left out with an error line.

    Parameter(s):
        NONE

    Returns:
        Nests [ARRAY of [id, type, kind, pos, seed, state]]
*/

// Seeds stay below 1e6, so str in Liberation's save writes them as whole numbers
private _seedRange = 1e6;

private _startPos = getPosATL startbase;
private _capitals = sectors_bigtown apply {markerPos _x};

private _nests = [];
private _id = 0;

{
    _x params ["_type", "_count"];

    for "_i" from 1 to _count do {
        private _pos = [];
        private _attempt = 0;

        while {_pos isEqualTo [] && {_attempt < COIN_nestPlaceAttempts}} do {
            _attempt = _attempt + 1;
            // Whole metres, so a position reads the same in the RPT before and after a restart
            private _candidate = [round random worldSize, round random worldSize, 0];
            if (
                !(surfaceIsWater _candidate)
                && {(_candidate distance2D _startPos) >= COIN_nestMinDistStartBase}
                && {(_capitals findIf {(_candidate distance2D _x) < COIN_nestMinDistCapital}) < 0}
            ) then {
                _pos = _candidate;
            };
        };

        if (_pos isEqualTo []) then {
            diag_log format ["[COIN] nests: ERROR - no position for a %1 nest after %2 tries, nest left out", _type, COIN_nestPlaceAttempts];
        } else {
            _id = _id + 1;
            _nests pushBack [_id, _type, "terrain", _pos, floor random _seedRange, "active"];
        };
    };
} forEach COIN_nestSetup;

_nests
