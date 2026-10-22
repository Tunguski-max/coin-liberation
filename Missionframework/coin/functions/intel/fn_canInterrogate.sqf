/*
    File: fn_canInterrogate.sqf
    Author: COIN Liberation

    Description:
        May this interpreter interrogate this prisoner now? (ticket 3.8, DESIGN 7). Used by the action menu entry on the
        client and again on the server before an answer is given, so the client cannot talk its way past the rules.
        A prisoner is a fighter of the militia (the infantry classes of the enemy preset, the test COIN_fnc_canQuestion
        uses to leave him out) who has surrendered or is handcuffed (ACE). He must be alive, on foot, conscious, not a
        player, not interrogated before and not in a conversation. The asker must be an interpreter, alive, conscious and
        close enough. The side of the prisoner does not matter: a fighter handcuffed by a player is still on the enemy side.

    Parameter(s):
        _prisoner - Prisoner [OBJECT, defaults to objNull]
        _asker    - Unit that wants to interrogate him [OBJECT, defaults to objNull]
        _range    - Greatest distance between the two in m [NUMBER, defaults to COIN_talkRange]

    Returns:
        Interrogation is possible [BOOL]
*/

params [
    ["_prisoner", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_range", COIN_talkRange, [0]]
];

if (!COIN_enableInterrogation || {isNull _prisoner} || {isNull _asker}) exitWith {false};

(_asker getVariable ["COIN_interpreter", false])
&& {alive _asker}
&& {(vehicle _asker) isEqualTo _asker}
&& {lifeState _asker != "INCAPACITATED"}
&& {!(_asker getVariable ["ACE_isUnconscious", false])}
&& {_asker distance _prisoner <= _range}
&& {alive _prisoner}
&& {_prisoner isKindOf "CAManBase"}
&& {!isPlayer _prisoner}
&& {(vehicle _prisoner) isEqualTo _prisoner}
&& {lifeState _prisoner != "INCAPACITATED"}
&& {!(_prisoner getVariable ["ACE_isUnconscious", false])}
&& {(toLower typeOf _prisoner) in KPLIB_o_inf_classes || {typeOf _prisoner in militia_squad}}
&& {_prisoner getVariable ["ace_captives_isHandcuffed", false] || {_prisoner getVariable ["ace_captives_isSurrendering", false]}}
&& {!(_prisoner getVariable ["COIN_interrogated", false])}
&& {!(_prisoner getVariable ["COIN_talking", false])}
