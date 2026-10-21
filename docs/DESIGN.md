# Design: COIN Liberation (Arbeitstitel)

> Status: **Entwurf v0.4.4** – Grundlage für die Umsetzung mit Claude Code.
> v0.2: Entscheidungen aus Phase 0 eingearbeitet (ADR 0008–0015, `docs/kp-liberation-map.md`).
> v0.3: Spielfeld und Ausrüstung für Phase 1 festgelegt (ADR 0007, 0016), Abgleich mit Hearts and Minds.
> v0.3.1: Sektorauswahl von Hand ergänzt (ADR 0016), Ressourcen-Wirtschaft (ADR 0017).
> v0.4: Miliz-Netzwerk für Phase 2 festgelegt (Nester, Camps, Datenmodell, KI-Budget, ADR 0015 geändert).
> v0.4.1: Verteilung der Nester nach dem Prinzip „bester Kandidat“ mit Randabstand (Test 2026-10-20).
> v0.4.2: Mindestens 2 Nester pro Typ, Häuser passend zum Typ (Fläche, Gebäudepositionen, Klassenliste der VBIED-Garage).
> v0.4.3: Gebäude-Nester nach Templates pro Hausklasse und Nest-Typ (ADR 0019).
> v0.4.4: Gelände-Nester nach Templates mit Richtungspfeil, Hangneigung und Wachenring (ADR 0020).
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
    ein einfaches Platzhalter-Template. Ein Richtungspfeil markiert Mitte und „vorne“, der Seed wählt das Template und
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
  Ruf (Phase 5), Readiness-Abzug (Phase 6, ADR 0013) und Dokumente (Phase 3).
- Beim Zerstören besteht eine Chance auf **Intel-Gegenstände** (Dokumente), die auf ein anderes Nest zeigen.
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
Balancing-Änderungen auch in laufenden Kampagnen. Intel-Felder kommen in Phase 3 mit einer neuen `COIN_saveVersion`.

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
  Ausgehobene Camps liefern mit einer gewissen Chance Dokumente oder einen Gefangenen, die als Intel auf das
  zugehörige Nest zeigen.
- Ein Camp ist **ausgehoben**, wenn in seiner Nähe kein Kämpfer des Camps mehr kampffähig ist (tot, gefangen,
  ergeben oder geflohen), die Besatzung des Technicals eingeschlossen.
- KI und Objekte spawnen erst, wenn Spieler in der Nähe sind (gleiche Regeln wie bei Nestern). Ein Camp spawnt ganz
  oder gar nicht, nur wenn danach höchstens 30 COIN-Einheiten leben, Nest-Wachen eingerechnet (ADR 0015). Ist kein
  Platz, entsteht es, sobald wieder Platz ist.
- Der Technical eines Camps ist nicht gesperrt und kann erbeutet werden.
- Camps nutzen dieselbe Template-Mechanik wie Gelände-Nester, mit eigenen 2–3 Camp-Templates (ohne Kernobjekt).

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

Alle Bedrohungen werden aus Budgets gespeist, die an Nester gekoppelt sind. Ohne Werkstatt
keine IEDs, ohne Garage keine VBIEDs.

| Bedrohung | Ablauf | Hinweise für Spieler | Gegenmaßnahme |
|---|---|---|---|
| IED (vergraben) | An Straßen und Engstellen im Radius einer Werkstatt | Frisch aufgewühlte Erde, Müllhaufen, auffällig leere Straße | ACE-Minensucher, ACE-Entschärfen |
| IED (ferngezündet) | Mit Auslöser in Sichtweite | Zivilist mit Telefon, der beobachtet | Auslöser ausschalten, dann entschärfen |
| Attrappe | Wie IED, harmlos | – | Kostet Zeit, kein Schaden |
| VBIED | Ziviles Fahrzeug fährt auf Konvoi/FOB zu | Fahrer allein, ignoriert Warnungen, hält nicht an | Stoppen, Distanz, Feuer |
| Selbstmordattentäter | Zivilist nähert sich Gruppe | Ignoriert Aufforderungen, Hände verdeckt, zielstrebig | Befehl an Zivilisten (ACE „Get Down“/„Go Away“, ggf. eigenes „Stehen bleiben“), Distanz |
| Hinterhalt | Miliz-Gruppe an Straße mit vorbereiteter Stellung | Plötzlich keine Zivilisten mehr | Aufklärung, Routen wechseln |
| Kämpfer in Zivil | Unbewaffnet, bis Kontakt | Verhalten, Nähe zu Nestern | Vorsicht, Durchsuchen (ACE) |

- Das **Entschärfen** eines IEDs erhöht den Ruf.
- Befehle an Zivilisten kann jeder Spieler geben, ohne Dolmetscher (Gesten). Sie müssen im Interaktionsmenü
  für Spieler logisch auffindbar sein; reichen die ACE-Einträge dafür nicht, bauen wir eigene, einheitliche.
- Budgets und Häufigkeiten stehen in `coin_config.sqf` und sind ohne Code-Änderung anpassbar.
- Liberations eigene IEDs (in feindlichen Sektoren bei negativem Ruf) und Guerilla-Hinterhalte
  (in befreiten Ortschaften bei Ruf ≤ −25) werden **ersetzt** und sind per Schalter abschaltbar.
  Liberations Überfälle auf KI-Logistikkonvois bleiben (ADR 0008).

## 7. System C: Dolmetscher und Intel

**Dolmetscher**
- Zwei Slots in der Führungsgruppe beim Kommandanten.
- Befragen geht nur, wenn der Dolmetscher **selbst fragt oder höchstens ~5 m entfernt** steht.
- Fällt der Dolmetscher aus, gibt es keine Gespräche. Das macht ihn zu einem Schutzobjekt.

**Befragung (ACE-Interaktion „Befragen“ am Zivilisten)**
- **Jeder** Zivilist ist befragbar, auch die von Liberation in umkämpften Orten und auf Patrouille.
  Damit befreite Ortschaften nicht leer sind, spawnt die Mission dort bei Spielernähe eine eigene
  Bevölkerung, darunter den Ältesten (ADR 0011).
- Jeder Zivilist kann nur **einmal** befragt werden.
- Mögliche Ergebnisse, gewichtet nach Ruf:
  - „Ich weiß nichts.“
  - **Gerücht**: großer Kreis (z. B. 600 m) um ein Nest
  - **Hinweis**: mittlerer Kreis (z. B. 300 m)
  - **Konkreter Tipp**: kleiner Kreis (z. B. 100 m)
  - **Warnung**: IED oder Hinterhalt in der Nähe
  - **Lüge**: Kreis an einer falschen Stelle. Häufig bei niedrigem Ruf.
- Zusätzlich kann der Dolmetscher fragen, **wie die Bevölkerung zur Armee steht**. Die Antwort nennt das
  Ruf-Band in Worten (der Ruf wird nicht als Zahl angezeigt, siehe Abschnitt 8).
- **Triangulation:** Mehrere wahre Hinweise auf dasselbe Nest verkleinern den Kreis.
- Ergebnisse erscheinen als Kartenmarker für die ganze Seite und werden gespeichert.
- Wahre Marker eines zerstörten Nests verschwinden automatisch. Lügen-Marker bleiben, bis Spieler das
  Gebiet durchsucht haben, damit ihr Verschwinden nichts verrät.

**Weitere Intel-Quellen**
- **Gefangene verhören** (ACE-Fesseln plus Dolmetscher): überall möglich, einmal pro Gefangenem, höhere
  Chance auf konkrete Tipps. Liberations Belohnung für das Abliefern an der FOB (Intel-Punkte) bleibt zusätzlich.
- **Dokumente** bei toten Anführern, in zerstörten Nestern und ausgehobenen Camps.
  - *Option (E13):* Dokumente sind echte **ACE Intel Items** (Dokument/Foto) im Inventar.
    Sie müssen eingesammelt und zum **Dolmetscher** gebracht werden. Erst bei der Auswertung
    entsteht der Intel-Marker. Geht der Träger verloren, liegt das Dokument bei seiner Leiche.
    Hinweis: ACE Intel Items lassen sich laut ACE-Issues nur mit einer Karte im Inventar öffnen.
- **Informanten** (Liberation-Funktion): Ab Ruf +25 meldet sich gelegentlich ein Zivilist, der zu einer
  FOB gebracht werden muss. Liberation gibt dafür Intel-Punkte; wir ergänzen ein Intel zu einem aktiven Nest (ADR 0011).

**Intel und Intel-Punkte**
- „Intel“ meint immer unseren Hinweis auf ein Nest oder eine Bedrohung.
- Liberations Ressource heißt „Intel-Punkte“. Damit werden weiterhin die Nebenmissionen
  Konvoi-Überfall und Rettung bezahlt. Die Nebenmission „FOB Hunting“ entfällt, weil feindliche Basen
  neben den Nestern das Netzwerk verwässern würden.

## 8. System D: Bevölkerung und Ruf

Der Ruf **ist** Liberations „Civil Reputation“: ein globaler Wert von **−100 bis +100** (ADR 0009).

| Ruf steigt | Ruf sinkt |
|---|---|
| IED entschärfen | Zivilist getötet¹ oder verletzt |
| Nest zerstören | Gebäude zerstört² |
| Ortschaft befreien¹ | Grundloses Schießen nahe Zivilisten |
| Verwundeten Zivilisten helfen (ACE)¹ | Gefangene oder sich ergebende Gegner töten |
| Informant zur FOB gebracht¹ | Zivilfahrzeug beschlagnahmt¹ oder zerstört |
| *Später:* Hilfsgüter liefern | Befreundeten Widerstandskämpfer getötet¹ |

¹ macht Liberation bereits. Wir ziehen dafür nicht doppelt ab.
² Liberation rechnet Gebäudeschäden nur bei der Einnahme einer Ortschaft ab. Zusätzlich kostet ein Gebäude
in einer **befreiten** Ortschaft Ruf, wenn die Armee es zerstört hat.

**Ruf-Bänder**

| Band | Ruf | Bedeutung |
|---|---|---|
| niedrig | < 0 | Viele Lügen, kleine Wahrheitsquote |
| mittel | 0 bis < 25 | Gemischte Ergebnisse |
| hoch | ≥ 25 | Gute Intel, Informanten erscheinen, Widerstand steht auf unserer Seite |

- **Start: −20.** Zu Beginn lügen viele Zivilisten. Das zwingt zum Aufbau von Vertrauen.
  Der Widerstand ist bei −20 noch neutral (feindlich erst unter −25).
- **Keine Zahl im Overlay.** Spieler erfahren den Ruf, indem der Dolmetscher die Bevölkerung fragt (Abschnitt 7).
- Ruf wirkt auf: Wahrheitsquote und Kreisgröße bei Intel, Häufigkeit der Informanten (steigt mit dem Ruf,
  unter +25 keine), Häufigkeit von Attentätern unter Zivilisten.
- Der Ruf bleibt **global**, wie bei Liberation. Ruf pro Ortschaft wäre eine spätere Erweiterung (E4).

### 8.1 Unterstützung bei sehr hohem Ruf (Vorschlag)

Wer die Bevölkerung wirklich auf seiner Seite hat, bekommt mehr als nur Informationen:
**lokale Kämpfer** (dorfeigene Wachen, Stammeskämpfer) helfen aktiv mit.

**Gefälligkeiten**
- Ab einer hohen Ruf-Schwelle (etwa +50, final im Spec zu Phase 5) sammelt die Armee **Gefälligkeiten**, z. B. 1 pro 2 Stunden Spielzeit.
- Höchstens 2 auf Vorrat. Fällt der Ruf unter die Schwelle, wächst nichts nach.
- Angefordert wird über den **Dolmetscher** beim Ältesten einer befreiten Ortschaft (ACE-Interaktion).
  Das hält die Rolle bis zum Ende der Kampagne wichtig.

| Gefälligkeit | Ablauf | Wirkung |
|---|---|---|
| **Ablenkungsangriff** | Spieler wählen auf der Karte ein Ziel (Camp, Ortschaft der Miliz) und einen Zeitpunkt. Lokale Kämpfer greifen dort an. | Miliz-Gruppen und Eingreiftruppen der Umgebung werden für 15–20 Min. dorthin abgezogen. Das eigentliche Ziel der Spieler ist in dieser Zeit schwächer besetzt. |
| **Verstärkung** | Eine Gruppe von 4–6 lokalen Kämpfern stößt am Standort des Ältesten zur Armee. | Die Gruppe folgt einem Spieler-Gruppenführer, bis sie aufgerieben ist, die Region verlassen wird oder 60 Min. vorbei sind. |

- Sterben die lokalen Kämpfer, gibt es keinen Ruf-Abzug, aber eine längere Wartezeit bis zur nächsten Gefälligkeit.
  (Tötet die Armee sie selbst, zieht Liberation Ruf ab.)
- Lokale Kämpfer sind Einheiten von Liberations **Widerstand** (ADR 0012). Dessen Haltung hängt global am Ruf:
  ab +25 auf unserer Seite, darunter neutral, unter −25 auf Seiten der Miliz.
  **Fällt der Ruf unter +25, ziehen aktive lokale Kämpfer ab.**
- Erkennungszeichen: Alle KI-Kämpfer von Miliz und Widerstand tragen ein farbiges Kopftuch (Shemag): **rot = Miliz**,
  **grün = Widerstand, feindlich** (Ruf unter −25), **blau = Widerstand, neutral oder freundlich**. Die Farbe folgt dem
  Ruf live, auch bei bereits lebenden Kämpfern. Die Spieler lesen das im Karten-Tagebuch „COIN Liberation“ (ADR 0012, 0014).
- Liberations spontane Guerilla-Einsätze bleiben: Bei hohem Ruf stoßen gelegentlich Widerstandskämpfer
  zu unseren Sektorangriffen, bei Ruf unter −25 kämpfen sie für die Miliz.

### 8.2 Aufträge

Neben Liberations **Nebenmissionen** (Konvoi-Überfall, Rettung, mit Intel-Punkten gekauft) gibt es eigene
**Aufträge** in zwei Arten. Sie werden nicht gespeichert und verfallen beim Serverneustart.
Scheitern oder Abbruch kosten nichts.

| | Hilfsauftrag | Aufklärungsauftrag |
|---|---|---|
| Woher | Der Dolmetscher spricht mit dem Ältesten einer befreiten Ortschaft. Gibt es gerade keinen Auftrag, heißt es „Kommt später wieder“. | Entsteht mit gewisser Chance als Ergebnis einer Befragung oder eines Verhörs. |
| Verfügbarkeit | In jedem Ruf-Band. Pro Ortschaft 1 Angebot, danach Wartezeit; höchstens 2 gleichzeitig aktiv. | Zeitfenster (z. B. 30–60 Min.); höchstens 1 gleichzeitig aktiv. |
| Belohnung | Ruf | Intel (Konkreter Tipp), teils sinkende Readiness |

**Hilfsaufträge (erste Welle)**
- **Hilfsgüter liefern:** eine Liberation-Supply-Kiste in die Ortschaft bringen (kostet Supplies).
- **Arzt-Einsatz:** 3–5 kranke oder verletzte Zivilisten versorgen. Die Patienten können nicht sterben,
  auch nicht durch Querschläger. Behandelt wird über eine eigene Aktion „Behandeln“ (nur Sanitäter, verbraucht
  Material). Ruf pro Patient, Bonus für den ganzen Einsatz. Läuft die Zeit ab, gibt es nur keinen Bonus.
- **Infrastruktur reparieren:** einen beschädigten Generator oder Brunnen instand setzen (EOD/Pionier).
- *Später:* Straße räumen (nach Phase 4), Entführte befreien.

**Aufklärungsaufträge (erste Welle)**
- **Kurier abfangen:** Ein Fahrzeug mit Dokumenten fährt in einem Zeitfenster eine bekannte Strecke.
- **Anführer festnehmen:** Ein Miliz-Anführer ist zu einer Zeit an einem Ort und muss lebend gefangen werden.
  Zusätzlich sinkt die Readiness um 10 %.
- **Waffentransport abfangen:** Ein Lkw ist unterwegs zu einem Waffenlager. Readiness −10 %, Hinweis auf das Ziel-Lager.

Liberations HVT-Aufgabe nach Informanten bleibt unverändert daneben bestehen.

## 9. System E: Gegenangriffe und Hauptstadt

- Liberation-Gegenangriffe auf eingenommene Sektoren bleiben, werden aber **asymmetrisch**:
  Technicals und Infanterie, höchstens **ein Altfahrzeug** pro Gegenangriff, keine Kampfpanzer.
  Dazu Mörserbeschuss auf FOBs und Überfälle auf Konvois.
- Gegenangriffe starten nur aus Regionen mit aktivem **Kommandoposten**. Kommandoposten sind auch die
  Quelle für Verstärkung angegriffener Miliz-Sektoren; Liberations Funktürme entfallen (ADR 0013).
- Die **Netzwerkstärke deckelt Liberations Readiness**: Je weniger Nester aktiv sind, desto niedriger der
  Höchstwert. Zusätzlich **senkt jedes zerstörte Nest die Readiness sofort** (z. B. um 10, Kommandoposten 20),
  einige Aufklärungsaufträge um 10 %. Die Readiness bleibt im Overlay sichtbar (ADR 0013).
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
  ausgegraut), Einflussradien, Camps mit Linie zu ihrem Nest, die Netzwerkstärke und später IEDs auf der Karte.
  Schaltet zugleich die ausführlichen `[COIN]`-Logs ein.

**Slots (15)**
- Führungsgruppe: Kommandant (Zeus), 2 Dolmetscher
- Trupp A und Trupp B: je Truppführer, Sanitäter, EOD, 2 Schützen
- 2 Hubschrauberpiloten

**Performance (kein Headless Client)**
- **Budget für Gegner-KI** (ADR 0015): Liberations drei Obergrenzen bekommen einen gemeinsamen Wert (100 mal
  Unitcap-Faktor), die COIN-Einheiten kommen obendrauf. Nester spawnen immer vollständig, Camps nur innerhalb eines
  eigenen COIN-Budgets. Für Zivilisten gilt ein gemeinsamer Wert, geregelt ab Phase 3.
- Dazu eine Obergrenze für gleichzeitige IEDs.
- Spawnen nur im Umkreis von Spielern, wie bei Liberation.
- Startwerte (in Tests anpassen): Liberation ~100 Gegner-KI, Camps nur bis ~30 COIN-Einheiten insgesamt
  (Nest-Wachen eingerechnet), ~30 Zivilisten, ~25 IEDs.

**Persistenz**
- Alle neuen Zustände (Nester, Intel-Marker, Budgets) werden über den
  **Liberation-Speichermechanismus** mitgespeichert, als zusätzlicher Block im Liberation-Spielstand.
  Kein eigenes zweites Speichersystem (ADR 0005). Der Ruf wird von Liberation selbst gespeichert.
- Die Mission speichert unter einem eigenen Namen, damit sie sich nicht mit dem normalen
  KP Liberation auf Lythium in die Quere kommt.
- Ausnahme: **Camps** werden bewusst nicht gespeichert (siehe Abschnitt 5.1).

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
| E12 | Unterstützung bei sehr hohem Ruf (Abschnitt 8.1) | Gefälligkeiten über den Ältesten: Ablenkungsangriff und Verstärkung | vorgeschlagen |
| E13 | Dokumente als ACE Intel Items, die zum Dolmetscher gebracht werden müssen? | Option für Phase 3, Entscheidung beim Spec von Ticket 3.6 | offen |
