# Design: COIN Liberation (Arbeitstitel)

> Status: **Entwurf v0.7** – Grundlage für die Umsetzung mit Claude Code.
> v0.2: Entscheidungen aus Phase 0 eingearbeitet (ADR 0008–0015, `docs/kp-liberation-map.md`).
> v0.3: Spielfeld und Ausrüstung für Phase 1 festgelegt (ADR 0007, 0016), Abgleich mit Hearts and Minds.
> v0.3.1: Sektorauswahl von Hand ergänzt (ADR 0016), Ressourcen-Wirtschaft (ADR 0017).
> v0.4: Miliz-Netzwerk für Phase 2 festgelegt (Nester, Camps, Datenmodell, KI-Budget, ADR 0015 geändert).
> v0.4.1: Verteilung der Nester nach dem Prinzip „bester Kandidat“ mit Randabstand (Test 2026-10-20).
> v0.4.2: Mindestens 2 Nester pro Typ, Häuser passend zum Typ (Fläche, Gebäudepositionen, Klassenliste der VBIED-Garage).
> v0.4.3: Gebäude-Nester nach Templates pro Hausklasse und Nest-Typ (ADR 0019).
> v0.4.4: Gelände-Nester nach Templates mit Richtungspfeil, Hangneigung und Wachenring (ADR 0020).
> v0.4.5: Meldung an alle Spieler bei zerstörtem Nest und ausgehobenem Camp (Ticket 2.14).
> v0.5: Dolmetscher und Intel für Phase 3 festgelegt (Gespräch, Abklingzeit, Triangulation, Lügen, Verhör, Dokumente, ADR 0021).
> v0.5.1: Dokumente als ACE Intel Items verworfen (E13).
> v0.6: Asymmetrische Bedrohungen für Phase 4 festgelegt (Budget, IED-Varianten, VBIED, Attentäter, Hinterhalt, Warnung vor IED, ADR 0022).
> v0.6.1: IED löst zu Fuß erst ab zwei Soldaten in etwa 6 m aus, sonst wäre Entschärfen nicht möglich (Ticket 4.1a, Test am 2026-10-22).
> v0.6.2: Attentäter wirkt im ganzen Radius der Werkstatt (keine Ortschaft nötig) und kontert ACEs „Get Down!“/„Go Away!“ nicht (Ticket 4.4, Test am 2026-10-23, Niklas).
> v0.6.3: Hinterhalt: Platz neben der nächsten Straße, Kämpfer halten Feuer bis 150 m, Ersatzcamp nach Umzug bekommt garantiert einen Hinterhalt (Ticket 4.5, Test am 2026-10-23, Niklas).
> v0.7: Ruf und Konsequenzen für Phase 5 festgelegt (Ruf-Werte, Stimmung, Ältester mit Dialog, Hilfs- und Zugriffsaufträge, Nebenmissionen beim Ältesten, Verstärkung per Funk, Ablenkungsangriff gestrichen, ADR 0023).
> Offene Entscheidungen stehen gesammelt in [Abschnitt 12](#12-offene-entscheidungen).
> Begriffe sind in [`CONTEXT.md`](../CONTEXT.md) definiert.

---

## 1. Vision in einem Satz

Ein persistenter Coop-Modus für **5–10 Spieler** auf **Lythium**: Eine Taliban-ähnliche
Miliz hat Kalae Noowi zu ihrer Hauptstadt gemacht und sich mit einem Netzwerk aus
Verstecken, IED-Werkstätten und Waffenlagern in der ganzen Region eingegraben. Die Spieler sind die
Armee, die dieses Netzwerk mit Hilfe der Bevölkerung **aufspürt und zerschlägt**, bevor sie die Hauptstadt stürmt.

**Basis:** KP Liberation (Logistik, FOBs, Ressourcen, Sektoren, Speichern).
**Zusatzschicht, inspiriert von Hearts and Minds (nur Ideen, ADR 0002):** Dolmetscher, Intel von Zivilisten, Ruf,
IEDs, VBIEDs, Selbstmordattentäter, Hinterhalte.

## 2. Design-Säulen

1. **Aufklärung vor Feuerkraft.** Wer nur stürmt, kämpft gegen einen voll versorgten Gegner.
   Wer vorher Intel sammelt und Nester ausschaltet, kämpft gegen einen geschwächten.
2. **Die Bevölkerung ist das Schlachtfeld.** Ruf entscheidet, ob Zivilisten reden, lügen
   oder schweigen. Kollateralschäden haben spürbare Folgen.
3. **Gefahr ist lesbar.** IEDs, VBIEDs und Attentäter zeigen Hinweise, auf die aufmerksame
   Spieler reagieren können. Kein Tod ohne Chance.
4. **Weit, aber gezielt.** Die ganze Karte ist Einsatzgebiet, aber mit wenigen, verteilten Zielen.
   Die Bedrohung zwischen den Zielen kommt aus dem Netzwerk der Miliz, nicht aus der Zahl der Sektoren.
5. **Zeus bleibt Herr im Haus.** Alles, was die Mission erzeugt, kann Zeus sehen, ändern und löschen.

## 3. Spielfeld

Einsatzgebiet ist **ganz Lythium**, stark ausgedünnt (ADR 0016).

| Element | Anzahl | Herkunft | Zweck |
|---|---|---|---|
| Hauptstadt | 1: **Kalae Noowi** (Norden) | Liberation-Sektor (Typ „Hauptstadt“) | Finales Ziel, Sitz der Miliz |
| Ortschaften | 29: 25 per Regel (davon 7 herabgestufte Hauptstädte), 4 von Hand ergänzt | Liberation-Sektoren (Städte/Dörfer) | Einnehmen, halten, Bevölkerung gewinnen |
| Supply Points | 8: 5 per Regel, 3 von Hand ergänzt | Liberation-Fabriken/Ressourcen-Sektoren | Ressourcen-Produktion (ADR 0017) |
| Militärposten | 6: 4 per Regel, 2 von Hand ergänzt (u. a. Kalae Barracks (E) an der Hauptstadt) | Liberation-Militärsektoren | Optionale harte Ziele, schalten je ein Elite-Fahrzeug frei |
| Miliz-Nester | 11 | **neu** (siehe Abschnitt 5) | Verdeckt, nur über Intel auffindbar |
| Miliz-Camps | bis 10 gleichzeitig | **neu** (siehe Abschnitt 5.1) | Zufällig im Gelände, Spur zu den Nestern |
| Startbasis | 1 | Liberation-Startpunkt im Südwesten | Ausgangspunkt, etwa 19 km von der Hauptstadt |

- Auswahl der Ziele aus den vorhandenen Liberation-Markern: Mindestabstand 2,5 km zwischen Ortschaften,
  im Umkreis von 1 km um die Hauptstadt liegt kein weiteres Ziel. Die übrigen Hauptstädte werden zu
  Ortschaften herabgestuft (Arobster entfällt). Einzelne Ziele ergänzt Niklas von Hand ohne Abstandsregeln,
  vor allem in der Mitte und Kalae Barracks (E) direkt an der Hauptstadt (ADR 0016). Die Auswahl steht in
  `docs/sektorauswahl.md`.
- **Ressourcen** (ADR 0017): Lobby-Standard Ressourcen-Multiplikator x2, die Sorten (Supplies, Munition,
  Treibstoff) sind bei Kampagnenstart unter den Supply Points ausgeglichen (bei 8 immer 3-3-2). Preise unverändert.
- **Keine Funktürme** (ADR 0013): Sie würden Nester und Camps auf der Karte verraten.
- Die Spawnpunkte der Miliz (`opfor_point`, `opfor_airspawn`) bleiben.
- Die erste FOB bringen die Spieler per Hubschrauber (FOB-Container an der Chinook) an eine frei gewählte Stelle.
- Siegbedingung: Hauptstadt eingenommen (nicht: alle Sektoren). Mit genau einem Hauptstadt-Sektor
  erfüllt Liberations Lobby-Parameter „Siegbedingung: alle Hauptstädte“ das ohne eigenen Code.

## 4. Spielschleife

```
Patrouille / Ortschaft besuchen
        │
        ▼
Dolmetscher befragt Zivilisten ──► Intel (Kreis auf der Karte, Größe je nach Ruf)
        │                                   │
        │                                   ▼
        │                       Weitere Intel verkleinert den Kreis
        │                                   │
        ▼                                   ▼
Ruf steigt/sinkt  ◄──────────────  Nest finden und zerstören
        │                                   │
        │                                   ▼
        │                     Netzwerk schwächer: weniger IEDs, schwächere
        │                     Gegenangriffe, kleinere Garnisonen
        ▼                                   │
Ortschaft einnehmen ◄───────────────────────┘
        │
        ▼
FOB bauen, Logistik ausweiten (Liberation)
        │
        ▼
Endphase: Sturm auf die Hauptstadt (Stärke hängt vom Restnetzwerk ab)
```

## 5. System A: Miliz-Netzwerk (neu)

Das Herzstück. Die „OPFOR-FOBs“ aus deiner Idee sind hier **Nester**: verdeckte Knoten,
die jeweils einen **Einflussradius** haben und dort einen konkreten Effekt erzeugen.

| Nest-Typ | Effekt im Einflussradius | Wenn zerstört |
|---|---|---|
| Kommandoposten | Steuert Patrouillen, Gegenangriffe und Verstärkung | Keine Gegenangriffe und keine Verstärkung mehr aus dieser Region, weniger Patrouillen |
| IED-Werkstatt | Erzeugt IED-Budget | IED-Obergrenze im Radius sinkt deutlich |
| Waffenlager | Verstärkt Garnisonen und Ausrüstung, bewacht 1–2 Altfahrzeuge | Garnisonen kleiner, weniger schwere Waffen, seine Altfahrzeuge verschwinden |
| VBIED-Garage | Ermöglicht VBIED-Ereignisse | Keine VBIEDs mehr im Radius |
| Rekrutierungsstelle | Füllt Verluste der Miliz wieder auf | Miliz regeneriert langsamer |

**Regeln**
- 11 Nester zu Kampagnenbeginn, von jedem Typ mindestens 2: Reicht die Verteilung aus `coin_config.sqf` dafür nicht,
  gibt der häufigste Typ ein Nest ab (bei Gleichstand gelost), die Gesamtzahl bleibt (Test 2026-10-20, wie bei den
  Ressourcen). Typen mit den wenigsten passenden Häusern werden zuerst platziert, damit sie nicht immer im selben
  abgelegenen Haus landen.
- Gleichmäßig über die Karte verteilt: mindestens 2,5 km Abstand untereinander,
  mindestens 4 km von der Startbasis, keines im Umkreis von 1 km um die Hauptstadt. Findet die Verteilung keinen
  Platz, wird der Abstand schrittweise verringert (mit Logzeile).
  Gleichmäßig heißt: Für jedes Nest werden mehrere zulässige Stellen gezogen (Startwert 30), genommen wird die mit dem
  größten Abstand zu den bisherigen Nestern („bester Kandidat“). Mindestens 1 km Abstand zum Kartenrand.
  Grund (Test 2026-10-20): Rein zufällige Stellen bilden Haufen und lassen große Teile der Karte leer; ein starres
  Raster wäre für Spieler als Muster erkennbar.
- Einflussradius 1500–2500 m je nach Typ (Werte in `coin_config.sqf`).
- Nester stehen in Gebäuden in Ortschaften oder als kleine Lager im Gelände. Ob ein Nest ein Gebäude- oder
  ein Gelände-Nest wird, entscheidet ein Anteil pro Typ (Startwerte: Kommandoposten 0,5, IED-Werkstatt 0,7,
  Waffenlager 0,3, VBIED-Garage und Rekrutierungsstelle 1,0; im Schnitt etwa 7–8 Gebäude- und 3–4 Gelände-Nester).
  - **Gebäude-Nest:** nur in Ortschaften (nicht in der Hauptstadt), in einem vorhandenen Haus **am Ortsrand**,
    250–600 m vom Sektormittelpunkt. Grund: Liberation wertet einen Sektor im Radius von 175 m aus. Wachen darin
    würden die Einnahme blockieren und eine befreite Ortschaft als „angegriffen“ gelten lassen.
    Kernobjekt, Requisiten und bei der VBIED-Garage ein ziviles Fahrzeug kommen aus einem **Template pro Hausklasse
    und Nest-Typ** (ADR 0019): von Niklas in Eden eingerichtet, relativ zum Hausmodell gespeichert und beim Spawn an
    Lage und Ausrichtung des Hauses angepasst. Höchstens 3 Hausklassen pro Typ, nur Klassen, die mehrfach an
    Lythiums Ortsrändern stehen. Ein Gebäude-Nest kommt nur in ein Haus mit Template für seinen Typ; gibt es mehrere
    Templates, wählt der Seed. Wachen bleiben dynamisch (Gebäudepositionen und Patrouille).
    Ohne Template (älterer Spielstand, Typ noch ohne Template) gilt die freie Platzierung: Mindestfläche,
    Gebäudepositionen und Klassenliste pro Typ (Messlauf und Auswahl in Zeus, 2026-10-20). Nicht-Häuser wie Stege
    und Flughafengebäude sind ausgeschlossen.
  - **Gelände-Nest:** 2–3 Templates pro Nest-Typ (Zelte, Tarnnetz, Kisten, Kernobjekt), platziert an einer
    ebenen, freien Stelle mit denselben Abständen wie Camps (Abschnitt 5.1). Niklas baut die Templates im Eden-Editor
    und liest sie mit demselben Export-Befehl wie die Gebäude-Templates aus (ADR 0019); für den ersten Test gibt es je
    ein einfaches Template von Claude, das Niklas am 2026-10-21 übernommen hat. Ein Richtungspfeil markiert Mitte und „vorne“, der Seed wählt das Template und
    dreht es um die Nest-Position, jedes Objekt behält seine Höhe über dem Boden und kippt mit dem Hang. Etwa die Hälfte
    der Wachen steht in einem Ring um das Lager, der Rest patrouilliert (ADR 0020).
- Ein Gebäude-Nest bleibt aktiv, wenn die Armee seine Ortschaft einnimmt. Das Nest hängt nicht am Sektor.
- Beim Kampagnenstart entstehen nur Daten, gespeichert im Spielstand. Objekte und Wachen spawnen erst, wenn Spieler
  in der Nähe sind, und werden wieder abgebaut, wenn niemand mehr da ist:
  - Spawn ab 1000 m zum nächsten Spieler, Abbau, wenn 2 Minuten lang kein Spieler innerhalb von 1300 m ist.
  - Drohnen zählen als Spieler, aber wie bei Liberations Sektoren nur unter 500 m über Grund (Test 2026-10-20);
    bemannte Luftfahrzeuge mehr als 100 m über Grund zählen nicht.
  - Ein Nest sieht bei jedem Besuch gleich aus (Template, Ausrichtung und Plätze folgen aus einem gespeicherten Zufallswert).
- **Leichte Bewachung:** bei jedem Spawn vollständig, Verluste werden nicht gemerkt. Etwa die Hälfte sitzt beim
  Kernobjekt, der Rest patrouilliert im Umkreis von etwa 100 m. Ein Nest ruft keine Verstärkung (die kommt mit dem
  Kommandoposten in Phase 6). Nester spawnen immer vollständig, auch wenn viele Gegner auf der Karte sind (ADR 0015).
- Die **Altfahrzeuge eines Waffenlagers** sind besetzt und für Spieler gesperrt (ADR 0007). Sie sind wie die Wachen
  bei jedem Spawn wieder da, bis das Lager zerstört ist.
- Nester sind **nicht** auf der Karte markiert. Nur Intel macht sie sichtbar (siehe System C).
- Die **Netzwerkstärke** ist der Anteil der aktiven Nester an allen Nestern (0 bis 1, alle Typen gleich gewichtet).
  Die Garnison der Hauptstadt skaliert mit der Zahl der Nester:
  `Garnison = Basis × (1 + Faktor × verbleibende Nester)`.
- Ein Nest gilt als zerstört, wenn sein Kernobjekt zerstört ist (z. B. Waffenkiste, Funkgerät) oder das Haus eines
  Gebäude-Nests einstürzt. Kernobjekte sind nur Objekte, die Arma zerstören kann; passende, aber unzerstörbare Objekte
  (z. B. Werkbank) stehen nur als Requisite daneben. Löscht Zeus das Kernobjekt, ist das keine Zerstörung.
- Die Zerstörung wird sofort gespeichert und löst ein Ereignis aus. Daran hängen sich spätere Phasen:
  Ruf (Phase 5), Readiness-Abzug (Phase 6, ADR 0013).
- **Meldung an die Spieler:** Wird ein Nest zerstört, sehen es alle Spieler als Einblendung wie bei einem verlorenen FOB:
  Nest-Typ, keine Position (Entscheidung 2026-10-22). Ticket 2.14.
- *Später/optional:* Bei niedrigem Ruf kann die Miliz in Regionen ohne Spielerpräsenz langsam
  neue Nester aufbauen. Das hält das Netzwerk lebendig.

**Datenmodell (Server, persistent, Eintrag 22 im Liberation-Spielstand, ADR 0005, ADR 0018)**
```
[COIN_saveVersion, [nest, nest, ...]]
nest = [id, type, kind, pos, seed, state]
  id     Nummer
  type   "command" | "iedWorkshop" | "cache" | "vbiedGarage" | "recruitment"
  kind   "building" | "terrain"
  pos    Gebäude-Nest: Position des Hauses; Gelände-Nest: Mittelpunkt des Templates
  seed   Zufallswert für Template, Ausrichtung und Plätze von Kernobjekt und Requisiten
  state  "active" | "destroyed"
```
Einflussradius und Bewachung stehen nicht im Spielstand, sie kommen nach Typ aus `coin_config.sqf`. So wirken
Balancing-Änderungen auch in laufenden Kampagnen. Ab Phase 3 (`COIN_saveVersion` 2, ADR 0021) lautet der Block
`[2, [nest, ...], [intel, ...]]`, ein älterer Stand bekommt beim Laden eine leere Intel-Liste:
```
intel = [id, nestId, center, radius, level, shownType, fakePos]
  nestId     Nest, auf das der Marker zeigt; -1 bei einer Lüge
  center     Mittelpunkt des Kreises (das Nest liegt darin, aber nicht in der Mitte)
  radius     aktueller Radius, schrumpft mit jedem weiteren wahren Treffer
  level      "rumor" | "hint" | "tip"
  shownType  angezeigter Nest-Typ (bei einer Lüge zufällig, beim Gerücht leer)
  fakePos    Ersatzpunkt einer Lüge, sonst leer
```

### 5.1 Camps

Kleine, offene Lager der Miliz im Gelände zwischen den Ortschaften. Sie beleben die Fläche
und sind die zweite Intel-Quelle neben dem Dolmetscher.

| | Nest | Camp |
|---|---|---|
| Lage | Verdeckt, Gebäude oder versteckte Lager | Offen im Gelände, abseits von Ortschaften |
| Finden | Nur über Intel | Auch durch Patrouille, Drohne, nachts am Lagerfeuer |
| Besatzung | Bewachung plus Kernobjekt | 3–6 Kämpfer, eventuell ein Technical |
| Wirkung | Großer Effekt im Radius | Lokal: Ausgangspunkt für Patrouillen und Hinterhalte |
| Speichern | Ja | **Nein** – bei jedem Serverstart neu verteilt |

**Regeln (entschieden)**
- Gebiet: die ganze Karte.
- Platzierung zufällig auf ebenem Gelände mit Deckung, mit Mindestabstand zu Straßen,
  Ortschaften, FOBs und der Startbasis.
- Nicht persistent. Beim Serverstart wird die aktuelle Kapazität (siehe unten) neu verteilt.
- Jedes Camp **gehört zu einem Nest**: dem nächstgelegenen aktiven Nest, das noch Kapazität frei hat.
  Ausgehobene Camps haben keine eigene Intel-Quelle: Die Spur vom Camp zum Nest läuft über das Verhör ihrer Kämpfer.
- Ein Camp ist **ausgehoben**, wenn in seiner Nähe kein Kämpfer des Camps mehr kampffähig ist (tot, gefangen,
  ergeben oder geflohen), die Besatzung des Technicals eingeschlossen.
- KI und Objekte spawnen erst, wenn Spieler in der Nähe sind (gleiche Regeln wie bei Nestern). Ein Camp spawnt ganz
  oder gar nicht, nur wenn danach höchstens 30 COIN-Einheiten leben, Nest-Wachen eingerechnet (ADR 0015). Ist kein
  Platz, entsteht es, sobald wieder Platz ist.
- Der Technical eines Camps ist nicht gesperrt und kann erbeutet werden.
- Camps nutzen dieselbe Template-Mechanik wie Gelände-Nester, mit eigenen 2–3 Camp-Templates (ohne Kernobjekt).
- Wird ein Camp ausgehoben, sehen es **alle** Spieler als Einblendung, ohne Position und ohne Nest (Entscheidung 2026-10-22: eine
  Sitzung dauert Stunden und Spieler begegnen Camps selten; die Spur zum Nest bleibt Intel, Phase 3). Ticket 2.14.

**Wie viele Camps es gibt (Entscheidung E8)**

Die Anzahl hängt von zwei Dingen ab, die beide den Spielfortschritt abbilden:

1. **Kapazität aus den Nestern.** Jedes Nest hat ein Gewicht:
   Kommandoposten und Rekrutierungsstelle je 2, alle anderen Nest-Typen je 1.
   Die Kapazität ist der Anteil der aktiven Nester an diesem Gewicht, bezogen auf höchstens 10 Camps:
   `Kapazität = abrunden(10 × Gewicht der aktiven Nester / Gewicht aller Nester)`, mindestens 1, solange ein Nest aktiv ist.
   So verringert schon das erste zerstörte Nest die Camps, wichtige Typen stärker.
   Wird ein Nest zerstört, verschwinden seine Camps beim nächsten Abbau und es kommen keine neuen nach.
   *Beispiel:* Zu Beginn sind es 10 Camps (Gewicht 15 von 15). Ist ein Kommandoposten zerstört, sind es 8 (13/15),
   nach einem Waffenlager 9 (14/15). Sind noch 4 Nester übrig, sind es etwa 3–4 Camps, am Ende nur noch 1.
   (Geändert am 2026-10-19, vorher Summe der Gewichte gedeckelt bei 10: Die ersten 3–4 zerstörten Nester hätten
   an der Zahl der Camps nichts geändert.)
2. **Befreites Gebiet ist tabu.** Im Umkreis von 1 km um eingenommene Sektoren und um FOBs
   entstehen keine Camps. Je weiter ihr vorrückt, desto mehr werden die Camps Richtung Hauptstadt gedrängt.

**Nachschub und Wechsel**
- Ein ausgehobenes Camp wird nach 30–60 Minuten an anderer Stelle ersetzt, sofern noch Kapazität frei ist.
- Unentdeckte Camps (seit ihrer Entstehung war noch kein Spieler in der Nähe) werden nach 2–3 Stunden abgebaut
  und tauchen woanders neu auf. Entdeckte, aber nicht ausgehobene Camps bleiben, wo sie sind.
- Entsteht während einer Sitzung eine neue Sperrzone (Sektor eingenommen, FOB gebaut), wird ein Camp darin beim
  nächsten Abbau entfernt und an anderer Stelle neu gesetzt.
- Durch den Neustart kommen ausgehobene Camps zwar zurück, aber nur bis zur aktuellen
  Kapazität. Der Fortschritt bleibt also über die Nester erhalten.

## 6. System B: Asymmetrische Bedrohungen

Festgelegt beim Grilling für Phase 4 (2026-10-22), Grundsätze in ADR 0022.

Alle Bedrohungen werden aus Budgets gespeist, die an Nester gekoppelt sind. Ohne Werkstatt
keine IEDs und keine Attentäter, ohne Garage keine VBIEDs, ohne Camp keine Hinterhalte.

| Bedrohung | Quelle | Ablauf | Hinweise für Spieler | Gegenmaßnahme |
|---|---|---|---|---|
| IED (vergraben) | IED-Werkstatt | An Straßen im Radius einer Werkstatt | Keine Hinweise im Gelände, nur Aufmerksamkeit und Minensucher (Hinweis-Objekte verworfen am 2026-10-22) | ACE-Minensucher, ACE-Entschärfen |
| IED (ferngezündet) | IED-Werkstatt | Mit Auslöser in Sichtweite | Zivilist mit Telefon, der beobachtet | Auslöser ausschalten, dann entschärfen |
| Attrappe | IED-Werkstatt | Wie IED, harmlos | Wie IED | Kostet Zeit, kein Schaden |
| VBIED | VBIED-Garage | Ziviles Fahrzeug fährt auf Spieler oder FOB zu | Fahrer allein, ignoriert Warnungen, hält nicht an | Stoppen, Distanz, Feuer |
| Selbstmordattentäter | IED-Werkstatt, Häufigkeit nach Ruf | Zivilist nähert sich einer Spielergruppe zu Fuß | Kleidung mit Weste oder dickem Mantel, zielstrebig, Ruf kurz vor der Explosion | Distanz, früh ausschalten |
| Hinterhalt | Camp | Miliz-Gruppe in Deckung an einer Straße nahe einem Camp | Warnung von Zivilisten | Aufklärung, Routen wechseln |

**Budget:** Obergrenze, wie viele Bedrohungen eines aktiven Nests gleichzeitig im Feld sind. Was verbraucht ist
(ausgelöst, entschärft, verschwunden), ersetzt das Nest nach einer Wartezeit. Ein zerstörtes Nest ersetzt nichts mehr,
schon Gelegtes bleibt liegen. Darüber gilt die globale Obergrenze für IEDs (Abschnitt 11).

**IEDs**
- Echte Objekte auf der Karte (die vier Vanilla-IEDs, kein „ultra strong“), **nicht gespeichert**. Beim Missionsstart
  legt jede aktive Werkstatt ihr volles Budget (Startwert 6), nach einem Verbrauch kommt nach 20 min ein neues an
  anderer Stelle. Wie bei Camps bleibt der Fortschritt über die Nester erhalten (ADR 0022). Jedes IED gehört der
  Werkstatt, die es gelegt hat, auch wenn sich Radien überlappen.
- Platz: auf Straßen jeder Art im Einflussradius, auf der Fahrbahn oder bis etwa 4 m daneben; nicht im Ortskern
  (Sektorradius), nicht näher als 500 m an Startbasis und FOB, mindestens 300 m zwischen zwei IEDs. Engstellen werden
  nicht gesondert gesucht. Unentdeckte IEDs ziehen nicht um.
- **Nur die Armee löst aus:** ein Fahrzeug in etwa 8 m oder zwei Soldaten zu Fuß in etwa 6 m (wie bei Liberation: ein Einzelner kann herantreten und entschärfen). Zivilisten, Miliz,
  Widerstand und Luftfahrzeuge nie. Beschuss oder Sprengen bringt ein echtes IED zur Explosion (Sprengen an Ort und
  Stelle ist eine Gegenmaßnahme, bringt aber keinen Ruf).
- Varianten (Startwerte): 60 % vergraben, 25 % ferngezündet, 15 % Attrappen. Alle zählen zum Budget.
- **Ferngezündet:** Der Auslöser (Kämpfer in Zivil) steht 60–150 m entfernt mit Sichtlinie, bevorzugt an einem Haus
  oder erhöht, und spawnt, wenn ein Spieler 800 m nah ist. Er zündet, sobald die Armee etwa 15 m am IED ist. Ist er
  tot, gefangen oder ergeben, zündet das IED nie mehr (auch nicht, wenn er wieder befreit wird), muss aber noch
  entschärft werden. Er hält ein Telefon, geht ein paar Schritte hin und her (Radius 4 m) und läuft weg, sobald sein
  IED weg ist (Explosion oder Entschärfen); ein gefangener Auslöser bleibt stehen.
- **Attrappe:** dasselbe Objekt, vom Minensucher gefunden und entschärfbar, aber unzerstörbar und explodiert nie.
- **Entschärfen** eines echten IEDs bringt +2 Ruf, eine Attrappe nichts. Den IED-Gegenstand, den das Spiel beim
  Entschärfen ablegt, entfernen wir: Die Armee sammelt keine Sprengsätze.

**VBIED**
- Jede aktive Garage hat ein Budget von 1, danach 30 min Wartezeit. Alle 5 min eine Chance (Startwert 25 %), wenn
  eine FOB oder Spieler (zu Fuß oder im Fahrzeug) im Radius sind.
- Ein ziviles Fahrzeug aus der Liste der Garage mit nur einem Fahrer spawnt 800–1200 m vom Ziel außer Sicht auf einer
  Straße, fährt hin, folgt einem fahrenden Ziel und zündet in 10 m (stärker als ein IED).
- Fahrer tot oder Fahrzeug fahrunfähig: Es geht nichts hoch. Wird das Fahrzeug zerstört, explodiert die Ladung.
  Erreicht er sein Ziel nicht innerhalb von 15 min, verschwindet er und zählt als verbraucht.
- Das Ziel wird zufällig unter allen FOBs und Spielern im Radius gewählt, ohne Gewichtung; KI-Einheiten der Armee sind
  weder Ziel noch Auslöser. Das Fahrzeug stammt aus den zivilen Autos des Presets „Civilian Takistanis“ und hat nur
  die Ladung (ein IED-Magazin) im Inventar, damit eine Durchsuchung zeigt, was es war. Der Fahrer zählt wie der
  Auslöser nicht im COIN-Einheiten-Budget (Zivilisten-Seite). Etwa 60 m vor dem Ziel ruft der Fahrer einmal (Sound aus
  Drongos Map Population wie beim Selbstmordattentäter, ohne die Mod still).

**Selbstmordattentäter**
- Nur im Radius einer aktiven Werkstatt, wenn Spieler zu Fuß dort sind (keine Ortschaft nötig: oft liegt nur eine im Radius). Alle 5 min
  eine Chance nach Ruf-Band (Startwerte niedrig 15 %, mittel 7 %, hoch 2 %), höchstens einer pro Werkstatt, danach
  30 min Wartezeit.
- Spawnt neu, 100–200 m entfernt außer Sicht, geht zielstrebig auf den nächsten Spieler zu (wechselt, wenn ein anderer näher ist) und zündet in 5 m.
- Erkennungszeichen: Kleidung aus einer eigenen Liste (Weste, dicker Mantel). Vor der Explosion ruft er mit 50 % Chance
  (Sound aus Drongos Map Population; ohne die Mod still, ohne Fehler). Keine sichtbaren Sprengladungen.
- Erschossen zündet er mit 30 % Chance: Früh erkennen lohnt sich, Erschießen auf kurze Distanz ist nicht sicher.

**Befehle an Zivilisten**
- Kann jeder Spieler geben, ohne Dolmetscher (Gesten): ACEs „Get Down!“ und „Go Away!“ im ACE-Interaktionsmenü an der
  Person. Echte Zivilisten folgen mit ACEs Chancen (50 %, mit Waffe in der Hand 80 %). Der Attentäter kontert sie nicht
  eigens: Nach Niklas' Erfahrung kommt niemand nah genug heran, um sie zu geben, bevor er zündet (2026-10-23).
- Kein eigener Befehl „Stehen bleiben!“ (verworfen am 2026-10-22): ACE-Aktionen an einer Person brauchen so viel Nähe,
  dass sie gegen einen Attentäter nicht helfen. Gegenmaßnahmen sind Distanz und frühes Ausschalten.

**Hinterhalt**
- Ein aktives Camp hat mit 50 % Chance einen Hinterhalt, festgelegt beim Entstehen des Camps. Er liegt neben der
  nächsten Straße, deren Abschnitt 200–800 m vom Camp entfernt ist (kein Fußweg, keine Brücke; nicht im Ortskern, nicht
  nahe Startbasis und FOB, 300 m zu einem anderen Hinterhalt). Camps ohne Straße in dieser Entfernung (gut ein Viertel
  im ersten Test) haben keinen.
- Er spawnt wie ein Camp bei Spielernähe: 4–6 Kämpfer in Deckung neben der Straße (knieend, Blick zur Straße, Feuer
  halten) und 2–4 Deckungsobjekte (Sandsäcke, Betonbarriere, Reifen, Kiste), ganz oder gar nicht im Camp-Budget
  (ADR 0015). Feuer eröffnen sie, sobald die Armee (auch Fahrzeuge und Luftfahrzeuge) etwa 150 m nah ist oder einer von
  ihnen getroffen wird. Die Kämpfer nennen im Verhör das Nest ihres Camps.
- Ausgehoben (kein Kämpfer kann mehr kämpfen) spawnt er nicht mehr und niemand warnt mehr vor ihm; Leichen und Objekte
  bleiben, bis niemand in der Nähe ist. Zieht das Camp um, bekommt das Ersatzcamp einen Hinterhalt ohne Würfeln (an
  einer neuen Straße), sofern der alte nicht ausgehoben war und das Ersatzcamp eine Straße in Reichweite hat. Wird das
  Camp ausgehoben, bleibt ein gespawnter Hinterhalt bis zum Abbau.
- Einen Hinterhalt ohne Camp gibt es am **Einsatzort** von Arzt-Einsatz und Reparatur (Abschnitt 8.2, ADR 0024).

**Kämpfer in Zivil** (Auslöser, VBIED-Fahrer, Attentäter)
- Stehen technisch auf der Zivilisten-Seite, damit sie sich im Menü nicht von echten Zivilisten unterscheiden. Ihr Tod
  kostet keinen Ruf, sie zählen als COIN-Einheiten und spawnen immer, auch bei vollem Budget (ADR 0022).
- Einen eigenständigen „Kämpfer in Zivil“, der bei Kontakt die Waffe zieht, gibt es in Phase 4 nicht.

**Allgemein**
- Budgets, Chancen, Abstände und Wartezeiten stehen in `coin_config.sqf`, jede Bedrohung hat einen eigenen Schalter.
- Im Debug-Modus erscheinen IEDs (Farbe nach Variante) und Auslöser auf der Karte. IEDs und alle
  Einheiten gehen an Zeus.
- Liberations eigene IEDs (in feindlichen Sektoren bei negativem Ruf) und Guerilla-Hinterhalte
  (in befreiten Ortschaften bei Ruf ≤ −25) werden **ersetzt** und sind per Schalter abschaltbar.
  Liberations Überfälle auf KI-Logistikkonvois und die Guerilla bei Sektorkämpfen bleiben (ADR 0008).
- Wir bauen alles selbst, auch Attentäter und VBIED. Die Module von Drongos Map Population passen nicht (feindliche
  Seite, interner Skriptpfad), nur dessen Sounddatei wird genutzt (ADR 0022).

## 7. System C: Dolmetscher und Intel

Festgelegt beim Grilling für Phase 3 (2026-10-22). Speicherformat, Triangulation und Lügen: ADR 0021.

**Dolmetscher**
- Zwei Slots in der Führungsgruppe beim Kommandanten. Die Rolle hängt am Slot und bleibt nach einem Respawn erhalten
  (Dolmetscher und Schütze haben dieselbe Einheitenklasse).
- **Nur der Dolmetscher selbst** spricht mit Zivilisten und Gefangenen. Andere Spieler sehen kein Gespräch und bekommen
  keine Antwort.
- Fällt der Dolmetscher aus, gibt es keine Gespräche. Das macht ihn zu einem Schutzobjekt.

**Gespräch (normales Aktionsmenü)**
- Wie bei Liberations eigenen Aktionen läuft das Gespräch über das normale Aktionsmenü (Scrollrad oder Leertaste), nicht über ACE.
  Der Eintrag erscheint nur für den Dolmetscher, wenn er einen Befragbaren aus der Nähe (etwa 5 m) ansieht. Es gibt je Frage
  einen eigenen Eintrag: in Phase 3 **„Nach der Miliz fragen“** (Zivilist) und **„Verhören“** (Gefangener), ab Phase 5 **„Wie steht ihr zu uns?“**.
- Nimmt der Dolmetscher einen Zivilisten ins Visier, bleibt dieser stehen und schaut ihn an. Nach der Antwort oder nach etwa
  30 s ohne Frage geht er weiter. Kein Fortschrittsbalken.
- Die Antwort kommt nach 1–2 s als Untertitel (Name und Satz), nur beim Dolmetscher, mit einigen Satzvarianten pro
  Ergebnis auf Deutsch und Englisch. Entsteht ein Marker, bekommt die Seite einen kurzen Hinweis „Neue Intel auf der Karte“
  ohne Inhalt.

**Befragung („Nach der Miliz fragen“)**
- Befragbar ist jeder lebende, ansprechbare Zivilist zu Fuß, auch Liberations Zivilisten in umkämpften Orten und auf
  Patrouille. Nicht befragbar: Gefangene (Verhör), der Informant (eigener Ablauf), Bewusstlose, Insassen von Fahrzeugen.
- Jeder Zivilist kann nur **einmal** befragt werden.
- **Abklingzeit pro Dolmetscher:** Erzeugt eine Befragung oder ein Verhör einen Marker (auch eine Lüge), muss der Dolmetscher
  etwa 5 Minuten warten. Fragt er vorher, vertröstet ihn der Zivilist („Nicht jetzt. Hier sind zu viele Augen.“) und der
  Zivilist bleibt unbefragt. Nach „Ich weiß nichts“ gibt es keine Abklingzeit. Sie gilt pro Spieler (Spieler-ID), übersteht den Respawn und
  wird nicht gespeichert. Der Satz kommt vom Zivilisten und erscheint unter seinem Namen. Grund: Liberation spawnt bei jeder Aktivierung eines Sektors neue Zivilisten, „einmal pro
  Zivilist“ allein ließe eine Ortschaft abgrasen.
- Mögliche Ergebnisse, gewichtet nach Ruf-Band (Gewichte in `coin_config.sqf`):
  - „Ich weiß nichts.“
  - **Gerücht**: großer Kreis (Startwert 600 m) um ein Nest
  - **Hinweis**: mittlerer Kreis (300 m)
  - **Konkreter Tipp**: kleiner Kreis (100 m)
  - **Warnung**: Bedrohung in der Nähe. In Phase 3 ein Camp in der Umgebung (Kreis um das Camp, nicht gespeichert, weil
    Camps nicht gespeichert werden); ab Phase 4 auch IED und Hinterhalt. Der Zivilist warnt vor einem Camp im Umkreis von
    1500 m, der Kreis hat 150 m Radius (das Camp liegt darin, nicht in der Mitte) und hat ein eigenes rotes Symbol. Ein Camp
    bekommt höchstens einen Kreis, auch ein bereits entdecktes Camp darf einen bekommen. Der Kreis verschwindet, wenn das
    Camp ausgehoben, umgezogen oder entfernt wird. Gibt es kein Camp ohne Kreis in Reichweite, bleibt es bei „Ich weiß nichts“.
    Ab Phase 4 (Ticket 4.8, 4.5) warnt er ebenso vor einem IED im Umkreis von 1000 m (Kreis 100 m, auch vor Attrappen, er
    weiß es nicht besser) und vor einem Hinterhalt im Umkreis von 1000 m (Kreis 150 m). Jede Bedrohung bekommt höchstens einen Kreis, der mit ihr verschwindet;
    unter allen Bedrohungen ohne Kreis in Reichweite entscheidet der Zufall. Symbol, Farbe und Meldung wie beim Camp,
    nicht gespeichert
  - **Lüge**: Kreis an einer falschen Stelle. Häufig bei niedrigem Ruf.
- Ab Ruf +25 kann statt des Ergebnisses (außer „Ich weiß nichts“) ein **Zugriffsauftrag** entstehen: Er ersetzt das Intel
  der Befragung, damit es keine doppelte Belohnung gibt, und beginnt dafür früher (Abschnitt 8.2). Beim Verhör entsteht er
  zusätzlich zu den Ergebnissen.
- **Welches Nest:** ein zufälliges aktives Nest im Umkreis von etwa 4 km um den Zivilisten; gibt es dort keins, das nächste
  aktive Nest überhaupt. So zählt die Geografie, und am Ende sind auch die letzten Nester noch zu finden.

**Intel-Marker**
- Marker gelten für die ganze Seite und werden gespeichert (ADR 0021).
- **Ein Kreis pro Nest.** Das Nest liegt immer im Kreis, aber nicht in der Mitte.
- **Triangulation:** Jeder weitere wahre Treffer verkleinert den Kreis (alter Radius × Faktor, nie größer als die Stufe des
  neuen Treffers, nie kleiner als 50 m), der neue Kreis liegt möglichst im alten. Ein geschrumpfter Kreis ist damit sicher
  wahr: Zwei Quellen bestätigen sich.
- Ab Hinweis zeigt der Marker ein **Symbol pro Nest-Typ**, ein Gerücht nur ein neutrales „Miliz-Versteck“.
- Wahre Marker eines zerstörten Nests verschwinden automatisch.
- **Lügen** sehen aus wie echte Marker: zufälliger Nest-Typ, zufällige Größe. Sie schrumpfen nie. Jede Lüge hat einen
  verborgenen Ersatzpunkt auf glaubhaftem Gelände (Ortsrand oder freies Gelände), um den ihr Kreis gebaut ist. War ein
  Spieler zu Fuß nahe an diesem Punkt (etwa 50 m), gilt das Gebiet als durchsucht und der Marker verschwindet ohne Meldung.

**Weitere Intel-Quellen**
- **Gefangene verhören** (Aktionsmenü „Verhören“): überall möglich, einmal pro Gefangenem. Ein Verhör bringt 1–2 Ergebnisse
  mit eigenen Gewichten, die nicht vom Ruf abhängen (ein Gefangener gehört nicht zur Bevölkerung): mehr Tipps, wenig
  Lügen, beim ersten Ergebnis nie „Ich weiß nichts“. Ein Kämpfer aus einem Camp nennt das Nest seines Camps, eine
  Nest-Wache ein anderes Nest, alle anderen folgen der Regel „Welches Nest“. Beide Ergebnisse eines Verhörs betreffen dasselbe
  Nest: ein zweites wahres Ergebnis verkleinert nur den Kreis. Die Abklingzeit gilt auch hier.
  Liberations Belohnung für das Abliefern an der FOB (Intel-Punkte) bleibt zusätzlich.
- *Später/optional:* Für Gebäude-Nester ein Foto des Hauses im Tagebuch statt eines Kreises (braucht ein Bild pro Hausklasse).
- **Informanten** (Liberation-Funktion): Ab Ruf +25 meldet sich gelegentlich ein Zivilist, der zu einer FOB gebracht werden
  muss. Liberation gibt dafür Intel-Punkte. Zusätzlich liefert er einen **Konkreten Tipp** (nie eine Lüge) zum aktiven Nest,
  das seiner Ortschaft am nächsten liegt und noch keinen Marker hat; haben alle einen, zum nächsten aktiven Nest. Der Tipp
  zählt als wahrer Treffer (ADR 0011).

**Eigene Bevölkerung** (ADR 0011)
- Liberation hat in befreiten Ortschaften keine Zivilisten. Die Mission spawnt dort bei Spielernähe 4–8 eigene Zivilisten im
  Ortskern, mit denselben Abständen für Spawn und Abbau wie bei Nestern, innerhalb des gemeinsamen Zivilisten-Budgets
  (ADR 0015). Im Budget zählen nur die eigenen Zivilisten, nicht die von Liberation; eine Ortschaft bekommt ihre Bevölkerung ganz
  oder gar nicht (Entscheidung 2026-10-22). Sie entsteht erst, wenn Liberation mit der Ortschaft fertig ist (Sektor nicht aktiv).
  Weil sie bei jedem Besuch neu entstehen, verhindert die Abklingzeit das Abgrasen.
- Dazu gehört ab Phase 5 der **Älteste** (Abschnitt 8).

**Intel und Intel-Punkte**
- „Intel“ meint immer unseren Hinweis auf ein Nest oder eine Bedrohung.
- Liberations Ressource heißt „Intel-Punkte“. Damit werden weiterhin die Nebenmissionen
  Konvoi-Überfall und Rettung bezahlt, ab Phase 5 beim Ältesten gestartet, dazu die Verstärkung (Abschnitt 8). Die Nebenmission „FOB Hunting“ entfällt, weil feindliche Basen
  neben den Nestern das Netzwerk verwässern würden.

## 8. System D: Bevölkerung und Ruf

Der Ruf **ist** Liberations „Civil Reputation“: ein globaler Wert von **−100 bis +100** (ADR 0009).

Festgelegt beim Grilling für Phase 5 (2026-10-23, ADR 0023). Werte sind Startwerte in `coin_config.sqf`.

| Ruf steigt | | Ruf sinkt | |
|---|---|---|---|
| Ortschaft befreien¹ | +5 (Hauptstadt +10) | Zivilist getötet¹ (auch der Älteste) | −5 |
| Verwundeten Zivilisten nach der Befreiung behandeln¹ | +2 | Gefangenen getötet³ | −10 |
| Informant zur FOB gebracht¹ | +2 | Gebäude zerstört² | 0 |
| Echtes IED entschärft | +2 | Zivilfahrzeug zerstört⁴ | −2 |
| Nest zerstört (jeder Nest-Typ) | +5 | Zivilfahrzeug beschlagnahmt⁵ | 0 |
| Hilfsauftrag (Abschnitt 8.2) | +4 bis +7 | Befreundeten Widerstandskämpfer getötet¹ | −3 |
| | | Hilfsauftrag gescheitert (Zeit läuft ab oder der Älteste stirbt) | −(Ruf, den er gebracht hätte) |

¹ macht Liberation bereits. Wir ziehen dafür nicht doppelt ab.
² Zerstörte Häuser kosten **keinen** Ruf (2026-10-25). Liberation würde bei der Einnahme einer Ortschaft die Häuser im Umkreis
von 262,5 m um den Sektor-Marker mit dem Stand beim Serverstart vergleichen und je fehlendem Haus −3 abziehen (verrechnet mit
dem Gewinn der Einnahme). COIN schaltet das ab (Lobby-Parameter „Disable Building Destruction penalty“, Standard an; Liberations Wert wird auf 0 gesetzt): Die KI zerstört
solche Häuser oft selbst. Nach der Einnahme lässt sich der Täter einer Zerstörung nicht sicher zuordnen, ein falscher Abzug
wäre schlimmer als keiner. Der Gewinn für die Einnahme (+5, Hauptstadt +10) bleibt.
³ Gefangener im Sinne des Glossars: gefesselt, ergeben oder mit Liberations CAPTURE in den Squad aufgenommen. Insgesamt
immer −10: bei Kämpfern, die nur mit ACE gefesselt sind oder sich ergeben, ziehen wir −10 ab; bei Gefangenen aus
Liberations Ergeben-Skript zieht Liberation schon −5 ab (Zivilisten-Gruppe, auch an der FOB), wir −5 dazu; im Squad zieht
Liberation nichts, wir −10. Kämpfer in Zivil (Auslöser, VBIED-Fahrer, Attentäter) kosten nie Ruf (ADR 0022).
⁴ Liberation zählt das nur in der Statistik. Fahrzeuge, die COIN erzeugt (VBIED, Kurier, Export, Waffentransport),
kosten keinen Ruf, beschlagnahmte Fahrzeuge auch nicht (siehe ⁵).
⁵ Wer in ein Zivilfahrzeug einsteigt, beschlagnahmt es. Das kostet **keinen** Ruf (`COIN_repCivVehicleSeized`, Liberation sieht −2 vor), und das Fahrzeug gilt
danach als unseres: Zerstört die Armee es, kostet das nichts. Liberations Handler dafür hat einen Tippfehler (`setVehiclesSeized`, auch im Upstream) und
beschlagnahmt nie, COIN macht den Handler neu (Schalter `COIN_enableVehicleSeizure`). Beschlagnahmte Fahrzeuge werden mit gespeichert, sind für Zeus sichtbar, und die Zivil-Patrouille löscht sie nicht mehr (Hook 26).

Nicht umgesetzt (2026-10-23): „Grundloses Schießen nahe Zivilisten“, „Zivilist verletzt“, „Haus nach der Einnahme zerstört“
(2026-10-25, Ticket 5.8, Täter nicht zuzuordnen) und ein eigener Bonus für
geholfene Zivilisten. Liberation bestraft getötete Zivilisten schon, Verletzungen unter ACE und „grundlos“ lassen sich
nicht fair erkennen.

**Rückmeldung:** Unsere Ruf-Änderungen erzeugen im Spiel keine Meldung, nur eine `[COIN]`-Logzeile. Im Debug-Modus
erscheinen sie zusätzlich mit Betrag und neuem Wert im Systemchat. Liberations eigene Meldungen (z. B. „Zivilist getötet“)
bleiben.

**Ruf-Bänder**

| Band | Ruf | Bedeutung |
|---|---|---|
| niedrig | < 0 | Viele Lügen, kleine Wahrheitsquote |
| mittel | 0 bis < 25 | Gemischte Ergebnisse |
| hoch | ≥ 25 | Gute Intel, Informanten erscheinen, Widerstand steht auf unserer Seite |

- **Start: −20.** Zu Beginn lügen viele Zivilisten. Das zwingt zum Aufbau von Vertrauen.
  Der Widerstand ist bei −20 noch neutral (feindlich erst unter −25).
- **Keine Ruf-Anzeige im Overlay**, weder Zahl noch farbiges Symbol (Hook, Schalter `COIN_hideReputationNumber`).
  Spieler erfahren die Stimmung, indem der Dolmetscher die Bevölkerung fragt (siehe unten).
- Ruf wirkt auf: Wahrheitsquote und Kreisgröße bei Intel (Gewichte pro Ruf-Band, seit Phase 3), Häufigkeit der
  Informanten, Häufigkeit von Attentätern (pro Ruf-Band, seit Phase 4), Zugriffsaufträge (erst ab +25), Gefälligkeiten
  (erst ab +50).
- **Informanten** (Liberation-Ablauf, Abschnitt 7): unter +25 keine, von +25 bis unter +50 Liberations Werte
  (alle 90–180 min ein Versuch, 75 % Chance), ab +50 alle 45–90 min mit 100 %. Ein Server-Loop setzt dafür Liberations
  `KP_liberation_civinfo_*`-Werte nach dem Ruf, kein Hook.
- Der Ruf bleibt **global**, wie bei Liberation. Ruf pro Ortschaft wäre eine spätere Erweiterung (E4).

**Stimmung („Wie steht ihr zu uns?“)**
- Eigener Eintrag im Aktionsmenü, nur für den Dolmetscher, bei jedem befragbaren Zivilisten und beim Ältesten.
  Beliebig oft, zählt nicht als Befragung, keine Abklingzeit.
- Die Antwort nennt die **Stimmung** in fünf Stufen, immer wahr, mit einigen Satzvarianten pro Stufe:

| Ruf | Stimmung | Was das im Spiel heißt |
|---|---|---|
| < −25 | feindselig | Der Widerstand kämpft für die Miliz |
| −25 bis < 0 | misstrauisch | Viele Lügen |
| 0 bis < 25 | abwartend | Gemischte Intel |
| 25 bis < 50 | freundlich | Informanten, Zugriffsaufträge, Widerstand auf unserer Seite |
| ≥ 50 | sehr freundlich | Gefälligkeiten entstehen |

**Der Älteste**
- Jede befreite Ortschaft hat genau einen Ältesten. Er gehört zur eigenen Bevölkerung (Abschnitt 7), entsteht mit ihr und
  zählt zu ihrem Budget. Er steht fest an einem Gebäude nahe dem Ortskern (größtes Haus oder Moschee), trägt eigene
  Kleidung und heißt „Ältester …“.
- Er wird nicht nach der Miliz befragt. Der Dolmetscher hat bei ihm „Wie steht ihr zu uns?“ und **„Können wir helfen?“**.
- Wird er getötet, zieht Liberation −5 ab (Zivilist), und die Ortschaft hat 60 min keinen Ältesten; danach entsteht beim
  nächsten Besuch ein neuer.

**Dialog des Ältesten**
- „Können wir helfen?“ öffnet einen eigenen Dialog nach dem Vorbild von Liberations Nebenmissions-Dialog: links die Liste,
  rechts die Erklärung, unten „Annehmen“. Nur der Dolmetscher nimmt an, für die ganze Seite.
- Drei Abschnitte: **Hilfsaufträge** (8.2), **Nebenmissionen** (Liberations Konvoi-Überfall und Rettung, Kosten in
  Intel-Punkten wie bei Liberation, Start über Liberations Server-Aufruf) und **Gefälligkeit** (Verstärkung, 8.1).
- Was gerade nicht geht, ist grau und nennt den Grund. Wartet die Ortschaft noch oder läuft ihr Auftrag, sagt der Älteste
  beim Öffnen „Wir brauchen gerade nichts. Kommt später wieder.“, die Hilfsaufträge sind grau, der Rest bleibt wählbar.
- Liberations Eintrag „Nebenmissionen“ an der FOB entfällt (Hook mit Schalter). Vor der ersten befreiten Ortschaft gibt es
  damit keine Nebenmissionen.

### 8.1 Unterstützung bei sehr hohem Ruf

Wer die Bevölkerung wirklich auf seiner Seite hat, bekommt mehr als nur Informationen:
**lokale Kämpfer** (dorfeigene Wachen, Stammeskämpfer) helfen aktiv mit. Einzige Gefälligkeit ist die **Verstärkung**.
Der Ablenkungsangriff ist gestrichen (2026-10-23, ADR 0023): Liberations Guerilla-Einsätze leisten Ähnliches, und das
Abziehen von Besatzungen würde Liberations Sektor-Logik aushebeln.

**Gefälligkeiten**
- Solange der Ruf ≥ +50 ist und mindestens ein Spieler online ist, entsteht alle 120 min eine Gefälligkeit, höchstens 2 auf
  Vorrat. Vorrat und laufender Zähler werden gespeichert.
- Einlösen beim Ältesten kostet eine Gefälligkeit **und** 10 Intel-Punkte und geht ab Ruf +25. Höchstens eine Verstärkung
  gleichzeitig.

**Verstärkung**
- Nach „Annehmen“ klickt der Dolmetscher einen Punkt auf der Karte an (wie beim HALO-Sprung von Liberation). 10 lokale
  Kämpfer entstehen am Ältesten, laufen dorthin und halten den Punkt. Der Punkt liegt nicht im Wasser und höchstens
  `COIN_reinforcementMaxDistance` (2500 m) vom Ältesten entfernt; die Karte zeigt diese Reichweite als Kreis, ein Klick
  außerhalb wird abgelehnt (die Karte bleibt offen). Ausrüstung nach Liberations aktueller
  Widerstands-Stufe. Sie spawnen immer und zählen in keinem Gegner-Budget.
- **Funk:** Solange eine Verstärkung unterwegs ist, haben Kommandant, Truppführer (beide Trupps) und Dolmetscher im
  Kommunikationsmenü (0-8) drei Befehle, ohne Entfernungsgrenze. Jeder von ihnen darf jeden Befehl geben, der letzte
  Befehl gilt und ersetzt den alten:
  - **„Folgt uns“:** Die Gruppe folgt dem Spieler, der den Befehl gibt (Skript alle 10 s) und bleibt 15 m hinter ihm.
    Stirbt er oder geht er offline, hält sie ihre Stellung.
  - **„Geht dorthin“:** Klick auf die Karte (Esc bricht ab, kostet nichts), die Gruppe läuft hin und hält. Im Wasser wird
    abgelehnt, eine Reichweitengrenze gibt es nicht.
  - **„Greift an“:** Die Gruppe läuft im Kampfmodus zur Mitte der **ihr nächsten** Ortschaft der Miliz und sucht und
    zerstört dort (SAD). Gibt es keine Ortschaft der Miliz mehr, antwortet der Funk „kein Ziel“ und der alte Befehl bleibt.
    Liberation aktiviert eine Ortschaft nur bei Spielern in Reichweite; ohne Spieler trifft die Gruppe dort niemanden.
    Gedacht als gemeinsamer Angriff.
  - Ein Befehl setzt die 30 min nicht zurück. Die Ankunftsmeldung gilt nur dem ersten Punkt der Anforderung. Mit dem Ende der
    Verstärkung (Zeit, Ruf, aufgerieben) verschwinden die Befehle.
  - **Bestätigung:** ein kurzer Funkspruch (Chatzeile mit dem Rufzeichen „Verstärkung“) nur an den Befehlsgeber, dazu eine
    Logzeile je Befehl. Das Briefing „Verstärkung führen“ steht im Karten-Tagebuch „COIN Liberation“ von Kommandant,
    Truppführer und Dolmetscher, solange die Verstärkung aktiv ist.
- **Meldungen:** an alle, wenn die Gruppe am Punkt ankommt, und beim Abzug mit dem Grund (Zeit, Ruf, aufgerieben).
  Liberations Stärke des Widerstands sinkt mit jedem Gefallenen (`kill_manager.sqf`), das bleibt so.
- **Ende:** nach 30 min ab dem Entstehen (die Laufzeit zählt mit), wenn der Ruf unter +25 fällt oder wenn die Gruppe
  aufgerieben ist (alle tot, bevor sie abzieht). Die Kämpfer laufen zurück zur
  Ortschaft ihres Ältesten und verschwinden außer Sicht. Eine laufende Verstärkung wird nicht gespeichert.
- Wird die Gruppe aufgerieben, kommt die nächste Gefälligkeit 60 min später. Ruf kostet ihr Tod nicht.
  (Tötet die Armee sie selbst, zieht Liberation Ruf ab.)
- Lokale Kämpfer sind Einheiten von Liberations **Widerstand** in einer eigenen Gruppe (ADR 0012), sie treten keiner
  Spielergruppe bei. Dessen Haltung hängt global am Ruf: ab +25 auf unserer Seite, darunter neutral, unter −25 auf Seiten
  der Miliz. **Fällt der Ruf unter +25, ziehen aktive lokale Kämpfer ab.**
- Erkennungszeichen: Alle KI-Kämpfer von Miliz und Widerstand tragen ein farbiges Kopftuch (Shemag): **rot = Miliz**,
  **grün = Widerstand, feindlich** (Ruf unter −25), **blau = Widerstand, neutral oder freundlich**. Die Farbe folgt dem
  Ruf live, auch bei bereits lebenden Kämpfern. Die Spieler lesen das im Karten-Tagebuch „COIN Liberation“ (ADR 0012, 0014).
- Liberations spontane Guerilla-Einsätze bleiben: Bei hohem Ruf stoßen gelegentlich Widerstandskämpfer
  zu unseren Sektorangriffen, bei Ruf unter −25 kämpfen sie für die Miliz.

### 8.2 Aufträge

Neben Liberations **Nebenmissionen** (Konvoi-Überfall, Rettung, mit Intel-Punkten beim Ältesten gekauft) gibt es eigene
**Aufträge** in zwei Arten. Jeder Auftrag ist eine Arma-Aufgabe für die ganze Seite (Meldung „Neuer Auftrag“), angenommen
vom Dolmetscher. Aufträge werden nicht gespeichert und verfallen beim Serverneustart. Läuft ein **Zugriffsauftrag** ab oder scheitert er, kostet das nichts. Läuft bei einem **Hilfsauftrag** die Zeit ab oder stirbt der Älteste, merkt sich die Bevölkerung den gebrochenen Wunsch: Ihr Ruf wird abgezogen, den der Auftrag gebracht hätte (beim Arzt-Einsatz alle Patienten und der Bonus, auch wenn schon einige behandelt waren). Kein Abzug gibt es, wenn der Auftrag technisch endet (Hilfsaufträge ausgeschaltet, ein Gerät oder Patient gelöscht). Einen Abbruch gibt es nicht.

| | Hilfsauftrag | Zugriffsauftrag |
|---|---|---|
| Woher | Dialog des Ältesten einer befreiten Ortschaft (Abschnitt 8). | Entsteht mit 15 % Chance bei einer Befragung (Ergebnis außer „Ich weiß nichts“) anstelle von deren Intel, oder zusätzlich zu den Ergebnissen eines Verhörs. |
| Bedingung | Jedes Ruf-Band. Pro Ortschaft 1 Auftrag, danach 60 min Wartezeit ab dessen Ende; höchstens 2 gleichzeitig. | Ruf ≥ +25 (auch beim Verhör); höchstens 1 gleichzeitig. |
| Zeit | 60 min | Beginn 15–25 min nach dem Annehmen, Fenster insgesamt 45–75 min (der Kurier braucht bei höchstens 70 km/h rund 30–40 min für Hin, Warten und Zurück) |
| Belohnung | Ruf | Intel (Konkreter Tipp) und/oder Readiness −10 (Punkte; Waffentransport −20) |

**Hilfsaufträge**

Die Objekte eines Hilfsauftrags entstehen beim Annehmen und bleiben bis zu seinem Ende, auch wenn die Bevölkerung
abgebaut wird.

| Hilfsauftrag | Was zu tun ist | Wer | Belohnung |
|---|---|---|---|
| **Hilfsgüter liefern** | Eine Liberation-Supply-Kiste (100 Supplies, aus jeder FOB) am Boden abstellen, höchstens 20 m vom Ältesten entfernt. Die Kiste verschwindet. | jeder Spieler | +5 Ruf |
| **Arzt-Einsatz** | 3–5 Patienten 10–40 m um die Dorfmitte des Einsatzorts (siehe unten) behandeln (Aktion „Behandeln“, verbraucht eine Bandage, heilt sofort). Verwundeten-Animation und 25-m-Kreise kommen von Liberations Verwundeten-Funktion (`F_cr_woundedAnim`); die Aktion ist eine Nachbildung von `KPLIB_fnc_crAddAceAction`, bei der der Server den Schutz der Patienten nur für das Heilen aufhebt. Die Patienten sind unverwundbar, zählen nicht zum Budget und sind nicht befragbar. Am Ende stehen alle auf und werden außer Sicht entfernt, die Kreise verschwinden. | jeder Spieler mit einer ACE-Bandage (eine pro Patient) | +1 Ruf pro Patient, +2 extra, wenn alle in der Zeit behandelt sind |
| **Infrastruktur reparieren** | 2–3 beschädigte, rauchende Geräte (tragbare Generatoren, Klassenliste in der Config) am Einsatzort (siehe unten) reparieren: 20–100 m um die Dorfmitte, 20 m voneinander entfernt. Aktion „Reparieren“, 30 s mit ACE-Fortschrittsbalken, abbrechbar (dann kein Fortschritt, später neu beginnen). Repariert: Rauch aus. Am Ende des Auftrags werden die Geräte außer Sicht entfernt. | nur ACE-Pionier (Slot EOD) mit Werkzeugkasten | +4 Ruf, wenn alle Geräte repariert sind |

*Später:* Straße räumen, Entführte befreien.

**Einsatzort und Hinterhalt** (Arzt-Einsatz und Reparatur, ADR 0024, festgelegt beim Grilling am 2026-10-26)

Diese beiden Hilfsaufträge spielen nicht in der befreiten Ortschaft, sondern an einem **Einsatzort**: einem Dorf außerhalb der
Liberation-Sektoren, damit ein Hinterhalt der Miliz glaubhaft ist (er taucht nicht plötzlich in der befreiten Stadt auf).
„Hilfsgüter liefern“ bleibt beim Ältesten, dort ist der Transport die Schwierigkeit.
- **Auswahl:** Das nächste Karten-Dorf (`NameVillage` oder `NameLocal`) mit mindestens 6 Häusern im Umkreis von 150 m (so
  fallen Camps, FOBs und Fabriken heraus, dazu eine Ausschlussliste in der Config), mindestens 500 m von jeder Ortschaft
  und Stadt (sonst wäre es die befreite Ortschaft selbst) und 150 m von jeder Fabrik, jedem Militärposten und Turm, 1200 m
  von jedem noch nicht befreiten Sektor (Liberation aktiviert Sektoren bei 1000 m), höchstens 3000 m vom Ältesten,
  gerade nicht Einsatzort eines anderen Auftrags. Dorfmitte ist der Mittelpunkt der Häuser. Gibt es keines, ist der Eintrag
  im Dialog grau („Kein Dorf in der Nähe, das Hilfe braucht.“).
- **Sichtbar:** Der Dialog, der Titel der Aufgabe und der Karten-Marker nennen das Dorf, der Älteste sagt im Untertitel, wohin.
- **Schalter:** `COIN_enableAidSites` aus = Patienten und Geräte stehen in der befreiten Ortschaft wie vorher.
- **Hinterhalt am Einsatzort:** Wenn ein aktives Nest (jeder Typ) den Einsatzort im Einflussradius hat, wartet beim Annehmen
  mit 75 % die Miliz: 4–6 Kämpfer in Deckung mit 2–4 Deckungsobjekten, 100–250 m vor dem Dorf auf der Seite der befreiten
  Ortschaft (Richtung Ältester, ±45°), möglichst an einer Straße; dazu 2–3 versteckte Kämpfer in Häusern des Dorfes. Feuer bei
  etwa 150 m Abstand der Armee oder wenn einer getroffen wird. Sie entstehen bei Spielernähe (1000 m), zählen ganz oder gar nicht
  zum Camp-Budget (kein Platz = kein Hinterhalt, der Auftrag ist sicher) und gehen am Ende des Auftrags außer Sicht, sobald niemand
  in der Nähe ist. Der Älteste warnt nur vage im Untertitel, nur wenn die Gefahr beschlossen ist. Ein gefangener Kämpfer nennt
  im Verhör das nächste aktive Nest im Radius, soweit ohne Umbau möglich. Schalter `COIN_enableAidAmbush`.
- Belohnung, Zeitlimit (60 min) und Abzug beim Scheitern bleiben. Hilfsgüter liefern hat keine Gefahr.

**Zugriffsaufträge**
- Der Zivilist oder Gefangene erzählt davon im Untertitel, danach öffnet sich beim Dolmetscher derselbe Dialog wie beim
  Ältesten mit genau einem Eintrag. Schließt er ihn ohne „Annehmen“, ist die Gelegenheit weg.
- Die Art wird zufällig aus denen gewählt, deren Voraussetzung erfüllt ist. Die Aufgabe nennt Uhrzeit im Spiel und Ort
  bzw. Start und Ziel der Strecke; beim Waffentransport nur zwei Punkte auf der Route, damit das Lager nicht verraten wird.
- Die Einheiten aller Arten entstehen zum Beginn, wie der Konvoi von Liberation unabhängig vom Abstand der Spieler (damit Fahrzeuge wirklich fahren). Sie zählen als
  COIN-Einheiten, spawnen aber immer.

| Zugriffsauftrag | Voraussetzung | Ablauf | Erfolg | Scheitern |
|---|---|---|---|---|
| **Kurier abfangen** | ein aktives Nest | Ein Auto (kein Technical) mit dem Kurier als Fahrer und 2–3 bewaffneten Wachen der Miliz in Uniform fährt wie der Konvoi der Liberation-Nebenmission irgendwo auf der Karte los (ohne Rücksicht auf die Spieler, vorzugsweise von einer Ortschaft der Miliz) zu einer beliebigen anderen Ortschaft (befreit oder nicht) in 3–6 km Luftlinie, wartet dort 2 Minuten und fährt zurück zum Start (Marker an Start und Ziel). Die Strecke prüft Arma vorher auf Befahrbarkeit. | Auto gestoppt (Kurier tot, gefangen oder Auto fahrunfähig) und „Dokumente durchsuchen“ am Auto: Konkreter Tipp zum Nest des Kuriers | Auto ist zurück am Start oder brennt aus |
| **Anführer festnehmen** | ein aktiver Kommandoposten | Der Anführer, unbewaffnet in eigener Kleidung (läuft nicht weg), steht für das Zeitfenster neben einem Haus in einem Karten-Dorf (eines der drei nächsten, mindestens 1000 m vom Kommandoposten, zu dem er gehört), mit 8–10 Wachen der Miliz: ein Teil (40 %) steht im Ring um ihn, der Rest patrouilliert im Umkreis von 75 m. Mindestens die Hälfte der Wachen trägt Weste und Helm (Islamic-State-Zwillinge, ADR 0014, bei hoher Readiness mehr). Sie bleiben stehen, bis die Gruppe im Kampf ist. | Er wird festgenommen (ACE gefesselt oder ergeben) und lebend zur FOB gebracht (höchstens 30 m): Readiness −10, er bleibt 15 min für das Verhör; sein Verhör bringt als erstes Ergebnis immer einen Konkreten Tipp zu seinem Kommandoposten | Er stirbt oder das Zeitfenster endet |
| **Waffentransport abfangen** | ein aktives Waffenlager (das Ziel des Transports) | Ein Konvoi aus **2 Technicals, einem Lkw und einem Auto mit gepanzerter Infanterie** (Weste und Helm, Islamic-State-Zwillinge, ADR 0014) fährt wie der Konvoi der Liberation-Nebenmission irgendwo auf der Karte los (ohne Rücksicht auf die Spieler) auf der Straße zum Lager. **Start und Ziel nennt die Aufgabe nicht**, damit sie das Lager nicht verrät. Sie nennt **zwei Punkte auf der Route** (Straßenabschnitte, etwa bei einem Drittel und zwei Dritteln der Strecke, der zweite mindestens 2000 m vor dem Lager) mit je einem Zeitfenster, in dem der Konvoi dort durchkommt. Der Lkw ist wie in der Liberation-Nebenmission mit Munitionskisten beladen. Die Spieler legen dort einen Hinterhalt, **durchsuchen den Lkw nach den Lieferdokumenten** (Aktion „Lieferdokumente suchen“, wie die Suche beim Kurier) und zerstören anschließend alles, sodass nur Wracks bleiben. Hinter dem letzten Punkt gibt es keinen Hinweis mehr. | **Alle vier Fahrzeuge sind komplett zerstört**, bevor eines das Lager erreicht (gestoppt genügt nicht): Readiness −20. Der Konkrete Tipp zum Ziel-Lager kommt **nur durch die Suche im Lkw** (wird der Lkw vorher zerstört, sind die Dokumente weg) | Ein Fahrzeug kommt am Lager an (der Konvoi verschwindet außer Sicht), oder das Zeitfenster endet |
| **Export** | Die Miliz hält eine Ortschaft, die Hauptstadt oder einen Militärposten im Umkreis von 3 km um einen Flugplatz (Liste in der Config: Kinduf Airport, Kinduf Airfield, Kalae Airport) | Zivilflugzeug (Cessna, Klasse in der Config) auf der Piste, daneben ein leerer Lkw und ein Technical (die Ware); 8–12 Wachen, etwa die Hälfte läuft Streife um das Flugzeug, der Rest steht im Ring. | Flugzeug zerstört: Readiness −10 | Fenster endet: kein echter KI-Start, das Flugzeug verschwindet außer Sicht |

Liberations HVT-Aufgabe nach Informanten bleibt unverändert daneben bestehen.

## 9. System E: Gegenangriffe und Hauptstadt

- Liberation-Gegenangriffe auf eingenommene Sektoren bleiben, werden aber **asymmetrisch**:
  Technicals und Infanterie, höchstens **ein Altfahrzeug** pro Gegenangriff, keine Kampfpanzer.
  Dazu Mörserbeschuss auf FOBs und Überfälle auf Konvois.
- Gegenangriffe starten nur aus Regionen mit aktivem **Kommandoposten**. Kommandoposten sind auch die
  Quelle für Verstärkung angegriffener Miliz-Sektoren; Liberations Funktürme entfallen (ADR 0013).
- Die **Netzwerkstärke deckelt Liberations Readiness**: Je weniger Nester aktiv sind, desto niedriger der
  Höchstwert. Zusätzlich **senkt jedes zerstörte Nest die Readiness sofort** (z. B. um 10, Kommandoposten 20),
  einige Zugriffsaufträge um 10 Punkte (der Waffentransport um 20). Die Readiness bleibt im Overlay sichtbar (ADR 0013).
- Hohe Readiness bedeutet: mehr Patrouillen, stärkere Besatzungen in den Sektoren, häufigere Gegenangriffe.
- **Hauptstadt:** Garnisonsstärke skaliert mit dem Restnetzwerk (siehe Abschnitt 5).
  Bei 0 verbleibenden Nestern: Mindestbesetzung. Bei vollem Netzwerk: praktisch nicht einnehmbar.
  Fest dazu gehört schweres Gerät für den Endkampf: **2 Kampfpanzer T-72**, **1 Flakpanzer ZSU-23-4**
  und Igla-Schützen. Es hängt nicht an den Waffenlagern.
- Einnahme der Hauptstadt = Kampagnensieg.

## 10. Ausrüstung: leichte Brigade

Die Armee ist eine **leichte Brigade** (RHS USAF Desert), keine schwere Streitmacht. Die Bau- und Kauflisten
von Liberation werden über ein eigenes BLUFOR-Preset stark reduziert. Siehe ADR 0007.

| Kategorie | Status |
|---|---|
| Infanterie, Scharfschützen, Pioniere, Sanitäter | erlaubt |
| Radfahrzeuge (MRAP, Humvee, Lkw, Logistik) | erlaubt |
| Statische Waffen (MG, Granatmaschinenwerfer, TOW, Mörser) | erlaubt |
| Kleine Aufklärungsdrohnen (Darter, Pelican) | erlaubt |
| Hubschrauber (Transport, MEDEVAC, mit Türschützen, UH-1Y Ground Suppression) | erlaubt |
| Bergepanzer CRV-6e Bobcat (Reparatur) | erlaubt (einzige Ausnahme bei Kettenfahrzeugen) |
| M113A3 (M2, Mk19), Stryker M1126, Stryker M1134 (TOW) | nur als Elite-Fahrzeug |
| M113A3 (Medical) | erlaubt (Ausnahme bei Kettenfahrzeugen, frei kaufbar) |
| Kampfhubschrauber AH-1Z, leichter Kampfhubschrauber AH-6M | nur als Elite-Fahrzeug, je max. 1 gleichzeitig, 30 Min. Sperre nach Kauf |
| AH-64D | **ausgeschlossen** |
| **Artillerie** außer Mörsern (Panzerhaubitzen, Raketenwerfer, gezogenes Geschütz M119A2) | **ausgeschlossen** |
| **Jets** und Transportflugzeuge | **ausgeschlossen** |
| Kettenfahrzeuge (Kampf- und Schützenpanzer) | **ausgeschlossen** (Ausnahme M113A3: Medical frei, M2/Mk19 als Elite-Fahrzeug) |
| Große Drohnen, Luftabwehrsystem MIM-145, Boote | **ausgeschlossen** |

**Kopplung an die Miliz:** Die Miliz hat Kampfpanzer nur in der Hauptstadt und Altfahrzeuge bei Waffenlagern.
Die Spieler bekommen dafür Radpanzer (Stryker) über Militärposten, aber keine Kampfpanzer.

**Elite-Fahrzeuge:** Jeder der 6 Militärposten schaltet eines frei (Zuordnung ausgelost):
M113A3 (M2), M113A3 (Mk19), Stryker M1126, Stryker M1134, AH-1Z, AH-6M (ADR 0007, 0014).

**Die Miliz selbst:** Eigenes Preset auf Basis von Project OPFOR „Afghan Militia“ (ADR 0014):
Infanterie, Technicals, Motorräder, zivile Fahrzeuge, leichte statische Waffen und Mörser.
- Sektorverteidiger und Patrouillen: nur Technicals.
- Rüstung: Afghan Militia ist ungeschützt. Die Feld-Squads mischen gepanzerte Islamic-State-Kämpfer (Weste, Helm) nach Bereitschaft ein (25 % bei 30 bis 75 % bei 100), die Garnison bleibt ungeschützt (ADR 0014).
- Gegenangriffe: Technicals und Truppentransporter (Ural), höchstens 1 Altfahrzeug (BTR-60, M113; auch als Truppentransporter nutzbar).
- Waffenlager: 1–2 Altfahrzeuge. Hauptstadt: 2 T-72, 1 ZSU-23-4 (Abschnitt 9).
- Keine Luftangriffe, keine Hubschrauber (leere Listen im Preset).

## 11. Querschnitt

**Zeus**
- Zeus ist der **Kommandant** (Slot „Kommandant (Zeus)“, bei Liberation „Platoon Leader (Commander)“), kein eigener Spielleiter-Slot.
  Standardmäßig ohne Einschränkungen und mit Sicht auf Gegner (ADR 0010).
- Alle von der Mission erzeugten Einheiten, Fahrzeuge und Objekte werden automatisch allen
  Kuratoren als bearbeitbar hinzugefügt (gesammelte Funktion, nicht pro Skript).
- Debug-Modus (Lobby-Parameter „COIN Debug“, Standard aus): zeigt allen Spielern Nester (Farbe nach Typ, zerstörte
  ausgegraut), Einflussradien, Camps mit Linie zu ihrem Nest, die Netzwerkstärke, bei Intel-Markern wahr oder gelogen,
  die Nest-ID und den Ersatzpunkt einer Lüge, ab Phase 4 IEDs (Farbe nach Variante) und Auslöser auf der Karte.
  Schaltet zugleich die ausführlichen `[COIN]`-Logs ein.

**Slots (15)**
- Führungsgruppe: Kommandant (Zeus), 2 Dolmetscher
- Trupp A und Trupp B: je Truppführer, Sanitäter, EOD, 2 Schützen
- 2 Hubschrauberpiloten

**Performance (kein Headless Client)**
- **Budget für Gegner-KI** (ADR 0015): Liberations drei Obergrenzen bekommen einen gemeinsamen Wert (100 mal
  Unitcap-Faktor), die COIN-Einheiten kommen obendrauf. Nester spawnen immer vollständig, Camps nur innerhalb eines
  eigenen COIN-Budgets. Für Zivilisten zählen nur die eigenen der Bevölkerung (Ticket 3.7), nicht Liberations.
- Dazu eine Obergrenze für gleichzeitige IEDs. Auslöser, VBIED-Fahrer und Attentäter sind einzelne Einheiten, zählen als
  COIN-Einheiten und spawnen immer; die Kämpfer eines Hinterhalts zählen zum Camp-Budget.
- Spawnen nur im Umkreis von Spielern, wie bei Liberation.
- Startwerte (in Tests anpassen): Liberation ~100 Gegner-KI, Camps nur bis ~30 COIN-Einheiten insgesamt
  (Nest-Wachen eingerechnet), ~30 eigene Zivilisten, ~25 IEDs.

**Persistenz**
- Alle neuen Zustände (Nester, Intel-Marker, Budgets, Vorrat an Gefälligkeiten) werden über den
  **Liberation-Speichermechanismus** mitgespeichert, als zusätzlicher Block im Liberation-Spielstand.
  Kein eigenes zweites Speichersystem (ADR 0005). Der Ruf wird von Liberation selbst gespeichert.
- Die Mission speichert unter einem eigenen Namen, damit sie sich nicht mit dem normalen
  KP Liberation auf Lythium in die Quere kommt.
- Ausnahme: **Camps** werden bewusst nicht gespeichert (siehe Abschnitt 5.1), ebenso die Bedrohungen aus Abschnitt 6
  (IEDs, VBIEDs, Attentäter, Hinterhalte) und ihre Wartezeiten. Nach einem Neustart legen die aktiven Nester neu (ADR 0022).
  Auch Aufträge, Wartezeiten der Ortschaften und eine laufende Verstärkung werden nicht gespeichert (ADR 0023).

**Fraktionen**
- Armee: RHS USAF Desert (Liberation-Lythium-Standard).
- Miliz: eigenes Preset auf Basis „Afghan Militia“ (Abschnitt 10). Zivilisten: Liberation-Preset
  „Middle Eastern“.
- Umfang der Ausrüstung beider Seiten: siehe Abschnitt 10.

**Nicht im Umfang (vorerst)**
- Luftkrieg, Seekrieg, chemische Waffen
- Eigenes Wirtschaftssystem jenseits von Liberation
- PvP
- Code aus Hearts and Minds (ADR 0002)

## 12. Offene Entscheidungen

| # | Frage | Vorschlag / Ergebnis | Status |
|---|---|---|---|
| E1 | Welche Armee spielen die Spieler? | RHS USAF Desert | **entschieden** |
| E2 | Name und Erscheinung der Miliz | Fiktiver Name; Erscheinung: Project OPFOR „Afghan Militia“ (ADR 0014) | offen (Name) |
| E3 | Welche Stadt wird Hauptstadt, welches Gebiet? | Kalae Noowi, ganze Karte ausgedünnt (ADR 0016) | **entschieden** |
| E4 | Ruf global oder pro Ortschaft? | Global starten (Liberation-Ruf ist global, ADR 0009) | offen |
| E5 | Bauen sich Nester neu auf? | Ja, langsam, ab Phase 6 | offen |
| E6 | Reicht ein Dolmetscher-Slot oder zwei? | Zwei, in der Führungsgruppe | **entschieden** |
| E7 | Funktions-Präfix für eigenen Code | `COIN` (siehe ADR 0003) | **entschieden** |
| E8 | Regel für die Anzahl der Camps | Kapazität anteilig aus dem Gewicht der aktiven Nester (max. 10, geändert 2026-10-19), keine Camps nahe befreitem Gebiet | **entschieden** |
| E9 | Panzer für die Spieler? | Keine Kampfpanzer; Stryker M1126/M1134 als Elite-Fahrzeuge (ADR 0007) | **entschieden** |
| E10 | Welches schwere Gerät darf die Miliz haben? | Technicals überall, Altfahrzeuge bei Waffenlagern und max. 1 pro Gegenangriff, 2 T-72 + 1 ZSU-23-4 in der Hauptstadt (ADR 0014) | **entschieden** |
| E11 | Mörser und Hubschrauber für die Spieler? | Mörser ja, Hubschrauber außer AH-64D ja, AH-1Z/AH-6M nur als Elite mit Limit (ADR 0007) | **entschieden** |
| E12 | Unterstützung bei sehr hohem Ruf (Abschnitt 8.1) | Gefälligkeiten ab +50 über den Ältesten, kosten zusätzlich 10 Intel-Punkte; nur Verstärkung (per Funk gesteuert), Ablenkungsangriff gestrichen (ADR 0023) | **entschieden** |
| E13 | Dokumente als ACE Intel Items, die zum Dolmetscher gebracht werden müssen? | Nein, verworfen (2026-10-22): zu viele Hinweise ohne Bremse, dazu technische Risiken mit ACE (Index geht beim Weitergeben verloren). Die Spur vom Camp zum Nest läuft über das Verhör (Ticket 3.9, #66 geschlossen) | **entschieden** |
