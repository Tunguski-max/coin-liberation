/*
    File: fn_placeNestVehicle.sqf
    Author: COIN Liberation

    Description:
        Civilian vehicle of a VBIED garage (ticket #44, decided 2026-10-20): a prop, not the core object, decoration only.
        The class follows from the nest's seed (COIN_vbiedGarageVehicles), so the garage looks the same on every visit.
        Stands inside the hall on the ground floor if there is room (house centre or a ground floor building position,
        facing along the house or across), otherwise on a free spot next to the house (findEmptyPosition, up to
        COIN_nestVehicleOutside beyond it). Locked for players, without simulation, not saved by Liberation.
        Server only.

    Parameter(s):
        _house    - House of the nest [OBJECT]
        _seed     - Seed of the nest [NUMBER]
        _blockers - Taken places [ARRAY of [position ATL, radius]]

    Returns:
        Vehicle, objNull if no class exists or there is no room [OBJECT]
*/

params [
    ["_house", objNull, [objNull]],
    ["_seed", 0, [0]],
    ["_blockers", [], [[]]]
];

// Value streams of the seed (COIN_fnc_seededRandom index), apart from those of COIN_fnc_spawnBuildingNest
private _streamClass = 6000;
private _streamTurn = 6001;

private _classes = COIN_vbiedGarageVehicles select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_classes isEqualTo []) exitWith {
    diag_log format ["[COIN] nests: no class of COIN_vbiedGarageVehicles exists, VBIED garage without vehicle (%1)", COIN_vbiedGarageVehicles];
    objNull
};

private _class = _classes select (floor ([_seed, _streamClass, count _classes] call COIN_fnc_seededRandom));
private _vehicle = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_vehicle enableSimulationGlobal false;
(boundingBoxReal _vehicle) params ["_c1", "_c2"];
private _halfX = abs ((_c2 select 0) - (_c1 select 0)) / 2;
private _halfY = abs ((_c2 select 1) - (_c1 select 1)) / 2;

// Inside: house centre and ground floor building positions (the lowest floor of the house)
private _positions = _house buildingPos -1;
private _groundZ = selectMin (_positions apply {_x select 2});
private _houseCenter = getPosATL _house;
private _candidates = [[_houseCenter select 0, _houseCenter select 1, _groundZ]];
_candidates append (_positions select {((_x select 2) - _groundZ) < COIN_spotSameFloor});

// Facing along the house first, the seed decides which way round
private _houseDir = getDir _house;
private _turn = [0, 180] select (([_seed, _streamTurn, 2] call COIN_fnc_seededRandom) >= 1);
private _dirs = [_houseDir + _turn, _houseDir + _turn + 180, _houseDir + 90, _houseDir + 270];

private _spot = [];
private _spotDir = _houseDir;
{
    private _candidate = _x;
    {
        if ([_candidate, _x, _halfX, _halfY, [_vehicle], _blockers] call COIN_fnc_isSpotFree) exitWith {
            _spot = _candidate;
            _spotDir = _x;
        };
    } forEach _dirs;
    if !(_spot isEqualTo []) exitWith {};
} forEach _candidates;

private _inside = !(_spot isEqualTo []);
if (!_inside) then {
    (boundingBoxReal _house) params ["_h1", "_h2"];
    private _houseRadius = ((abs ((_h2 select 0) - (_h1 select 0))) max (abs ((_h2 select 1) - (_h1 select 1)))) / 2;
    _spot = _houseCenter findEmptyPosition [_houseRadius, _houseRadius + COIN_nestVehicleOutside, _class];
};

if (_spot isEqualTo []) exitWith {
    deleteVehicle _vehicle;
    diag_log format ["[COIN] nests: no room for a %1 in or next to %2, VBIED garage without vehicle", _class, typeOf _house];
    objNull
};

_vehicle setDir _spotDir;
_vehicle setPosATL _spot;
[_vehicle] call COIN_fnc_snapToFloor;
_vehicle setVehicleLock "LOCKED";
_vehicle setVariable ["KP_liberation_preplaced", true];
_vehicle setVariable ["COIN_nestVehicleInside", _inside];

_vehicle
