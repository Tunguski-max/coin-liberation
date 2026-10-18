# Modul `coin/`

Hier liegt der gesamte eigene Code der COIN-Schicht (siehe ADR 0003).

## Vorgeschlagene Struktur

Wird in Phase 0 an die tatsächliche Liberation-Struktur angepasst (Ticket 0.6).

```
coin/
├── coin_config.sqf        Balancing und Feature-Schalter
├── CfgFunctions.hpp       Registrierung aller COIN_fnc_* (in description.ext eingebunden)
├── init_server.sqf        Server-Start der COIN-Systeme
├── init_client.sqf        Client-Start (ACE-Interaktionen, Marker)
└── functions/
    ├── common/            Logging, Zeus-Anbindung (COIN_fnc_addToCurators), Hilfsfunktionen
    ├── nests/             Phase 2: Platzieren, Spawnen, Zerstörung, Netzwerkstärke
    ├── intel/             Phase 3: Befragung, Verhör, Marker, Triangulation, Dokumente
    ├── threats/           Phase 4: IED, VBIED, Attentäter, Hinterhalt
    ├── reputation/        Phase 5: Anbindung an Liberation-Ruf
    └── persistence/       Speichern/Laden über den Liberation-Save
```

Dateinamen nach Arma-Konvention: `fn_<name>.sqf` → `COIN_fnc_<name>`.
