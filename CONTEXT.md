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
| **Dolmetscher** (`interpreter`) | Spielerrolle (zwei Slots in der Führungsgruppe). Nur der Dolmetscher selbst befragt Zivilisten, andere Spieler bekommen keine Antwort. |
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
| **Gebäude-Nest** | Nest in einem vorhandenen Haus am Rand einer Ortschaft. |
| **Gelände-Nest** | Nest als kleines Lager im Gelände abseits der Ortschaften. |
| **Kernobjekt** | Das Objekt, dessen Zerstörung das Nest zerstört (Waffenkiste, Werkbank, Funkgerät …). |
| **Einflussradius** (`influenceRadius`) | Bereich, in dem ein Nest wirkt. |
| **Netzwerkstärke** (`networkStrength`) | Anteil der aktiven Nester an allen Nestern der Kampagne (0 bis 1, alle Nest-Typen gleich gewichtet). Bestimmt u. a. die Hauptstadt-Garnison und den Höchstwert der Readiness. |
| **Readiness** (`combat_readiness`) | Liberations Maß (0–100) dafür, wie aggressiv die Miliz auftritt: Besatzungen, Gegenangriffe, Patrouillen. |
| **Gegenangriff** | Angriff der Miliz auf befreite Sektoren oder FOBs (Liberation: „Battlegroup“). |
| **Camp** (`camp`) | Kleines, offenes Lager der Miliz im Gelände. Gehört zu einem Nest, wird nicht gespeichert, wechselt seine Position. |
| **Unentdeckt** (`undiscovered`) | Zustand eines Camps, in dessen Nähe seit seiner Entstehung noch kein Spieler war. Nur unentdeckte Camps wechseln ihre Position. |
| **Ausgehoben** (`cleared`) | Zustand eines Camps, in dessen Nähe kein Kämpfer des Camps mehr kampffähig ist (tot, gefangen, ergeben oder geflohen). _Nicht:_ „zerstört“, das gilt nur für Nester. |
| **Camp-Kapazität** (`campCapacity`) | Maximale Zahl gleichzeitiger Camps, berechnet aus den aktiven Nestern. |
| **Sperrzone** (`campExclusionRadius`) | Bereich um befreite Sektoren und FOBs, in dem keine Camps entstehen. |
| **Altfahrzeug** | Erbeuteter, veralteter Schützen- oder Transportpanzer der Miliz (z. B. BTR-60, M113). Kein Kampfpanzer. |
| **Budget** (`budget`) | Obergrenze, wie viele Bedrohungen eines aktiven Nests gleichzeitig im Feld sein dürfen. Was verbraucht ist (ausgelöst, entschärft), ersetzt das Nest nach einer Wartezeit (z. B. IED-Budget einer Werkstatt). Ein zerstörtes Nest ersetzt nichts mehr. _Nicht:_ ein endlicher Vorrat für die ganze Kampagne. |

## Bedrohungen

| Begriff | Bedeutung |
|---|---|
| **IED** | Improvisierte Sprengfalle an einer Straße, gelegt von einer IED-Werkstatt. Nur die Armee löst sie aus. Varianten: vergraben, ferngezündet, Attrappe. |
| **Auslöser** (`triggerman`) | Kämpfer in Zivil, der ein ferngezündetes IED aus Sichtweite zündet. Ist er ausgeschaltet, zündet das IED nicht mehr, muss aber noch entschärft werden. |
| **Attrappe** (`decoy`) | IED, das wie ein echtes aussieht und gefunden und entschärft werden kann, aber nie explodiert. Kostet Zeit, bringt beim Entschärfen keinen Ruf. |
| **VBIED** | Autobombe in einem zivilen Fahrzeug. |
| **Attentäter** (`suicideBomber`) | Zivilist mit Sprengweste. Kommt nur im Einflussradius einer IED-Werkstatt vor, wie oft, hängt am Ruf. |
| **Hinterhalt** (`ambush`) | Vorbereiteter Überfall an einer Straße, ausgehend von einem aktiven Camp. |
| **Kämpfer in Zivil** | Miliz-Einheit ohne sichtbare Waffe, bis es zum Kontakt kommt. |

## Intel und Bevölkerung

| Begriff | Bedeutung |
|---|---|
| **Gespräch** | Die Fragen des Dolmetschers an Zivilisten und Gefangene. Je Frage ein Eintrag im normalen Aktionsmenü (Scrollrad), nur für den Dolmetscher (z. B. „Nach der Miliz fragen“, „Verhören“). |
| **Befragung** (`questioning`) | Gespräch des Dolmetschers mit einem Zivilisten. _Nicht:_ bei Gefangenen, das ist ein Verhör. |
| **Verhör** (`interrogation`) | Gespräch mit einem Gefangenen. _Nicht:_ „Befragung“. |
| **Gefangener** (`prisoner`) | Kämpfer der Miliz, der sich ergeben hat, gefesselt ist oder mit Liberations Aktion CAPTURE in den Squad aufgenommen wurde. Gilt nicht als Zivilist, auch wenn Liberation ihn intern so führt. Läuft er aus dem Squad weg, ist er wieder ein normaler Gegner. |
| **Intel** | Hinweis auf ein Nest oder eine Bedrohung (Camp, ab Phase 4 auch IED und Hinterhalt). Erscheint als Kartenmarker. |
| **Intel-Punkte** (`resources_intel`) | Liberation-Ressource, mit der Nebenmissionen bezahlt werden. Nicht mit Intel verwechseln. |
| **Intel-Stufen** | Gerücht (groß) → Hinweis (mittel) → Konkreter Tipp (klein). Dazu: Warnung, Lüge. |
| **Lüge** | Intel-Marker, der wie ein echter aussieht, aber auf kein Nest zeigt. Verschwindet erst, wenn Spieler die Stelle durchsucht haben, an der das angebliche Nest liegen soll. |
| **Triangulation** | Mehrere wahre Hinweise auf dasselbe Nest verkleinern dessen einen Markerkreis. Lügen schrumpfen nie. |
| **Ruf** (`reputation`) | Globales Ansehen der Armee bei der Bevölkerung, Skala −100 bis +100. Ist Liberations „Civil Reputation“. |
| **Ruf-Band** | Einteilung des Rufs in niedrig, mittel und hoch, an der sich ruf-abhängige Regeln orientieren (ADR 0009). |
| **Stimmung** (`mood`) | Wie die Bevölkerung zur Armee steht, in Worten, abgeleitet aus dem Ruf in fünf Stufen: feindselig, misstrauisch, abwartend, freundlich, sehr freundlich. Erfährt nur der Dolmetscher mit „Wie steht ihr zu uns?“. _Nicht:_ „Haltung“ (das ist die Haltung des Widerstands), nicht dasselbe wie das Ruf-Band. |
| **Gefälligkeit** (`favor`) | Unterstützung durch die Bevölkerung, die ab sehr hohem Ruf (+50) gesammelt und beim Ältesten gegen Intel-Punkte eingelöst wird. Einzige Art: Verstärkung. |
| **Ältester** (`elder`) | Ansprechpartner in einer befreiten Ortschaft, bei dem über den Dolmetscher Gefälligkeiten angefordert und Hilfsaufträge angenommen werden. |
| **Auftrag** (`task`) | Zeitlich begrenzte Aufgabe der COIN-Schicht für die Armee. Arten: Hilfsauftrag, Zugriffsauftrag. _Nicht:_ „Sidequest“. |
| **Hilfsauftrag** (`aidTask`) | Auftrag des Ältesten zur Unterstützung der Bevölkerung (z. B. Hilfsgüter, Arzt-Einsatz). Belohnung: Ruf. |
| **Zugriffsauftrag** (`strikeTask`) | Auftrag, der aus Befragung oder Verhör entsteht und auf diese Information hin zugreift (z. B. Kurier abfangen, Anführer festnehmen). Belohnung: Intel, teils sinkende Readiness. _Nicht:_ „Aufklärungsauftrag“ (man klärt nicht auf, man greift zu). |
| **Nebenmission** | Liberations eigene, mit Intel-Punkten gekaufte Missionen (Konvoi-Überfall, Rettung), die der Dolmetscher beim Ältesten startet. Kein Auftrag im Sinne der COIN-Schicht. |
| **Lokale Kämpfer** (`localFighters`) | Freundliche Dorfwachen und Stammeskämpfer aus dem Widerstand, die über eine Gefälligkeit kommen und als Verstärkung zur Armee stoßen. _Nicht:_ Liberations spontane Guerilla-Einsätze in Sektorkämpfen. |
| **Verstärkung** (`reinforcement`) | Gruppe lokaler Kämpfer, die über eine Gefälligkeit kommt und für begrenzte Zeit per Funk geführt wird (folgen, hingehen, angreifen). Bleibt Widerstand, tritt keiner Spielergruppe bei. |
| **Informant** | Zivilist, der sich bei hohem Ruf von sich aus meldet und zu einer FOB gebracht werden muss (Liberation-Funktion). Liefert Intel-Punkte und Intel. |

## Technik

| Begriff | Bedeutung |
|---|---|
| **Upstream** | Das Original-Repo KP Liberation. |
| **Hook** | Stelle im Liberation-Code, an der unser Code eingehängt ist. Dokumentiert in `docs/hooks.md`. |
| **RPT** | Arma-Logdatei. Hauptquelle für Fehleranalyse. |
| **Preset** | Liberation-Datei, die Fraktionen (Einheiten, Fahrzeuge, Baulisten) festlegt. |
| **Template** | Gespeicherte Anordnung von Objekten relativ zu einem Mittelpunkt, aus der Gelände-Nester und Camps aufgebaut werden. |
