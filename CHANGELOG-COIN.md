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

### Behoben
- Build brach ab, wenn kein Preset eine Workshop-ID hat (`_tools/gulpfile.ts`)
