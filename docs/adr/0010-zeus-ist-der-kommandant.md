# ADR 0010: Zeus ist der Kommandant, ohne Einschränkungen

**Status:** Akzeptiert (2026-10-18)

## Kontext
Liberation gibt Zeus dem Slot „Platoon Leader (Commander)“ (`commandant`). Die Lobby-Parameter
`LimitedZeus` (Standard an: kein Platzieren, Bearbeiten, Zerstören) und `ZeusAddEnemies` (Standard aus)
passen nicht zu Säule 5 „Zeus bleibt Herr im Haus“.

## Entscheidung
- Der Kommandant-Slot bleibt Zeus. Es gibt keinen eigenen Spielleiter-Slot.
- In `ui/mission_params.hpp` werden die Standardwerte geändert: `LimitedZeus` aus, `ZeusAddEnemies` an
  (Hook). In der Lobby bleiben beide änderbar.

## Begründung
- Kein Umbau der `mission.sqm` und kein Risiko mit Liberations Client-Init für einen reinen Zeus-Slot.
- Standardwerte statt Erzwingen: richtig voreingestellt, für Tests trotzdem umstellbar.

## Folgen
- Zeus spielt mit und führt zugleich.
- Liberations `zeus_synchro.sqf` fügt Zivilisten und Objekte nie hinzu und entfernt per `attachTo`
  befestigte Objekte. `COIN_fnc_addToCurators` muss das für COIN-Inhalte abdecken.
