/*
    File: fn_isPrisoner.sqf
    Author: COIN Liberation

    Description:
        Is this unit a prisoner in the sense of the glossary? A fighter of the militia (the infantry classes of the
        enemy preset) who has surrendered, is handcuffed (ACE) or was taken along with Liberation's action CAPTURE.
        - Surrendered or handcuffed: the ACE state. A fighter handcuffed by a player is still on the enemy side, one made
          by Liberation's surrender script is in a civilian group. ACE sets isHandcuffed back to false when the unit dies
          (ace_captives_fnc_handleKilled) and handcuffing ends the surrender, so COIN_fnc_initReputationEvents remembers
          the state while the unit lives (COIN_prisonerState) and a dead unit counts by that.
        - Taken along (CAPTURE): the unit joins the group of the player and Liberation ends the surrender, so no ACE state
          is left. Militia classes are in no other group than the enemy one, BLUFOR and the resistance have their own
          classes, so a militia class on the BLUFOR or civilian side is such a prisoner: in the squad, and at a FOB
          where Liberation seats him in a civilian group until it deletes him. Walking away from the squad he goes back to
          the enemy group and is a plain fighter again.
        A fighter in civilian clothes (triggerman, VBIED driver, suicide bomber) is never a prisoner (ADR 0022), he
        has civilian classes anyway. Used by the interrogation (ticket 3.8) and the reputation for a prisoner who is
        killed (ticket 5.1).

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
&& {
    _unit getVariable ["ace_captives_isHandcuffed", false]
    || {_unit getVariable ["ace_captives_isSurrendering", false]}
    || {!alive _unit && {_unit getVariable ["COIN_prisonerState", false]}}
    || {(side group _unit) in [GRLIB_side_friendly, GRLIB_side_civilian]}
}
