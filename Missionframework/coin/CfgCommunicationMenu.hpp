/*
    File: CfgCommunicationMenu.hpp
    Author: COIN Liberation

    Description:
        The radio orders for the reinforcement (ticket 5.19, DESIGN 8.1): items of the communication menu (0-8). COIN_fnc_updateRadio adds
        them to those who may give orders (COIN_fnc_canGiveRadioOrder) while a reinforcement is on its way and takes them away
        afterwards. The class has the id of the order: coin_radio_<follow|goto|attack>. The text is a key of the COIN package in
        stringtable.xml, so the game decides the language (ADR 0026, ticket 7.0c, #180). The expression hands the order to
        COIN_fnc_giveRadioOrder.
        Included at the end of coin\ui\CfgDialogs.hpp (a COIN file, so no hook in Liberation's files is needed).
*/

class CfgCommunicationMenu {
    class coin_radio_follow {
        text = $STR_COIN_radio_menu_follow;
        submenu = "";
        expression = "[player, 'follow'] spawn COIN_fnc_giveRadioOrder;";
        icon = "";
        cursor = "";
        enable = "1";
        removeAfterExpressionCall = 0;
    };
    class coin_radio_goto: coin_radio_follow {
        text = $STR_COIN_radio_menu_goto;
        expression = "[player, 'goto'] spawn COIN_fnc_giveRadioOrder;";
    };
    class coin_radio_attack: coin_radio_follow {
        text = $STR_COIN_radio_menu_attack;
        expression = "[player, 'attack'] spawn COIN_fnc_giveRadioOrder;";
    };
};
