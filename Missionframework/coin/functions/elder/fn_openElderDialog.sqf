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
        _offers - [id, section, can be accepted, reason key, reason value] per offer [ARRAY, defaults to []]
        _active - Aid tasks running now, all towns [NUMBER, defaults to 0]

    Returns:
        The dialog was opened, or will be (the call is moved to the scheduler first) [BOOL]
*/

params [
    ["_elder", objNull, [objNull]],
    ["_busy", "", [""]],
    ["_offers", [], [[]]],
    ["_active", 0, [0]]
];

if (!hasInterface || {isNull _elder}) exitWith {false};
// remoteExecCall runs unscheduled, the dialog loop needs to sleep
if (!canSuspend) exitWith {_this spawn COIN_fnc_openElderDialog; true};

private _index = [1, 0] select (language isEqualTo "German");

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

COIN_elderDialogTexts params ["_header", "_accept", "_tasks"];
(_display displayCtrl 108) ctrlSetText (_header select _index);
_button ctrlSetText (_accept select _index);
(_display displayCtrl 107) ctrlSetText format [_tasks select _index, _active, COIN_aidTaskMaxActive];

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
            private _label = (([COIN_aidTaskTexts, _id] call COIN_fnc_findByType) select 1) select _index;
            private _row = _list lbAdd ("    " + _label);
            _list lbSetData [_row, _id];
            if (!_enabled) then {_list lbSetColor [_row, [0.5, 0.5, 0.5, 1]]};
        } forEach _rows;
    };
} forEach COIN_elderSections;

// The first entry that is no header
private _first = 0;
for "_i" from 0 to ((lbSize _list) - 1) do {
    if ((_list lbData _i) isNotEqualTo "") exitWith {_first = _i};
};
_list lbSetCurSel _first;

private _old = -2;
private _range = COIN_talkRange + COIN_talkRangeMargin;
while {dialog && {alive player} && {alive _elder} && {(player distance _elder) <= _range} && {COIN_elderAccept == 0}} do {
    private _selected = lbCurSel _list;
    if (_selected != _old) then {
        _old = _selected;
        private _id = _list lbData _selected;
        private _offer = _offers select {(_x select 0) isEqualTo _id};
        if (_id isEqualTo "" || {_offer isEqualTo []}) then {
            _text ctrlSetStructuredText parseText "";
            _button ctrlEnable false;
            _button ctrlSetTooltip "";
        } else {
            (_offer select 0) params ["", "", "_enabled", "_reasonKey", "_reasonValue"];
            private _row = [COIN_aidTaskTexts, _id] call COIN_fnc_findByType;
            private _explanation = format [(_row select 2) select _index, COIN_aidTaskTimeoutMin, COIN_aidSupplyDistance, COIN_aidSupplyMinValue];
            private _reason = "";
            private _shown = format ["<t color='#e0e0e0'>%1</t>", _explanation];
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
    [_elder, player, _chosen] remoteExecCall ["COIN_fnc_acceptElderOffer", 2];
};

true
