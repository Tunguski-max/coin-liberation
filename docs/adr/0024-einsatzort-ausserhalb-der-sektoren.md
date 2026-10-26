# ADR 0024: Einsatzort außerhalb der Sektoren: Arzt-Einsatz und Reparatur spielen im Nachbardorf, die Gefahr hängt am Nest-Netzwerk

**Status:** Akzeptiert (2026-10-26)

## Kontext
- Arzt-Einsatz (5.11) und Reparatur (5.12) sind risikolos und liefern billig Ruf (+4 bis +7). Eine Gefahr am Einsatzort soll
  sie schwieriger machen (Ticket #130). „Hilfsgüter liefern“ bleibt unverändert, dort ist der Transport die Schwierigkeit.
- Die vorhandenen Bedrohungen lassen sich nicht an einem beliebigen Ort aufrufen (Recherche am 2026-10-26): `createIED`
  sucht selbst eine Straße im Radius einer Werkstatt und kennt nur Nest-Listen, `spawnAmbush` braucht ein Camp, Camps liegen
  nie näher als 1000 m an einer befreiten Ortschaft (`COIN_campExclusionRadius`). Nur der Attentäter ist frei aufrufbar.
- Liberation und COIN benutzen bisher keine Karten-Orte (`nearestLocations`). Außerhalb der Sektoren gibt es keine Zivilisten
  und keine Bevölkerung. Lythium hat 45 Dörfer, 7 `NameLocal` und 3 Städte als beschriftete Orte, 30 davon mehr als 500 m,
  21 mehr als 1000 m von jedem der 44 Sektoren entfernt; einige Einträge sind Camps und FOBs (z. B. `GreenCampBase`).
- Ein Hinterhalt, der plötzlich in der befreiten Ortschaft auftaucht, ist unglaubwürdig (Niklas, 2026-10-26).

## Entscheidung
- **Einsatzort außerhalb der Sektoren:** Arzt-Einsatz und Reparatur spielen in einem Dorf, das kein Liberation-Sektor ist:
  das nächste Karten-Dorf (`NameVillage` oder `NameLocal`) mit mindestens 6 Häusern, mindestens 500 m von jedem Sektor und
  1200 m von jedem nicht befreiten Sektor, höchstens 3000 m von der Ortschaft des Ältesten, gerade nicht Einsatzort eines
  anderen Auftrags. Ohne Dorf ist der Eintrag grau. Ein Schalter (`COIN_enableAidSites`) stellt den alten Zustand her.
- **Gefahr: Hinterhalt am Einsatzort**, nicht IED und nicht Attentäter. Eine neue Spawn-Logik ohne Camp (4–6 Kämpfer in Deckung
  100–250 m vor dem Dorf auf der Zufahrtsseite der befreiten Ortschaft, 2–3 versteckte Kämpfer in Häusern), mit den Werten
  der Camp-Hinterhalte als Vorbild.
- **Kopplung an das Netzwerk:** Die Gefahr entsteht nur, wenn ein aktives Nest (jeder Typ) den Einsatzort im Einflussradius
  hat, dann mit 75 %. Wer Nester zerstört, macht die Aufträge dort sicher.
- **Budget und Spawn:** Camp-Budget (ADR 0015), ganz oder gar nicht, Spawn bei Spielernähe wie bei Camps.
- **Warnung und Auftrag:** Nur ein vager Satz des Ältesten, Belohnung, Zeitlimit und Abzug beim Scheitern bleiben.

## Begründung
- Das Dorf außerhalb der Sektoren macht den Hinterhalt glaubhaft und gibt der Gruppe ein Ziel jenseits ihrer Ortschaft.
- Ein Hinterhalt ist der einfachste Baustein für beide Aufträge: ein Verhalten, ein Test. Eine IED-Falle am Gerät bräuchte
  eine neue, nest-ungebundene Umsetzung mit eigenem Entschärfen, Ruf und Aufräumen.
- Die Kopplung an Nester gibt den Aufträgen einen Bezug zum Netzwerk und folgt dem Grundsatz aus ADR 0022 „alle
  Bedrohungen kommen aus dem Netzwerk“. Eine Kopplung an Camps wäre sinnlos (Sperrzone von 1000 m).
- Die Schwierigkeit muss aus Risiko kommen, nicht aus Fahrzeit: Mit Fahrzeug sind 100 m mehr nur 10 bis 20 Sekunden.

## Verworfene Alternativen
- **Aufträge und Gefahr in der befreiten Ortschaft:** einfacher, aber ein Hinterhalt dort ist unglaubwürdig.
- **IED-Falle am Patienten oder Gerät:** thematisch gut, aber ein zweiter, größerer Neubau (Spawn, Entschärfen, Ruf, Aufräumen).
- **Attentäter:** frei aufrufbar, aber laut ADR 0022 an eine Werkstatt im Radius gebunden und nicht für beide Aufträge passend.
- **Mehr Distanz und abnehmender Ertrag nach Ruf-Band:** bringt kein Risiko beziehungsweise verändert die Belohnung, beides
  nicht gewollt (Niklas, 2026-10-26). Die Werte der drei Aufträge bleiben.

## Folgen
- Neue Tickets: #132 (Einsatzort wählen), #133 (Arzt-Einsatz und Reparatur im Dorf), #134 (Hinterhalt am Einsatzort).
  Roadmap 5.20 bis 5.22.
- Der Mindestabstand von 50 m zum Ältesten aus #110 entfällt, Patienten und Geräte stehen um die Dorfmitte des Einsatzorts.
- Die Auswahl hängt an den beschrifteten Karten-Orten; unbeschriftete Siedlungen erscheinen nicht. Die Ausschlussliste für Camps
  und FOBs (`COIN_siteExcludedLocations`) wird im Test von #132 vervollständigt.
- Ein gefangener Kämpfer des Hinterhalts nennt das nächste aktive Nest im Radius, soweit die Verhör-Logik das ohne Umbau
  hergibt (klärt #134).
