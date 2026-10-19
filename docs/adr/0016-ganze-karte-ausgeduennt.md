# ADR 0016: Die ganze Karte ist Einsatzgebiet, ausgedünnt

**Status:** Akzeptiert (2026-10-18)

## Kontext
Ursprünglich war ein kleiner Kartenausschnitt (5–8 km um die Hauptstadt) geplant, alles außerhalb inaktiv
(Säule 4 „Klein und dicht“). Ein 5,5-km-Kreis um Kalae Noowi wirkte zu klein: Die Miliz soll sich in der
ganzen Region eingegraben haben, und nicht alles soll sich um die Hauptstadt drehen.

## Entscheidung
- **Hauptstadt:** Kalae Noowi (Norden von Lythium).
- **Einsatzgebiet ist die ganze Karte.** Es gibt keinen Kartenausschnitt, keine Grenze und keine Randzone.
- **Ausgedünnt:** 25 Ortschaften (davon 7 herabgestufte Hauptstädte), 5 Supply Points, 4 Militärposten.
  Mindestabstand 2,5 km zwischen Ortschaften, nichts im Umkreis von 1 km um die Hauptstadt. Arobster und
  alle Funktürme entfallen. Die Spawnpunkte der Miliz bleiben.
- **Von Hand ergänzt** (2026-10-19, ohne Abstandsregeln, die Regel-Auswahl bleibt unverändert):
  - Kalae Barracks (E) als Militärposten direkt an der Hauptstadt: Eine Gruppe würde sich dieser Anlage
    ohnehin bemächtigen. Ein starker Gegenangriff dort ist gewollt. Kalae Airport und Kalae Field Hospital bleiben aus.
  - Mitte verdichtet: Ortschaften Tonkuf, Kandar, Ramir, Kalae Village (N); Militärposten Mountain Patrol Camp.
  - Supply Points Kandar Factory, Zarath Windpark, Kalae Factory (ADR 0017).
  - Damit gesamt: **29 Ortschaften, 8 Supply Points, 6 Militärposten.**
- Die **Startbasis** bleibt am Liberation-Startpunkt im Südwesten. Die erste FOB wird per Hubschrauber
  frei im Gebiet gesetzt.
- **Umsetzung:** eigene Kopie `Missionbasefiles/coin_liberation.lythium/mission.sqm`. Ein Skript filtert
  die Liberation-Marker nach diesen Regeln; Niklas prüft den Vorschlag und tauscht einzelne Ziele.
  Slots werden im Eden-Editor gesetzt.
- Säule 4 lautet neu: „Weit, aber gezielt.“

## Begründung
- Die Dichte entsteht durch die Zahl der Ziele, nicht durch die Fläche. Zwischen den Zielen sorgt das
  Netzwerk der Miliz (Nester, Camps, IEDs auf Straßen) für die Bedrohung.
- Keine Grenzlogik nötig: einfacher als ein Ausschnitt.
- Die Kopie der `mission.sqm` hält Liberations Original als Referenz unverändert.

## Verworfene Alternativen
- Kreis mit 5,5 km: zu klein, alles konzentriert sich auf die Hauptstadt.
- Kreis mit 10–12 km: Grenzlogik bleibt nötig, Startbasis läge außerhalb.

## Folgen
- Längere Wege: Hubschrauber und frei platzierbare FOBs werden wichtig (ADR 0007).
- Nester bekommen größere Einflussradien (1500–2500 m) und halten Abstand zur Startbasis (4 km).
- Upstream-Fixes an Liberations Lythium-`mission.sqm` müssen von Hand übernommen werden.
- Eine spätere Erweiterung um eine zweite Hauptstadt ist möglich (Liberations Siegbedingung
  „alle Hauptstädte“), aber nicht geplant.
