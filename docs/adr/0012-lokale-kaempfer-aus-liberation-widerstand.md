# ADR 0012: Lokale Kämpfer bauen auf Liberations Widerstand auf

**Status:** Akzeptiert (2026-10-18)

## Kontext
Liberation hat eine Widerstandsfraktion (Seite RESISTANCE) mit Ausrüstungsstufen
(`KPLIB_fnc_spawnGuerillaGroup`). Ihre Haltung hängt global am Ruf: ab +25 auf unserer Seite,
zwischen −25 und +25 neutral, unter −25 auf Seiten der Miliz. Liberation schickt außerdem spontan
Guerilla-Gruppen in Sektorkämpfe (`sector_guerilla.sqf`, 35 % bei |Ruf| ≥ 25).

## Entscheidung
- Lokale Kämpfer (Gefälligkeiten, DESIGN 8.1) werden als Liberation-Widerstand gespawnt.
- Fällt der Ruf unter 25, ziehen aktive lokale Kämpfer ab.
- Liberations spontane Guerilla-Einsätze bleiben: Hilfe bei gutem Ruf, Gegner bei schlechtem.

## Verworfene Alternative
- Eigene Einheiten auf BLUFOR-Seite: unabhängig vom Ruf, aber Liberation würde sie in FOB-Nähe als
  eigene KI-Gruppen speichern und nach dem Neustart wieder spawnen. Das bräuchte einen Filter-Hook im Save.

## Folgen
- Der Abzug bei Vertrauensverlust passt thematisch und tritt selten ein (von +50 unter +25 fallen
  bedeutet etwa fünf getötete Zivilisten).
- Lokale Kämpfer brauchen eine erkennbare Kleidung, siehe ADR 0014.
