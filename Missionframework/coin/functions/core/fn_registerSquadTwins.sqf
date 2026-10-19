/*
    File: fn_registerSquadTwins.sqf
    Author: COIN Liberation

    Description:
        Adds the Islamic State twin classes (COIN_squadMixTwins) to KPLIB_o_inf_classes on this machine.
        Liberation uses that list to recognise enemy infantry (prisoner script on clients, save filter on the server),
        and init_presets.sqf builds it from the Afghan Militia classes only. Runs on the server and on every client
        (also late joiners). Lowercase, because Liberation compares with toLower typeOf.
        The twins do not change which class a battlegroup draws, COIN_fnc_mixClass normalises every class to its role.

    Parameter(s):
        NONE

    Returns:
        Number of classes added [NUMBER]
*/

if (!(missionNamespace getVariable ["COIN_enableSquadMix", false])) exitWith {0};

private _added = 0;
{
    private _twin = toLower (_x select 1);
    if (isClass (configFile >> "CfgVehicles" >> _twin) && {KPLIB_o_inf_classes pushBackUnique _twin >= 0}) then {_added = _added + 1;};
} forEach COIN_squadMixTwins;

_added
