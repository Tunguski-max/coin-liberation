# ADR 0015: Gemeinsames Budget für Gegner-KI und Zivilisten

**Status:** Akzeptiert (2026-10-18, geändert am 2026-10-19)

## Kontext
Liberation zählt für seine Obergrenzen alle OPFOR-Einheiten (`KPLIB_fnc_getOpforCap`, `countSide allUnits`), also auch
unsere Nest-Wachen und Camp-Kämpfer. Seine Grenzen (Sektoren 180, Battlegroups 150, Patrouillen 150, jeweils mal
Lobby-Parameter `Unitcap`) liegen weit über unserem Zielwert. Ohne Headless Client zählt die Gesamtlast.

Liberation prüft seine Grenzen **vor** dem Spawn: Ein Sektor, der startet, spawnt seine ganze Besatzung (Ortschaft etwa
30–60, Militärposten 45–75, Hauptstadt etwa 85 Gegner). Die Gesamtzahl kann also über jeder Grenze liegen.

## Entscheidung
- **Gegner-KI:** Liberation bekommt für seine drei Grenzen (`GRLIB_sector_cap`, `GRLIB_battlegroup_cap`, `GRLIB_patrol_cap`)
  einen gemeinsamen Wert `COIN_maxEnemyAI` (100) mal Unitcap-Faktor. Die Einheiten der COIN-Schicht kommen **obendrauf**.
- Damit Liberation unsere Einheiten nicht mitrechnet, setzt eine Schleife auf dem Server die drei Grenzen regelmäßig auf
  `COIN_maxEnemyAI × Unitcap-Faktor + aktuelle Zahl der COIN-Einheiten` und verteilt sie an die Clients
  (für Liberations Overlay-Hinweis „Obergrenze erreicht“). Kein Hook, weil es globale Variablen sind.
- **Nester spawnen immer vollständig**, ohne Obergrenze.
- **Camps** spawnen ganz oder gar nicht, solange die COIN-Einheiten zusammen unter `COIN_maxCampAI` (20) liegen.
  Ist kein Platz, entsteht das Camp, sobald wieder Platz ist.
- **Zivilisten:** gemeinsamer Wert in `coin_config.sqf`, geregelt mit dem eigenen Zivilisten-Spawner in Phase 3.

Geändert am 2026-10-19 (Phase 2, Grilling): vorher ein Gesamtwert, unter dem auch COIN bleiben musste. Weil Liberation
über seine Grenzen schießt, hätte COIN in solchen Momenten nichts spawnen dürfen. Ein Nest ohne Wachen soll es nicht geben.

## Begründung
- Liberations Sektoren, Gegenangriffe und Patrouillen werden deutlich gedämpft (100 statt 150–180), ohne in seine Logik einzugreifen.
- Nester sind selten mehr als 1–2 gleichzeitig in Spielernähe. Ihre Wachen sind planbar, eine Grenze würde nur unbewachte Nester erzeugen.
- Camps sind entbehrlich: Ein Camp, das später entsteht, merkt kein Spieler, weil er es noch nicht kennt.

## Verworfene Alternativen
- Getrennte Grenzen ohne Absenkung: bis zu 180 + COIN gleichzeitig möglich.
- COIN-Grenze zählt alle, Liberation unverändert: Während Sektorkämpfen würden Nester und Camps nie spawnen.
- Ein Gesamtwert für beide, Liberation bekommt Gesamt minus Reserve: Liberations Überschießen nimmt COIN die Reserve, Nester wären unbewacht.
- Hook in `KPLIB_fnc_getOpforCap`, der COIN-Einheiten abzieht: exakt, aber Eingriff in eine Funktion, die Liberation an vielen Stellen
  und auch auf Clients aufruft.

## Folgen
- Liberation aktiviert weniger Sektoren gleichzeitig, sein Aktivierungsradius (1000 m) schrumpft schon ab 50 Gegnern
  (bis 750 m ab 100), zufällige Gegenangriffe und Patrouillen pausieren bei großen Kämpfen.
- Gleichzeitig können etwa 100 Gegner von Liberation, sein Überschießen und die COIN-Einheiten auf der Karte sein.
- Startwerte kommen aus den Testabenden (Phase 7).
