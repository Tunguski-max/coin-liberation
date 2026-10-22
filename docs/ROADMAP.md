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
- [x] 2.3 Nest-Objekte und Bewachung spawnen, wenn Spieler in der Nähe sind
  (Gebäude-Nest: Kernobjekt und Requisiten auf freie Gebäudeplätze; Gelände-Nest: Template;
  Kernobjekte pro Typ im Spec festlegen)
  Gebäude-Nest (#30) getestet: Spawn bei etwa 1000 m, Abbau nach 2 min außerhalb 1300 m, erneuter Besuch gleich,
  Wachen mit rotem Tuch, Zeus sieht alles, Budget steigt um die Wachen, Hubschrauber über 100 m und Drohne über 500 m
  spawnen nichts, gesteuerte Drohne darunter schon, Kisten als Kernobjekt zerstörbar.
  Gebäude-Templates (#44, ADR 0019) getestet: Template aus Eden spawnt in anders gedrehten Häusern derselben Klasse
  an anderer Stelle wie gebaut, erneuter Besuch gleich, Autos stehen, scharfe Minen auslösbar, neue Kampagne nur in
  Template-Klassen. Alle 15 Gebäude-Templates (#32) eingetragen und am 2026-10-21 getestet: alle 15 nutzbar, Nester
  spawnen stabil nach Template. Gelände-Nest siehe 2.3a; nicht getestet: Mine entschärfen
- [x] 2.3a Template-Mechanik für Gelände-Nester und Camps: Platzhalter-Templates von Claude,
  danach je 2–3 Templates pro Nest-Typ und für Camps von Niklas (Eden, Export um einen Richtungspfeil, ADR 0020).
  Gelände-Nest (#31) am 2026-10-21 getestet: jeder Typ als Gelände-Nest gesehen (auch per `COIN_fnc_debugTerrainNest`),
  gleicher Seed gleiches Template und gleiche Drehung, etwa die Hälfte der Wachen im Ring, Spawn und Abbau wie beim
  Gebäude-Nest. Niklas übernimmt die Gelände-Templates von Claude (je eines pro Typ). Drei Camp-Templates von Niklas (#32)
  am 2026-10-22 getestet: `3 for camps` nutzbar, Templates 1 bis 3 im Spiel gesehen, gleicher Seed gleiches Template
- [x] 2.4 Zerstörung erkennen, Zustand speichern, Ereignis auslösen
  (#33: Kernobjekt zerstört oder Haus eingestürzt, sofort gespeichert, Ereignis `COIN_nestDestroyed`. Am 2026-10-21 getestet:
  Kernobjekt gesprengt bei Gebäude- und Gelände-Nest, Marker grau, Ereignis je Nest einmal, kein Respawn, nach Neustart
  weiter zerstört, Zeus-Löschen ist keine Zerstörung, eingestürzte Halle zerstört das Nest sofort)
- [x] 2.5 (#28) Debug-Anzeige (Parameter): Nester und Radien auf der Karte (Lobby-Parameter „COIN Debug“; getestet: an zeigt 11 Nester
  mit Farbe und Radius nach Typ, aus zeigt keine Marker; später beitretender Spieler: siehe 7.5)
- [x] 2.6 (#34) Netzwerkstärke berechnen und im Debug anzeigen (am 2026-10-22 getestet: neue Kampagne 1,00 (11 von 11), Haus der Rekrutierungsstelle eingestürzt ergibt 0,91 (10 von 11) mit einer RPT-Zeile, Debug-Eintrag im Karten-Tagebuch „COIN Debug“ folgt dem Wert, nach Neustart bleibt 0,91; später beitretender Client: siehe 7.5)
- [x] 2.7 (#36) Camps: Kapazität aus aktiven Nestern berechnen (Entscheidung E8; am 2026-10-21 getestet: neue Kampagne 10 Camps,
  Kommandoposten zerstört ergibt 8, mit zusätzlich zerstörter Rekrutierungsstelle nach Neustart 7, kein Nest über seinem Gewicht;
  Waffenlager → 9 nicht einzeln getestet, gleiche Rechnung). Camps sind erst Daten, der Inhalt kommt mit 2.9
- [x] 2.8 (#37) Camps zufällig platzieren (ganze Karte, Abstandsregeln, Sperrzone um befreites Gebiet; am 2026-10-21 getestet:
  7 von 7 Camps mit Straße ≥ 164 m, Ort ≥ 935 m, Startbasis ≥ 5841 m, Deckung ≥ 4, eingenommener Sektor und FOB kommen aus dem
  Spielstand, kein Camp unter 1 km. Die Regel unmittelbar neben einem Sektor oder FOB wurde nicht gesondert erzwungen;
  mit 500 Versuchen blieben 2 von 7 Camps ohne Platz, daher 1000. Gelände-Nester teilen die Prüfung für Ort, Straße und Ebene)
- [x] 2.9 (#38) Camp-Inhalt spawnen bei Spielernähe (Zelte, Feuer, 3–6 Kämpfer, optional Technical; am 2026-10-21 getestet:
  Spawn bei Annäherung mit Platzhalter-Template, Kämpfer im Ring und auf Patrouille, Technical erzwungen und erbeutet
  (bleibt beim Abbau, kommt nicht wieder), Abbau nach 2 Minuten, Budget: Camp wartet mit `COIN_maxCampAI = 1` und
  erscheint danach, Zeus sieht alles, Gelände-Nester unverändert)
- [x] 2.9a (#35) Waffenlager bekommen 1–2 Altfahrzeuge, die mit dem Lager verschwinden (am 2026-10-22 getestet: Waffenlager besucht, 2 besetzte Altfahrzeuge (BTR-60, M113) neben dem Nest, für Spieler gesperrt, nach Abbau und Rückkehr wieder da an gleicher Stelle, zerstörtes Lager spawnt keine mehr)
- [x] 2.10 (#39) Nachschub nach Zerstörung und Wechsel unentdeckter Camps (am 2026-10-22 getestet: ausgehobenes Camp wird nach
  `COIN_campReplaceMinutes` an anderer Stelle ersetzt, ein weggeteleportierter Wächter verhindert das Ausheben nicht, unentdeckte
  Camps ziehen um und ein entdecktes bleibt, ein Camp in einer neuen Sperrzone (Sektor Kandar) wird beim Abbau versetzt, Camps
  eines zerstörten Nests verschwinden ohne Ersatz und die Gesamtzahl folgt der Kapazität, nach Neustart 6 von 6 Camps bei
  Kapazität 6. Netzwerkstärke: siehe 2.6)
- [x] 2.11 (#36) Debug-Anzeige für Camps und ihr zugehöriges Nest (getestet: Dreieck mit Linie zum Eigentümer-Nest,
  Camps eines zerstörten Nests werden grau)
- [x] 2.12 (#26) Liberation-Nebenmission „FOB Hunting“ abschalten (ADR 0011; getestet: Hooks 15 und 16,
  `COIN_fnc_secondaryMissionStatus`, Start per Debug-Konsole vom Server abgelehnt)
- [x] 2.13 (#27) KI-Budget: Liberations Obergrenzen auf 100, COIN-Einheiten obendrauf, Nester immer vollständig, Camps nur bis
  30 COIN-Einheiten insgesamt (ADR 0015; getestet: `COIN_fnc_aiBudget` 100 → 105 → 110 mit Test-Einheiten, nach dem Löschen wieder 100,
  Abschalten zur Laufzeit stellt 180/150/150 wieder her, `COIN_fnc_campFitsBudget` 25 ja / 26 nein;
  Unitcap ×1,5 beim Wipe: 270/225/225 → 150, auch nach Neustart; später beitretender Client: siehe 7.5)
- [x] 2.14 (#54) Meldung an alle Spieler bei zerstörtem Nest (Typ, ohne Position) und ausgehobenem Camp (ohne Position, ohne Nest),
  analog zur FOB-Meldung von Liberation; Ereignis `COIN_campCleared` dazu (am 2026-10-22 getestet: Einblendung bei zerstörtem Waffenlager mit Typ und bei zwei ausgehobenen Camps, je Ereignis genau eine Meldung, keine bei Camp-Umzug, Zeus-Löschen des Kernobjekts meldet nichts, beide Schalter einzeln abschaltbar; Texte nur auf Englisch gesehen, Deutsch und Sicht aller Spieler: siehe 7.5)

**DoD:** Mit Debug-Anzeige ein Nest finden und zerstören, Neustart, Nest bleibt zerstört,
Netzwerkstärke ist gesunken. Nach dem Neustart gibt es entsprechend weniger Camps,
und keines liegt näher als die Sperrzone an einem befreiten Sektor.

> Die Spur vom Camp zum Nest (Dokumente, Gefangene) kommt in Phase 3 (Tickets 3.8 und 3.9),
> weil sie das Intel-System braucht.

## Phase 3 – Dolmetscher und Intel

Ziel: Zivilisten befragen liefert brauchbare (oder gelogene) Hinweise auf Nester.
Schnitt in dünne, einzeln testbare Durchstiche (Grilling 2026-10-22, DESIGN 7 v0.5, ADR 0021).
3.1 bis 3.4 sind der Kern, danach ist die DoD im Prinzip spielbar.

- [x] 3.1 (#58) Durchstich Befragung: Dolmetscher-Rolle am Slot (übersteht Respawn), Aktionsmenü „Nach der Miliz fragen“
  nur für den Dolmetscher an befragbaren Zivilisten (zu Fuß, ansprechbar, kein Gefangener, kein Informant), Zivilist bleibt
  stehen, Antwort als Untertitel nur beim Dolmetscher; Ergebnis vorerst immer wahr (Gerücht, Hinweis oder Tipp, Nest im
  Umkreis von etwa 4 km, sonst das nächste), Marker für die Seite, einmal pro Zivilist (Speichern: 3.2);
  Debug zeigt die Nest-ID
  (am 2026-10-22 getestet: Dolmetscher-Slot per Rollenbeschreibung erkannt, Eintrag im Aktionsmenü aus 5 m, Zivilist bleibt stehen, Untertitel und Kreis um das Nest (Mitte 20–80 % des Radius daneben), zweite Frage derselbe Zivilist nicht, Gefangener und ergebener Ex-Gegner ohne Eintrag, Zivilist im Fahrzeug ohne Eintrag, Eintrag nach dem Respawn wieder da; nicht getestet: Bewusstlose, Dolmetscher im Fahrzeug; Mehrspieler: siehe 7.5)
- [x] 3.2 (#59) Intel speichern: `COIN_saveVersion` 2 mit Umwandlung von Version 1, Marker verschwinden mit ihrem zerstörten Nest (ADR 0021)
  (am 2026-10-22 getestet: Stand aus Phase 2 wird umgewandelt, zwei Marker überstehen den Neustart mit gleicher Lage und Größe, Marker verschwindet mit seinem zerstörten Nest und bleibt nach dem Neustart weg, Wipe ohne Marker; Mehrspieler: siehe 7.5)
- [x] 3.3 (#60) Triangulation: ein Kreis pro Nest, jeder wahre Treffer verkleinert ihn; Symbol pro Nest-Typ ab Hinweis, Gerücht neutral
  (am 2026-10-22 mit Befehlen in der Debug-Konsole getestet und von Niklas bestätigt; ein Gerücht nach einem Tipp verkleinert den Kreis weiter, nach der Formel, vergrößert ihn nie)
- [x] 3.4 (#61) Ruf-Gewichte und Lügen: alle Ergebnisse nach Ruf-Band, Lüge mit Ersatzpunkt, zufälligem Typ und Größe;
  Spieler zu Fuß nahe am Ersatzpunkt entfernt sie ohne Meldung (ADR 0011, 0021); Debug zeigt wahr oder gelogen
  (am 2026-10-22 getestet: Ruf-Bänder über die RPT-Zeile je Befragung, Lügen bei Ruf −50, Lüge verschwindet ohne Meldung zu Fuß am Ersatzpunkt (23 bis 38 m) und der Stand wird gespeichert, Verweigerung bei bewaffneten Gegnern in der Nähe; nicht getestet: Fahrzeug am Ersatzpunkt, Neustart mit Lüge im Spielstand, Lage der Ersatzpunkte (Wasser, Startbasis, Hauptstadt), Mehrspieler: siehe 7.5; die Warnung zählt bis 3.6 als „Ich weiß nichts“; überarbeitete Antworttexte von Niklas übernommen: Sätze nach Nest-Typ ohne Typ-Nennung, Verweigerung bei bewaffneten Gegnern in der Nähe, Sätze für die Abklingzeit liegen schon in der Config für 3.5)
- [x] 3.5 (#62) Abklingzeit pro Dolmetscher nach jedem Marker (auch Lüge), Dolmetscher bremst selbst, Zivilist bleibt unbefragt
  (am 2026-10-22 von Niklas im Spiel getestet und bestätigt: pro Spieler-UID auf dem Server, 300 s, nicht gespeichert; „Ich weiß nichts“ und Verweigerung starten nichts; der Zivilist vertröstet den Dolmetscher mit einem Satz unter seinem Namen; Mehrspieler: siehe 7.5; die Sätze aus Sicht des Zivilisten sind im Spiel noch nicht gesehen)
- [x] 3.6 (#63) Warnung: Kreis um ein Camp in der Nähe, nicht gespeichert (IED und Hinterhalt ab Phase 4)
  (am 2026-10-22 getestet: Höchstabstand 1500 m, Kreis 150 m, ein Camp bekommt nur einen Warnkreis, rotes Warnsymbol, eigene Meldung „WARNUNG“, Texte von Niklas; Warnkreis bei 1454 m gesetzt, verschwindet im RPT beim Ausheben des Camps, nach dem Neustart keine Warnkreise; nicht getestet: Zivilist mehr als 1500 m vom nächsten Camp, Mehrspieler: siehe 7.5)
- [ ] 3.7 (#64) Eigene Bevölkerung: 4–8 Zivilisten im Kern befreiter Ortschaften bei Spielernähe, im Zivilisten-Budget
  (ADR 0011, 0015); der Älteste kommt in Phase 5
- [x] 3.8 (#65) Verhör: Aktionsmenü „Verhören“ an Gefangenen, einmal pro Gefangenem, 1–2 Ergebnisse mit eigenen Gewichten;
  Camp-Kämpfer nennt sein Nest, Nest-Wache ein anderes (ADR 0011)
  (am 2026-10-22 von Niklas im Spiel getestet und bestätigt: Camp-Kämpfer nennt das Nest seines Camps, Nest-Wache ein anderes Nest, zwei Ergebnisse zum selben Nest lassen den Kreis nicht größer werden, Abklingzeit 300 s gilt auch für Gefangene; Gewichte 1. Ergebnis [0, 15, 30, 40, 7, 8], 2. Ergebnis [25, 20, 25, 20, 5, 5] mit 50 % Chance, Texte von Niklas; Befragung und Abklingzeit (3.1, 3.5) laufen nach dem Umbau unverändert; nicht gesehen: zweites Verhör desselben Gefangenen, Lüge und Warnung im Verhör, ergebener Kämpfer (Variable ace_captives_isSurrendering); Liberations Intel-Punkte an der FOB gibt es nur für Gefangene, die durch Liberations Ergeben-Skript laufen und über „Gefangen nehmen“ zur FOB gebracht werden, nicht für nur gefesselte Camp-Wachen; Mehrspieler: siehe 7.5)
- [ ] 3.9 (#66) Dokumente als ACE Intel Items (E13): bei toten Anführern, in zerstörten Nestern (anderes Nest) und ausgehobenen
  Camps (Nest des Camps), Auswertung beim Dolmetscher, nie gelogen
- [x] 3.10 (#67) Liberation-Informant liefert bei Ablieferung zusätzlich einen Konkreten Tipp zu einem aktiven Nest (Hook, ADR 0011)
  (am 2026-10-22 von Niklas im Spiel getestet und bestätigt: Tipp (100 m) zum nächsten aktiven Nest ohne Kreis, Test per Konsole mit gesetztem COIN_home; zwei Hooks in Liberation, siehe docs/hooks.md Nr. 21; nicht gesehen: Kreis schrumpft, wenn alle Nester schon einen haben, Schalter aus, Liberations Belohnung im RPT nicht geprüft; echter Informant ab Ruf 25 und Mehrspieler: siehe 7.5)

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
- [ ] 7.5 Tests mit einem zweiten Spieler auf dem Dedicated Server (lokal reicht ein Spieler): später beitretender Spieler sieht die Debug-Marker (2.5), die Gegner-Grenzen des Servers (`COIN_enemyAICaps`, 2.13) und die Netzwerkstärke im Tagebuch „COIN Debug“ (2.6); Zeus-Kurator, der erst später entsteht, sieht COIN-Inhalte; Meldungen an alle Spieler (2.14): sehen alle Spieler sie, auch weit vom Camp oder Nest entfernt, und der deutsche Text (Spielsprache Deutsch, Titel mit Umlaut);
  Intel (Phase 3): andere Spieler sehen den Menüeintrag und keinen Untertitel, alle sehen Marker und Hinweis „Neue Intel“ (3.1),
  später beitretender Spieler sieht geladene Marker (3.2), Abklingzeit des einen Dolmetschers bremst den zweiten nicht (3.5),
  ein Schütze sammelt ein Dokument ein und gibt es dem Dolmetscher, ein Dokument lässt sich nur einmal auswerten (3.9)

**DoD:** Ein echter Spielabend mit der Gruppe ohne Abstürze, Save übersteht Neustart.
