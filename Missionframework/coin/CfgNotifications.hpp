/*
    File: CfgNotifications.hpp
    Author: COIN Liberation

    Description:
        Notification classes of the COIN module (ticket 2.14, #54), shown with BIS_fnc_showNotification like
        Liberation's "FOB destroyed". Included in Missionframework/ui/liberation_notifications.hpp inside class
        CfgNotifications (hook, see docs/hooks.md), so lib_default_notification is known here.
        Liberation keeps its texts in stringtable.xml; the COIN module does not touch that file, so every message
        exists once per language and COIN_fnc_showNotification picks the class by the game language.
        Look of Liberation's "hostile FOB destroyed" (green, success sound): the news is good for the players.
        %1 of a nest message is the nest type.
*/

class coin_nest_destroyed_en: lib_default_notification {
    title = "MILITIA NEST DESTROYED";
    description = "%1 destroyed!";
    iconPicture = "res\notif\ui_notif_sob.paa";
    color[] = { 0, 1, 0, 1 };
    sound = "taskSucceeded";
};
class coin_nest_destroyed_de: coin_nest_destroyed_en {
    title = "MILIZ-NEST ZERSTÖRT";
    description = "%1 zerstört!";
};
class coin_camp_cleared_en: coin_nest_destroyed_en {
    title = "MILITIA CAMP CLEARED";
    description = "A militia camp has been cleared.";
};
class coin_camp_cleared_de: coin_camp_cleared_en {
    title = "MILIZ-CAMP AUSGEHOBEN";
    description = "Ein Miliz-Camp wurde ausgehoben.";
};
// New intel on the map (ticket 3.1): tells nothing about its content, also not whether it is true
class coin_intel_new_en: coin_nest_destroyed_en {
    title = "NEW INTEL";
    description = "A new lead has been added to the map.";
    color[] = { 1, 0.6, 0, 1 };
    sound = "taskCreated";
};
class coin_intel_new_de: coin_intel_new_en {
    title = "NEUE SPUR";
    description = "Eine neue Spur wurde auf der Karte eingetragen.";
};
