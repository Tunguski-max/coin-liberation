/*
    File: fn_isPrisoner.sqf
    Author: COIN Liberation

    Description:
        Is this unit a prisoner in the sense of the glossary? A fighter of the militia (the infantry classes of the
        enemy preset) who has surrendered or is handcuffed (ACE). The side of his group does not matter: a fighter
        handcuffed by a player is still on the enemy side, one made by Liberation's surrender script is in a civilian group.
        A fighter in civilian clothes (triggerman, VBIED driver, suicide bomber) is never a prisoner (ADR 0022), he
        has civilian classes anyway. Alive or dead: the ACE state stays on the body. Used by the interrogation (ticket
        3.8) and the reputation for a prisoner who is killed (ticket 5.1).

    Parameter(s):
        _unit - Unit to test [OBJECT, defaults to objNull]

    Returns:
        Unit is a prisoner [BOOL]
*/

params [
    ["_unit", objNull, [objNull]]
];

!isNull _unit
&& {_unit isKindOf "CAManBase"}
&& {!(_unit getVariable ["COIN_civilianFighter", false])}
&& {(toLower typeOf _unit) in KPLIB_o_inf_classes || {typeOf _unit in militia_squad}}
&& {_unit getVariable ["ace_captives_isHandcuffed", false] || {_unit getVariable ["ace_captives_isSurrendering", false]}}
