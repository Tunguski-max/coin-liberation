/*
    File: CfgCommunicationMenu.hpp
    Author: COIN Liberation

    Description:
        The radio orders for the reinforcement (ticket 5.19, DESIGN 8.1): items of the communication menu (0-8). COIN_fnc_updateRadio adds
        them to those who may give orders (COIN_fnc_canGiveRadioOrder) while a reinforcement is on its way and takes them away
        afterwards. The class has the id of the order and the language: coin_radio_<follow|goto|attack>_<en|de>, picked by the game
        language like the notifications (CfgNotifications.hpp). The expression hands the order to COIN_fnc_giveRadioOrder.
        Included at the end of coin\ui\CfgDialogs.hpp (a COIN file, so no hook in Liberation's files is needed).
*/

class CfgCommunicationMenu {
    class coin_radio_follow_en {
        text = "Reinforcement: Follow us";
        submenu = "";
        expression = "[player, 'follow'] spawn COIN_fnc_giveRadioOrder;";
        icon = "";
        cursor = "";
        enable = "1";
        removeAfterExpressionCall = 0;
    };
    class coin_radio_follow_de: coin_radio_follow_en {
        text = "Verstärkung: Folgt uns";
    };
    class coin_radio_goto_en: coin_radio_follow_en {
        text = "Reinforcement: Go there";
        expression = "[player, 'goto'] spawn COIN_fnc_giveRadioOrder;";
    };
    class coin_radio_goto_de: coin_radio_goto_en {
        text = "Verstärkung: Geht dorthin";
    };
    class coin_radio_attack_en: coin_radio_follow_en {
        text = "Reinforcement: Attack";
        expression = "[player, 'attack'] spawn COIN_fnc_giveRadioOrder;";
    };
    class coin_radio_attack_de: coin_radio_attack_en {
        text = "Verstärkung: Greift an";
    };
};
