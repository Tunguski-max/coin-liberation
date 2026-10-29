private [ "_tutorial_titles", "_tutorial_pages", "_current_page", "_old_page", "_dialog" ];

if ( isNil "howtoplay" ) then { howtoplay = 0; };

// COIN BEGIN: the pages are the COIN tutorial (ADR 0026, docs/hooks.md hook 37), a list of keys of the COIN package
_tutorial_titles = [];
_tutorial_pages = [];
{
    _tutorial_titles pushBack (localize format ["STR_COIN_tutorial_title_%1", _x]);
    _tutorial_pages pushBack format ["STR_COIN_tutorial_text_%1", _x];
} forEach [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
// COIN END

_current_page = 0;
_old_page = -99;

while { true } do {
    waitUntil { sleep 0.3; howtoplay == 1 };
    waitUntil { !dialog };
    sleep 0.1;

    _dialog = createDialog "liberation_tutorial";
    if ( !cinematic_camera_started ) then {
        [] spawn cinematic_camera;
    };

    waitUntil { dialog };

    {
        lbAdd [ 513, _x];
    } foreach _tutorial_titles;

    lbSetCurSel [ 513, 0 ];

    while { howtoplay == 1 && alive player && dialog } do {
        _current_page = lbCurSel 513;
        if ( _current_page != _old_page ) then {
            ctrlSetText [ 514, _tutorial_titles select _current_page ];
            ((findDisplay 5353) displayCtrl (515)) ctrlSetStructuredText parseText localize (_tutorial_pages select _current_page);
            _old_page = _current_page;
        };
        sleep 0.2;
    };
    if ( dialog ) then { closeDialog 0 };

    cinematic_camera_started = false;
    howtoplay = 0;
}
