/*
    File: fn_updateRadio.sqf
    Author: COIN Liberation

    Description:
        Client: brings the radio of this player in line with the state (ticket 5.19, DESIGN 8.1). While a reinforcement is on its way
        (COIN_reinforcementOn) and the player may give orders (COIN_fnc_canGiveRadioOrder) he has the three orders in the communication
        menu (0-8, the classes of CfgCommunicationMenu.hpp, texts are keys) and the briefing "Verstärkung führen" in the map diary,
        tab "COIN Liberation". Otherwise both are gone. Called when COIN_reinforcementOn changes (the public variable, or directly on a
        local host), after a respawn (the items and the diary belong to the unit, the caller has reset COIN_radioMenuIds) and
        for a late joiner. Without a change it does nothing.

    Parameter(s):
        _unit - The player's unit, the one of a respawn that is just made [OBJECT, defaults to player]

    Returns:
        The player has the orders now [BOOL]
*/

params [
    ["_unit", player, [objNull]]
];

if (!hasInterface || {isNull _unit}) exitWith {false};

if (isNil "COIN_radioMenuIds") then {COIN_radioMenuIds = []};

private _should = COIN_enableRadio
    && {missionNamespace getVariable ["COIN_reinforcementOn", false]}
    && {[_unit] call COIN_fnc_canGiveRadioOrder};
private _has = COIN_radioMenuIds isNotEqualTo [];

if (_should && {!_has}) then {
    {
        COIN_radioMenuIds pushBack ([_unit, format ["coin_radio_%1", _x]] call BIS_fnc_addCommMenuItem);
    } forEach ["follow", "goto", "attack"];

    _unit createDiarySubject ["COIN_info", "COIN Liberation"];
    COIN_radioBriefingRecord = _unit createDiaryRecord ["COIN_info", COIN_radioBriefing apply {[_x] call COIN_fnc_text}];
    if (COIN_debug) then {diag_log format ["[COIN] radio: %1 has the radio orders now (%2)", name _unit, roleDescription _unit]};
};

if (!_should && {_has}) then {
    {[_unit, _x] call BIS_fnc_removeCommMenuItem} forEach COIN_radioMenuIds;
    COIN_radioMenuIds = [];
    if (!isNil "COIN_radioBriefingRecord") then {
        _unit removeDiaryRecord ["COIN_info", COIN_radioBriefingRecord];
        COIN_radioBriefingRecord = nil;
    };
    if (COIN_debug) then {diag_log format ["[COIN] radio: %1 has no radio orders any more", name _unit]};
};

_should
