/*
    File: fn_getFighterState.sqf
    Author: COIN Liberation

    Description:
        Can a fighter in civilian clothes (triggerman, VBIED driver, suicide bomber, later assassin) still act? (tickets 4.2b,
        4.3 and 4.4, DESIGN 6) Three states:
        - "free": alive, conscious, not captured,
        - "down": unconscious (ACE or the engine), he may wake up,
        - "out": dead, gone (deleted), or captured (ACE handcuffed or surrendering, or captive). Not coming back.
        Server only (reads the unit's variables).

    Parameter(s):
        _unit - The fighter [OBJECT]

    Returns:
        "free", "down" or "out" [STRING]
*/

params [
    ["_unit", objNull, [objNull]]
];

switch (true) do {
    case (isNull _unit || {!alive _unit}): {"out"};
    case (
        _unit getVariable ["ace_captives_isHandcuffed", false]
        || {_unit getVariable ["ace_captives_isSurrendering", false]}
        || {captive _unit}
    ): {"out"};
    case (lifeState _unit == "INCAPACITATED" || {_unit getVariable ["ACE_isUnconscious", false]}): {"down"};
    default {"free"};
}
