# Changelog COIN Liberation

Änderungen der COIN-Schicht. Änderungen von KP Liberation selbst stehen in `CHANGELOG.md`.

## [Unveröffentlicht]

### Hinzugefügt
- Starter-Dokumentation: Design, Roadmap, Glossar, ADRs 0001–0006, Test- und Deploy-Anleitung
- Modul-Skelett `Missionframework/coin/` mit `coin_config.sqf`
- Design: Miliz-Camps (zufällig, nicht persistent, an Nester gekoppelt)
- Design: Ausrüstung als leichte Brigade (ADR 0007)
- Design: Gefälligkeiten bei sehr hohem Ruf (Ablenkungsangriff, Verstärkung) – Vorschlag
- Design: Option für Dokumente als ACE Intel Items (E13)
- Code-Landkarte `docs/kp-liberation-map.md` (Phase 0, Tickets 0.4/0.5)
- ADRs 0008–0015 (Phase-0-Entscheidungen), ADR 0003 und 0005 akzeptiert, DESIGN.md v0.2
- Modul `coin/` eingebunden: `COIN_fnc_init` (postInit) lädt `coin_config.sqf` und startet `init_server.sqf` / `init_client.sqf` (Ticket 0.6)
- Eigene Mission im Build: `coin_liberation.lythium`, Titel „COIN Liberation Lythium dev (KP v0.96.7a)“, eigene Beschreibung;
  Build liest `_tools/_presets.coin.json`, Liberation-Karten optional mit `COIN_ALL_PRESETS=1`

- Design v0.3 (Phase-1-Befragung): ganze Karte ausgedünnt mit Hauptstadt Kalae Noowi (ADR 0016),
  Bauliste und Elite-Fahrzeuge der leichten Brigade (ADR 0007), schweres Gerät der Miliz (ADR 0014),
  Ruf nur über den Dolmetscher erfahrbar, Verhör überall, Regeln für Intel-Marker (ADR 0009, 0011),
  ADR 0002 akzeptiert, 15 Slots, Roadmap Phase 1 neu geschnitten
- Design: Aufträge (Hilfs- und Aufklärungsaufträge, DESIGN 8.2), sofortiger Readiness-Abzug pro zerstörtem Nest
  (ADR 0013), Roadmap-Tickets 1.10 und 5.9–5.16
- Eigene Missionsbasis `Missionbasefiles/coin_liberation.lythium/mission.sqm` (Kopie von Liberations Lythium,
  ADR 0016, Ticket 1.2 / #3); der Build nutzt sie statt des Originals
- Skript für den Sektor-Vorschlag `_tools/coin/sectors/` (Ticket 1.3 / #4): Regeln in `rules.json`, Tausche per `raus`/`rein`,
  Ausgabe `docs/sektorauswahl.md` und `.svg`, Tests mit `node --test`; Ergänzungen von Hand per `dazu`
- Design: ADR 0017 Ressourcen-Wirtschaft (8 Supply Points, Multiplikator x2, jede Sorte garantiert),
  ADR 0016 um von Hand ergänzte Ziele erweitert (29 Ortschaften, 8 Supply Points, 6 Militärposten)
- Ausgedünnte Karte (Ticket 1.3 / #5): `_tools/coin/sectors/write.js` schreibt die Auswahl in die COIN-`mission.sqm`
  (157 Sektor-Marker entfernt, 7 Hauptstädte zu Ortschaften); gemeinsamer Parser `sqm.js`

- Eigener Spielstand und Lobby-Standardwerte (Ticket 1.7/1.8 / #6): Save-Key `COIN_LIBERATION_<WORLD>_SAVEGAME`, eigener Key für gespeicherte
  Lobby-Parameter, Standardwerte `LimitedZeus` aus, `ZeusAddEnemies` an, `VictoryCondition` alle Hauptstädte, `SuppMod` aus,
  `ResourcesMultiplier` x2 (Hooks 4–6); `[COIN]`-Logzeilen mit Save-Key und Lobby-Werten beim Serverstart

- 15 Slots in der COIN-Missionsbasis (Ticket 1.5 / #10): Führungsgruppe (Kommandant, 2 Dolmetscher), Trupp A und B (Truppführer, Sanitäter, EOD,
  2 Schützen), 2 Hubschrauberpiloten; zweiter Squad, Logistik, CAS und UAV entfallen. `COIN_fnc_applyRoleTraits` gibt EOD (ACE-Pionier) und
  Sanitäter (ACE-Sanitäter) ihre Fähigkeiten beim Start und nach jedem Respawn, Schalter `COIN_enableRoleTraits`

### Behoben
- Sektor-Vorschlag: Marker-Parser kam mit mehrzeiligen Arrays (`addons[]=`) aus dem Tritt (Ergebnis bisher zufällig richtig)
- Build brach ab, wenn kein Preset eine Workshop-ID hat (`_tools/gulpfile.ts`)
