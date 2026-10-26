/*
    File: fn_getAidOffers.sqf
    Author: COIN Liberation

    Description:
        What the elder of a town offers now (ticket 5.9b, DESIGN 8.2): one entry per aid task of COIN_aidTaskTexts, each with
        whether it can be accepted and, if not, why. The reasons, the first that applies:
        - "town_running": the town has an aid task running (at most one per town),
        - "town_wait": the town waits COIN_aidTaskCooldownMin after its last aid task (value: minutes left),
        - "limit": COIN_aidTaskMaxActive aid tasks run already (value: the limit),
        - "no_ace": only for "medical" (ticket 5.11) and "repair" (ticket 5.12), the bandages and the progress bar of the tasks are ACE
          (KP_liberation_ace),
        - "no_site": only for "medical" and "repair" with COIN_enableAidSites (tickets 5.20 and 5.21, ADR 0024): no village outside
          the sectors for the task (COIN_fnc_findSite), or all of them are the site of another aid task.
        Used for the dialog and again for the check when an offer is accepted. Server only.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]

    Returns:
        [busy, offers, active]: busy is "" or "busy" while the town runs or waits for a task (the elder says so on opening),
        offers are [id, section, can be accepted, reason key, reason value, place, site] per offer: the place is the name of the
        village the task plays in, else of the town; the site is [name, village centre, distance] for "medical" and "repair" with
        COIN_enableAidSites, else []. Active is the number of running aid tasks
        [ARRAY]
*/

params [
    ["_elder", objNull, [objNull]]
];

if (!isServer || {isNull _elder}) exitWith {["", [], 0]};

private _sector = _elder getVariable ["COIN_sector", ""];
private _active = count COIN_aidActive;
private _running = (COIN_aidActive getOrDefault [_sector, []]) isNotEqualTo [];
private _minutesLeft = ceil (((COIN_aidCooldown getOrDefault [_sector, 0]) - time) / 60);

private _reason = if (_running) then {
    ["town_running", 0]
} else {
    if (_minutesLeft > 0) then {
        ["town_wait", _minutesLeft]
    } else {
        if (_active >= COIN_aidTaskMaxActive) then {["limit", COIN_aidTaskMaxActive]} else {["", 0]}
    }
};

// The villages that are the site of a running aid task (4th entry of COIN_aidActive) are not offered again
private _occupied = (values COIN_aidActive) apply {_x param [3, ""]} select {_x isNotEqualTo ""};
private _town = markerText _sector;
// Looked for once: "medical" and "repair" of one town have the same site (ticket 5.21)
private _site = [];
private _siteSearched = false;

private _offers = COIN_aidTaskTexts apply {
    private _id = _x select 0;
    private _hasSite = COIN_enableAidSites && {_id in ["medical", "repair"]};
    private _offerReason = if ((_reason select 0) isEqualTo "" && {_id in ["medical", "repair"]} && {!KP_liberation_ace}) then {["no_ace", 0]} else {_reason};
    if ((_offerReason select 0) isEqualTo "" && {_hasSite}) then {
        if (!_siteSearched) then {
            _siteSearched = true;
            _site = [_sector, _occupied] call COIN_fnc_findSite;
        };
        if (_site isEqualTo []) then {_offerReason = ["no_site", 0]};
    };
    // The place the task plays in: the village, else the town. Its centre only for the server (COIN_fnc_acceptElderOffer)
    private _place = if (_hasSite && {_site isNotEqualTo []}) then {_site select 0} else {_town};
    [_id, "aid", (_offerReason select 0) isEqualTo "", _offerReason select 0, _offerReason select 1, _place, [[], _site] select _hasSite]
};

[["", "busy"] select (_running || {_minutesLeft > 0}), _offers, _active]
