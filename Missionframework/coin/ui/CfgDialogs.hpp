/*
    File: CfgDialogs.hpp
    Author: COIN Liberation

    Description:
        Dialog classes of the COIN module. Included in Missionframework/description.ext after Liberation's
        ui\liberation_interface.hpp (hook, see docs/hooks.md), so liberation_secondary is known here.
        The elder's dialog (ticket 5.9b) has the look of Liberation's secondary mission dialog: list on the left,
        explanation on the right, button below. It inherits the layout and the controls (101 list, 102 text,
        103 start, 104 cancel, 105 close, 106 picture, 107 label) and changes only what differs; the texts are set
        by COIN_fnc_openElderDialog because they come from the config, not from Liberation's stringtable.
*/

class coin_elder_dialog: liberation_secondary {
    idd = 6843;

    class Header: Header {
        idc = 108;
        text = "";
    };
    class StartButton: StartButton {
        text = "";
        action = "COIN_elderAccept = 1;";
    };
};

// The radio orders for the reinforcement (ticket 5.19): items of the communication menu, in a file of their own
#include "..\CfgCommunicationMenu.hpp"
