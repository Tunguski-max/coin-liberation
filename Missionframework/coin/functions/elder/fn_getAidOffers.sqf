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
          (KP_liberation_ace).
        Used for the dialog and again for the check when an offer is accepted. Server only.

    Parameter(s):
        _elder - The elder [OBJECT, defaults to objNull]

    Returns:
        [busy, offers, active]: busy is "" or "busy" while the town runs or waits for a task (the elder says so on opening),
        offers are [id, section, can be accepted, reason key, reason value], active is the number of running aid tasks
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

private _offers = COIN_aidTaskTexts apply {
    private _id = _x select 0;
    private _offerReason = if ((_reason select 0) isEqualTo "" && {_id in ["medical", "repair"]} && {!KP_liberation_ace}) then {["no_ace", 0]} else {_reason};
    [_id, "aid", (_offerReason select 0) isEqualTo "", _offerReason select 0, _offerReason select 1]
};

[["", "busy"] select (_running || {_minutesLeft > 0}), _offers, _active]
