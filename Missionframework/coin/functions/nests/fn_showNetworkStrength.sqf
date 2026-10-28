/*
    File: fn_showNetworkStrength.sqf
    Author: COIN Liberation

    Description:
        Debug display of the network strength (ticket 2.6, lobby parameter "COIN Debug"): record "Netzwerkstärke" in the
        map diary, tab "COIN Debug", with the share and "x von y Nestern aktiv" from the published values
        COIN_networkStrength and COIN_networkCounts (COIN_fnc_updateNetworkStrength), and the readiness cap that follows
        from it (COIN_fnc_getReadinessCap, ticket 6.6a), "keiner" in a campaign without nests, or "aus" with
        COIN_capReadinessByNetwork off. The cap only
        changes with the strength, so the record stays up to date. The text is German, players read it. Diary records belong to the player unit: with _create the record is made (start and after every respawn),
        without it the text of the existing record is replaced. Before the server has published, the record says so.
        Client with interface only.

    Parameter(s):
        _unit   - Player unit [OBJECT, defaults to player]
        _create - Make the record first [BOOL, defaults to false]

    Returns:
        Record was written [BOOL]
*/

params [
    ["_unit", player, [objNull]],
    ["_create", false, [false]]
];

if (!hasInterface || {isNull _unit}) exitWith {false};

if (_create) then {
    _unit createDiarySubject ["COIN_debug", "COIN Debug"];
    _unit setVariable ["COIN_networkRecord", _unit createDiaryRecord ["COIN_debug", ["Netzwerkstärke", ""]]];
};

private _record = _unit getVariable ["COIN_networkRecord", diaryRecordNull];
if (isNull _record) exitWith {false};

private _text = "Noch nicht vom Server berechnet.";
if (!isNil "COIN_networkStrength" && {!isNil "COIN_networkCounts"}) then {
    COIN_networkCounts params ["_active", "_total"];
    // German decimal comma, two digits
    private _share = (COIN_networkStrength toFixed 2) regexReplace ["\.", ","];
    private _capValue = [] call COIN_fnc_getReadinessCap;
    private _cap = switch (true) do {
        case (!COIN_capReadinessByNetwork): {"aus"};
        case (_capValue < 0): {"keiner (Kampagne ohne Nester)"};
        default {format ["%1 (bei 0 Nestern %2)", round _capValue, COIN_readinessCapFloor]};
    };
    _text = format [
        "<font size='18'>Netzwerkstärke: %1</font><br/>%2 von %3 Nestern aktiv<br/>Readiness-Deckel: %4<br/><br/>Alle Nest-Typen zählen gleich. Der Wert sinkt mit jedem zerstörten Nest.",
        _share, _active, _total, _cap
    ];
};

_unit setDiaryRecordText [["COIN_debug", _record], ["Netzwerkstärke", _text]];

true
