/*
    File: CfgNotifications.hpp
    Author: COIN Liberation

    Description:
        Notification classes of the COIN module (ticket 2.14, #54), shown with BIS_fnc_showNotification like
        Liberation's "FOB destroyed". Included in Missionframework/ui/liberation_notifications.hpp inside class
        CfgNotifications (hook, see docs/hooks.md), so lib_default_notification is known here.
        The texts are keys of the COIN package in stringtable.xml (ADR 0026, ticket 7.0a, #177): one class per message, the
        game decides the language, English is the fall-back. %1 of a nest message is the nest type, of a reinforcement
        message the town, of the mortar message the FOB.
        Look of Liberation's "hostile FOB destroyed" (green, success sound): the news is good for the players.
*/

class coin_nest_destroyed: lib_default_notification {
    title = $STR_COIN_notify_nestDestroyed_title;
    description = $STR_COIN_notify_nestDestroyed_text;
    iconPicture = "res\notif\ui_notif_sob.paa";
    color[] = { 0, 1, 0, 1 };
    sound = "taskSucceeded";
};
class coin_camp_cleared: coin_nest_destroyed {
    title = $STR_COIN_notify_campCleared_title;
    description = $STR_COIN_notify_campCleared_text;
};
// New intel on the map (ticket 3.1): tells nothing about its content, also not whether it is true
class coin_intel_new: coin_nest_destroyed {
    title = $STR_COIN_notify_intelNew_title;
    description = $STR_COIN_notify_intelNew_text;
    iconPicture = "res\notif\ui_notif_int.paa";
    color[] = { 1, 0.6, 0, 1 };
    sound = "taskCreated";
};
// Warning of a camp (ticket 3.6)
class coin_intel_warning: coin_intel_new {
    title = $STR_COIN_notify_intelWarning_title;
    description = $STR_COIN_notify_intelWarning_text;
    color[] = { 1, 0.2, 0.2, 1 };
};
// Mortar fire on a FOB (ticket 6.7b, #159): %1 is the name of the FOB. Red like the warning. Texts to be agreed with Niklas
class coin_mortar_attack: coin_intel_warning {
    title = $STR_COIN_notify_mortarAttack_title;
    description = $STR_COIN_notify_mortarAttack_text;
    iconPicture = "res\notif\ui_notif_fob_und.paa";
};
// Reinforcement (ticket 5.6): %1 is the town of the elder. Arrived is good news (green), leaving is a hint (orange), wiped out a warning (red)
class coin_reinforcement_arrived: coin_nest_destroyed {
    title = $STR_COIN_notify_reinforcementArrived_title;
    description = $STR_COIN_notify_reinforcementArrived_text;
    iconPicture = "res\notif\ui_notif_ref.paa";
};
class coin_reinforcement_left_time: coin_intel_new {
    title = $STR_COIN_notify_reinforcementLeftTime_title;
    description = $STR_COIN_notify_reinforcementLeftTime_text;
    iconPicture = "res\notif\ui_notif_ref.paa";
};
class coin_reinforcement_left_reputation: coin_reinforcement_left_time {
    description = $STR_COIN_notify_reinforcementLeftReputation_text;
};
class coin_reinforcement_left_wiped: coin_intel_warning {
    title = $STR_COIN_notify_reinforcementWiped_title;
    description = $STR_COIN_notify_reinforcementWiped_text;
    iconPicture = "res\notif\ui_notif_ref.paa";
};
