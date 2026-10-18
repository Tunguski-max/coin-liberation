# Design: COIN Liberation (Arbeitstitel)

> Status: **Entwurf v0.1** – Grundlage für die Umsetzung mit Claude Code.
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
| Militärische Posten | 2–4 | Liberation-Militärsektoren | Optionale harte Ziele |
| Miliz-Nester | 8–14 | **neu** (siehe Abschnitt 5) | Verdeckt, nur über Intel auffindbar |
| Miliz-Camps | bis 10 gleichzeitig | **neu** (siehe Abschnitt 5.1) | Zufällig im Gelände, Spur zu den Nestern |
| Startbasis | 1 | Liberation-Startpunkt | Am Rand des Spielfelds |

- Der Ausschnitt wird in Phase 1 gemeinsam auf der Karte festgelegt (Radius grob 5–8 km um die Hauptstadt).
- Alle Liberation-Sektoren außerhalb des Ausschnitts werden aus der `mission.sqm` entfernt.
- Siegbedingung: Hauptstadt eingenommen (nicht: alle Sektoren).

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
| Kommandoposten | Steuert Patrouillen und Gegenangriffe | Keine Gegenangriffe mehr aus dieser Region, weniger Patrouillen |
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
- Liberation bringt laut Changelog eigene asymmetrische Bedrohungen (IEDs, Guerilla-Hinterhalte) mit.
  **In Phase 0 prüfen**, was davon nutzbar ist. Ziel: ausbauen statt doppelt bauen.

## 7. System C: Dolmetscher und Intel

**Dolmetscher**
- Eigene Rolle (Slot) in der Lobby. Optional zweiter Slot als Ersatz.
- Befragen geht nur, wenn der Dolmetscher **selbst fragt oder höchstens ~5 m entfernt** steht.
- Fällt der Dolmetscher aus, gibt es keine Gespräche. Das macht ihn zu einem Schutzobjekt.

**Befragung (ACE-Interaktion „Befragen“ am Zivilisten)**
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
- **Informanten** (Liberation-Funktion, falls vorhanden): Zivilist meldet sich selbst.

## 8. System D: Bevölkerung und Ruf

Ausgangspunkt ist das Ruf-System von Liberation (laut Changelog vorhanden, in Phase 0 prüfen).

| Ruf steigt | Ruf sinkt |
|---|---|
| IED entschärfen | Zivilist getötet oder verletzt |
| Nest zerstören | Gebäude zerstört |
| Ortschaft befreien | Grundloses Schießen nahe Zivilisten |
| Verwundeten Zivilisten helfen (ACE) | Gefangene oder sich ergebende Gegner töten |
| *Später:* Hilfsgüter liefern | Zivilfahrzeuge zerstört |

- **Start: niedrig.** Zu Beginn lügen viele Zivilisten. Das zwingt zum Aufbau von Vertrauen.
- Ruf wirkt auf: Wahrheitsquote und Kreisgröße bei Intel, Anzahl Informanten,
  Häufigkeit von Attentätern unter Zivilisten.
- Offene Frage: ein **globaler** Ruf (einfach, wie Liberation) oder **pro Ortschaft** (taktischer, aufwendiger).
  Vorschlag: global starten, pro Ortschaft als spätere Erweiterung.

### 8.1 Unterstützung bei sehr hohem Ruf (Vorschlag)

Wer die Bevölkerung wirklich auf seiner Seite hat, bekommt mehr als nur Informationen:
**lokale Kämpfer** (dorfeigene Wachen, Stammeskämpfer) helfen aktiv mit.

**Gefälligkeiten**
- Ab einer hohen Ruf-Schwelle sammelt die Armee **Gefälligkeiten**, z. B. 1 pro 2 Stunden Spielzeit.
- Höchstens 2 auf Vorrat. Fällt der Ruf unter die Schwelle, wächst nichts nach.
- Angefordert wird über den **Dolmetscher** beim Ältesten einer befreiten Ortschaft (ACE-Interaktion).
  Das hält die Rolle bis zum Ende der Kampagne wichtig.

| Gefälligkeit | Ablauf | Wirkung |
|---|---|---|
| **Ablenkungsangriff** | Spieler wählen auf der Karte ein Ziel (Camp, Ortschaft der Miliz) und einen Zeitpunkt. Lokale Kämpfer greifen dort an. | Miliz-Gruppen und Eingreiftruppen der Umgebung werden für 15–20 Min. dorthin abgezogen. Das eigentliche Ziel der Spieler ist in dieser Zeit schwächer besetzt. |
| **Verstärkung** | Eine Gruppe von 4–6 lokalen Kämpfern stößt am Standort des Ältesten zur Armee. | Die Gruppe folgt einem Spieler-Gruppenführer, bis sie aufgerieben ist, die Region verlassen wird oder 60 Min. vorbei sind. |

- Sterben die lokalen Kämpfer, gibt es keinen Ruf-Abzug, aber eine längere Wartezeit bis zur nächsten Gefälligkeit.
- Liberation hat laut Changelog eine eigene **Guerilla/Widerstand**-Fraktion, deren Haltung vom Ruf
  abhängt. **In Phase 0 prüfen**, ob wir diese Fraktion für die lokalen Kämpfer nutzen können.

## 9. System E: Gegenangriffe und Hauptstadt

- Liberation-Gegenangriffe auf eingenommene Sektoren bleiben, werden aber **asymmetrisch**:
  Technicals und Infanterie statt Panzern, Mörserbeschuss auf FOBs, Überfälle auf Konvois.
- Gegenangriffe starten nur aus Regionen mit aktivem **Kommandoposten**.
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

**Die Miliz selbst (Vorschlag):** Infanterie, Technicals, Motorräder, zivile Fahrzeuge,
leichte statische Waffen und Mörser. Keine Luftangriffe und keine Panzerverbände.
Die entsprechenden Liberation-Funktionen (Luftangriffe, schwere Battlegroups) werden über das
Miliz-Preset und die Config abgeschaltet.

## 11. Querschnitt

**Zeus**
- Alle von der Mission erzeugten Einheiten, Fahrzeuge und Objekte werden automatisch allen
  Kuratoren als bearbeitbar hinzugefügt (gesammelte Funktion, nicht pro Skript).
- Debug-Modus (Parameter): Nester, Einflussradien und IEDs auf der Karte anzeigen.

**Performance (kein Headless Client)**
- Harte Obergrenzen in der Config: aktive Miliz-KI, Zivilisten, IEDs gleichzeitig.
- Spawnen nur im Umkreis von Spielern, wie bei Liberation.
- Startwerte (in Tests anpassen): max. ~80 aktive Miliz-KI, ~30 Zivilisten, ~25 IEDs.

**Persistenz**
- Alle neuen Zustände (Nester, Intel-Marker, Budgets, Ruf) werden über den
  **Liberation-Speichermechanismus** mitgespeichert. Kein eigenes zweites Speichersystem.
- Ausnahme: **Camps** werden bewusst nicht gespeichert (siehe Abschnitt 5.1).

**Fraktionen**
- Ausgangspunkt: die Lythium-Fassung von Liberation (RHS USAF gegen Project OPFOR).
- Miliz und Zivilisten über Liberation-Presets; BLUFOR-Wahl ist offen.
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
| E2 | Name und Erscheinung der Miliz | Fiktiver Name, Project-OPFOR-Fraktion | offen |
| E3 | Welche Stadt wird Hauptstadt, welcher Ausschnitt? | Gemeinsam in Phase 1 festlegen | offen |
| E4 | Ruf global oder pro Ortschaft? | Global starten | offen |
| E5 | Bauen sich Nester neu auf? | Ja, langsam, ab Phase 6 | offen |
| E6 | Reicht ein Dolmetscher-Slot oder zwei? | Zwei (Haupt + Ersatz) | offen |
| E7 | Funktions-Präfix für eigenen Code | `COIN` (siehe ADR 0003) | vorgeschlagen |
| E8 | Regel für die Anzahl der Camps | Kapazität aus aktiven Nestern (max. 10), keine Camps nahe befreitem Gebiet | **entschieden** |
| E9 | Panzer für die Spieler? | Nur wenn die Miliz Panzer hat, dann wenige und teuer | offen |
| E10 | Welches schwere Gerät darf die Miliz haben? | Technicals und Mörser; optional 1–2 erbeutete Altfahrzeuge | offen |
| E11 | Mörser und Hubschrauber für die Spieler? | Mörser ja, Transport-/MEDEVAC-Hubschrauber ja, keine Kampfhubschrauber | offen |
| E12 | Unterstützung bei sehr hohem Ruf (Abschnitt 8.1) | Gefälligkeiten über den Ältesten: Ablenkungsangriff und Verstärkung | vorgeschlagen |
| E13 | Dokumente als ACE Intel Items, die zum Dolmetscher gebracht werden müssen? | Option für Phase 3, Entscheidung beim Spec von Ticket 3.6 | offen |
