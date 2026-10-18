# ADR 0003: Eigener Modulordner und Präfix `COIN`

**Status:** Vorgeschlagen

## Kontext
Unser Code könnte entweder direkt in die Liberation-Dateien geschrieben werden oder in einem
eigenen Bereich liegen, der an wenigen Stellen eingehängt ist.

## Entscheidung
- Eigener Code liegt in `Missionframework/coin/`.
- Funktionen heißen `COIN_fnc_*`, globale Variablen `COIN_*`.
- Liberation-Dateien werden nur an markierten Einstiegspunkten (Hooks) verändert, gelistet in `docs/hooks.md`.

## Begründung
- Upstream-Updates von Liberation bleiben mergebar.
- Klar sichtbar, was von uns kommt und was von Liberation.
- Features lassen sich einzeln abschalten und testen.

## Alternativen
- Direkt in Liberation-Code schreiben: schneller am Anfang, später schwer wartbar.
- Separater Mod (Addon) statt Missionscode: sauberer, aber alle Spieler müssten einen weiteren Mod laden. Für eine private Gruppe unnötiger Aufwand.

## Folgen
- Etwas mehr Aufwand für saubere Schnittstellen.
- Präfix `COIN` muss auf Kollisionen mit geladenen Mods geprüft werden (Phase 0).
