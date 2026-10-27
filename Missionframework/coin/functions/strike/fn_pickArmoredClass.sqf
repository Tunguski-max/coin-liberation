/*
    File: fn_pickArmoredClass.sqf
    Author: COIN Liberation

    Description:
        A militia infantry class for a fighter of a strike task who is to wear vest and helmet (tickets 5.15 and 5.16): a class of
        militia_squad changed into its Islamic State twin (COIN_fnc_mixClass, ADR 0014). A role without a twin is picked again a few
        times (COIN_leaderSpotTries); without the squad mix, or if none has a twin, the plain class is returned. With _armored false the plain
        class of a random role is returned. Server only.

    Parameter(s):
        _armored - He wears vest and helmet [BOOL, defaults to true]

    Returns:
        Class [STRING]
*/

params [
    ["_armored", true, [true]]
];

private _class = "";
for "_try" from 1 to COIN_leaderSpotTries do {
    _class = [selectRandom militia_squad, true, [0, 1] select _armored] call COIN_fnc_mixClass;
    if (!_armored || {isNil "COIN_squadTwinsLower"} || {(toLower _class) in COIN_squadTwinsLower}) exitWith {};
};

_class
