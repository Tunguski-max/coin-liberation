/*
    File: fn_getWarnableThreats.sqf
    Author: COIN Liberation

    Description:
        Everything a civilian can warn of right now (ticket 4.8, DESIGN 7): the one place that knows what a threat is
        and where it lies, so a new kind only adds its case here and a row in
        COIN_warningKinds. Used to make a warning (COIN_fnc_createWarning) and to see whether the threat of a warning
        is still there (COIN_fnc_warningLoop).
        - "camp": every active camp,
        - "ied": every IED that is laid, a decoy as well (the civilian does not know better), while COIN_enableIEDWarnings
          is on,
        - "ambush" (ticket 4.5): the ambush of every active camp that is not cleared, while COIN_enableAmbushWarnings is on
          (its id is the id of its camp).
        Server only.

    Parameter(s):
        NONE

    Returns:
        [kind, id, position, label for the debug map and the log] per threat [ARRAY of ARRAYs]
*/

private _threats = [];

if (!isNil "COIN_camps") then {
    {
        _x params ["_campId", "_nestId", "_campPos"];
        if ((_x select 6) isEqualTo "active") then {
            _threats pushBack ["camp", _campId, _campPos, format ["camp %1 (nest %2)", _campId, _nestId]];
        };
    } forEach COIN_camps;
};

if (COIN_enableIEDWarnings && {!isNil "COIN_ieds"}) then {
    {
        _x params ["_iedId", "_nestId", "", "_iedPos", "_variant"];
        _threats pushBack ["ied", _iedId, _iedPos, format ["IED %1 (nest %2, %3)", _iedId, _nestId, _variant]];
    } forEach COIN_ieds;
};

if (COIN_enableAmbushWarnings && {!isNil "COIN_camps"}) then {
    {
        _x params ["_campId", "_nestId", "", "", "", "", "_state"];
        private _ambush = _x param [8, []];
        if (_state isEqualTo "active" && {_ambush isNotEqualTo []} && {!(_ambush select 2)}) then {
            _threats pushBack ["ambush", _campId, _ambush select 0, format ["ambush of camp %1 (nest %2)", _campId, _nestId]];
        };
    } forEach COIN_camps;
};

_threats
