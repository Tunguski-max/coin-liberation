# CONTEXT.md – Glossar

Gemeinsame Sprache für Doku, Specs, Tickets und Code-Kommentare.
Code-Bezeichner stehen in Klammern.

## Akteure

| Begriff | Bedeutung |
|---|---|
| **Armee** | Die Spielerseite (BLUFOR). Konkrete Fraktion: offen (Entscheidung E1). Ausgerüstet als **leichte Brigade**. |
| **Leichte Brigade** | Ausrüstungsrahmen der Armee: Infanterie, geschützte Radfahrzeuge, leichte Unterstützung. Keine fahrbare Artillerie, keine Jets. |
| **Miliz** (`militia`) | Der Gegner (OPFOR). Taliban-ähnlich, asymmetrisch, nutzt Project-OPFOR-Einheiten („Afghan Militia“). |
| **Zivilisten** (`civ`) | Bevölkerung. Quelle von Intel, aber auch Tarnung für Attentäter. |
| **Widerstand** (`resistance`) | Bewaffnete Einheimische (Liberation-Fraktion, im Code auch „Guerilla“). Ihre Haltung zur Armee und zur Miliz hängt vom Ruf ab. Erkennbar am Kopftuch: grün feindlich, blau neutral oder freundlich. |
| **Erkennungstuch** (`COIN_marker*`) | Farbiges Kopftuch (Shemag) der KI-Kämpfer: rot Miliz, grün feindlicher Widerstand, blau neutraler oder freundlicher Widerstand. |
| **Dolmetscher** (`interpreter`) | Spielerrolle. Ohne ihn keine Befragungen. |
| **Trupp** | Spielergruppe der Armee aus Truppführer, Sanitäter, EOD und zwei Schützen. |
| **Kommandant** (`commandant`) | Spieler-Slot „Kommandant (Zeus)“ in der Führungsgruppe. Führt die Armee und ist zugleich Zeus. |
| **Zeus** | Spielleiter-Rolle (Kurator), liegt beim Kommandanten. Darf alles sehen, ändern, löschen. |

## Spielfeld

| Begriff | Bedeutung |
|---|---|
| **Startbasis** | Ausgangspunkt der Armee (Liberation-Startpunkt im Südwesten von Lythium). Von hier wird die erste FOB per Hubschrauber ins Gebiet gebracht. |
| **Sektor** (`sector`) | Liberation-Begriff für ein einnehmbares Gebiet (Stadt, Fabrik, Militärposten …). |
| **Hauptstadt** (`capital`) | Der eine zentrale Sektor der Miliz (Liberation-Sektortyp `bigtown`). Einnahme = Kampagnensieg. |
| **Ortschaft** | Städtischer Sektor, über die ganze Karte verteilt (20–25 Stück, Liberation-Sektortyp `capture`). |
| **Supply Point** | Liberation-Ressourcen-Sektor (Fabrik). Erzeugt Supplies, Munition, Treibstoff. |
| **Militärposten** | Hart verteidigter, optionaler Sektor. Schaltet bei Einnahme ein Elite-Fahrzeug frei. |
| **Elite-Fahrzeug** | Wertvolles Gerät der Armee, das erst über einen Militärposten baubar wird. |
| **FOB** | Vorgeschobene Basis der **Armee** (Liberation). Nie für die Miliz verwendet. |
| **Region** | Bereich um ein Nest, definiert durch dessen Einflussradius. |

## Miliz-Netzwerk

| Begriff | Bedeutung |
|---|---|
| **Nest** (`nest`) | Verdeckter Knoten der Miliz mit Effekt im Einflussradius. Ersetzt die Idee „OPFOR-FOB“. |
| **Nest-Typ** (`nestType`) | Kommandoposten (`command`), IED-Werkstatt (`iedWorkshop`), Waffenlager (`cache`), VBIED-Garage (`vbiedGarage`), Rekrutierungsstelle (`recruitment`). |
| **Gebäude-Nest** | Nest in einem vorhandenen Haus einer Ortschaft. |
| **Gelände-Nest** | Nest als kleines Lager im Gelände abseits der Ortschaften. |
| **Kernobjekt** | Das Objekt, dessen Zerstörung das Nest zerstört (Waffenkiste, Werkbank, Funkgerät …). |
| **Einflussradius** (`influenceRadius`) | Bereich, in dem ein Nest wirkt. |
| **Netzwerkstärke** (`networkStrength`) | Kennzahl aus allen aktiven Nestern. Bestimmt u. a. die Hauptstadt-Garnison und den Höchstwert der Readiness. |
| **Readiness** (`combat_readiness`) | Liberations Maß (0–100) dafür, wie aggressiv die Miliz auftritt: Besatzungen, Gegenangriffe, Patrouillen. |
| **Gegenangriff** | Angriff der Miliz auf befreite Sektoren oder FOBs (Liberation: „Battlegroup“). |
| **Camp** (`camp`) | Kleines, offenes Lager der Miliz im Gelände. Gehört zu einem Nest, wird nicht gespeichert, wechselt seine Position. |
| **Camp-Kapazität** (`campCapacity`) | Maximale Zahl gleichzeitiger Camps, berechnet aus den aktiven Nestern. |
| **Sperrzone** (`campExclusionRadius`) | Bereich um befreite Sektoren und FOBs, in dem keine Camps entstehen. |
| **Altfahrzeug** | Erbeuteter, veralteter Schützen- oder Transportpanzer der Miliz (z. B. BTR-60, M113). Kein Kampfpanzer. |
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
| **Intel-Punkte** (`resources_intel`) | Liberation-Ressource, mit der Nebenmissionen bezahlt werden. Nicht mit Intel verwechseln. |
| **Intel-Stufen** | Gerücht (groß) → Hinweis (mittel) → Konkreter Tipp (klein). Dazu: Warnung, Lüge. |
| **Triangulation** | Mehrere wahre Hinweise auf dasselbe Nest verkleinern den Markerkreis. |
| **Dokumente** | Intel-Gegenstand bei toten Anführern oder in zerstörten Nestern. |
| **Ruf** (`reputation`) | Globales Ansehen der Armee bei der Bevölkerung, Skala −100 bis +100. Ist Liberations „Civil Reputation“. |
| **Ruf-Band** | Einteilung des Rufs in niedrig, mittel und hoch, an der sich ruf-abhängige Regeln orientieren (ADR 0009). |
| **Gefälligkeit** (`favor`) | Unterstützung durch die Bevölkerung, die ab sehr hohem Ruf gesammelt und beim Ältesten eingelöst wird. |
| **Ältester** (`elder`) | Ansprechpartner in einer befreiten Ortschaft, bei dem über den Dolmetscher Gefälligkeiten angefordert und Hilfsaufträge angenommen werden. |
| **Auftrag** (`task`) | Zeitlich begrenzte Aufgabe der COIN-Schicht für die Armee. Arten: Hilfsauftrag, Aufklärungsauftrag. _Nicht:_ „Sidequest“. |
| **Hilfsauftrag** (`aidTask`) | Auftrag des Ältesten zur Unterstützung der Bevölkerung (z. B. Hilfsgüter, Arzt-Einsatz). Belohnung: Ruf. |
| **Aufklärungsauftrag** (`reconTask`) | Auftrag, der aus Befragung oder Verhör entsteht (z. B. Kurier abfangen). Belohnung: Intel, teils sinkende Readiness. |
| **Nebenmission** | Liberations eigene, mit Intel-Punkten gekaufte Missionen (Konvoi-Überfall, Rettung). Kein Auftrag im Sinne der COIN-Schicht. |
| **Lokale Kämpfer** (`localFighters`) | Freundliche Dorfwachen und Stammeskämpfer aus dem Widerstand, die über eine Gefälligkeit kommen. Führen Ablenkungsangriffe durch oder stoßen als Verstärkung dazu. |
| **Ablenkungsangriff** (`diversion`) | Angriff lokaler Kämpfer auf ein Ziel, der Miliz-Kräfte für eine Zeit dorthin abzieht. |
| **Verstärkung** (`reinforcement`) | Gruppe lokaler Kämpfer, die einem Spieler-Gruppenführer für begrenzte Zeit folgt. |
| **Informant** | Zivilist, der sich bei hohem Ruf von sich aus meldet und zu einer FOB gebracht werden muss (Liberation-Funktion). Liefert Intel-Punkte und Intel. |

## Technik

| Begriff | Bedeutung |
|---|---|
| **Upstream** | Das Original-Repo KP Liberation. |
| **Hook** | Stelle im Liberation-Code, an der unser Code eingehängt ist. Dokumentiert in `docs/hooks.md`. |
| **RPT** | Arma-Logdatei. Hauptquelle für Fehleranalyse. |
| **Preset** | Liberation-Datei, die Fraktionen (Einheiten, Fahrzeuge, Baulisten) festlegt. |
| **Template** | Gespeicherte Anordnung von Objekten relativ zu einem Mittelpunkt, aus der Gelände-Nester und Camps aufgebaut werden. |
