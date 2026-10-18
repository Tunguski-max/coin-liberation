# ADR 0003: Eigener Modulordner und Präfix `COIN`

**Status:** Akzeptiert (2026-10-18)

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
- Präfix-Check (Phase 0, siehe `docs/kp-liberation-map.md` Abschnitt 9): Weder Liberation noch die
  installierten Versionen von CBA, ACE, RHS, Project OPFOR, CUP Terrains, TFAR, Jbad und Lythium
  verwenden `COIN` als Funktions-Tag oder Variablenpräfix. Bei neuen Mods erneut prüfen.
