# Modul `coin/`

Hier liegt der gesamte eigene Code der COIN-Schicht (siehe ADR 0003).
Der Build (`build.bat`) kopiert den Ordner automatisch mit in die Mission.

## Struktur

```
coin/
├── CfgFunctions.hpp       Registrierung aller COIN_fnc_* (in description.ext eingebunden, Hook #1)
├── coin_config.sqf        Balancing und Feature-Schalter, auf jeder Maschine geladen
├── init_server.sqf        Server-Teil des Moduls
├── init_client.sqf        Client-Teil des Moduls (Maschinen mit Interface)
└── functions/
    └── core/
        ├── fn_init.sqf              COIN_fnc_init: Einstiegspunkt (postInit)
        ├── fn_applyRoleTraits.sqf   COIN_fnc_applyRoleTraits: ACE-Fähigkeiten der Slots (EOD, Sanitäter)
        ├── fn_markFactions.sqf      COIN_fnc_markFactions: Server-Schleife, farbiges Kopftuch für Miliz und Widerstand
        ├── fn_mixSquads.sqf         COIN_fnc_mixSquads: Server-Schleife, gepanzerte Islamic-State-Kämpfer in den Feld-Squads der Miliz
        └── fn_createDiary.sqf       COIN_fnc_createDiary: Karten-Tagebuch "COIN Liberation" für Spieler
```

Geplante weitere Kategorien unter `functions/` (anlegen, wenn sie gebraucht werden):
`common/` (Zeus-Anbindung `COIN_fnc_addToCurators`, Hilfsfunktionen), `nests/` (Phase 2),
`intel/` (Phase 3), `threats/` (Phase 4), `reputation/` (Phase 5), `persistence/` (Speichern über den Liberation-Save, ADR 0005).

## Ablauf beim Missionsstart

1. Arma startet `COIN_fnc_init` auf **jeder** Maschine (CfgFunctions `postInit`).
2. `COIN_fnc_init` lädt `coin_config.sqf`.
3. Es wartet, bis Liberations `init.sqf` auf dieser Maschine fertig ist (`KPLIB_init`), höchstens `COIN_initTimeout` Sekunden.
4. Auf dem Server läuft `init_server.sqf`, auf Maschinen mit Interface `init_client.sqf`.
   Beim lokalen Host laufen beide.

Spätere Synchronisationspunkte aus Liberation: `save_is_loaded` (Spielstand geladen, public).
Siehe `docs/kp-liberation-map.md` Abschnitt 2.

## Neue Funktion anlegen

1. Datei `functions/<kategorie>/fn_<name>.sqf` anlegen (Kopfkommentar wie in `fn_init.sqf`).
2. In `CfgFunctions.hpp` unter der Kategorie eintragen (`class <name> {};`), ggf. neue Kategorie mit `file = "coin\functions\<kategorie>";`.
3. Aufruf als `COIN_fnc_<name>`. Ein `CfgRemoteExec` gibt es nicht, für `remoteExec` ist kein Eintrag nötig.

## Logs

`diag_log format ["[COIN] <modul>: %1", ...]`. Debug-Ausgaben nur, wenn `COIN_debug` aktiv ist.
