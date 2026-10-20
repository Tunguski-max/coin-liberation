/*
    COIN Liberation - templates

    Building templates (ADR 0019, ticket #44): how a nest of a type is set up in a house of a class.
    Built by Niklas in Eden or in the mission with Zeus and read out with the export command
    (COIN_fnc_exportNestTemplate in the mission, the snippet in docs/templates.md in Eden).
    Its output is one complete line "COIN_nestBuildingTemplates pushBack [...];", paste it below the list.

    [nest type, house class, [[class, position in the house model, direction relative to the house, role], ...]]
      role  "core"     the core object, exactly one (destroying it destroys the nest)
            "prop"     decoration
            "vehicle"  vehicle of a VBIED garage (locked, decoration)
            "mine"     live mine (createMine, ACE can defuse it); exported as its ammunition class, mapped on start
    Several templates for the same type and house class: the nest's seed picks one.
    At most 3 house classes per nest type (ADR 0019). A type without template keeps the free placement.

    Loaded on every machine by COIN_fnc_init right after coin_config.sqf.
*/

COIN_nestBuildingTemplates = [];

// Templates (paste exported lines here)
// VBIED garage in Land_i_Shed_Ind_F (Niklas, 2026-10-20; ambient effects taken out)
COIN_nestBuildingTemplates pushBack ["vbiedGarage","Land_i_Shed_Ind_F",[["CUP_C_Volha_Gray_TKCIV",[-1.168,1.011,-1.504],0.9,"vehicle"],["jbad_crates_02",[0.974,-0.178,-1.495],207.3,"prop"],["Box_IED_Exp_F",[2.045,-0.992,-0.636],16.0,"core"],["jbad_Kitchen_Chair_a",[2.479,-0.208,-1.498],358.3,"prop"],["Land_WoodenTable_large_F",[2.457,-1.123,-1.494],269.1,"prop"],["Land_WeldingTrolley_01_F",[0.581,3.261,-1.495],327.6,"prop"],["Land_MetalWire_F",[3.984,-0.932,-0.645],207.3,"prop"],["Land_File_F",[4.337,-0.840,-0.640],312.8,"prop"],["ATMine_Range_Ammo",[4.410,-1.133,-0.643],207.3,"mine"],["Land_Screwdriver_V2_F",[4.549,-0.789,-0.613],159.9,"prop"],["Land_WoodenTable_large_F",[4.666,-1.068,-1.495],269.1,"prop"],["ATMine_Range_Ammo",[4.825,-1.134,-0.641],207.3,"mine"],["jbad_Tv_a",[-5.160,0.366,-0.628],89.7,"prop"],["jbad_water_pipe",[-5.291,-0.407,-0.627],207.3,"prop"],["Land_WoodenTable_large_F",[-5.237,0.353,-1.490],1.1,"prop"],["Land_CanisterFuel_F",[5.334,-0.459,-1.495],228.9,"prop"],["Land_Bucket_painted_F",[5.900,-0.653,-1.495],207.3,"prop"],["CUP_C_Lada_GreenTK_CIV",[8.177,1.151,-1.506],1.0,"vehicle"],["GunrackTK_EP1",[3.139,7.876,-1.497],179.1,"prop"],["Land_Metal_rack_Tall_F",[1.797,8.335,-1.495],181.0,"prop"],["Land_Metal_rack_Tall_F",[2.758,8.340,-1.495],181.0,"prop"],["jbad_opx2_pronapane",[9.453,2.854,-1.604],207.3,"prop"],["Land_PortableLight_single_F",[-8.420,8.417,-1.500],325.3,"prop"],["Land_PortableLight_double_F",[15.130,7.971,-1.490],49.7,"prop"]]];
// VBIED garage in Land_CarService_F (Niklas, 2026-10-20)
COIN_nestBuildingTemplates pushBack ["vbiedGarage","Land_CarService_F",[["Land_WeldingTrolley_01_F",[-0.938,-0.850,-1.258],270.7,"prop"],["Lantern_01_blue_F",[0.496,2.388,-0.393],20.5,"prop"],["Land_Wrench_F",[0.872,2.547,-0.396],305.2,"prop"],["Land_WoodenTable_large_F",[0.739,3.179,-1.258],0.3,"prop"],["Box_IED_Exp_F",[0.849,3.367,-1.259],90.4,"core"],["jbad_carpetV2",[3.048,1.738,-1.257],180.5,"prop"],["CUP_C_Lada_TK_CIV",[-2.839,3.159,-1.108],179.0,"vehicle"],["Land_Barrel_sand",[4.503,-0.538,-1.257],20.5,"prop"],["Land_Barrel_sand",[4.505,-1.236,-1.257],20.5,"prop"],["jbad_Tv_a",[1.666,8.006,-0.562],359.9,"prop"],["CUP_conference_table_a",[1.661,8.031,-1.257],180.0,"prop"]]];
// VBIED garage in Land_Jbad_Ind_Garage01 (Niklas, 2026-10-20)
COIN_nestBuildingTemplates pushBack ["vbiedGarage","Land_Jbad_Ind_Garage01",[["CUP_C_TT650_RU",[-0.473,0.480,-0.716],182.3,"vehicle"],["Land_Carpet_rack_EP1",[1.489,0.502,-0.713],90.2,"prop"],["Box_IED_Exp_F",[-1.595,3.335,-0.704],183.4,"core"]]];
// IED workshop in Land_jbad_House_8_old (Niklas, 2026-10-20)
COIN_nestBuildingTemplates pushBack ["iedWorkshop","Land_jbad_House_8_old",[["Box_IED_Exp_F",[-1.731,-1.811,-1.569],91.1,"core"],["CUP_BOX_TK_MILITIA_Ammo_F",[2.045,2.161,-1.016],267.9,"prop"],["Box_IED_Exp_F",[-2.653,-1.866,-1.560],91.2,"prop"],["CUP_C_TT650_CIV",[-2.821,-5.050,-1.679],96.9,"vehicle"]]];
// IED workshop in Land_jbad_House_7_old (Niklas, 2026-10-20)
COIN_nestBuildingTemplates pushBack ["iedWorkshop","Land_jbad_House_7_old",[["CUP_BOX_TK_MILITIA_Grenades_F",[-0.408,3.405,-0.264],89.2,"prop"],["Lantern_01_black_F",[-2.291,2.677,0.204],216.4,"prop"],["Box_IED_Exp_F",[2.538,3.707,-0.264],179.6,"core"],["Lantern_01_red_F",[4.752,3.730,0.238],216.4,"prop"]]];
