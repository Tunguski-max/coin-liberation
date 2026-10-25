/*
    File: fn_hideReputationDisplay.sqf
    Author: COIN Liberation

    Description:
        Hides the reputation (number and coloured icon) in Liberation's resources overlay (ticket 5.3, ADR 0009,
        DESIGN 8). The players learn the mood only from the interpreter. Called at the end of
        KPLIB_fnc_overlayUpdateResources (hook), after Liberation has shown its controls, so the overlay on the map
        loses it as well. With COIN_debug the display stays, so tests can see the reputation.
        Switch: COIN_hideReputationNumber (off: the display is as in Liberation).
        Client only.

    Parameter(s):
        _overlay - Liberation's overlay [DISPLAY]

    Returns:
        Display was hidden [BOOL]
*/

params [
    ["_overlay", displayNull, [displayNull]]
];

// Until the config is loaded the display stays hidden, so the number does not flash up at the start
private _hide = isNil "COIN_hideReputationNumber" || {COIN_hideReputationNumber && {!COIN_debug}};

if (!hasInterface || {isNull _overlay} || {!_hide}) exitWith {false};

// One line in the RPT as proof, the function runs with every UI update
if (isNil "COIN_reputationDisplayLogged") then {
    COIN_reputationDisplayLogged = true;
    diag_log "[COIN] reputation: display in the overlay is hidden (debug off)";
};

{
    (_overlay displayCtrl _x) ctrlShow false;
} forEach [
    758026, // IDC_OVERLAY_RSC_PIC_CIVREP
    758027, // IDC_OVERLAY_RSC_PIC_CIVREP_SHADOW
    758028  // IDC_OVERLAY_RSC_LABEL_CIVREP
];

true
