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
// IED workshop in Land_jbad_House_c_5_v2 (Niklas, 2026-10-21)
COIN_nestBuildingTemplates pushBack ["iedWorkshop","Land_jbad_House_c_5_v2",[["Land_MetalWire_F",[1.985,3.584,-0.505],59.4,"prop"],["Land_MetalWire_F",[2.195,3.710,-0.507],280.2,"prop"],["Land_Magazine_rifle_F",[2.073,4.116,-0.509],257.0,"prop"],["Land_Screwdriver_V2_F",[1.271,4.582,-0.547],280.2,"prop"],["Land_DuctTape_F",[1.980,4.348,-0.505],280.2,"prop"],["Land_CanisterPlastic_F",[0.480,4.879,-0.561],280.2,"prop"],["Box_IED_Exp_F",[2.009,4.409,-1.368],271.1,"core"],["Land_WoodenTable_large_F",[2.248,4.417,-1.363],181.2,"prop"],["Land_Can_V2_F",[-2.256,-4.681,-0.503],280.2,"prop"],["Land_ChairWood_F",[-2.909,-4.117,-1.371],2.0,"prop"],["Land_Pliers_F",[1.345,5.123,-0.561],249.9,"prop"],["AluminiumFoil_01_F",[2.386,5.083,-0.506],72.8,"prop"],["Land_Suitcase_F",[-2.492,-4.921,-1.370],280.2,"prop"],["Land_GasTank_01_blue_F",[-3.728,-4.174,-1.370],280.2,"prop"],["Land_BakedBeans_F",[-2.263,-5.299,-0.507],280.2,"prop"],["Land_WaterBottle_01_pack_F",[-3.078,-4.749,-1.370],316.6,"prop"],["Land_WoodenTable_small_F",[-2.884,-4.944,-1.365],270.5,"prop"],["Land_BakedBeans_F",[-2.351,-5.285,-0.507],280.2,"prop"],["Land_WaterBottle_01_pack_F",[-3.021,-5.190,-1.370],280.2,"prop"],["Land_PlasticBucket_01_closed_F",[-3.362,-5.188,-0.508],280.2,"prop"],["Land_FoodContainer_01_White_F",[-3.589,-4.934,-1.369],280.2,"prop"]]];

// Weapons cache in Land_jbad_House_3_old (Niklas, 2026-10-21)
COIN_nestBuildingTemplates pushBack ["cache","Land_jbad_House_3_old",[["Land_CampingTable_small_F",[-0.061,-0.355,-0.222],357.8,"prop"],["Land_Pliers_F",[-0.385,-0.114,0.587],145.5,"prop"],["CUP_BOX_TK_MILITIA_Grenades_F",[0.743,2.719,-0.225],90.1,"prop"],["CUP_BOX_TK_MILITIA_Grenades_F",[1.539,2.638,-0.225],35.2,"prop"],["Box_Syndicate_WpsLaunch_F",[-3.104,2.951,-0.052],88.0,"prop"],["Land_Ammobox_rounds_F",[-3.703,2.271,0.075],68.4,"prop"],["Land_Ammobox_rounds_F",[-3.976,1.795,-0.234],176.9,"prop"],["Box_Syndicate_Wps_F",[-3.813,2.248,-0.056],356.7,"prop"],["Land_Pallet_F",[-3.670,2.693,-0.227],87.9,"prop"],["Land_Ammobox_rounds_F",[-4.000,2.273,0.076],85.2,"prop"],["Box_IED_Exp_F",[-3.912,2.968,-0.065],80.8,"core"],["Box_IED_Exp_F",[-4.279,3.275,0.362],179.9,"prop"],["Box_IED_Exp_F",[-4.653,2.982,-0.121],92.2,"prop"]]];

// Weapons cache in land_ffaa_casa_af_7 (Niklas, 2026-10-21)
COIN_nestBuildingTemplates pushBack ["cache","land_ffaa_casa_af_7",[["jbad_Tv_a",[-3.130,-1.302,-1.039],183.5,"prop"],["Land_TableSmall_01_F",[-3.112,-1.364,-1.470],270.8,"prop"],["CUP_BOX_TK_MILITIA_WpsLaunch_F",[3.390,-0.924,-1.503],1.0,"prop"],["Land_Ammobox_rounds_F",[-3.854,-3.724,-1.180],340.7,"prop"],["Box_Syndicate_WpsLaunch_F",[-4.479,-3.056,-1.268],359.5,"prop"],["Box_Syndicate_Wps_F",[-3.860,-3.916,-1.310],269.3,"prop"],["CUP_BOX_TK_MILITIA_Grenades_F",[-3.222,4.590,-1.473],181.4,"prop"],["Land_Ammobox_rounds_F",[-3.810,-4.076,-1.183],38.9,"prop"],["Land_Ammobox_rounds_F",[-3.572,-4.304,-1.473],101.9,"prop"],["Land_Pallet_F",[-4.521,-3.619,-1.471],359.4,"prop"],["Box_IED_Exp_F",[-4.851,-3.532,-1.292],358.9,"core"],["Box_IED_Exp_F",[-4.598,-4.016,-0.870],88.4,"prop"],["Box_IED_Exp_F",[-4.863,-4.222,-1.306],358.9,"prop"]]];

// Weapons cache in Land_jbad_House_1 (Niklas, 2026-10-21)
COIN_nestBuildingTemplates pushBack ["cache","Land_jbad_House_1",[["Box_East_WpsLaunch_F",[-3.476,3.108,1.544],88.3,"prop"],["Box_East_WpsLaunch_F",[-3.965,3.090,1.539],88.3,"prop"],["ACE_medicalSupplyCrate",[2.120,6.162,1.567],182.5,"prop"],["CUP_BOX_TK_MILITIA_Grenades_F",[3.268,6.090,1.564],181.8,"prop"],["rhs_3Ya40_1_single",[-3.254,6.180,2.049],0.7,"core"],["rhs_3Ya40_1_single",[-3.828,5.949,2.050],178.9,"prop"]]];

// Command post in Land_jbad_House6 (Niklas, 2026-10-21)
COIN_nestBuildingTemplates pushBack ["command","Land_jbad_House6",[["Lantern_01_black_F",[-0.518,2.545,-0.772],127.4,"prop"],["Explosive",[-0.258,2.868,-0.781],37.7,"prop"],["OfficeTable_01_old_F",[-0.682,2.215,1.469],270.1,"prop"],["Land_Map_altis_F",[-0.697,1.988,2.298],0.1,"prop"],["Lantern_01_green_F",[-0.116,-3.080,-0.745],127.4,"prop"],["Land_WoodenTable_small_F",[0.429,-2.907,-1.609],270.1,"prop"],["Explosive",[-0.376,3.089,-0.774],127.4,"prop"],["Land_Pliers_F",[-0.096,3.116,-1.612],237.6,"prop"],["OfficeTable_01_old_F",[0.913,-3.149,1.469],180.0,"prop"],["CUP_BOX_TK_MILITIA_WpsLaunch_F",[2.759,-2.440,-1.640],266.7,"core"],["Computer",[0.997,-3.191,2.314],94.8,"prop"],["MapBoard_altis_F",[4.551,-3.042,1.470],136.8,"prop"],["Land_SatelliteAntenna_01_F",[0.116,2.730,4.447],228.6,"prop"]]];
