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

Ziel: Nur noch unser Kartenausschnitt existiert.

- [ ] 1.1 Ausschnitt und Hauptstadt festlegen (Entscheidung E3)
- [ ] 1.2 Sektoren außerhalb des Ausschnitts aus der `mission.sqm` entfernen, ebenso die
  Miliz-Spawnpunkte `opfor_point` und `opfor_airspawn`. Keine Funktürme (`tower`) im Ausschnitt (ADR 0013)
- [ ] 1.3 Hauptstadt, 15–20 Ortschaften, 3–5 Supply Points, 2–4 Militärposten setzen
- [ ] 1.4 Startbasis an den Rand des Ausschnitts verlegen
- [ ] 1.5 Dolmetscher-Slot(s) in der Lobby anlegen (Entscheidung E6)
- [ ] 1.6 Presets: Miliz, Zivilisten, BLUFOR (Entscheidung E1)
  - Auswahl der Presets in `_tools/_presets.coin.json` (überschreibt die Werte in `kp_liberation_config.sqf` beim Build)
  - BLUFOR als **leichte Brigade**: keine fahrbare Artillerie, keine Jets, Rest nach E9/E11 (siehe `DESIGN.md` Abschnitt 10)
  - Elite-Liste mit erlaubtem, wertvollem Gerät füllen (ADR 0014)
  - Miliz: eigenes Preset auf Basis Project OPFOR „Afghan Militia“, ohne Luftangriffe und Panzerverbände (E10, ADR 0014)
  - Widerstand: erkennbare Kleidung für lokale Kämpfer (ADR 0014)
  - Liberation-Artillerieunterstützung über Lobby-Parameter `SuppMod` abschalten
- [ ] 1.7 Siegbedingung auf „Hauptstadt eingenommen“ umstellen
  (genau ein Hauptstadt-Sektor + Lobby-Parameter `VictoryCondition` = „alle Hauptstädte“)
- [ ] 1.8 Erste Liberation-Hooks: eigener Save-Key (ADR 0005), Zeus-Standardwerte
  `LimitedZeus` aus und `ZeusAddEnemies` an (ADR 0010)

**DoD:** Neue Kampagne starten, Karte zeigt nur unsere Sektoren, ein Sektor lässt sich einnehmen,
Speichern und Laden funktioniert nach Neustart.

## Phase 2 – Miliz-Netzwerk

Ziel: Nester existieren, sind persistent und schwächen bei Zerstörung das Netzwerk.

- [ ] 2.1 Datenmodell für Nester festlegen (Spec) und in den Liberation-Save einhängen (Eintrag 22, ADR 0005)
- [ ] 2.2 Nester beim Kampagnenstart platzieren (Gebäude in Ortschaften, Lager im Gelände)
- [ ] 2.3 Nest-Objekte und Bewachung spawnen, wenn Spieler in der Nähe sind
- [ ] 2.4 Zerstörung erkennen, Zustand speichern, Ereignis auslösen
- [ ] 2.5 Debug-Anzeige (Parameter): Nester und Radien auf der Karte
- [ ] 2.6 Netzwerkstärke berechnen und im Debug anzeigen
- [ ] 2.7 Camps: Kapazität aus aktiven Nestern berechnen (Entscheidung E8)
- [ ] 2.8 Camps zufällig platzieren (Kartenausschnitt plus Randzone, Abstandsregeln, Sperrzone um befreites Gebiet)
- [ ] 2.9 Camp-Inhalt spawnen bei Spielernähe (Zelte, Feuer, 3–6 Kämpfer, optional Technical)
- [ ] 2.10 Nachschub nach Zerstörung und Wechsel unentdeckter Camps
- [ ] 2.11 Debug-Anzeige für Camps und ihr zugehöriges Nest
- [ ] 2.12 Liberation-Nebenmission „FOB Hunting“ abschalten (ADR 0011)
- [ ] 2.13 Gemeinsames KI-Budget: COIN prüft gegen den Gesamtwert, Liberations Obergrenzen werden daraus abgeleitet (ADR 0015)

**DoD:** Mit Debug-Anzeige ein Nest finden und zerstören, Neustart, Nest bleibt zerstört,
Netzwerkstärke ist gesunken. Nach dem Neustart gibt es entsprechend weniger Camps,
und keines liegt näher als die Sperrzone an einem befreiten Sektor.

> Die Spur vom Camp zum Nest (Dokumente, Gefangene) kommt in Phase 3 (Ticket 3.6),
> weil sie das Intel-System braucht.

## Phase 3 – Dolmetscher und Intel

Ziel: Zivilisten befragen liefert brauchbare (oder gelogene) Hinweise auf Nester.

- [ ] 3.1 ACE-Interaktion „Befragen“ an jedem Zivilisten (auch Liberations), nur mit Dolmetscher in Reichweite
- [ ] 3.2 Ergebnis-Logik (Nichts, Gerücht, Hinweis, Tipp, Warnung, Lüge) mit Ruf-Gewichtung
- [ ] 3.3 Intel-Marker für die Seite, persistent
- [ ] 3.4 Triangulation: weitere Hinweise verkleinern den Kreis
- [ ] 3.5 Gefangene verhören (ACE-Fesseln)
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
- [ ] 4.4 Selbstmordattentäter unter Zivilisten (abhängig vom Ruf)
- [ ] 4.5 Hinterhalte an Straßen
- [ ] 4.6 Werkstatt/Garage zerstört → Budgets und Ereignisse im Radius versiegen
- [ ] 4.7 Liberations IEDs und Hinterhalte in Ortschaften per Schalter abschalten (ADR 0008)

**DoD:** Fahrt durch eine Region mit Werkstatt trifft auf IEDs; nach Zerstörung der Werkstatt
kommen dort keine neuen mehr hinzu.

## Phase 5 – Ruf und Konsequenzen

Ziel: Verhalten der Spieler verändert die Welt spürbar.

- [ ] 5.1 Liberation-Ruf um die Aktionen aus `DESIGN.md` Abschnitt 8 erweitern
- [ ] 5.2 Ruf wirkt auf Intel-Qualität, Informanten-Häufigkeit (über Liberations Informanten-Werte) und Attentäter-Häufigkeit
- [ ] 5.3 Anzeige des aktuellen Rufs für Spieler: Liberation-Overlay zeigt ihn bereits; prüfen, ob zusätzlich das Ruf-Band angezeigt werden soll
- [ ] 5.4 Gefälligkeiten: Zähler ab Ruf-Schwelle, Vorrat, Anforderung beim Ältesten über den Dolmetscher (E12)
- [ ] 5.5 Gefälligkeit „Ablenkungsangriff“: Ziel und Zeitpunkt wählen, Miliz-Kräfte abziehen
- [ ] 5.6 Gefälligkeit „Verstärkung“: Gruppe lokaler Kämpfer, die einem Spieler-Gruppenführer folgt
  (Liberation-Widerstand; fällt der Ruf unter +25, ziehen aktive lokale Kämpfer ab, ADR 0012)
- [ ] 5.7 Start-Ruf −20 bei neuer Kampagne (ADR 0009)
- [ ] 5.8 Ruf-Abzug für Gebäude, die die Armee in befreiten Ortschaften zerstört (ADR 0009)

**DoD:** Zwei Testläufe (absichtlich „gut“ und „schlecht“ spielen) zeigen deutlich
unterschiedliche Intel-Qualität. Mit Ruf im Debug hochgesetzt lassen sich beide
Gefälligkeiten anfordern, und die Miliz reagiert sichtbar auf den Ablenkungsangriff.

## Phase 6 – Gegenangriffe und Hauptstadt

- [ ] 6.1 Gegenangriffe und Verstärkung nur aus Regionen mit aktivem Kommandoposten
- [ ] 6.2 Asymmetrische Gegenangriffe: Technicals, Mörser auf FOBs, Konvoi-Überfälle
- [ ] 6.3 Hauptstadt-Garnison skaliert mit Netzwerkstärke
- [ ] 6.4 Optional: Miliz baut Nester langsam neu auf (Entscheidung E5)
- [ ] 6.5 Kampagnenende mit Abschluss-Statistik
- [ ] 6.6 Netzwerkstärke deckelt Liberations Readiness (ADR 0013)

**DoD:** Komplettdurchlauf im Debug-Modus beschleunigt möglich, von Start bis Sieg.

## Phase 7 – Server und Balancing

- [ ] 7.1 Erstes Deployment auf G-Portal (siehe `docs/DEPLOY.md`)
- [ ] 7.2 Persistenz über Server-Neustart testen
- [ ] 7.3 Performance unter Last messen (Server-FPS bei 5–10 Spielern)
- [ ] 7.4 Balancing-Werte in `coin_config.sqf` nach Testabenden anpassen

**DoD:** Ein echter Spielabend mit der Gruppe ohne Abstürze, Save übersteht Neustart.
