/*
    File: fn_seededRandom.sqf
    Author: COIN Liberation

    Description:
        Repeatable random number from a saved seed (ADR 0018): the same seed and index always give the same value,
        so a nest looks the same on every visit. Different indices give independent values for one seed.

    Parameter(s):
        _seed  - Seed of the nest [NUMBER]
        _index - Which value of this seed, e.g. 0 for the core position, 1 for the first prop [NUMBER]
        _max   - Upper bound [NUMBER]

    Returns:
        Number from 0 up to below _max [NUMBER]
*/

params [
    ["_seed", 0, [0]],
    ["_index", 0, [0]],
    ["_max", 1, [0]]
];

// A large prime keeps the seeds of neighbouring indices apart
((_seed + _index * 7919) random _max) min (_max * 0.999999)
