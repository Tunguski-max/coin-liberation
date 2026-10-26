/*
    File: fn_openElderDialog.sqf
    Author: COIN Liberation

    Description:
        Client: opens the dialog of the elder (ticket 5.9b, DESIGN 8) for the interpreter: list on the left, explanation
        on the right, "Accept" below, like Liberation's secondary mission dialog (class coin_elder_dialog inherits it).
        The list has sections (COIN_elderSections), so offers of other kinds can be added to the data without changing
        the dialog. An offer that cannot be accepted is grey; its explanation starts with the reason in red and the
        button stays disabled. Sent by COIN_fnc_askElderHelp. If the town waits for a task or runs one, the elder says so
        as a subtitle on opening. "Accept" sends the offer to the server (COIN_fnc_acceptElderOffer), which checks again.
        The dialog closes by itself when the interpreter walks away or the elder is gone.

    Parameter(s):
        _elder  - The elder [OBJECT, defaults to objNull]
        _busy   - "busy" if the town runs or waits for an aid task, else "" [STRING, defaults to ""]
        _offers - [id, section, can be accepted, reason key, reason value, place, site] per offer, the place (village or town) is %6 of
                  the explanation [ARRAY, defaults to []]
        _active - Aid tasks running now, all towns [NUMBER, defaults to 0]
        _mode   - "elder" or "strike" (tickets 5.13 and 5.14): the dialog of a strike task has the texts and section of
                  COIN_strikeDialogTexts and COIN_strikeSections, one entry of COIN_strikeTaskTexts, no elder to stay near ("_elder" is the one
                  who told of it, he speaks after the accepting) and "Accept" goes to COIN_fnc_acceptStrikeTask [STRING, defaults to "elder"]

    Returns:
        The dialog was opened, or will be (the call is moved to the scheduler first) [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_busy", "", [""]],
    ["_offers", [], [[]]],
    ["_active", 0, [0]],
    ["_mode", "elder", [""]]
];

if (!hasInterface || {isNull _elder}) exitWith {false};
// remoteExecCall runs unscheduled, the dialog loop needs to sleep
if (!canSuspend) exitWith {_this spawn COIN_fnc_openElderDialog; true};

private _index = [1, 0] select (language isEqualTo "German");
private _strike = _mode isEqualTo "strike";

if (_busy isNotEqualTo "") then {
    [_elder, "busy"] call COIN_fnc_showElderSentence;
};

COIN_elderAccept = 0;
if (!createDialog "coin_elder_dialog") exitWith {
    diag_log "[COIN] elder: ERROR - the dialog coin_elder_dialog could not be opened";
    false
};
private _display = findDisplay 6843;
private _list = _display displayCtrl 101;
private _text = _display displayCtrl 102;
private _button = _display displayCtrl 103;
private _pictureCtrl = _display displayCtrl 106;

(if (_strike) then {COIN_strikeDialogTexts} else {COIN_elderDialogTexts}) params ["_header", "_accept", "_tasks"];
(_display displayCtrl 108) ctrlSetText (_header select _index);
_button ctrlSetText (_accept select _index);
(_display displayCtrl 107) ctrlSetText format [_tasks select _index, _active, [COIN_aidTaskMaxActive, COIN_strikeTaskMaxActive] select _strike];

// Sections with their offers; a section header has no data and cannot be accepted
{
    _x params ["_section", "_title"];
    private _rows = _offers select {(_x select 1) isEqualTo _section};
    if (_rows isNotEqualTo []) then {
        private _headerRow = _list lbAdd (_title select _index);
        _list lbSetData [_headerRow, ""];
        _list lbSetColor [_headerRow, [0.8, 0.8, 0.8, 0.6]];
        {
            _x params ["_id", "", "_enabled"];
            // A secondary mission of Liberation (ticket 5.17) has Liberation's title, an aid task its own
            private _secondary = [COIN_secondaryOffers, _id] call COIN_fnc_findByType;
            private _label = if (_secondary isNotEqualTo []) then {
                localize (_secondary select 2)
            } else {
                (([[COIN_aidTaskTexts, COIN_strikeTaskTexts] select _strike, _id] call COIN_fnc_findByType) select 1) select _index
            };
            private _row = _list lbAdd ("    " + _label);
            _list lbSetData [_row, _id];
            if (!_enabled) then {_list lbSetColor [_row, [0.5, 0.5, 0.5, 1]]};
        } forEach _rows;
    };
} forEach ([COIN_elderSections, COIN_strikeSections] select _strike);

// The first entry that is no header
private _first = 0;
for "_i" from 0 to ((lbSize _list) - 1) do {
    if ((_list lbData _i) isNotEqualTo "") exitWith {_first = _i};
};
_list lbSetCurSel _first;

private _old = -2;
private _range = COIN_talkRange + COIN_talkRangeMargin;
// A strike task does not tie the dialog to the one who told of it (a civilian walks away after he has spoken)
while {dialog && {alive player} && {_strike || {alive _elder && {(player distance _elder) <= _range}}} && {COIN_elderAccept == 0}} do {
    private _selected = lbCurSel _list;
    if (_selected != _old) then {
        _old = _selected;
        private _id = _list lbData _selected;
        private _offer = _offers select {(_x select 0) isEqualTo _id};
        // The picture of the offer, like Liberation's pictures of its side missions; none if the file is not there
        private _secondary = [COIN_secondaryOffers, _id] call COIN_fnc_findByType;
        private _picture = if (_secondary isNotEqualTo []) then {_secondary select 4} else {format [COIN_aidImagePath, _id]};
        _pictureCtrl ctrlSetText (["", _picture] select (_id isNotEqualTo "" && {fileExists _picture}));
        if (_id isEqualTo "" || {_offer isEqualTo []}) then {
            _text ctrlSetStructuredText parseText "";
            _button ctrlEnable false;
            _button ctrlSetTooltip "";
        } else {
            (_offer select 0) params ["", "", "_enabled", "_reasonKey", "_reasonValue", "_place"];
            // No village for the task: the explanation names no place of the town, as the offer is grey for that reason
            if (_reasonKey isEqualTo "no_site") then {_place = COIN_aidNoSitePlace select _index};
            private _row = [[COIN_aidTaskTexts, COIN_strikeTaskTexts] select _strike, _id] call COIN_fnc_findByType;
            private _explanation = if (_secondary isNotEqualTo []) then {
                // Liberation's briefing, then its cost and the intel points the army has
                (localize (_secondary select 3)) + "<br/><br/>" + format [
                    COIN_secondaryCostText select _index, GRLIB_secondary_missions_costs select (_secondary select 1), missionNamespace getVariable ["resources_intel", 0]
                ]
            } else {
                if (_strike) then {
                    // The minutes until the event starts and the whole window, each as [least, most]
                    format [(_row select 2) select _index, COIN_strikeTaskDelayMin select 0, COIN_strikeTaskDelayMin select 1, COIN_strikeTaskWindowMin select 0, COIN_strikeTaskWindowMin select 1]
                } else {
                    format [(_row select 2) select _index, COIN_aidTaskTimeoutMin, COIN_aidSupplyDistance, COIN_aidSupplyMinValue, COIN_aidRepairSeconds, COIN_aidRepairRadius select 0, _place]
                }
            };
            private _reason = "";
            // The look of Liberation's briefings: the title big and orange, then the text; the lines of the explanation carry their
            // own colours (blue and orange). A secondary mission has its title in Liberation's briefing
            private _shown = _explanation;
            if (_secondary isEqualTo []) then {
                private _title = ((_row select 1) select _index);
                _shown = format ["<t size='1.3' color='#ffa000'>%1</t><br/><br/>%2", _title, _explanation];
            };
            if (!_enabled) then {
                private _reasonRow = [COIN_aidReasonTexts, _reasonKey] call COIN_fnc_findByType;
                _reason = format [(_reasonRow param [1, ["", ""]]) select _index, _reasonValue];
                _shown = format ["<t color='#e00000'>%1</t><br/><br/>", _reason] + _shown;
            };
            _text ctrlSetStructuredText parseText _shown;
            _button ctrlEnable _enabled;
            _button ctrlSetTooltip _reason;
        };
    };
    sleep 0.1;
};

private _chosen = "";
if (COIN_elderAccept == 1 && {dialog}) then {
    _chosen = _list lbData (lbCurSel _list);
};
if (dialog) then {closeDialog 0};

if (_chosen isNotEqualTo "") then {
    [_elder, player, _chosen] remoteExecCall [["COIN_fnc_acceptElderOffer", "COIN_fnc_acceptStrikeTask"] select _strike, 2];
};

true
