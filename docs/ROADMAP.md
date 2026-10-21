# Roadmap

Jede Phase endet mit einem **lokal testbaren Stand** („Definition of Done“, DoD).
Erst wenn eine Phase lokal sauber läuft, geht es in die nächste.
Server-Deployment kommt bewusst erst in Phase 7, kann aber jederzeit vorgezogen werden,
sobald der G-Portal-Server steht.

Ablauf pro Ticket (siehe `CLAUDE.md`):
`grill-with-docs` → `to-spec` / `to-tickets` → `implement` → lokaler Test durch Niklas → RPT-Rückmeldung.

---

## Phase 0 – Fundament

Ziel: Unveränderte Liberation-Mission läuft lokal auf Lythium, und Claude Code kennt den Code.

- [x] 0.1 KP Liberation auf GitHub forken, Starter-Dateien einspielen (siehe `SETUP.md`)
- [x] 0.2 Build lokal ausführen und Lythium-Mission erzeugen (`build.bat`, Ausgabeort dokumentieren)
- [x] 0.3 Mission lokal als Host starten, mit den Mods aus `docs/TESTING.md`
- [x] 0.4 **Code-Landkarte** schreiben: `docs/kp-liberation-map.md`
  (Ordnerstruktur, Init-Reihenfolge, Speichern/Laden, Sektor-Logik, Presets, Zeus-Anbindung)
- [x] 0.5 Vorhandene Liberation-Features prüfen und dokumentieren:
  Ruf (Civil Reputation), Informanten, asymmetrische Bedrohungen, Guerilla.
  Ergebnis: Was nutzen wir, was erweitern wir, was ersetzen wir?
- [x] 0.6 Modul-Ordner `Missionframework/coin/` einbinden (leere Init, Log-Ausgabe „[COIN] init“)

**DoD:** Mission startet lokal ohne Fehler im RPT, `[COIN] init` erscheint im Log,
`kp-liberation-map.md` existiert und ist von Niklas gelesen.

> Erfüllt am 2026-10-18 (lokaler Host): `[COIN] init (server)` und `[COIN] init (client)` im RPT, keine Fehler
> aus Liberation- oder COIN-Code. Verbleibende RPT-Meldungen stammen aus Mod-Configs bzw. Vanilla-Arma
> (z. B. `Error compiling 'HitEngine' in 'hithull'` beim Spawn der Startfahrzeuge).

## Phase 1 – Spielfeld

Ziel: Lythium ist ausgedünnt auf unsere Ziele, Slots und Ausrüstung passen zum Design (ADR 0007, 0016).

- [x] 1.1 Hauptstadt und Gebiet festlegen (E3): Kalae Noowi, ganze Karte ausgedünnt (ADR 0016)
- [x] 1.2 Eigene `Missionbasefiles/coin_liberation.lythium/mission.sqm` als Kopie anlegen, Build darauf umstellen (#3)
- [x] 1.3 Skript: Sektoren auswählen und in die Kopie schreiben (#4 Vorschlag, #5 Schreiben)
  - 25 Ortschaften (7 herabgestufte Hauptstädte, Arobster entfällt), 5 Supply Points, 4 Militärposten per Regel,
    dazu von Hand: 4 Ortschaften, 3 Supply Points, 2 Militärposten (gesamt 29/8/6, ADR 0016, 0017)
  - Mindestabstand 2,5 km zwischen Ortschaften, nichts im Umkreis von 1 km um Kalae Noowi
  - alle Funktürme entfernen (ADR 0013), Miliz-Spawnpunkte behalten
  - Vorschlag als Karte an Niklas, Tausche einarbeiten, dann schreiben
- [ ] ~~1.4 Startbasis verlegen~~ – entfällt, die Startbasis bleibt im Südwesten (ADR 0016)
- [x] 1.5 (#10) Slots im Eden-Editor (15): Führungsgruppe (Kommandant, 2 Dolmetscher), Trupp A und B
  (je Truppführer, Sanitäter, EOD, 2 Schützen), 2 Hubschrauberpiloten (E6)
- [x] 1.6 Presets (ADR 0007, 0014): #7 BLUFOR, #8 Miliz, #9 Widerstand
  - Auswahl der Presets in `_tools/_presets.coin.json` (überschreibt die Werte in `kp_liberation_config.sqf` beim Build)
  - BLUFOR (RHS USAF Desert) als **leichte Brigade** nach `DESIGN.md` Abschnitt 10
    (#7 getestet: Preset 31 `coin_light_brigade.sqf`)
  - Elite-Liste: M113A3 (M2), M113A3 (Mk19), Stryker M1126, Stryker M1134, AH-1Z, AH-6M
  - Miliz: eigenes Preset auf Basis Project OPFOR „Afghan Militia“: Technicals in Sektoren und Patrouillen,
    Gegenangriffe mit Technicals, Truppentransportern (Ural) und seltenem Altfahrzeug, leere Luft- und Hubschrauberlisten
    (#8 getestet: Preset 21 `coin_militia.sqf`)
  - Widerstand und Miliz: farbiges Kopftuch als Erkennungszeichen (#9 getestet): rot Miliz, grün feindlicher
    Widerstand, blau neutraler oder freundlicher Widerstand, live nach Ruf; Erklärung im Karten-Tagebuch (`COIN_fnc_markFactions`)
  - Rüstung der Miliz: gepanzerte Islamic-State-Kämpfer nach Bereitschaft in die Feld-Squads gemischt (Hooks 9 und 10, `COIN_fnc_mixSquad`, getestet)
- [x] 1.7 (#5, #6) Siegbedingung „Hauptstadt eingenommen“: genau ein Hauptstadt-Sektor (aus 1.3) und Lobby-Standard
  `VictoryCondition` = „alle Hauptstädte“ (in 1.8)
- [x] 1.8 (#6) Erste Liberation-Hooks: eigener Save-Key (ADR 0005), Lobby-Standardwerte `LimitedZeus` aus,
  `ZeusAddEnemies` an (ADR 0010), `VictoryCondition` = 0, `SuppMod` = 0, `ResourcesMultiplier` = x2 (ADR 0017)
- [x] 1.9 (#11) Limit für AH-1Z und AH-6M: je max. 1 gleichzeitig, 30 Min. Sperre ab Kauf, nicht gespeichert
  (Hook im Kaufmenü, Prüfung auf dem Server, Werte pro Klasse in `coin_config.sqf`, ADR 0007;
  getestet: Hooks 11 bis 13, `COIN_fnc_vehicleLimit*`)
- [x] 1.10 (#12) Test: Liberations Verwundete nach einer Einnahme beobachtet. Ergebnis: Zivilisten lassen sich mit dem
  Sanitäter über „Heilen“ versorgen, kein Hook nötig. Aufgefallen: bewusstlose Gegner werden bei der Einnahme zu Zivilisten,
  ihr Tod kostet Ruf. Fix bewusst verworfen (zu riskant für den Nutzen), Ruf bei Bedarf manuell zurückgeben
- [x] 1.11 (#14) Ressourcen-Sorten ausgleichen: nach Liberations Auslosung der Supply Points Supplies, Munition
  und Treibstoff so verteilen, dass sich die Sorten um höchstens 1 unterscheiden, bei 8 also 3-3-2 (Hook, Schalter in `coin_config.sqf`, ADR 0017;
  getestet: Hook 14, `COIN_fnc_guaranteeResources`, Auslosung 3-1-4 wurde zu 3-2-3)

**DoD:** Neue Kampagne starten, Karte zeigt nur unsere Sektoren, ein Sektor lässt sich einnehmen,
Speichern und Laden funktioniert nach Neustart. Bauliste und Slots entsprechen `DESIGN.md`,
ein zweiter AH-1Z lässt sich nicht kaufen.

> Erfüllt am 2026-10-19 (lokaler Host): Alle Tickets 1.1 bis 1.11 sind umgesetzt und im Spiel getestet. Speichern und Laden
> unter dem eigenen Save-Key und die Sperre für einen zweiten AH-1Z hat Niklas bestätigt.

## Phase 2 – Miliz-Netzwerk

Ziel: Nester existieren, sind persistent und schwächen bei Zerstörung das Netzwerk.

- [x] 2.1 (#28) Datenmodell für Nester festlegen (Spec) und in den Liberation-Save einhängen (Eintrag 22, ADR 0005, ADR 0018;
  getestet: Spielstand aus Phase 1 bekommt 11 Nester, Sektoren, FOBs und Ressourcen bleiben, Neustart lädt dieselben Nester,
  Wipe per Lobby erzeugt neue; Platzierung vorerst einfach, die Regeln kommen mit 2.2)
- [x] 2.2 (#29) Nester beim Kampagnenstart platzieren (Gebäude in Ortschaften, Lager im Gelände;
  gleichmäßig über die Karte, mindestens 4 km von der Startbasis; getestet in 5 neuen Kampagnen: „bester Kandidat“
  ohne Lockerung, kleinster Abstand 3,4–4 km, Gebäude-Nester 250–600 m vom Ortsmittelpunkt, Gelände-Nester abseits
  von Straßen und Orten auf ebenem Boden, Häuser passend zum Typ (Mindestfläche, VBIED-Garage nur in Hallen und
  Garagen aus einer Klassenliste, in Zeus ausgewählt), mindestens 2 Nester pro Typ)
- [ ] 2.3 Nest-Objekte und Bewachung spawnen, wenn Spieler in der Nähe sind
  (Gebäude-Nest: Kernobjekt und Requisiten auf freie Gebäudeplätze; Gelände-Nest: Template;
  Kernobjekte pro Typ im Spec festlegen)
  Gebäude-Nest (#30) getestet: Spawn bei etwa 1000 m, Abbau nach 2 min außerhalb 1300 m, erneuter Besuch gleich,
  Wachen mit rotem Tuch, Zeus sieht alles, Budget steigt um die Wachen, Hubschrauber über 100 m und Drohne über 500 m
  spawnen nichts, gesteuerte Drohne darunter schon, Kisten als Kernobjekt zerstörbar.
  Gebäude-Templates (#44, ADR 0019) getestet: Template aus Eden spawnt in anders gedrehten Häusern derselben Klasse
  an anderer Stelle wie gebaut, erneuter Besuch gleich, Autos stehen, scharfe Minen auslösbar, neue Kampagne nur in
  Template-Klassen. Alle 15 Gebäude-Templates (#32) eingetragen und am 2026-10-21 getestet: alle 15 nutzbar, Nester
  spawnen stabil nach Template; offen: Gelände-Nest (#31), Gelände- und Camp-Templates (#32), Mine entschärfen nicht getestet
- [ ] 2.3a Template-Mechanik für Gelände-Nester und Camps: Platzhalter-Templates von Claude,
  danach je 2–3 Templates pro Nest-Typ und für Camps von Niklas (Eden, Export um einen Richtungspfeil, ADR 0020).
  Gelände-Nest spawnen mit Platzhalter-Templates (#31): implementiert, ungetestet
- [ ] 2.4 Zerstörung erkennen, Zustand speichern, Ereignis auslösen
- [x] 2.5 (#28) Debug-Anzeige (Parameter): Nester und Radien auf der Karte (Lobby-Parameter „COIN Debug“; getestet: an zeigt 11 Nester
  mit Farbe und Radius nach Typ, aus zeigt keine Marker; noch offen: später beitretender Spieler)
- [ ] 2.6 Netzwerkstärke berechnen und im Debug anzeigen
- [ ] 2.7 Camps: Kapazität aus aktiven Nestern berechnen (Entscheidung E8)
- [ ] 2.8 Camps zufällig platzieren (ganze Karte, Abstandsregeln, Sperrzone um befreites Gebiet)
- [ ] 2.9 Camp-Inhalt spawnen bei Spielernähe (Zelte, Feuer, 3–6 Kämpfer, optional Technical);
  Waffenlager bekommen 1–2 Altfahrzeuge, die mit dem Lager verschwinden
- [ ] 2.10 Nachschub nach Zerstörung und Wechsel unentdeckter Camps
- [ ] 2.11 Debug-Anzeige für Camps und ihr zugehöriges Nest
- [x] 2.12 (#26) Liberation-Nebenmission „FOB Hunting“ abschalten (ADR 0011; getestet: Hooks 15 und 16,
  `COIN_fnc_secondaryMissionStatus`, Start per Debug-Konsole vom Server abgelehnt)
- [x] 2.13 (#27) KI-Budget: Liberations Obergrenzen auf 100, COIN-Einheiten obendrauf, Nester immer vollständig, Camps nur bis
  30 COIN-Einheiten insgesamt (ADR 0015; getestet: `COIN_fnc_aiBudget` 100 → 105 → 110 mit Test-Einheiten, nach dem Löschen wieder 100,
  Abschalten zur Laufzeit stellt 180/150/150 wieder her, `COIN_fnc_campFitsBudget` 25 ja / 26 nein;
  Unitcap ×1,5 beim Wipe: 270/225/225 → 150, auch nach Neustart; noch offen: später beitretender Client)

**DoD:** Mit Debug-Anzeige ein Nest finden und zerstören, Neustart, Nest bleibt zerstört,
Netzwerkstärke ist gesunken. Nach dem Neustart gibt es entsprechend weniger Camps,
und keines liegt näher als die Sperrzone an einem befreiten Sektor.

> Die Spur vom Camp zum Nest (Dokumente, Gefangene) kommt in Phase 3 (Ticket 3.6),
> weil sie das Intel-System braucht.

## Phase 3 – Dolmetscher und Intel

Ziel: Zivilisten befragen liefert brauchbare (oder gelogene) Hinweise auf Nester.

- [ ] 3.1 ACE-Interaktion „Befragen“ an jedem Zivilisten (auch Liberations), nur mit Dolmetscher in Reichweite
- [ ] 3.2 Ergebnis-Logik (Nichts, Gerücht, Hinweis, Tipp, Warnung, Lüge) mit Ruf-Gewichtung
- [ ] 3.3 Intel-Marker für die Seite, persistent; wahre Marker verschwinden mit ihrem Nest,
  Lügen-Marker erst nach Durchsuchen des Gebiets (ADR 0011)
- [ ] 3.4 Triangulation: weitere Hinweise verkleinern den Kreis
- [ ] 3.5 Gefangene verhören (ACE-Fesseln), überall, einmal pro Gefangenem (ADR 0011)
- [ ] 3.6 Dokumente bei toten Anführern, in zerstörten Nestern und in ausgehobenen Camps
  (Camps zeigen auf ihr zugehöriges Nest)
  - *Option (E13):* als ACE Intel Items, die eingesammelt und beim Dolmetscher ausgewertet werden
    (`ace_intelitems_fnc_addIntel`, serverseitig)
- [ ] 3.7 Eigene Bevölkerung in befreiten Ortschaften bei Spielernähe, inklusive Ältestem (ADR 0011)
- [ ] 3.8 Liberation-Informant liefert bei Ablieferung zusätzlich ein Intel zu einem aktiven Nest (ADR 0011)

**DoD:** Ohne Debug-Anzeige allein über Befragungen ein Nest finden und zerstören.

## Phase 4 – Asymmetrische Bedrohungen

Ziel: IEDs, VBIEDs, Attentäter und Hinterhalte, gespeist aus den Nestern.

- [ ] 4.1 IED-Budget pro Werkstatt, IED-Platzierung an Straßen im Radius
- [ ] 4.2 IED-Varianten: vergraben, ferngezündet mit Auslöser, Attrappe; ACE-Entschärfen
- [ ] 4.3 VBIED-Ereignis (nur mit aktiver Garage)
- [ ] 4.4 Selbstmordattentäter unter Zivilisten (abhängig vom Ruf); Befehle an Zivilisten prüfen
  (ACE „Get Down“/„Go Away“ für Spieler logisch auffindbar? sonst eigene Einträge inkl. „Stehen bleiben“)
- [ ] 4.5 Hinterhalte an Straßen
- [ ] 4.6 Werkstatt/Garage zerstört → Budgets und Ereignisse im Radius versiegen
- [ ] 4.7 Liberations IEDs und Hinterhalte in Ortschaften per Schalter abschalten (ADR 0008)

**DoD:** Fahrt durch eine Region mit Werkstatt trifft auf IEDs; nach Zerstörung der Werkstatt
kommen dort keine neuen mehr hinzu.

## Phase 5 – Ruf und Konsequenzen

Ziel: Verhalten der Spieler verändert die Welt spürbar.

- [ ] 5.1 Liberation-Ruf um die Aktionen aus `DESIGN.md` Abschnitt 8 erweitern
- [ ] 5.2 Ruf wirkt auf Intel-Qualität, Informanten-Häufigkeit (über Liberations Informanten-Werte) und Attentäter-Häufigkeit
- [ ] 5.3 Ruf-Anzeige: Zahl im Liberation-Overlay ausblenden (Hook), Dolmetscher kann Zivilisten nach ihrer
  Haltung fragen und erfährt das Ruf-Band in Worten (ADR 0009)
- [ ] 5.4 Gefälligkeiten: Zähler ab Ruf-Schwelle, Vorrat, Anforderung beim Ältesten über den Dolmetscher (E12)
- [ ] 5.5 Gefälligkeit „Ablenkungsangriff“: Ziel und Zeitpunkt wählen, Miliz-Kräfte abziehen
- [ ] 5.6 Gefälligkeit „Verstärkung“: Gruppe lokaler Kämpfer, die einem Spieler-Gruppenführer folgt
  (Liberation-Widerstand; fällt der Ruf unter +25, ziehen aktive lokale Kämpfer ab, ADR 0012)
- [ ] 5.7 Start-Ruf −20 bei neuer Kampagne (ADR 0009)
- [ ] 5.8 Ruf-Abzug für Gebäude, die die Armee in befreiten Ortschaften zerstört (ADR 0009)

**Aufträge (DESIGN 8.2)**
- [ ] 5.9 Ältester-Dialog über den Dolmetscher: Hilfsauftrag anbieten, „Kommt später wieder“, Wartezeit pro Ortschaft
- [ ] 5.10 Hilfsauftrag „Hilfsgüter liefern“ (Liberation-Supply-Kiste)
- [ ] 5.11 Hilfsauftrag „Arzt-Einsatz“ (unsterbliche Patienten, Aktion „Behandeln“ nur für Sanitäter)
- [ ] 5.12 Hilfsauftrag „Infrastruktur reparieren“
- [ ] 5.13 Aufklärungsauftrag entsteht aus Befragung/Verhör (Chance, Zeitfenster, max. 1 gleichzeitig)
- [ ] 5.14 Aufklärungsauftrag „Kurier abfangen“
- [ ] 5.15 Aufklärungsauftrag „Anführer festnehmen“ (lebend, Readiness −10 %)
- [ ] 5.16 Aufklärungsauftrag „Waffentransport abfangen“ (Readiness −10 %, Hinweis auf Ziel-Lager)

**DoD:** Zwei Testläufe (absichtlich „gut“ und „schlecht“ spielen) zeigen deutlich
unterschiedliche Intel-Qualität. Mit Ruf im Debug hochgesetzt lassen sich beide
Gefälligkeiten anfordern, und die Miliz reagiert sichtbar auf den Ablenkungsangriff.
Je ein Hilfs- und ein Aufklärungsauftrag lassen sich annehmen und abschließen; die Belohnung erscheint im Log.

## Phase 6 – Gegenangriffe und Hauptstadt

- [ ] 6.1 Gegenangriffe und Verstärkung nur aus Regionen mit aktivem Kommandoposten
- [ ] 6.2 Asymmetrische Gegenangriffe: Technicals und Truppentransporter, höchstens 1 Altfahrzeug pro Gegenangriff (Hook),
  Mörser auf FOBs, Konvoi-Überfälle
- [ ] 6.3 Hauptstadt-Garnison skaliert mit Netzwerkstärke; festes schweres Gerät: 2 T-72BA, 1 ZSU-23-4,
  Igla-Schützen (Klassen in `coin_config.sqf`, ADR 0014)
- [ ] 6.4 Optional: Miliz baut Nester langsam neu auf (Entscheidung E5)
- [ ] 6.5 Kampagnenende mit Abschluss-Statistik
- [ ] 6.6 Netzwerkstärke deckelt Liberations Readiness; zerstörtes Nest senkt die Readiness sofort (ADR 0013)

**DoD:** Komplettdurchlauf im Debug-Modus beschleunigt möglich, von Start bis Sieg.

## Phase 7 – Server und Balancing

- [ ] 7.1 Erstes Deployment auf G-Portal (siehe `docs/DEPLOY.md`)
- [ ] 7.2 Persistenz über Server-Neustart testen
- [ ] 7.3 Performance unter Last messen (Server-FPS bei 5–10 Spielern)
- [ ] 7.4 Balancing-Werte in `coin_config.sqf` nach Testabenden anpassen

**DoD:** Ein echter Spielabend mit der Gruppe ohne Abstürze, Save übersteht Neustart.
