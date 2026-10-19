if ( isNil "GRLIB_secondary_starting" ) then { GRLIB_secondary_starting = false; };
if ( isNil "GRLIB_secondary_in_progress" ) then { GRLIB_secondary_in_progress = -1; };

_dialog = createDialog "liberation_secondary";
dostartsecondary = 0;

waitUntil { dialog };

{
    lbAdd [ 101, localize _x ];
} foreach [
    "STR_SECONDARY_MISSION0",
    "STR_SECONDARY_MISSION1",
    "STR_SECONDARY_MISSION2"
];

// COIN: grey out secondary missions that are switched off (ticket 2.12)
for "_i" from 0 to ((lbSize 101) - 1) do {
    if !(([_i] call COIN_fnc_secondaryMissionStatus) select 0) then {lbSetColor [101, _i, [0.5, 0.5, 0.5, 1]];};
};

private [ "_oldchoice", "_images", "_briefings", "_missioncost" ];

_images = [
    "res\secondary\fob_hunting.jpg",
    "res\secondary\convoy_hijack.jpg",
    "res\secondary\sar.jpg"
];

_briefings = [
    "STR_SECONDARY_BRIEFING0",
    "STR_SECONDARY_BRIEFING1",
    "STR_SECONDARY_BRIEFING2"
];

_oldchoice = -1;
lbSetCurSel [ 101, 0 ];
private _coinStatus = [true, ""]; // COIN: result of the switch check for the selected mission (ticket 2.12)

while { dialog && alive player && dostartsecondary == 0 } do {

    if ( _oldchoice != lbCurSel 101 ) then {
        _oldchoice = lbCurSel 101;
        ctrlSetText [ 106, _images select _oldchoice ];
        ((findDisplay 6842) displayCtrl (102)) ctrlSetStructuredText parseText localize (_briefings select _oldchoice);
        // COIN: show why a switched off mission cannot be started instead of its briefing (ticket 2.12)
        _coinStatus = [_oldchoice] call COIN_fnc_secondaryMissionStatus;
        if !(_coinStatus select 0) then {
            ((findDisplay 6842) displayCtrl (102)) ctrlSetStructuredText parseText format ["<t color='#e00000' align='center'>%1</t>", _coinStatus select 1];
        };
    };

    _missioncost = GRLIB_secondary_missions_costs select _oldchoice;

    // COIN: a switched off mission keeps the start button disabled (ticket 2.12)
    if ( ( _missioncost <= resources_intel ) && ( !GRLIB_secondary_starting ) && ( _coinStatus select 0 ) )  then {
        ctrlEnable [ 103, true ];
        ((findDisplay 6842) displayCtrl (103)) ctrlSetTooltip "";
    } else {
        ctrlEnable [ 103, false ];
        if ( _missioncost > resources_intel ) then {
            ((findDisplay 6842) displayCtrl (103)) ctrlSetTooltip (localize "STR_SECONDARY_NOT_ENOUGH_INTEL");
        };
        if ( GRLIB_secondary_starting ) then {
            ((findDisplay 6842) displayCtrl (103)) ctrlSetTooltip (localize "STR_SECONDARY_IN_PROGRESS");
        };
        // COIN: the switched off reason wins over the intel and progress hints (ticket 2.12)
        if !(_coinStatus select 0) then {
            ((findDisplay 6842) displayCtrl (103)) ctrlSetTooltip (_coinStatus select 1);
        };
    };

    if ( GRLIB_secondary_in_progress >= 0 ) then {
        lbSetCurSel [ 101, GRLIB_secondary_in_progress ];
        ctrlEnable [ 101, false ];
    } else {
        ctrlEnable [ 101, true ];
    };

    ctrlSetText [ 107, format [ localize "STR_SECONDARY_INTEL", resources_intel ] ];
    sleep 0.1;
};

if ( dostartsecondary == 1 ) then {
    private _index = lbCurSel 101;
    if !(([2000,999999,false] call KPLIB_fnc_getOpforSpawnPoint) isEqualTo "") then {
        [_index] remoteExec ["start_secondary_remote_call", 2];
    } else {
        hint "There is not enough enemy territory left for secondary missions.";
        uiSleep 2;
        hintSilent "";
    }
};

if ( dialog ) then {
    closeDialog 0;
};
