/*
    File: fn_updateRadio.sqf
    Author: COIN Liberation

    Description:
        Client: brings the radio of this player in line with the state (ticket 5.19, DESIGN 8.1). While a reinforcement is on its way
        (COIN_reinforcementOn) and the player may give orders (COIN_fnc_canGiveRadioOrder) he has the three orders in the communication
        menu (0-8, the classes of CfgCommunicationMenu.hpp in the game language) and the briefing "Verstärkung führen" in the map diary,
        tab "COIN Liberation". Otherwise both are gone. Called when COIN_reinforcementOn changes (the public variable, or directly on a
        local host), after a respawn (the items and the diary belong to the unit, the caller has reset COIN_radioMenuIds) and
        for a late joiner. Without a change it does nothing.

    Parameter(s):
        NONE

    Returns:
        The player has the orders now [BOOL]
*/

if (!hasInterface || {isNull player}) exitWith {false};

if (isNil "COIN_radioMenuIds") then {COIN_radioMenuIds = []};

private _should = COIN_enableRadio
    && {missionNamespace getVariable ["COIN_reinforcementOn", false]}
    && {[player] call COIN_fnc_canGiveRadioOrder};
private _has = COIN_radioMenuIds isNotEqualTo [];

if (_should && {!_has}) then {
    private _language = ["en", "de"] select (language isEqualTo "German");
    {
        COIN_radioMenuIds pushBack ([player, format ["coin_radio_%1_%2", _x, _language]] call BIS_fnc_addCommMenuItem);
    } forEach ["follow", "goto", "attack"];

    player createDiarySubject ["COIN_info", "COIN Liberation"];
    COIN_radioBriefingRecord = player createDiaryRecord ["COIN_info", COIN_radioBriefing];
    if (COIN_debug) then {diag_log format ["[COIN] radio: %1 has the radio orders now (%2)", name player, roleDescription player]};
};

if (!_should && {_has}) then {
    {[player, _x] call BIS_fnc_removeCommMenuItem} forEach COIN_radioMenuIds;
    COIN_radioMenuIds = [];
    if (!isNil "COIN_radioBriefingRecord") then {
        player removeDiaryRecord ["COIN_info", COIN_radioBriefingRecord];
        COIN_radioBriefingRecord = nil;
    };
    if (COIN_debug) then {diag_log format ["[COIN] radio: %1 has no radio orders any more", name player]};
};

_should
