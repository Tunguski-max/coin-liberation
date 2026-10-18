# CONTEXT.md – Glossar

Gemeinsame Sprache für Doku, Specs, Tickets und Code-Kommentare.
Code-Bezeichner stehen in Klammern.

## Akteure

| Begriff | Bedeutung |
|---|---|
| **Armee** | Die Spielerseite (BLUFOR). Konkrete Fraktion: offen (Entscheidung E1). Ausgerüstet als **leichte Brigade**. |
| **Leichte Brigade** | Ausrüstungsrahmen der Armee: Infanterie, geschützte Radfahrzeuge, leichte Unterstützung. Keine fahrbare Artillerie, keine Jets. |
| **Miliz** (`militia`) | Der Gegner (OPFOR). Taliban-ähnlich, asymmetrisch, nutzt Project-OPFOR-Einheiten. |
| **Zivilisten** (`civ`) | Bevölkerung. Quelle von Intel, aber auch Tarnung für Attentäter. |
| **Dolmetscher** (`interpreter`) | Spielerrolle. Ohne ihn keine Befragungen. |
| **Zeus** | Spielleiter-Slot (Kurator). Darf alles sehen, ändern, löschen. |

## Spielfeld

| Begriff | Bedeutung |
|---|---|
| **Kartenausschnitt** | Der Teil von Lythium, auf dem gespielt wird. Alles außerhalb ist inaktiv. |
| **Sektor** (`sector`) | Liberation-Begriff für ein einnehmbares Gebiet (Stadt, Fabrik, Militärposten …). |
| **Hauptstadt** (`capital`) | Der eine zentrale Sektor der Miliz. Einnahme = Kampagnensieg. |
| **Ortschaft** | Städtischer Sektor um die Hauptstadt herum (15–20 Stück). |
| **Supply Point** | Liberation-Ressourcen-Sektor (Fabrik). Erzeugt Supplies, Munition, Treibstoff. |
| **FOB** | Vorgeschobene Basis der **Armee** (Liberation). Nie für die Miliz verwendet. |
| **Region** | Bereich um ein Nest, definiert durch dessen Einflussradius. |

## Miliz-Netzwerk

| Begriff | Bedeutung |
|---|---|
| **Nest** (`nest`) | Verdeckter Knoten der Miliz mit Effekt im Einflussradius. Ersetzt die Idee „OPFOR-FOB“. |
| **Nest-Typ** (`nestType`) | Kommandoposten (`command`), IED-Werkstatt (`iedWorkshop`), Waffenlager (`cache`), VBIED-Garage (`vbiedGarage`), Rekrutierungsstelle (`recruitment`). |
| **Kernobjekt** | Das Objekt, dessen Zerstörung das Nest zerstört (Waffenkiste, Werkbank, Funkgerät …). |
| **Einflussradius** (`influenceRadius`) | Bereich, in dem ein Nest wirkt. |
| **Netzwerkstärke** (`networkStrength`) | Kennzahl aus allen aktiven Nestern. Bestimmt u. a. die Hauptstadt-Garnison. |
| **Camp** (`camp`) | Kleines, offenes Lager der Miliz im Gelände. Gehört zu einem Nest, wird nicht gespeichert, wechselt seine Position. |
| **Camp-Kapazität** (`campCapacity`) | Maximale Zahl gleichzeitiger Camps, berechnet aus den aktiven Nestern. |
| **Sperrzone** (`campExclusionRadius`) | Bereich um befreite Sektoren und FOBs, in dem keine Camps entstehen. |
| **Budget** (`budget`) | Vorrat, aus dem Bedrohungen entstehen (z. B. IED-Budget einer Werkstatt). |

## Bedrohungen

| Begriff | Bedeutung |
|---|---|
| **IED** | Improvisierte Sprengfalle. Varianten: vergraben, ferngezündet, Attrappe. |
| **Auslöser** (`triggerman`) | Miliz-Kämpfer (oft in Zivil), der ein ferngezündetes IED auslöst. |
| **VBIED** | Autobombe in einem zivilen Fahrzeug. |
| **Attentäter** (`suicideBomber`) | Zivilist mit Sprengweste. |
| **Hinterhalt** (`ambush`) | Vorbereiteter Überfall an einer Straße. |
| **Kämpfer in Zivil** | Miliz-Einheit ohne sichtbare Waffe, bis es zum Kontakt kommt. |

## Intel und Bevölkerung

| Begriff | Bedeutung |
|---|---|
| **Befragung** (`interrogation` bei Gefangenen, `questioning` bei Zivilisten) | ACE-Interaktion mit Dolmetscher. |
| **Intel** | Hinweis auf ein Nest oder eine Bedrohung. Erscheint als Kartenmarker. |
| **Intel-Stufen** | Gerücht (groß) → Hinweis (mittel) → Konkreter Tipp (klein). Dazu: Warnung, Lüge. |
| **Triangulation** | Mehrere wahre Hinweise auf dasselbe Nest verkleinern den Markerkreis. |
| **Dokumente** | Intel-Gegenstand bei toten Anführern oder in zerstörten Nestern. |
| **Ruf** (`reputation`) | Ansehen der Armee bei der Bevölkerung. Baut auf Liberations „Civil Reputation“ auf. |
| **Gefälligkeit** (`favor`) | Unterstützung durch die Bevölkerung, die ab sehr hohem Ruf gesammelt und beim Ältesten eingelöst wird. |
| **Ältester** (`elder`) | Ansprechpartner in einer befreiten Ortschaft, bei dem über den Dolmetscher Gefälligkeiten angefordert werden. |
| **Lokale Kämpfer** (`localFighters`) | Freundliche Dorfwachen und Stammeskämpfer. Führen Ablenkungsangriffe durch oder stoßen als Verstärkung dazu. |
| **Ablenkungsangriff** (`diversion`) | Angriff lokaler Kämpfer auf ein Ziel, der Miliz-Kräfte für eine Zeit dorthin abzieht. |
| **Verstärkung** (`reinforcement`) | Gruppe lokaler Kämpfer, die einem Spieler-Gruppenführer für begrenzte Zeit folgt. |
| **Informant** | Zivilist, der von sich aus Intel anbietet (Liberation-Funktion, in Phase 0 prüfen). |

## Technik

| Begriff | Bedeutung |
|---|---|
| **Upstream** | Das Original-Repo KP Liberation. |
| **Hook** | Stelle im Liberation-Code, an der unser Code eingehängt ist. Dokumentiert in `docs/hooks.md`. |
| **RPT** | Arma-Logdatei. Hauptquelle für Fehleranalyse. |
| **Preset** | Liberation-Datei, die Fraktionen (Einheiten, Fahrzeuge, Baulisten) festlegt. |
