/*
    File: fn_informantFrequencyLoop.sqf
    Author: COIN Liberation

    Description:
        Server loop (ticket 5.2, ADR 0009, DESIGN 8): sets how often Liberation's informant shows up by the reputation.
        Liberation's civinfo_loop.sqf reads KP_liberation_civinfo_min, _max and _chance anew in every round, so no hook is
        needed: this loop only changes the three values.
          below COIN_repBandHigh      stage "none":   Liberation's values; its loop waits for a reputation of +25 by itself
          from COIN_repBandHigh       stage "normal": Liberation's values (90-180 min, 75 %)
          from COIN_informantHighRep  stage "fast":   COIN_informantFastMinMax and COIN_informantFastChance
        A new stage counts from the next interval Liberation draws, the one it is sleeping now is not cut short. One log
        line at every change of the stage. Runs as long as COIN_enableInformantFrequency is true (off: Liberation's
        values stay). Server only.

    Parameter(s):
        NONE

    Returns:
        Loop ended [BOOL]
*/

if (!isServer) exitWith {false};

if (isNil "KP_liberation_civinfo_min" || {isNil "KP_liberation_civinfo_max"} || {isNil "KP_liberation_civinfo_chance"}) exitWith {
    diag_log "[COIN] informants: ERROR - Liberation's civinfo values are missing, frequency by reputation is off";
    false
};

// Liberation's own values, [min, max, chance]
private _normal = [KP_liberation_civinfo_min, KP_liberation_civinfo_max, KP_liberation_civinfo_chance];
private _fast = [COIN_informantFastMinMax select 0, COIN_informantFastMinMax select 1, COIN_informantFastChance];
private _stage = "";

while {COIN_enableInformantFrequency} do {
    private _reputation = missionNamespace getVariable ["KP_liberation_civ_rep", 0];
    private _newStage = if (_reputation >= COIN_informantHighRep) then {"fast"} else {
        ["none", "normal"] select (_reputation >= COIN_repBandHigh)
    };

    if !(_newStage isEqualTo _stage) then {
        _stage = _newStage;
        ([_normal, _fast] select (_stage isEqualTo "fast")) params ["_min", "_max", "_chance"];
        KP_liberation_civinfo_min = _min;
        KP_liberation_civinfo_max = _max;
        KP_liberation_civinfo_chance = _chance;
        diag_log format [
            "[COIN] informants: reputation %1, stage %2, an informant is tried every %3 to %4 s with a chance of %5 percent",
            _reputation, _stage, _min, _max, _chance
        ];
    };

    sleep COIN_informantCheckSeconds;
};

true
