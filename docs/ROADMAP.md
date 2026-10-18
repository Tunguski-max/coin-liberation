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

- [ ] 0.1 KP Liberation auf GitHub forken, Starter-Dateien einspielen (siehe `SETUP.md`)
- [ ] 0.2 Build lokal ausführen und Lythium-Mission erzeugen (`build.bat`, Ausgabeort dokumentieren)
- [ ] 0.3 Mission lokal als Host starten, mit den Mods aus `docs/TESTING.md`
- [ ] 0.4 **Code-Landkarte** schreiben: `docs/kp-liberation-map.md`
  (Ordnerstruktur, Init-Reihenfolge, Speichern/Laden, Sektor-Logik, Presets, Zeus-Anbindung)
- [ ] 0.5 Vorhandene Liberation-Features prüfen und dokumentieren:
  Ruf (Civil Reputation), Informanten, asymmetrische Bedrohungen, Guerilla.
  Ergebnis: Was nutzen wir, was erweitern wir, was ersetzen wir?
- [ ] 0.6 Modul-Ordner `Missionframework/coin/` einbinden (leere Init, Log-Ausgabe „[COIN] init“)

**DoD:** Mission startet lokal ohne Fehler im RPT, `[COIN] init` erscheint im Log,
`kp-liberation-map.md` existiert und ist von Niklas gelesen.

## Phase 1 – Spielfeld

Ziel: Nur noch unser Kartenausschnitt existiert.

- [ ] 1.1 Ausschnitt und Hauptstadt festlegen (Entscheidung E3)
- [ ] 1.2 Sektoren außerhalb des Ausschnitts aus der `mission.sqm` entfernen
- [ ] 1.3 Hauptstadt, 15–20 Ortschaften, 3–5 Supply Points, 2–4 Militärposten setzen
- [ ] 1.4 Startbasis an den Rand des Ausschnitts verlegen
- [ ] 1.5 Dolmetscher-Slot(s) in der Lobby anlegen (Entscheidung E6)
- [ ] 1.6 Presets: Miliz (Project OPFOR), Zivilisten, BLUFOR (Entscheidung E1)
  - BLUFOR als **leichte Brigade**: keine fahrbare Artillerie, keine Jets, Rest nach E9/E11 (siehe `DESIGN.md` Abschnitt 10)
  - Miliz ohne Luftangriffe und Panzerverbände (E10)
  - Liberation-Funktionen für Artillerieunterstützung und Luftangriffe prüfen und passend abschalten
- [ ] 1.7 Siegbedingung auf „Hauptstadt eingenommen“ umstellen

**DoD:** Neue Kampagne starten, Karte zeigt nur unsere Sektoren, ein Sektor lässt sich einnehmen,
Speichern und Laden funktioniert nach Neustart.

## Phase 2 – Miliz-Netzwerk

Ziel: Nester existieren, sind persistent und schwächen bei Zerstörung das Netzwerk.

- [ ] 2.1 Datenmodell für Nester festlegen (Spec) und in den Liberation-Save einhängen
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

**DoD:** Mit Debug-Anzeige ein Nest finden und zerstören, Neustart, Nest bleibt zerstört,
Netzwerkstärke ist gesunken. Nach dem Neustart gibt es entsprechend weniger Camps,
und keines liegt näher als die Sperrzone an einem befreiten Sektor.

> Die Spur vom Camp zum Nest (Dokumente, Gefangene) kommt in Phase 3 (Ticket 3.6),
> weil sie das Intel-System braucht.

## Phase 3 – Dolmetscher und Intel

Ziel: Zivilisten befragen liefert brauchbare (oder gelogene) Hinweise auf Nester.

- [ ] 3.1 ACE-Interaktion „Befragen“ an Zivilisten, nur mit Dolmetscher in Reichweite
- [ ] 3.2 Ergebnis-Logik (Nichts, Gerücht, Hinweis, Tipp, Warnung, Lüge) mit Ruf-Gewichtung
- [ ] 3.3 Intel-Marker für die Seite, persistent
- [ ] 3.4 Triangulation: weitere Hinweise verkleinern den Kreis
- [ ] 3.5 Gefangene verhören (ACE-Fesseln)
- [ ] 3.6 Dokumente bei toten Anführern, in zerstörten Nestern und in ausgehobenen Camps
  (Camps zeigen auf ihr zugehöriges Nest)
  - *Option (E13):* als ACE Intel Items, die eingesammelt und beim Dolmetscher ausgewertet werden
    (`ace_intelitems_fnc_addIntel`, serverseitig)

**DoD:** Ohne Debug-Anzeige allein über Befragungen ein Nest finden und zerstören.

## Phase 4 – Asymmetrische Bedrohungen

Ziel: IEDs, VBIEDs, Attentäter und Hinterhalte, gespeist aus den Nestern.

- [ ] 4.1 IED-Budget pro Werkstatt, IED-Platzierung an Straßen im Radius
- [ ] 4.2 IED-Varianten: vergraben, ferngezündet mit Auslöser, Attrappe; ACE-Entschärfen
- [ ] 4.3 VBIED-Ereignis (nur mit aktiver Garage)
- [ ] 4.4 Selbstmordattentäter unter Zivilisten (abhängig vom Ruf)
- [ ] 4.5 Hinterhalte an Straßen
- [ ] 4.6 Werkstatt/Garage zerstört → Budgets und Ereignisse im Radius versiegen

**DoD:** Fahrt durch eine Region mit Werkstatt trifft auf IEDs; nach Zerstörung der Werkstatt
kommen dort keine neuen mehr hinzu.

## Phase 5 – Ruf und Konsequenzen

Ziel: Verhalten der Spieler verändert die Welt spürbar.

- [ ] 5.1 Liberation-Ruf um die Aktionen aus `DESIGN.md` Abschnitt 8 erweitern
- [ ] 5.2 Ruf wirkt auf Intel-Qualität, Informanten und Attentäter-Häufigkeit
- [ ] 5.3 Anzeige des aktuellen Rufs für Spieler (z. B. im Liberation-Overlay)
- [ ] 5.4 Gefälligkeiten: Zähler ab Ruf-Schwelle, Vorrat, Anforderung beim Ältesten über den Dolmetscher (E12)
- [ ] 5.5 Gefälligkeit „Ablenkungsangriff“: Ziel und Zeitpunkt wählen, Miliz-Kräfte abziehen
- [ ] 5.6 Gefälligkeit „Verstärkung“: Gruppe lokaler Kämpfer, die einem Spieler-Gruppenführer folgt

**DoD:** Zwei Testläufe (absichtlich „gut“ und „schlecht“ spielen) zeigen deutlich
unterschiedliche Intel-Qualität. Mit Ruf im Debug hochgesetzt lassen sich beide
Gefälligkeiten anfordern, und die Miliz reagiert sichtbar auf den Ablenkungsangriff.

## Phase 6 – Gegenangriffe und Hauptstadt

- [ ] 6.1 Gegenangriffe nur aus Regionen mit aktivem Kommandoposten
- [ ] 6.2 Asymmetrische Gegenangriffe: Technicals, Mörser auf FOBs, Konvoi-Überfälle
- [ ] 6.3 Hauptstadt-Garnison skaliert mit Netzwerkstärke
- [ ] 6.4 Optional: Miliz baut Nester langsam neu auf (Entscheidung E5)
- [ ] 6.5 Kampagnenende mit Abschluss-Statistik

**DoD:** Komplettdurchlauf im Debug-Modus beschleunigt möglich, von Start bis Sieg.

## Phase 7 – Server und Balancing

- [ ] 7.1 Erstes Deployment auf G-Portal (siehe `docs/DEPLOY.md`)
- [ ] 7.2 Persistenz über Server-Neustart testen
- [ ] 7.3 Performance unter Last messen (Server-FPS bei 5–10 Spielern)
- [ ] 7.4 Balancing-Werte in `coin_config.sqf` nach Testabenden anpassen

**DoD:** Ein echter Spielabend mit der Gruppe ohne Abstürze, Save übersteht Neustart.
