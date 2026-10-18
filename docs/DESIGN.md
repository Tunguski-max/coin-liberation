# Design: COIN Liberation (Arbeitstitel)

> Status: **Entwurf v0.2** – Grundlage für die Umsetzung mit Claude Code.
> v0.2: Entscheidungen aus Phase 0 eingearbeitet (ADR 0008–0015, `docs/kp-liberation-map.md`).
> Offene Entscheidungen stehen gesammelt in [Abschnitt 12](#12-offene-entscheidungen).
> Begriffe sind in [`CONTEXT.md`](../CONTEXT.md) definiert.

---

## 1. Vision in einem Satz

Ein persistenter Coop-Modus für **5–10 Spieler** auf **Lythium**: Eine Taliban-ähnliche
Miliz hat eine Stadt zu ihrer Hauptstadt gemacht und baut von dort ein Netzwerk aus
Verstecken, IED-Werkstätten und Waffenlagern auf. Die Spieler sind die Armee, die dieses
Netzwerk mit Hilfe der Bevölkerung **aufspürt und zerschlägt**, bevor sie die Hauptstadt stürmt.

**Basis:** KP Liberation (Logistik, FOBs, Ressourcen, Sektoren, Speichern).
**Zusatzschicht im Stil von Hearts and Minds:** Dolmetscher, Intel von Zivilisten, Ruf,
IEDs, VBIEDs, Selbstmordattentäter, Hinterhalte.

## 2. Design-Säulen

1. **Aufklärung vor Feuerkraft.** Wer nur stürmt, kämpft gegen einen voll versorgten Gegner.
   Wer vorher Intel sammelt und Nester ausschaltet, kämpft gegen einen geschwächten.
2. **Die Bevölkerung ist das Schlachtfeld.** Ruf entscheidet, ob Zivilisten reden, lügen
   oder schweigen. Kollateralschäden haben spürbare Folgen.
3. **Gefahr ist lesbar.** IEDs, VBIEDs und Attentäter zeigen Hinweise, auf die aufmerksame
   Spieler reagieren können. Kein Tod ohne Chance.
4. **Klein und dicht statt groß und leer.** Ein Kartenausschnitt, den 5–10 Leute in
   mehreren Wochen Spielzeit realistisch befreien können.
5. **Zeus bleibt Herr im Haus.** Alles, was die Mission erzeugt, kann Zeus sehen, ändern und löschen.

## 3. Spielfeld

| Element | Anzahl | Herkunft | Zweck |
|---|---|---|---|
| Hauptstadt | 1 | Liberation-Sektor (Typ „Hauptstadt“) | Finales Ziel, Sitz der Miliz |
| Ortschaften | 15–20 | Liberation-Sektoren (Städte/Dörfer) | Einnehmen, halten, Bevölkerung gewinnen |
| Supply Points | 3–5 | Liberation-Fabriken/Ressourcen-Sektoren | Ressourcen-Produktion |
| Militärische Posten | 2–4 | Liberation-Militärsektoren | Optionale harte Ziele, schalten Elite-Fahrzeuge frei (ADR 0014) |
| Miliz-Nester | 8–14 | **neu** (siehe Abschnitt 5) | Verdeckt, nur über Intel auffindbar |
| Miliz-Camps | bis 10 gleichzeitig | **neu** (siehe Abschnitt 5.1) | Zufällig im Gelände, Spur zu den Nestern |
| Startbasis | 1 | Liberation-Startpunkt | Am Rand des Spielfelds |

- Der Ausschnitt wird in Phase 1 gemeinsam auf der Karte festgelegt (Radius grob 5–8 km um die Hauptstadt).
- Alle Liberation-Sektoren außerhalb des Ausschnitts werden aus der `mission.sqm` entfernt, ebenso die
  Spawnpunkte der Miliz (`opfor_point`, `opfor_airspawn`). Sonst kommen Gegenangriffe und Patrouillen von außerhalb.
- **Keine Funktürme** im Ausschnitt (ADR 0013): Sie würden Nester und Camps auf der Karte verraten.
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
| Waffenlager | Verstärkt Garnisonen und Ausrüstung | Garnisonen kleiner, weniger schwere Waffen |
| VBIED-Garage | Ermöglicht VBIED-Ereignisse | Keine VBIEDs mehr im Radius |
| Rekrutierungsstelle | Füllt Verluste der Miliz wieder auf | Miliz regeneriert langsamer |

**Regeln**
- Nester stehen in Gebäuden in Ortschaften oder als kleine Lager im Gelände. Leichte Bewachung.
- Nester sind **nicht** auf der Karte markiert. Nur Intel macht sie sichtbar (siehe System C).
- Jedes Nest zählt zur **Netzwerkstärke**. Die Garnison der Hauptstadt skaliert damit:
  `Garnison = Basis × (1 + Faktor × verbleibende Nester)`.
- Ein Nest gilt als zerstört, wenn sein Kernobjekt zerstört ist (z. B. Waffenkiste, Werkbank, Funkgerät).
- Beim Zerstören besteht eine Chance auf **Intel-Gegenstände** (Dokumente), die auf ein anderes Nest zeigen.
- *Später/optional:* Bei niedrigem Ruf kann die Miliz in Regionen ohne Spielerpräsenz langsam
  neue Nester aufbauen. Das hält das Netzwerk lebendig.

**Datenmodell (Server, persistent)** – Vorschlag, wird in Phase 2 festgelegt:
```
[id, typ, position, einflussradius, zustand ("aktiv"|"zerstört"), intel_level, ...]
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
- Gebiet: Kartenausschnitt plus eine **Randzone von 1–2 km**.
- Platzierung zufällig auf ebenem Gelände mit Deckung, mit Mindestabstand zu Straßen,
  Ortschaften, FOBs und der Startbasis.
- Nicht persistent. Beim Serverstart wird die aktuelle Kapazität (siehe unten) neu verteilt.
- Jedes Camp **gehört zu einem Nest**. Ausgehobene Camps liefern mit einer gewissen Chance
  Dokumente oder einen Gefangenen, die als Intel auf das zugehörige Nest zeigen.
- KI und Objekte spawnen erst, wenn Spieler in der Nähe sind.

**Wie viele Camps es gibt (Vorschlag, Entscheidung E8)**

Die Anzahl hängt von zwei Dingen ab, die beide den Spielfortschritt abbilden:

1. **Kapazität aus den Nestern.** Jedes aktive Nest „versorgt“ eine Anzahl Camps:
   Kommandoposten und Rekrutierungsstelle je 2, alle anderen Nest-Typen je 1.
   Die Summe ist die Kapazität, gedeckelt bei 10.
   Wird ein Nest zerstört, verschwinden seine Camps beim nächsten Abbau und es kommen keine neuen nach.
   *Beispiel:* Zu Beginn mit 11 Nestern liegt die Kapazität rechnerisch bei 15, gedeckelt also bei 10. Sind noch 4 Nester übrig, sind es etwa 5 Camps, am Ende nur noch 1–2.
2. **Befreites Gebiet ist tabu.** Im Umkreis von 1 km um eingenommene Sektoren und um FOBs
   entstehen keine Camps. Je weiter ihr vorrückt, desto mehr werden die Camps Richtung Hauptstadt gedrängt.

**Nachschub und Wechsel**
- Ein zerstörtes Camp wird nach 30–60 Minuten an anderer Stelle ersetzt, sofern noch Kapazität frei ist.
- Unentdeckte Camps werden nach 2–3 Stunden abgebaut und tauchen woanders neu auf.
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
| Selbstmordattentäter | Zivilist nähert sich Gruppe | Ignoriert Aufforderungen, Hände verdeckt, zielstrebig | Anhalten lassen (ACE-Geste), Distanz |
| Hinterhalt | Miliz-Gruppe an Straße mit vorbereiteter Stellung | Plötzlich keine Zivilisten mehr | Aufklärung, Routen wechseln |
| Kämpfer in Zivil | Unbewaffnet, bis Kontakt | Verhalten, Nähe zu Nestern | Vorsicht, Durchsuchen (ACE) |

- Das **Entschärfen** eines IEDs erhöht den Ruf.
- Budgets und Häufigkeiten stehen in `coin_config.sqf` und sind ohne Code-Änderung anpassbar.
- Liberations eigene IEDs (in feindlichen Sektoren bei negativem Ruf) und Guerilla-Hinterhalte
  (in befreiten Ortschaften bei Ruf ≤ −25) werden **ersetzt** und sind per Schalter abschaltbar.
  Liberations Überfälle auf KI-Logistikkonvois bleiben (ADR 0008).

## 7. System C: Dolmetscher und Intel

**Dolmetscher**
- Eigene Rolle (Slot) in der Lobby. Optional zweiter Slot als Ersatz.
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
- **Triangulation:** Mehrere wahre Hinweise auf dasselbe Nest verkleinern den Kreis.
- Ergebnisse erscheinen als Kartenmarker für die ganze Seite und werden gespeichert.

**Weitere Intel-Quellen**
- **Gefangene verhören** (ACE-Fesseln plus Dolmetscher): höhere Chance auf konkrete Tipps.
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
- Lokale Kämpfer tragen eine erkennbare Kleidung, damit sie nicht mit der Miliz verwechselt werden (ADR 0014).
- Liberations spontane Guerilla-Einsätze bleiben: Bei hohem Ruf stoßen gelegentlich Widerstandskämpfer
  zu unseren Sektorangriffen, bei Ruf unter −25 kämpfen sie für die Miliz.

## 9. System E: Gegenangriffe und Hauptstadt

- Liberation-Gegenangriffe auf eingenommene Sektoren bleiben, werden aber **asymmetrisch**:
  Technicals und Infanterie statt Panzern, Mörserbeschuss auf FOBs, Überfälle auf Konvois.
- Gegenangriffe starten nur aus Regionen mit aktivem **Kommandoposten**. Kommandoposten sind auch die
  Quelle für Verstärkung angegriffener Miliz-Sektoren; Liberations Funktürme entfallen (ADR 0013).
- Die **Netzwerkstärke deckelt Liberations Readiness**: Je weniger Nester aktiv sind, desto niedriger der
  Höchstwert. Das macht ein geschwächtes Netzwerk auf der ganzen Karte spürbar (ADR 0013).
- **Hauptstadt:** Garnisonsstärke skaliert mit dem Restnetzwerk (siehe Abschnitt 5).
  Bei 0 verbleibenden Nestern: Mindestbesetzung. Bei vollem Netzwerk: praktisch nicht einnehmbar.
- Einnahme der Hauptstadt = Kampagnensieg.

## 10. Ausrüstung: leichte Brigade

Die Armee ist eine **leichte Brigade**, keine schwere Streitmacht. Die Bau- und Kauflisten von
Liberation werden über ein eigenes BLUFOR-Preset stark reduziert. Siehe ADR 0007.

| Kategorie | Status |
|---|---|
| Infanterie, Scharfschützen, Pioniere, Sanitäter | erlaubt |
| Geschützte Radfahrzeuge (MRAP), leichte Transporter, Logistik-Lkw | erlaubt |
| Statische Waffen (MG, Granatmaschinenwerfer) | erlaubt |
| Kleine Aufklärungsdrohnen | erlaubt (Vorschlag) |
| Statische Mörser | offen (E11) |
| Hubschrauber (Transport, MEDEVAC) | offen (E11) |
| Kampfhubschrauber | offen (E11), Vorschlag: nein |
| **Fahrbare Artillerie** (Panzerhaubitzen, Raketenwerfer) | **ausgeschlossen** |
| **Jets** | **ausgeschlossen** |
| Kampf- und Schützenpanzer | offen (E9), hängt an E10 |

**Kopplung an die Miliz (Vorschlag):** Die Ausrüstung der Spieler richtet sich nach der Miliz.
- Hat die Miliz keine Panzer, haben die Spieler auch keine.
- Hat die Miliz einzelne erbeutete Altfahrzeuge (z. B. 1–2 alte Schützenpanzer in der Hauptstadt
  oder in Waffenlagern), dürfen die Spieler wenige Schützenpanzer zu hohen Ressourcenkosten bauen.

**Elite-Fahrzeuge:** Militärposten schalten wertvolles, aber erlaubtes Gerät frei (z. B. schwer bewaffnete
MRAPs, Transport-Hubschrauber, wenige Schützenpanzer nach E9). Die Liste wird mit E9/E11 in Ticket 1.6 festgelegt (ADR 0014).

**Die Miliz selbst:** Eigenes Preset auf Basis von Project OPFOR „Afghan Militia“ (ADR 0014):
Infanterie, Technicals, Motorräder, zivile Fahrzeuge, leichte statische Waffen und Mörser.
Keine Luftangriffe und keine Panzerverbände (Details E10).
Liberations Luftangriffe und schwere Gegenangriffe werden über das Miliz-Preset abgeschaltet
(leere Listen für Flugzeuge und Hubschrauber, keine Panzer in den Fahrzeuglisten).

## 11. Querschnitt

**Zeus**
- Zeus ist der **Kommandant** (Liberation-Slot „Platoon Leader (Commander)“), kein eigener Spielleiter-Slot.
  Standardmäßig ohne Einschränkungen und mit Sicht auf Gegner (ADR 0010).
- Alle von der Mission erzeugten Einheiten, Fahrzeuge und Objekte werden automatisch allen
  Kuratoren als bearbeitbar hinzugefügt (gesammelte Funktion, nicht pro Skript).
- Debug-Modus (Parameter): Nester, Einflussradien und IEDs auf der Karte anzeigen.

**Performance (kein Headless Client)**
- **Gemeinsames Budget** pro Kategorie (Gegner-KI, Zivilisten): Ein Gesamtwert gilt für Liberation
  und COIN zusammen. Liberations eigene Obergrenzen werden daraus abgeleitet (ADR 0015).
- Dazu eine Obergrenze für gleichzeitige IEDs.
- Spawnen nur im Umkreis von Spielern, wie bei Liberation.
- Startwerte (in Tests anpassen): max. ~80 Gegner-KI, ~30 Zivilisten, ~25 IEDs.

**Persistenz**
- Alle neuen Zustände (Nester, Intel-Marker, Budgets) werden über den
  **Liberation-Speichermechanismus** mitgespeichert, als zusätzlicher Block im Liberation-Spielstand.
  Kein eigenes zweites Speichersystem (ADR 0005). Der Ruf wird von Liberation selbst gespeichert.
- Die Mission speichert unter einem eigenen Namen, damit sie sich nicht mit dem normalen
  KP Liberation auf Lythium in die Quere kommt.
- Ausnahme: **Camps** werden bewusst nicht gespeichert (siehe Abschnitt 5.1).

**Fraktionen**
- Ausgangspunkt: die Lythium-Fassung von Liberation (RHS USAF gegen Project OPFOR „Islamic State“).
- Miliz: eigenes Preset auf Basis „Afghan Militia“ (Abschnitt 10). Zivilisten: Liberation-Preset
  „Middle Eastern“. BLUFOR-Wahl ist offen (E1).
- Umfang der Ausrüstung beider Seiten: siehe Abschnitt 10.

**Nicht im Umfang (vorerst)**
- Die gesamte Karte
- Luftkrieg, Seekrieg, chemische Waffen
- Eigenes Wirtschaftssystem jenseits von Liberation
- PvP

## 12. Offene Entscheidungen

| # | Frage | Vorschlag | Status |
|---|---|---|---|
| E1 | Welche Armee spielen die Spieler? | RHS USAF (Liberation-Lythium-Standard) zum Start | offen |
| E2 | Name und Erscheinung der Miliz | Fiktiver Name; Erscheinung: Project OPFOR „Afghan Militia“ (ADR 0014) | offen (Name) |
| E3 | Welche Stadt wird Hauptstadt, welcher Ausschnitt? | Gemeinsam in Phase 1 festlegen | offen |
| E4 | Ruf global oder pro Ortschaft? | Global starten (Liberation-Ruf ist global, ADR 0009) | offen |
| E5 | Bauen sich Nester neu auf? | Ja, langsam, ab Phase 6 | offen |
| E6 | Reicht ein Dolmetscher-Slot oder zwei? | Zwei (Haupt + Ersatz) | offen |
| E7 | Funktions-Präfix für eigenen Code | `COIN` (siehe ADR 0003) | **entschieden** |
| E8 | Regel für die Anzahl der Camps | Kapazität aus aktiven Nestern (max. 10), keine Camps nahe befreitem Gebiet | **entschieden** |
| E9 | Panzer für die Spieler? | Nur wenn die Miliz Panzer hat, dann wenige und teuer | offen |
| E10 | Welches schwere Gerät darf die Miliz haben? | Technicals und Mörser aus „Afghan Militia“; optional 1–2 erbeutete Altfahrzeuge (z. B. BTR-60, M113) | offen |
| E11 | Mörser und Hubschrauber für die Spieler? | Mörser ja, Transport-/MEDEVAC-Hubschrauber ja, keine Kampfhubschrauber | offen |
| E12 | Unterstützung bei sehr hohem Ruf (Abschnitt 8.1) | Gefälligkeiten über den Ältesten: Ablenkungsangriff und Verstärkung | vorgeschlagen |
| E13 | Dokumente als ACE Intel Items, die zum Dolmetscher gebracht werden müssen? | Option für Phase 3, Entscheidung beim Spec von Ticket 3.6 | offen |
