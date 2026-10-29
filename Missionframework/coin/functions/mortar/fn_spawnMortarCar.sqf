/*
    File: fn_spawnMortarCar.sqf
    Author: COIN Liberation

    Description:
        The unarmed car the mortar squad drives away in (follow-up of tickets 6.7a and 6.7b, #158 and #159): the first class of
        COIN_mortarCarClasses that exists, is not armed (no turret) and has seats for the whole squad (driver and
        COIN_mortarCrew - 1 passengers). It stands COIN_mortarCarDistance behind the mortar, seen from the FOB, on a free
        spot (findEmptyPosition) that is dry and not steep; tries a few directions around "behind". It is empty and
        goes to Zeus. Without a class, a spot or with COIN_enableMortarGetaway off there is no car. Server only.

    Parameter(s):
        _spot - Position of the mortar [ARRAY]
        _fob  - Position of the FOB [ARRAY]

    Returns:
        The car, objNull if there is none [OBJECT]
*/

params [
    ["_spot", [], [[]], [2, 3]],
    ["_fob", [], [[]], [2, 3]]
];

if (!isServer || {!COIN_enableMortarGetaway}) exitWith {objNull};

private _seatsNeeded = COIN_mortarCrew - 1;
private _class = "";
{
    private _cfg = configFile >> "CfgVehicles" >> _x;
    if (isClass _cfg && {getNumber (_cfg >> "transportSoldier") >= _seatsNeeded} && {count ("true" configClasses (_cfg >> "Turrets")) == 0}) exitWith {
        _class = _x;
    };
} forEach COIN_mortarCarClasses;
if (_class isEqualTo "") exitWith {
    diag_log format ["[COIN] mortar: no car for the squad, no class of COIN_mortarCarClasses exists, is unarmed and has %1 passenger seats: %2", _seatsNeeded, COIN_mortarCarClasses];
    objNull
};

COIN_mortarCarDistance params ["_distMin", "_distMax"];
private _away = _spot getDir _fob;
_away = _away + 180;

private _position = [];
{
    private _candidate = _spot getPos [_distMin + random (_distMax - _distMin), _away + _x];
    private _free = _candidate findEmptyPosition [0, COIN_mortarCarFreeRadius, _class];
    if (_free isNotEqualTo [] && {!surfaceIsWater _free} && {((surfaceNormal _free) select 2) >= COIN_mortarMinNormalZ}) exitWith {
        _position = _free;
    };
} forEach COIN_mortarCarAngles;
if (_position isEqualTo []) exitWith {
    diag_log format ["[COIN] mortar: no free spot for the car of the squad at %1, the squad has none", _spot apply {round _x}];
    objNull
};

private _car = createVehicle [_class, [_position select 0, _position select 1, 0], [], 0, "CAN_COLLIDE"];
// Nose to the way out: away from the FOB
_car setDir (_away + (random (2 * COIN_mortarCarHeadingJitter)) - COIN_mortarCarHeadingJitter);
_car setVectorUp (surfaceNormal (getPosATL _car));
[[_car]] call COIN_fnc_addToCurators;

diag_log format ["[COIN] mortar: car %1 stands %2 m behind the mortar at %3", _class, round (_position distance2D _spot), _position apply {round _x}];
_car
