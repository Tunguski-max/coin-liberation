/*
    COIN Liberation - templates

    Building templates (ADR 0019, ticket #44): how a nest of a type is set up in a house of a class.
    Built by Niklas in Eden (or in the mission with Zeus) and read out with the export command
    (COIN_fnc_exportNestTemplate, or the console snippet in the test guide of #44). Paste its output into the list.

    [nest type, house class, [[class, position in the house model, direction relative to the house, role], ...]]
      role  "core"     the core object, exactly one (destroying it destroys the nest)
            "prop"     decoration
            "vehicle"  vehicle of a VBIED garage (locked, decoration)
    Several templates for the same type and house class: the nest's seed picks one.
    At most 3 house classes per nest type (ADR 0019). A type without template keeps the free placement.

    Loaded on every machine by COIN_fnc_init right after coin_config.sqf.
*/

COIN_nestBuildingTemplates = [
];
