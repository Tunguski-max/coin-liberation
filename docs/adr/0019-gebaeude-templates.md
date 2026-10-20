# ADR 0019: Gebäude-Nester nach Templates

**Status:** Akzeptiert (2026-10-20)

## Kontext
- Ein Gebäude-Nest bestand bisher aus einem Kernobjekt und 2–4 Requisiten, die der Code auf Gebäudepositionen und
  freie Stellen im Haus verteilt (#30, #44). Gebäudepositionen sind für Soldaten gedacht und liegen bei manchen Häusern
  im Hof oder auf freien Flächen.
- Test am 2026-10-20 (#44):
  - Bei `Land_jbad_terrace` standen die Objekte draußen zwischen den Gebäuden.
  - In `Land_jbad_House3_dam` stand alles im Haus, aber wahllos.
  - Das Fahrzeug der VBIED-Garage fand in `Land_CarService_F` keinen Platz und stand auf der Straße.
- Ein Algorithmus findet freie Stellen, weiß aber nicht, was in einem Haus sinnvoll ist, zum Beispiel wo die Einfahrt
  ist. Mehr Regeln machen das besser, aber nicht gut.

## Entscheidung
- **Templates pro Hausklasse und Nest-Typ:** Niklas richtet ein Nest in Eden in einem echten Lythium-Haus ein.
  Ein Export-Befehl speichert jedes Objekt mit Klasse, Position und Richtung **relativ zum Hausmodell**.
  Dazu gehören das Kernobjekt (genau eines), die Requisiten und bei der VBIED-Garage das Fahrzeug.
  Beim Spawn wird das Template in die Lage und Ausrichtung des jeweiligen Hauses umgerechnet, die Anordnung bleibt
  also in jedem Haus der Klasse gleich.
- **Höchstens 3 Hausklassen pro Nest-Typ**, nur Klassen, die laut Katalog mehrfach an Lythiums Ortsrändern stehen.
  Vorschlag vom 2026-10-20:

  | Nest-Typ | Hausklassen |
  |---|---|
  | VBIED-Garage | `Land_i_Shed_Ind_F`, `Land_CarService_F`, `Land_Jbad_Ind_Garage01` |
  | IED-Werkstatt | `Land_jbad_House_8_old`, `Land_jbad_House_7_old`, `Land_jbad_House_c_5_v2` |
  | Waffenlager | `Land_jbad_House_3_old`, `land_ffaa_casa_af_7`, `Land_jbad_House_1` |
  | Kommandoposten | `Land_jbad_House6`, `Land_jbad_House7`, `Land_jbad_House3` |
  | Rekrutierungsstelle | `Land_jbad_House8`, `Land_jbad_terrace`, `Land_jbad_House_c_11` |

- **Hausauswahl:** Ein Gebäude-Nest kommt nur in ein Haus, für dessen Klasse es ein Template des Typs gibt. Die
  Ortsrand-Regeln (ADR 0018) und die Verteilung bleiben. Klassenlisten und Mindestflächen aus #29 gelten nur noch,
  solange ein Typ noch kein Template hat.
- **Zufall:** Welches Haus, entscheidet die Verteilung. Gibt es für eine Hausklasse und einen Typ mehrere Templates,
  wählt der Seed eines aus. Ein Nest sieht dann bei jedem Besuch gleich aus, gleiche Häuser an verschiedenen Orten
  können sich unterscheiden.
- **Wachen bleiben dynamisch** (Gebäudepositionen, Patrouille wie in #30), sie stehen nicht im Template.
- **Ersatz:** Ein Nest, dessen Hausklasse kein Template für den Typ hat (z. B. aus einem älteren Spielstand),
  wird weiter mit der freien Platzierung aus #44 eingerichtet.
- Die Bodensuche aus #44 bleibt als Sicherheitsnetz: Jedes Objekt wird auf den Boden unter seiner Template-Stelle
  gesetzt, falls Häuser derselben Klasse leicht unterschiedlich im Gelände stehen.
- Templates stehen in einer eigenen Datei `Missionframework/coin/coin_templates.sqf`, im selben Format wie später
  die Gelände-Templates (#31, #32).

## Begründung
- Niklas sieht in Eden sofort, was sinnvoll ist. Ein einmal gebautes Template gilt für jedes Haus der Klasse,
  bei bis zu 15 Templates ist der Aufwand überschaubar.
- Relativ zum Hausmodell: Häuser derselben Klasse sind auf der Karte unterschiedlich gedreht. Die Anordnung muss
  der Orientierung des Hauses folgen.
- Wenige, häufige Klassen sorgen dafür, dass jedes Template oft zum Einsatz kommt und genug Häuser für die
  Verteilung da sind.
- Die Wachen haben sich im Test mit Gebäudepositionen und Patrouille bewährt.

## Verworfene Alternativen
- **Freie Platzierung verfeinern** (nur Hauptgebäude, an Wänden ausrichten usw.): ohne Wissen über das Haus bleibt das
  Ergebnis wahllos.
- **Templates nur für die VBIED-Garage:** löst das Fahrzeug, aber nicht das wahllose Platzieren bei den anderen vier Typen.
- **Ein Template pro Hausklasse für alle Typen** mit anderen Objekten je Typ: weniger Arbeit, aber IED-Werkstatt und
  Rekrutierungsstelle wären gleich angeordnet.
- **Wachenplätze im Template:** mehr Kontrolle, aber unnötig, die dynamischen Wachen funktionieren.

## Folgen
- Neue Kampagnen haben Gebäude-Nester nur in den Template-Klassen, laufende behalten ihre Häuser.
- Niklas baut die Templates in einem eigenen Eden-Szenario auf Lythium (#32). Für den ersten Test reicht eines.
- Ändert sich ein Template, sieht jedes Nest dieser Hausklasse beim nächsten Spawn anders aus. Das ist erlaubt,
  gespeichert werden nur Haus, Seed und Zustand (ADR 0018).
- Ergänzt am 2026-10-20: Minen im Template spawnen **scharf** (Rolle `mine`, `createMine`), Spieler können sie mit
  ACE entschärfen, ein Schuss kann sie auslösen. Liberation speichert jede Mine nahe einer FOB mit; eine FOB näher als
  etwa 150 m an so einem Nest verdoppelt die Minen nach einem Neustart (bekannte Einschränkung).
- Zivile Fahrzeuge in Templates dürfen aus CUP Vehicles kommen (seit 2026-10-20 erlaubte Abhängigkeit, CLAUDE.md).
