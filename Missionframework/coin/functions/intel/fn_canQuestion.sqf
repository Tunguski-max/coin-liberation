/*
    File: fn_canQuestion.sqf
    Author: COIN Liberation

    Description:
        May this interpreter question this civilian now? (ticket 3.1, DESIGN 7). Used for the ACE menu on the client and
        again on the server before an answer is given, so the client cannot talk its way past the rules.
        The civilian must be alive, on foot, conscious, of the civilian side, not a player, not captive (ACE surrendered or
        handcuffed: that covers prisoners, who are interrogated instead, and Liberation's informant while he waits to be
        picked up), not questioned before and not in a conversation. The asker must be an interpreter, alive, conscious
        and close enough.

    Parameter(s):
        _civ   - Civilian [OBJECT, defaults to objNull]
        _asker - Unit that wants to question him [OBJECT, defaults to objNull]
        _range - Greatest distance between the two in m [NUMBER, defaults to COIN_talkRange]

    Returns:
        Questioning is possible [BOOL]
*/

params [
    ["_civ", objNull, [objNull]],
    ["_asker", objNull, [objNull]],
    ["_range", COIN_talkRange, [0]]
];

if (!COIN_enableQuestioning || {isNull _civ} || {isNull _asker}) exitWith {false};

(_asker getVariable ["COIN_interpreter", false])
&& {alive _asker}
&& {lifeState _asker != "INCAPACITATED"}
&& {!(_asker getVariable ["ACE_isUnconscious", false])}
&& {_asker distance _civ <= _range}
&& {alive _civ}
&& {_civ isKindOf "CAManBase"}
&& {!isPlayer _civ}
&& {(side group _civ) isEqualTo GRLIB_side_civilian}
&& {(vehicle _civ) isEqualTo _civ}
&& {lifeState _civ != "INCAPACITATED"}
&& {!(_civ getVariable ["ACE_isUnconscious", false])}
&& {!(_civ getVariable ["ace_captives_isHandcuffed", false])}
&& {!(_civ getVariable ["ace_captives_isSurrendered", false])}
&& {!(_civ getVariable ["COIN_questioned", false])}
&& {!(_civ getVariable ["COIN_talking", false])}
