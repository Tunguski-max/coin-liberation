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

### Behoben
- Build brach ab, wenn kein Preset eine Workshop-ID hat (`_tools/gulpfile.ts`)
