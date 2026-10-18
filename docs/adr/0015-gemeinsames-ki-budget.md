# ADR 0015: Gemeinsames Budget für Gegner-KI und Zivilisten

**Status:** Akzeptiert (2026-10-18)

## Kontext
Liberation zählt für seine Obergrenzen alle OPFOR-Einheiten (`KPLIB_fnc_getOpforCap`), also auch
unsere Nest-Wachen und Camp-Kämpfer. Seine Grenzen (Sektoren 180, Battlegroups 150, Patrouillen 150)
liegen weit über unserem Zielwert von etwa 80 aktiven Gegnern. Ohne Headless Client zählt die Gesamtlast.

## Entscheidung
- Pro Kategorie (Gegner-KI, Zivilisten) gibt es **einen Gesamtwert** in `coin_config.sqf`.
- COIN spawnt nur, solange die Gesamtzahl darunter liegt.
- Unser Init leitet Liberations Grenzen (`GRLIB_sector_cap`, `GRLIB_battlegroup_cap`, `GRLIB_patrol_cap`)
  daraus ab. Kein Hook, weil es globale Variablen sind.

## Verworfene Alternativen
- Getrennte Grenzen: bis zu 180 + 80 Gegner gleichzeitig möglich.
- COIN-Grenze zählt alle, Liberation unverändert: Während Sektorkämpfen würden Nester und Camps nie spawnen.

## Folgen
- Startwerte kommen aus den Testabenden (Phase 7).
