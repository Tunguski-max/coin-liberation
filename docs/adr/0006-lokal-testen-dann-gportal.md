# ADR 0006: Erst lokal testen, dann auf G-Portal veröffentlichen

**Status:** Akzeptiert (2026-10-17)

## Kontext
Der G-Portal-Dedicated-Server steht noch nicht. Claude Code kann Arma nicht selbst ausführen.

## Entscheidung
- Entwicklung und Tests laufen **lokal** (Arma 3 als Host, siehe `docs/TESTING.md`).
- Veröffentlicht wird erst, wenn eine Roadmap-Phase lokal ihre Definition of Done erfüllt.
- Code wird trotzdem von Anfang an **dedicated-server-tauglich** geschrieben.

## Begründung
- Schnellere Iteration ohne Upload-Zyklus.
- Lokaler Host deckt Server- und Client-Code gleichzeitig ab. Fehler, die nur auf
  Dedicated auftreten (Lokalität), fallen allerdings erst in Phase 7 auf.

## Folgen
- Optional früher: lokaler Dedicated Server (`arma3server_x64.exe`) zum Gegentesten, sobald es Lokalitätsprobleme gibt.
- Deployment-Ablauf steht in `docs/DEPLOY.md`.
