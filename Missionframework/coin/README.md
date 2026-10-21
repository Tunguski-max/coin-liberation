# Modul `coin/`

Hier liegt der gesamte eigene Code der COIN-Schicht (siehe ADR 0003).
Der Build (`build.bat`) kopiert den Ordner automatisch mit in die Mission.

## Struktur

```
coin/
├── CfgFunctions.hpp       Registrierung aller COIN_fnc_* (in description.ext eingebunden, Hook #1)
├── coin_config.sqf        Balancing und Feature-Schalter, auf jeder Maschine geladen
├── coin_templates.sqf     Gebäude- und Gelände-Templates (ADR 0019, ADR 0020), nach coin_config.sqf geladen
├── init_server.sqf        Server-Teil des Moduls
├── init_client.sqf        Client-Teil des Moduls (Maschinen mit Interface)
└── functions/
    ├── core/
    │   ├── fn_init.sqf              COIN_fnc_init: Einstiegspunkt (postInit)
    │   ├── fn_applyRoleTraits.sqf   COIN_fnc_applyRoleTraits: ACE-Fähigkeiten der Slots (EOD, Sanitäter)
    │   ├── fn_markFactions.sqf      COIN_fnc_markFactions: Server-Schleife, farbiges Kopftuch für Miliz und Widerstand
    │   ├── fn_getSquadMixShare.sqf  COIN_fnc_getSquadMixShare: Anteil gepanzerter Islamic-State-Kämpfer nach Bereitschaft
    │   ├── fn_mixClass.sqf          COIN_fnc_mixClass: tauscht eine Miliz-Klasse gegen ihr Islamic-State-Gegenstück (Hook 10)
    │   ├── fn_mixSquad.sqf          COIN_fnc_mixSquad: tauscht eine ganze Squad (Hook 9)
    │   ├── fn_registerSquadTwins.sqf COIN_fnc_registerSquadTwins: Zwillingsklassen in KPLIB_o_inf_classes
    │   ├── fn_createDiary.sqf       COIN_fnc_createDiary: Karten-Tagebuch "COIN Liberation" für Spieler
    │   ├── fn_vehicleLimitStatus.sqf   COIN_fnc_vehicleLimitStatus: darf diese Klasse jetzt gekauft werden? (Kaufmenü und Server)
    │   ├── fn_vehicleLimitPurchase.sqf COIN_fnc_vehicleLimitPurchase: Server-Prüfung beim Kauf, startet die Sperre (Hook 12)
    │   ├── fn_vehicleLimitRelease.sqf  COIN_fnc_vehicleLimitRelease: Server hebt die Sperre eines abgebrochenen Kaufs auf
    │   ├── fn_vehicleLimitDeny.sqf     COIN_fnc_vehicleLimitDeny: Client bricht die Platzierung nach abgelehntem Kauf ab
    │   ├── fn_vehicleLimitCancel.sqf   COIN_fnc_vehicleLimitCancel: Client meldet einen abgebrochenen Kauf (Hook 13)
    │   ├── fn_guaranteeResources.sqf   COIN_fnc_guaranteeResources: gleicht die Sorten der Supply Points aus, bei 8 immer 3-3-2 (Hook 14)
    │   ├── fn_secondaryMissionStatus.sqf COIN_fnc_secondaryMissionStatus: darf diese Nebenmission starten? FOB Hunting ist abgeschaltet (Hooks 15 und 16)
    │   ├── fn_aiBudget.sqf             COIN_fnc_aiBudget: Server-Schleife, Liberations Gegner-Grenzen = 100 × Unitcap + COIN-Einheiten (ADR 0015)
    │   ├── fn_applyEnemyAICaps.sqf     COIN_fnc_applyEnemyAICaps: setzt Liberations drei Grenzen auf dieser Maschine (Server und Clients)
    │   ├── fn_markCoinUnits.sqf        COIN_fnc_markCoinUnits: kennzeichnet von COIN gespawnte Einheiten für das Budget
    │   ├── fn_countCoinUnits.sqf       COIN_fnc_countCoinUnits: zählt lebende COIN-Einheiten auf der Feindseite
    │   └── fn_campFitsBudget.sqf       COIN_fnc_campFitsBudget: darf ein Camp mit N Kämpfern jetzt spawnen? Ganz oder gar nicht (COIN_maxCampAI)
    ├── common/
    │   ├── fn_findByType.sqf           COIN_fnc_findByType: Zeile einer Config-Tabelle nach Nest-Typ
    │   ├── fn_addToCurators.sqf        COIN_fnc_addToCurators: alles, was COIN erzeugt, für jeden Zeus bearbeitbar
    │   ├── fn_curatorSync.sqf          COIN_fnc_curatorSync: Server-Schleife, auch für später erzeugte Kuratoren
    │   ├── fn_seededRandom.sqf         COIN_fnc_seededRandom: wiederholbarer Zufall aus dem gespeicherten Seed
    │   ├── fn_getPresence.sqf          COIN_fnc_getPresence: Spieler und Drohnen, die COIN-Inhalte spawnen lassen
    │   ├── fn_halfSize.sqf             COIN_fnc_halfSize: halbe Breite und Länge eines Objekts
    │   ├── fn_isDestructible.sqf       COIN_fnc_isDestructible: kann Arma Objekte dieser Klasse zerstören (Kernobjekte)?
    │   ├── fn_getFloorASL.sqf          COIN_fnc_getFloorASL: Höhe des Bodens unter einer Stelle (Gebäude oder Gelände)
    │   ├── fn_snapToFloor.sqf          COIN_fnc_snapToFloor: setzt ein Objekt auf den Boden darunter
    │   └── fn_isSpotFree.sqf           COIN_fnc_isSpotFree: ist an einer Stelle Platz (Wände, Objekte, Türen)?
    ├── debug/
    │   ├── fn_debugNestContent.sqf     COIN_fnc_debugNestContent: Kernobjekt, Requisiten und Fahrzeuge eines Typs nebeneinander (Abstimmung)
    │   ├── fn_exportNestTemplate.sqf   COIN_fnc_exportNestTemplate: Gebäude-Template des angeschauten Hauses in die Zwischenablage
    │   ├── fn_exportTerrainTemplate.sqf COIN_fnc_exportTerrainTemplate: Gelände-Template um den Richtungspfeil in die Zwischenablage
    │   └── fn_debugTerrainNest.sqf     COIN_fnc_debugTerrainNest: Gelände-Nest eines Typs vor dem Spieler, wie ein echtes
    ├── persistence/
    │   ├── fn_receiveSaveBlock.sqf     COIN_fnc_receiveSaveBlock: merkt sich Eintrag 22 beim Laden des Spielstands (Hook 18)
    │   └── fn_getSaveBlock.sqf         COIN_fnc_getSaveBlock: baut Eintrag 22 beim Speichern, [COIN_saveVersion, Nester] (Hook 17)
    └── nests/
        ├── fn_initNests.sqf            COIN_fnc_initNests: Server, Nester aus dem Spielstand oder neu, Debug-Karte (ADR 0018)
        ├── fn_createNests.sqf          COIN_fnc_createNests: Nester einer neuen Kampagne als Daten, Art pro Typ, „bester Kandidat“, Lockerung
        ├── fn_isNestSpotAllowed.sqf    COIN_fnc_isNestSpotAllowed: Regeln für jedes Nest (Kartenrand, Startbasis, Hauptstadt, Sektoren)
        ├── fn_collectNestHouses.sqf    COIN_fnc_collectNestHouses: Häuser am Ortsrand für Gebäude-Nester (250–600 m)
        ├── fn_findTerrainNestSpots.sqf COIN_fnc_findTerrainNestSpots: Kandidaten für Gelände-Nester (abseits von Orten und Straßen, eben)
        ├── fn_getNestRadius.sqf        COIN_fnc_getNestRadius: Einflussradius eines Nest-Typs aus COIN_nestSetup
        ├── fn_drawNestMarkers.sqf      COIN_fnc_drawNestMarkers: globale Debug-Marker der Nester (Lobby-Parameter „COIN Debug“)
        ├── fn_validateNestContent.sqf  COIN_fnc_validateNestContent: prüft Kernobjekte (zerstörbar) und Requisiten beim Start
        ├── fn_spawnBuildingNest.sqf    COIN_fnc_spawnBuildingNest: Kernobjekt, Requisiten und Wachen eines Gebäude-Nests
        ├── fn_spawnTerrainNest.sqf     COIN_fnc_spawnTerrainNest: Kernobjekt, Requisiten und Wachen eines Gelände-Nests (ADR 0020)
        ├── fn_spawnNestGuards.sqf      COIN_fnc_spawnNestGuards: stehende und patrouillierende Wachen eines Nests
        ├── fn_placeNestTemplate.sqf    COIN_fnc_placeNestTemplate: Objekte nach Gebäude- oder Gelände-Template (ADR 0019, ADR 0020)
        ├── fn_placeNestFree.sqf        COIN_fnc_placeNestFree: freie Platzierung für Häuser ohne Template
        ├── fn_placeNestVehicle.sqf     COIN_fnc_placeNestVehicle: ziviles Fahrzeug der VBIED-Garage bei freier Platzierung
        ├── fn_initCamps.sqf            COIN_fnc_initCamps: Server, Camps als Daten (Kapazität, Eigentümer-Nest), nicht gespeichert (Entscheidung E8)
        ├── fn_getCampCapacity.sqf      COIN_fnc_getCampCapacity: Kapazität aus dem Gewicht der aktiven Nester
        ├── fn_getCampWeight.sqf        COIN_fnc_getCampWeight: Gewicht eines Nest-Typs für die Camps (COIN_campsPerNest)
        ├── fn_findCampSpot.sqf         COIN_fnc_findCampSpot: einfacher zufälliger Platz an Land (ersetzt durch die Regeln aus 2.8)
        ├── fn_drawCampMarkers.sqf      COIN_fnc_drawCampMarkers: globale Debug-Marker der Camps mit Linie zu ihrem Nest
        ├── fn_nestSpawnLoop.sqf        COIN_fnc_nestSpawnLoop: Server-Schleife, Spawn ab 1000 m, Abbau nach 2 min außerhalb 1300 m, Zerstörung prüfen
        └── fn_destroyNest.sqf          COIN_fnc_destroyNest: Nest endgültig zerstört, sofort gespeichert, Ereignis COIN_nestDestroyed
```

Geplante weitere Kategorien unter `functions/` (anlegen, wenn sie gebraucht werden):
`intel/` (Phase 3), `threats/` (Phase 4), `reputation/` (Phase 5).

## Ablauf beim Missionsstart

1. Arma startet `COIN_fnc_init` auf **jeder** Maschine (CfgFunctions `postInit`).
2. `COIN_fnc_init` lädt `coin_config.sqf` und `coin_templates.sqf`.
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
