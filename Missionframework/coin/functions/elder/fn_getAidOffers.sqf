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
        With COIN_fnc_secondaryAtElder the secondary missions of COIN_secondaryOffers follow as section "secondary" (ticket 5.17), not
        tied to the town, with their own reasons: "secondary_running" (Liberation runs a secondary mission, only one at a time) and
        "no_intel" (value: the cost in intel points) and "no_territory" (no enemy territory left for a mission, as in Liberation's dialog).
        With COIN_enableFavors and COIN_enableReinforcement the favor "reinforcement" follows as section "favor" (ticket 5.6), not tied to
        the town either, with the first reason that applies: "reinforcement_running" (one at a time), "reinforcement_rep" (the reputation
        is below COIN_favorMinRep), "no_favor" (none in stock) and "no_intel" (value: COIN_favorIntelCost). It has an 8th entry,
        [favors in stock, most in stock], for the explanation.
        Used for the dialog and again for the check when an offer is accepted. Server only.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]

    Returns:
        [busy, offers, active]: busy is "" or "busy" while the town runs or waits for a task (the elder says so on opening),
        offers are [id, section, can be accepted, reason key, reason value, place, site] per offer: the place is the name of the
        village the task plays in, else of the town; the site is [name, village centre, distance] for "medical" and "repair" with
        COIN_enableAidSites, else []; only the favor has an 8th entry. Active is the number of running aid tasks
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

// The tasks that need ACE (ticket 5.11, 5.12) are the ones that play in a village
private _aceTasks = ["medical", "repair"];

private _offers = COIN_aidTaskTexts apply {
    private _id = _x select 0;
    private _hasSite = COIN_enableAidSites && {_id in _aceTasks};
    private _offerReason = if ((_reason select 0) isEqualTo "" && {_id in _aceTasks} && {!KP_liberation_ace}) then {["no_ace", 0]} else {_reason};
    if ((_offerReason select 0) isEqualTo "" && {_hasSite}) then {
        if (!_siteSearched) then {
            _siteSearched = true;
            _site = [_sector, _occupied] call COIN_fnc_findSite;
        };
        if (_site isEqualTo []) then {_offerReason = ["no_site", 0]};
    };
    // The place the task plays in: the village, else the town. The site (with the centre) is for COIN_fnc_acceptElderOffer; the
    // dialog gets it too (small). The village may be another one by the time the offer is accepted (taken or freed meanwhile):
    // the server looks again, and the elder names the village that was chosen
    private _place = if (_hasSite && {_site isNotEqualTo []}) then {_site select 0} else {_town};
    [_id, "aid", (_offerReason select 0) isEqualTo "", _offerReason select 0, _offerReason select 1, _place, [[], _site] select _hasSite]
};

// Liberation's secondary missions (ticket 5.17): not tied to the town. Grey when one runs already (Liberation's rule: one at a
// time) or the intel points are short; Liberation's cost is the price
if ([] call COIN_fnc_secondaryAtElder) then {
    private _intel = missionNamespace getVariable ["resources_intel", 0];
    private _secondaryRunning = (missionNamespace getVariable ["GRLIB_secondary_in_progress", -1]) >= 0
        || {missionNamespace getVariable ["GRLIB_secondary_starting", false]};
    // Liberation's dialog starts a mission only while enemy territory is left for it, its server call does not look
    COIN_secondaryTerritoryRange params ["_rangeMin", "_rangeMax"];
    private _territory = !(([_rangeMin, _rangeMax, false] call KPLIB_fnc_getOpforSpawnPoint) isEqualTo "");
    {
        _x params ["_id", "_index"];
        private _cost = GRLIB_secondary_missions_costs select _index;
        private _secondaryReason = if (_secondaryRunning) then {["secondary_running", 0]} else {
            if (_intel < _cost) then {["no_intel", _cost]} else {
                if (!_territory) then {["no_territory", 0]} else {["", 0]}
            }
        };
        _offers pushBack [_id, "secondary", (_secondaryReason select 0) isEqualTo "", _secondaryReason select 0, _secondaryReason select 1, "", []];
    } forEach COIN_secondaryOffers;
};

// The favor "reinforcement" (ticket 5.6, ADR 0023): not tied to the town. Grey with the first reason that applies: a reinforcement
// is on its way, the reputation is too low, no favor in stock, too few intel points
if (COIN_enableFavors && {COIN_enableReinforcement}) then {
    private _stock = missionNamespace getVariable ["COIN_favorStock", 0];
    private _favorReason = if ((missionNamespace getVariable ["COIN_reinforcement", []]) isNotEqualTo []) then {["reinforcement_running", 0]} else {
        if ((missionNamespace getVariable ["KP_liberation_civ_rep", 0]) < COIN_favorMinRep) then {["reinforcement_rep", 0]} else {
            if (_stock < 1) then {["no_favor", 0]} else {
                if ((missionNamespace getVariable ["resources_intel", 0]) < COIN_favorIntelCost) then {["no_intel", COIN_favorIntelCost]} else {["", 0]}
            }
        }
    };
    // The 8th entry is for the explanation: the favors in stock and the most
    _offers pushBack ["reinforcement", "favor", (_favorReason select 0) isEqualTo "", _favorReason select 0, _favorReason select 1, "", [], [_stock, COIN_favorMaxStored]];
};

[["", "busy"] select (_running || {_minutesLeft > 0}), _offers, _active]
