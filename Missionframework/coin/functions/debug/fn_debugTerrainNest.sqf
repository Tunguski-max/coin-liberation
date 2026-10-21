/*
    File: fn_debugTerrainNest.sqf
    Author: COIN Liberation

    Description:
        Debug helper for terrain templates (ticket #31): spawns a terrain nest of a type 30 m in front of the player,
        exactly as a real one spawns (COIN_fnc_spawnTerrainNest: template, direction, guards), so every type and
        every template can be looked at, also types that rarely become terrain nests. The same seed gives the same
        template and direction. Called with "" it removes what it spawned. The nest is not saved and has no
        influence radius. Local host / debug console only ("Lokal ausführen").

    Parameter(s):
        _type - Nest type, e.g. "vbiedGarage", or "" to clear [STRING]
        _seed - Seed, -1 for a random one [NUMBER, defaults to -1]

    Returns:
        Number of objects and units spawned [NUMBER]
*/

params [
    ["_type", "", [""]],
    ["_seed", -1, [0]]
];

// Objects are created where Zeus and the guards' AI live: on the server (local host)
if (!isServer) exitWith {
    hint "COIN_fnc_debugTerrainNest runs on the local host only";
    0
};

// Distance in front of the player
private _ahead = 30;

{
    deleteVehicle _x;
} forEach (missionNamespace getVariable ["COIN_debugTerrainNestObjects", []]);
COIN_debugTerrainNestObjects = [];
if (_type isEqualTo "") exitWith {
    hint "Debug terrain nest removed";
    0
};

if (_seed < 0) then {_seed = floor random 1000000};
private _pos = player getPos [_ahead, getDir player];
_pos = [round (_pos select 0), round (_pos select 1), 0];

COIN_debugTerrainNestObjects = [[-1, _type, "terrain", _pos, _seed, "active"], 0] call COIN_fnc_spawnTerrainNest;
hint format ["Debug terrain nest %1 with seed %2: %3 objects and units (details in the RPT)", _type, _seed, count COIN_debugTerrainNestObjects];

count COIN_debugTerrainNestObjects
