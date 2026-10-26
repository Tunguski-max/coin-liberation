/*
    File: fn_secondaryAtElder.sqf
    Author: COIN Liberation

    Description:
        Tells whether Liberation's secondary missions are started at the elder instead of at a FOB or the start base
        (ticket 5.17, ADR 0023). That is so with COIN_secondaryAtElder and when the elder and his dialog exist
        (COIN_enableElder, COIN_enableAidTasks). Hook 30 in Liberation's action "Secondary missions" asks it on every
        machine, so it works before the config is loaded: then the answer is no and Liberation's entry shows as before.

    Parameter(s):
        NONE

    Returns:
        The elder offers the secondary missions [BOOL]
*/

(missionNamespace getVariable ["COIN_secondaryAtElder", false])
&& {missionNamespace getVariable ["COIN_enableElder", false]}
&& {missionNamespace getVariable ["COIN_enableAidTasks", false]}
