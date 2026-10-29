# Befragung, Verhör und Intel: wer wann was erfährt

Dieses Dokument erklärt in einem Stück, **wie COIN aus Gesprächen Wissen macht**: wer befragt oder verhört werden kann,
wann daraus Gerüchte, Hinweise, Konkrete Tipps, Warnungen und Lügen entstehen und was davon später noch dazukommt.
Es ist für Menschen geschrieben (Spieler, Tester, Design), nicht für den Code. Die Begriffe sind die aus `CONTEXT.md`.

Stand: 2026-10-25 (Code auf `master`; vom Rest von Phase 5 ist der Ruf-Anteil 5.7 und 5.1 gebaut).

**Wo steht was verbindlich?** Das Design steht in `docs/DESIGN.md` (Abschnitte 7 und 8), die Entscheidungen in
`docs/adr/` (vor allem 0011, 0021, 0023). Dieses Dokument fasst zusammen und bindet nichts. Bei Abweichungen gilt der Code,
dann das Design. Die Zahlen sind **Startwerte aus `Missionframework/coin/coin_config.sqf`** und ändern sich beim Balancing.

**Statuszeichen in den Tabellen**

| Zeichen | Bedeutung |
|---|---|
| ✅ | umgesetzt und im Spiel getestet (siehe `docs/ROADMAP.md`) |
| 🔧 | implementiert, noch nicht getestet oder noch nicht gemergt |
| 📋 | festgelegt, noch nicht gebaut (Ticket in Klammern) |

---

## 1. COIN in einem Absatz

Die Miliz hat ein verstecktes **Netzwerk aus Nestern** (Kommandoposten, IED-Werkstätten, Waffenlager, VBIED-Garagen,
Rekrutierungsstellen). Die Nester erzeugen **Camps** und **Bedrohungen** (IEDs, VBIEDs, Attentäter, Hinterhalte) und
bestimmen mit, wie stark die Miliz auftritt. Die Spieler sind die Armee und müssen die Nester erst **finden**. Dafür gibt es
den **Dolmetscher**: Er befragt Zivilisten und verhört Gefangene, daraus entstehen **Intel-Kreise** auf der Karte.
Wie viel die Bevölkerung verrät, hängt vom **Ruf** ab.

```
Zivilisten befragen / Gefangene verhören
        │                                   Ruf der Armee bei der Bevölkerung
        ▼                                   entscheidet über Wahrheit und Lügen
Kreis auf der Karte (Gerücht → Hinweis → Konkreter Tipp, dazu Warnung oder Lüge)
        │
        ▼
Weitere Treffer verkleinern den Kreis (Triangulation) → Nest finden und zerstören
        │
        ▼
Weniger Bedrohungen, schwächere Miliz, Ruf steigt → bessere Auskunft
```

| System | Was es tut | Status |
|---|---|---|
| Nester und Camps | Verteilen sich über die Karte, werden bei Spielernähe aufgebaut, Nester werden gespeichert | ✅ (Phase 2) |
| Dolmetscher, Befragung, Verhör, Intel | Gegenstand dieses Dokuments | ✅ (Phase 3) |
| Bedrohungen | IEDs, VBIEDs, Attentäter, Hinterhalte, gespeist aus den Nestern | ✅ (Phase 4) |
| Ruf | Liberations „Civil Reputation“: Start −20, Nest zerstört +5, IED entschärft +2 | ✅ (Phase 5, #99 und #100) |
| | Gefangener getötet −10 (#101) | ✅ |
| | Zivilfahrzeug zerstört −2, Beschlagnahmen ohne Abzug (#102) | ✅ |
| | Stimmung „Wie steht ihr zu uns?“ (#105) | ✔ implementiert, ungetestet |
| | Informanten-Häufigkeit nach Ruf (#106) | ✔ implementiert, ungetestet |
| Ältester, Hilfsaufträge, Nebenmissionen | Ansprechpartner in befreiten Ortschaften | 📋 (Phase 5, Block 5B) |
| Zugriffsaufträge | Aufträge, die aus einer Befragung oder einem Verhör entstehen | 📋 (Phase 5, Block 5C) |
| Gefälligkeit „Verstärkung“ | Lokale Kämpfer bei sehr hohem Ruf | 📋 (Phase 5, Block 5D) |
| Gegenangriffe, Hauptstadt, Readiness-Deckel | Folgen eines zerstörten Netzwerks | 📋 (Phase 6) |

---

## 2. Der Dolmetscher

- Es gibt **zwei Dolmetscher-Slots** in der Führungsgruppe. Die Rolle hängt am **Slot** (Rollenbeschreibung „Dolmetscher“), nicht
  an der Einheitenklasse, und bleibt nach einem Respawn erhalten.
- **Nur der Dolmetscher selbst** kann sprechen. Andere Spieler sehen kein Gespräch, bekommen keine Antwort und haben keinen
  Menüeintrag. Alle sehen aber die entstandenen Kartenmarker und den Hinweis „Neue Intel“ (ohne Inhalt).
- Fällt der Dolmetscher aus (tot, bewusstlos), gibt es keine Gespräche. Er ist ein Schutzobjekt.
- Die Gespräche laufen über das **normale Aktionsmenü** (Scrollrad), nicht über ACE. Der Eintrag erscheint nur, wenn der
  Dolmetscher jemanden aus der Nähe (**5 m**) ansieht, den er fragen darf.
- Der Dolmetscher muss selbst handlungsfähig sein: lebt, ist wach, steht zu Fuß (nicht im Fahrzeug).

---

## 3. Wer kann befragt werden („Nach der Miliz fragen“)?

Befragen kann der Dolmetscher **Zivilisten**. Welche es gibt:

- Liberations Zivilisten (in umkämpften Ortschaften und auf Patrouille),
- die **eigene Bevölkerung** von COIN: 4–8 Zivilisten im Ortskern jeder befreiten Ortschaft, die entstehen, sobald Spieler
  in der Nähe sind, und neu entstehen, wenn man wiederkommt (✅ 3.7). Dazu kommt ein **Ältester** pro Ortschaft (5.9a, im Spiel bestätigt): Er steht fest an einer Moschee oder dem größten Haus nahe dem Ortskern, trägt eigene Kleidung und heißt „Ältester …“. Wird er getötet, hat die Ortschaft `COIN_elderAbsenceMinutes` (60) keinen, danach kommt beim nächsten Besuch ein neuer.

### 3.1 Zustände: wer ist befragbar?

| Zustand des Zivilisten | Befragbar? | Was passiert |
|---|---|---|
| Lebt, wach, zu Fuß, Zivilisten-Seite, Dolmetscher ≤ 5 m und schaut ihn an | **ja** ✅ | Er bleibt stehen und schaut den Dolmetscher an (bis zu 30 s), dann kommt die Antwort |
| Schon einmal befragt | nein | **Einmal pro Zivilist**, auch wenn er nichts wusste |
| Gerade im Gespräch | nein | |
| Bewaffneter Gegner (lebend, nicht gefangen, nicht bewusstlos) **≤ 100 m** | **verweigert** | Er redet nicht, **wird aber nicht verbraucht**: Der Dolmetscher kann ihn später wieder fragen |
| Der Dolmetscher hat Abklingzeit | **vertröstet** | „Nicht jetzt. Hier sind zu viele Augen.“ Der Zivilist bleibt unbefragt (siehe 3.3) |
| Im Fahrzeug | nein | |
| Bewusstlos oder kampfunfähig | nein | |
| Tot | nein | |
| Spieler | nein | |
| Gefesselt oder ergeben (ACE), auch Liberations **Informant**, solange er auf Abholung wartet | nein | Der Informant hat einen eigenen Ablauf (siehe Abschnitt 6) |
| Miliz-Kämpfer in ziviler Gruppe (z. B. ein Gegner, der sich ergeben hat) | nein | Das ist ein Gefangener, er wird verhört (Abschnitt 4) |
| **Kämpfer in Zivil** (Auslöser, VBIED-Fahrer, Attentäter) | nein | Er sieht aus wie ein Zivilist, ist aber keiner |
| **Ältester** | nein, nicht zur Miliz (5.9a, im Spiel bestätigt) | Er hat „Wie steht ihr zu uns?“; „Können wir helfen?“ öffnet den Dialog (5.9b). Alle anderen Zivilisten fragt man „Wo finde ich den Ältesten?“: Der Älteste (im Umkreis `COIN_elderLocateRange`, 600 m) wird für alle `COIN_elderMarkerSeconds` (5 min) auf der Karte markiert, ohne Befragung, Markierung oder Abklingzeit; ohne Ältesten sagt der Zivilist das (im Spiel bestätigt) |
| **Patienten** des Arzt-Einsatzes | nein (5.11, im Spiel bestätigt) | `COIN_patient`, `COIN_fnc_canQuestion` lässt sie aus |

### 3.2 Ablauf einer Befragung

1. Der Dolmetscher zielt auf einen befragbaren Zivilisten (≤ 5 m) und wählt **„Nach der Miliz fragen“**.
2. Der Server prüft alle Regeln **noch einmal** (der Client kann nichts erschleichen), prüft die Abklingzeit und markiert den
   Zivilisten als befragt.
3. Nach **1–2 s** wird das Ergebnis ausgewürfelt (Abschnitt 5) und der Zivilist antwortet als **Untertitel**, nur beim
   Dolmetscher, mit Name und Satz. Der Satz hängt vom Ergebnis ab, bei Hinweis und Tipp auch vom Nest-Typ (ohne ihn zu nennen).
4. Entsteht ein Marker (auch eine Lüge oder Warnung), erscheint für alle „Neue Intel“ und die **Abklingzeit** des
   Dolmetschers beginnt.
5. Der Zivilist bleibt noch ~5 s (Lesezeit) und geht dann weiter.

### 3.3 Abklingzeit

- Nach jeder Befragung oder jedem Verhör, das einen **Marker** erzeugt (auch Lüge, auch Warnung), muss **derselbe Dolmetscher**
  **5 Minuten** warten.
- „Ich weiß nichts“ und eine Verweigerung starten **keine** Abklingzeit.
- Sie gilt pro Spieler (Spieler-ID), übersteht den Respawn und wird nicht gespeichert. Ein zweiter Dolmetscher hat seine eigene.
- Grund: Liberation erzeugt bei jeder Sektoraktivierung neue Zivilisten. Ohne Bremse ließe sich eine Ortschaft abgrasen.

### 3.4 „Wie steht ihr zu uns?“ (Stimmung) ✔ implementiert, ungetestet (5.3, #105)

Ein zweiter Eintrag im Aktionsmenü, nur für den Dolmetscher, bei befragbaren Zivilisten (beim Ältesten kommt er mit 5.9a). Es gelten dieselben Regeln wie für „Nach der Miliz fragen“ (zu Fuß, ansprechbar, kein Gefangener, kein Kämpfer in Zivil), nur ohne „einmal pro Zivilist“: auch ein schon befragter Zivilist antwortet. Die Antwort kommt nach 1–2 s als Untertitel beim Dolmetscher (`COIN_fnc_askMood`, Texte in `COIN_moodAnswers`, Schalter `COIN_enableMood`); im RPT steht Ruf und Stufe:

- **beliebig oft**, zählt nicht als Befragung, **keine Abklingzeit**, erzeugt **kein** Intel,
- die Antwort nennt die **Stimmung** in fünf Stufen und ist **immer wahr**:

| Ruf | Stimmung | Was es im Spiel heißt |
|---|---|---|
| unter −25 | feindselig | Der Widerstand kämpft für die Miliz |
| −25 bis unter 0 | misstrauisch | Viele Lügen |
| 0 bis unter 25 | abwartend | Gemischte Intel |
| 25 bis unter 50 | freundlich | Informanten, Zugriffsaufträge, Widerstand auf unserer Seite |
| ab 50 | sehr freundlich | Gefälligkeiten entstehen |

Die **Ruf-Zahl im Overlay ist ausgeblendet** (#104, nur mit COIN Debug sichtbar). Spieler erfahren den Ruf nur noch über die Stimmung.

---

## 4. Wer kann verhört werden („Verhören“)?

Verhören kann der Dolmetscher **Gefangene**. Ein Gefangener ist ein **Kämpfer der Miliz** (die Infanterieklassen des
Gegner-Presets), der

- **ergeben** ist (Liberations Ergeben-Skript lässt Gegner am Sektorende mit 80 % Chance die Hände heben), oder
- **mit ACE gefesselt** ist, oder
- **mit Liberations „CAPTURE“ in den Squad aufgenommen** wurde (✅ #101).

Nicht verhörbar sind Kämpfer in Zivil (sie haben Zivilisten-Klassen) und alle, die weder gefesselt noch ergeben noch
aufgenommen sind. Die Piloten der Rettungsmission haben nach den Klassenlisten keine Miliz-Klasse und wären damit auch
keine Gefangenen; das ist im Spiel nicht geprüft.

### 4.1 Zustände: wer ist verhörbar?

| Zustand des Gefangenen | Verhörbar? | Bemerkung |
|---|---|---|
| Mit ACE gefesselt (Miliz-Gruppe), lebt, wach, zu Fuß | **ja** ✅ | auch Wachen aus Nestern und Camps |
| Ergeben durch Liberations Skript (Zivilisten-Gruppe, Hände oben) | **ja** ✅ | |
| Per CAPTURE im Squad | **ja** ✅ (#101) | Liberation beendet das Ergeben, danach hat er keinen ACE-Zustand mehr; COIN erkennt ihn an seiner Gruppe |
| Nach Abgabe an der FOB (sitzt bis zu 600 s in einer Zivilisten-Gruppe) | **ja** ✅ (#101) | danach löscht Liberation ihn |
| Nach CAPTURE aus dem Squad weggelaufen (> 100 m von Nicht-Miliz-Einheiten) | nein | Liberation macht ihn wieder zum Gegner |
| Kampfbereiter Gegner | nein | |
| Schon verhört | nein | **Einmal pro Gefangenem**, auch wenn er nichts sagte |
| Gerade im Gespräch | nein | |
| Im Fahrzeug | nein | |
| Bewusstlos, kampfunfähig, tot | nein | |
| Spieler | nein | |
| Der Dolmetscher hat Abklingzeit | **vertröstet** | wie bei der Befragung; der Gefangene bleibt unverhört |

**Unterschiede zur Befragung:** Ein Gefangener verweigert **nie** wegen Gegnern in der Nähe, und seine Gewichte hängen **nicht**
vom Ruf ab (ein Gefangener gehört nicht zur Bevölkerung). Entfernung, Dolmetscher-Regeln und Abklingzeit sind gleich.

### 4.2 Ablauf eines Verhörs

1. Dolmetscher zielt auf den Gefangenen (≤ 5 m), wählt **„Verhören“**.
2. Server prüft die Regeln, die Abklingzeit, markiert ihn als verhört.
3. Nach 1–2 s gibt es **genau ein Ergebnis** (seit 2026-10-29, gegen die doppelte Belohnung; `COIN_interrogationSecondChance` steht auf 0) mit eigenen Gewichten (Abschnitt 5.2).
4. Würde ein zweites Ergebnis wieder eingeschaltet, betreffen **beide dasselbe Nest**, und ein zweites wahres Ergebnis verkleinert nur den Kreis. Ein Zugriffsauftrag nach dem Verhör bleibt möglich (Entscheidung Niklas 2026-10-29, keine doppelte Belohnung).
5. **Welches Nest er nennt:**
   - Ein **Kämpfer aus einem Camp** nennt das **Nest seines Camps** (die Spur vom Camp zum Nest läuft über das Verhör).
   - Eine **Nest-Wache** nennt ein **anderes** Nest, nicht das, das sie bewacht.
   - Ein **Mörserschütze** nennt das Nest des **Kommandopostens**, in dessen Aufmarschraum sein Trupp stand; stand er nur im Aufmarschraum eines Militärpostens, folgt er der allgemeinen Regel.
   - Alle anderen (Ergebene, Aufgenommene) folgen der allgemeinen Regel („Welches Nest“, Abschnitt 5.3).
6. Der Gefangene antwortet mit eigenen Sätzen, es gilt die Abklingzeit.

### 4.3 Wie jemand zum Gefangenen wird, und was das einbringt

| Weg | Wie | Intel-Punkte (Liberation) |
|---|---|---|
| **ACE-Fesseln** | Kämpfer fesseln (am besten ergeben oder ohne Waffe) | keine, auch nicht an der FOB |
| **Ergeben, dann CAPTURE** | Nach der Befreiung eines Sektors heben die Gegner die Hände, die Aktion „CAPTURE“ (Liberation) nimmt sie in den Squad auf | an der FOB (< 30 m, nicht im Fahrzeug): 3–6 Punkte bei Klassen der Miliz-Liste, danach sitzt er bis zu 600 s, dann gelöscht |
| **Ergeben, nur stehen lassen** | Er bleibt mit Händen oben stehen | keine; Liberation räumt den Sektor ~11 min nach der Befreiung auf |

Das Verhör selbst ist unabhängig von den Intel-Punkten: Liberations Belohnung bleibt, wie sie ist, das Verhör kommt dazu.

Für das **Töten** von Gefangenen gibt es zusätzlich Ruf-Abzüge (insgesamt −10, ✅ #101, siehe `docs/DESIGN.md` Abschnitt 8).

---

## 5. Was bei einem Gespräch entstehen kann

### 5.1 Die Ergebnisarten

| Ergebnis | Was der Spieler sieht | Kreis | Bezieht sich auf | Gespeichert? | Verschwindet |
|---|---|---|---|---|---|
| **Ich weiß nichts** | nur Untertitel | kein Marker | | | |
| **Gerücht** | Kreis mit neutralem Symbol („Miliz-Versteck“) | **600 m** | Nest | ja | mit dem Nest |
| **Hinweis** | Kreis mit **Symbol des Nest-Typs** | **300 m** | Nest | ja | mit dem Nest |
| **Konkreter Tipp** | Kreis mit Symbol | **100 m** | Nest | ja | mit dem Nest |
| **Warnung** | **rotes** Warnsymbol, eigene Meldung „WARNUNG“ | 150 m (Camp, Hinterhalt), 100 m (IED) | Bedrohung in der Nähe | **nein** | mit der Bedrohung |
| **Lüge** | sieht aus wie ein Gerücht, Hinweis oder Tipp, zufälliger Nest-Typ und Größe | wie die Stufe | **nichts** (Ersatzpunkt) | ja | wenn ein Spieler zu Fuß am Ersatzpunkt war |

Gemeinsam bei den wahren Kreisen (ADR 0021):

- Das Nest liegt **immer im Kreis, aber nie in der Mitte** (die Mitte ist um 20–80 % des Radius versetzt).
- **Ein Kreis pro Nest.** Jeder weitere wahre Treffer auf dasselbe Nest **verkleinert** ihn (Faktor 0,5, nie größer als die Stufe
  des neuen Treffers, nie kleiner als 50 m). Das ist die **Triangulation**: Ein geschrumpfter Kreis ist sicher wahr, denn zwei
  Quellen bestätigen sich.
- **Lügen schrumpfen nie** und haben einen **verborgenen Ersatzpunkt** (Ortsrand oder freies Gelände, höchstens 4 km vom
  Sprecher). War ein Spieler **zu Fuß** nahe daran (~50 m), gilt das Gebiet als durchsucht und der Marker verschwindet **ohne
  Meldung**. Fahrzeuge und Hubschrauber suchen nicht.
- Eine Lüge ist für den Spieler **nicht** von einer Wahrheit zu unterscheiden.

**Warnungen** (Phase 3 und 4, ✅):

| Bedrohung | Reichweite des Sprechers | Kreis |
|---|---|---|
| Camp | 1500 m | 150 m |
| IED (auch Attrappe, der Zivilist weiß es nicht besser) | 1000 m | 100 m |
| Hinterhalt eines aktiven Camps | 1000 m | 150 m |

Jede Bedrohung bekommt **höchstens einen** Warnkreis. Gibt es in Reichweite keine Bedrohung ohne Kreis, bleibt es bei „Ich weiß
nichts“. Unter mehreren Bedrohungen entscheidet der Zufall.

### 5.2 Wann entsteht welches Ergebnis? (Gewichte)

Jedes Gespräch würfelt ein Ergebnis nach Gewichten, die zusammen 100 ergeben (also Prozent).

**Befragung eines Zivilisten, nach Ruf-Band**

| Ruf-Band | Ruf | Nichts | Gerücht | Hinweis | Tipp | Warnung | **Lüge** |
|---|---|---|---|---|---|---|---|
| niedrig | unter 0 | 40 | 15 | 5 | 0 | 5 | **35** |
| mittel | 0 bis unter 25 | 30 | 25 | 20 | 5 | 10 | 10 |
| hoch | ab 25 | 20 | 20 | 30 | 15 | 12 | 3 |

Der Ruf startet bei **−20**: Anfangs lügt mehr als jeder Dritte, und es gibt keinen einzigen Konkreten Tipp. Wer die Bevölkerung
gut behandelt, kommt ins mittlere und hohe Band.

**Verhör eines Gefangenen** (unabhängig vom Ruf)

| Ergebnis | Nichts | Gerücht | Hinweis | Tipp | Warnung | Lüge |
|---|---|---|---|---|---|---|
| 1. Ergebnis (immer) | 0 | 15 | 30 | **40** | 7 | 8 |
| 2. Ergebnis (derzeit aus, Chance 0) | 25 | 20 | 25 | 20 | 5 | 5 |

Das **erste Ergebnis ist nie „Ich weiß nichts“**, solange es ein aktives Nest gibt: Scheitert eine gewürfelte Lüge oder
Warnung (kein Platz, keine Bedrohung), wird stattdessen eine wahre Stufe gewählt.

### 5.3 Voraussetzungen und Rückfälle

| Situation | Folge |
|---|---|
| Es gibt **kein aktives Nest** | Es gibt nichts zu verraten: immer „Ich weiß nichts“ |
| **Lüge** gewürfelt, aber kein glaubhafter Ersatzpunkt gefunden (40 Versuche) | „Ich weiß nichts“ (beim Verhör: wahre Stufe) |
| **Warnung** gewürfelt, aber keine Bedrohung ohne Kreis in Reichweite | „Ich weiß nichts“ (beim Verhör: wahre Stufe) |
| Schalter `COIN_enableLies` / `COIN_enableWarnings` aus | Das Gewicht zählt als „Nichts“ |
| Befragung mit bewaffneten Gegnern ≤ 100 m | Verweigerung, Zivilist nicht verbraucht |

**Welches Nest?** Ein **zufälliges aktives Nest im Umkreis von 4 km** um den Sprecher. Gibt es dort keins, das **nächste aktive Nest
auf der Karte**. So zählt die Geografie, und am Ende lassen sich auch die letzten Nester finden.

### 5.4 Ein Beispiel

Ruf −20 (niedrig), der Dolmetscher befragt einen Zivilisten in einer Ortschaft, 3 km von zwei aktiven Nestern:

1. Würfel: 35 % Lüge → es entsteht ein Kreis (zum Beispiel „Hinweis, Waffenlager, 300 m“) um einen verborgenen Ersatzpunkt am
   Ortsrand, der Spieler sieht ihn wie jeden anderen.
2. Der Dolmetscher hat 5 Minuten Abklingzeit.
3. Ein Spieler zu Fuß geht zum Kreis, steht ~50 m vom Ersatzpunkt: Der Marker verschwindet ohne Meldung. Die Lüge war enttarnt,
   ohne dass es jemand gesagt hat.
4. Ein ergebener Kämpfer eines Camps wird verhört: Er nennt das Nest seines Camps (Konkreter Tipp, 100 m). Der Kreis um dieses
   Nest ist der erste, also entsteht er in voller Größe. Ein zweiter Treffer (Zivilist, Tipp) auf dasselbe Nest würde ihn verkleinern.

---

## 6. Alle Quellen für Intel im Überblick

| Quelle | Wann | Was entsteht | Status |
|---|---|---|---|
| **Befragung** (Zivilist) | Dolmetscher fragt einen befragbaren Zivilisten, Abschnitt 3 | alle Arten nach Ruf-Band | ✅ |
| **Verhör** (Gefangener) | Dolmetscher verhört einen Gefangenen, Abschnitt 4 | 1–2 Ergebnisse, Tipps bevorzugt, nie vom Ruf abhängig | ✅ |
| **Informant** (Liberation) | Ab **Ruf +25** meldet sich gelegentlich ein Zivilist, der zur FOB gebracht werden muss | **immer ein Konkreter Tipp**, nie eine Lüge, zählt als wahrer Treffer; zum aktiven Nest, das der Ortschaft des Informanten am nächsten liegt und noch keinen Kreis hat (sonst das nächste); dazu Liberations Intel-Punkte und Ruf +2 | ✅ (Tipp), ✔ Häufigkeit nach Ruf (5.2) ungetestet |
| **Zugriffsauftrag „Kurier abfangen“** | Erfolg: Auto gestoppt, „Dokumente durchsuchen“ | Konkreter Tipp zum Nest des Kuriers | 📋 (5.14) |
| **Zugriffsauftrag „Anführer festnehmen“** | Erfolg: Anführer gefesselt oder ergeben | Readiness −10; sein **Verhör** bringt als erstes Ergebnis immer einen Konkreten Tipp zum Kommandoposten | 📋 (5.15) |
| **Zugriffsauftrag „Waffentransport abfangen“** | Erfolg: Lkw zerstört oder gestoppt | Konkreter Tipp zum Ziel-Lager, Readiness −10 | 📋 (5.16) |
| **Zugriffsauftrag „Export“** | Erfolg: Flugzeug zerstört | Readiness −10, kein Intel | 📋 (5.18) |
| ~~Dokumente als ACE-Intel-Items~~ | verworfen am 2026-10-22 (zu viele Hinweise ohne Bremse) | | – |
| *Optional später* | Foto des Hauses statt Kreis bei Gebäude-Nestern | | 📋 |

**Hinweis:** „Intel“ ist immer der Kartenhinweis auf ein Nest oder eine Bedrohung. Liberations Ressource heißt **Intel-Punkte** und
bezahlt Nebenmissionen und (ab Phase 5) die Gefälligkeit „Verstärkung“.

---

## 7. Wie lange ein Marker lebt

| Marker | Entsteht | Verschwindet | Gespeichert |
|---|---|---|---|
| Wahrer Kreis (Gerücht, Hinweis, Tipp) | Befragung, Verhör, Informant | **sobald sein Nest zerstört ist** (automatisch); wird durch weitere Treffer kleiner | ja, übersteht Neustart |
| Lüge | Befragung, Verhör | wenn ein Spieler zu Fuß ~50 m am Ersatzpunkt war, ohne Meldung | ja |
| Warnung | Befragung, Verhör | sobald ihre Bedrohung weg ist (Camp ausgehoben, umgezogen, entfernt; IED explodiert oder entschärft; Hinterhalt ausgehoben), geprüft alle 10 s | **nein**: Camps, IEDs und Hinterhalte werden auch nicht gespeichert |

Die Intel-Marker gelten für **die ganze Seite** (alle Spieler sehen sie), auch für später beitretende.

---

## 8. Was noch dazukommt (Phase 5 bis 7)

| Thema | Was sich bei Gesprächen und Intel ändert | Ticket |
|---|---|---|
| **Ruf-Änderungen** | Neue Ruf-Quellen: Nest zerstört +5, Gefangener getötet −10, Zivilfahrzeug zerstört −2. Beschlagnahmen und zerstörte Häuser kosten nichts (auch Liberations Abzug bei der Einnahme ist aus). Der Ruf verschiebt die Gewichte aus 5.2 | 5.1 ✅ (Nest, Gefangener, Zivilfahrzeug); 5.8 verworfen |
| **Stimmung** | „Wie steht ihr zu uns?“ beim Zivilisten (Abschnitt 3.4), beim Ältesten mit 5.9a | 5.3 ✔ ungetestet |
| **Informanten-Häufigkeit** | Unter +25 keine, ab +25 Liberations Werte (alle 90–180 min ein Versuch, 75 %), ab +50 alle 45–90 min mit 100 % | 5.2 ✔ ungetestet. Ein Server-Loop setzt Liberations `KP_liberation_civinfo_*`, es gilt ab dem nächsten Intervall, das Liberation würfelt (`COIN_fnc_informantFrequencyLoop`, Schalter `COIN_enableInformantFrequency`) |
| **Ältester** | Pro befreiter Ortschaft einer, nicht zur Miliz befragbar; getötet → 60 min kein Ältester | 5.9a ✅ |
| **Dialog des Ältesten** | „Können wir helfen?“ (5.9b, 5.10 und 5.11 im Spiel bestätigt, 5.12 umgesetzt, ungetestet: Dialog nach Vorbild von Liberations Nebenmissions-Dialog, ein eigener erbt dessen Layout; Hilfsaufträge „Hilfsgüter liefern“, „Arzt-Einsatz“ und „Infrastruktur reparieren“; pro Ortschaft ein Auftrag, danach 60 min Wartezeit, höchstens 2 gleichzeitig, 60 min Zeitlimit; läuft die Zeit ab oder stirbt der Älteste, scheitert der Auftrag und der Ruf, den er gebracht hätte, wird abgezogen (`COIN_aidFailurePenaltyFactor`); Schalter `COIN_enableAidTasks`). Weiter: Nebenmissionen (Liberations Konvoi-Überfall und Rettung, bezahlt mit Intel-Punkten), Gefälligkeit | 5.17 📋 |
| **Zugriffsaufträge** | Mit **15 %** zusätzlich bei einer Befragung (Ergebnis außer „Ich weiß nichts“) oder einem Verhör, **nur ab Ruf +25**, höchstens einer gleichzeitig. Der Sprecher erzählt davon, ein Dialog mit einem Eintrag öffnet sich, ohne „Annehmen“ ist die Gelegenheit weg. Beginn 15–25 min nach dem Annehmen, Fenster 30–60 min | 5.13 📋 |
| **Gefälligkeiten und Verstärkung** | Ab Ruf **+50** alle 120 min eine Gefälligkeit (höchstens 2 auf Vorrat, gespeichert, `COIN_saveVersion` 3); Verstärkung kostet eine Gefälligkeit und 10 Intel-Punkte. 10 lokale Kämpfer, per Funk geführt | 5.4, 5.6, 5.19 📋 |
| **Readiness** | Netzwerkstärke deckelt Liberations Readiness; jedes zerstörte Nest senkt sie sofort; einige Zugriffsaufträge −10 | Phase 6 📋 |
| **Dedicated Server, Mehrspieler** | Zusätzlich zu testen: Menüeintrag und Untertitel nur beim Dolmetscher, Marker bei später Beitretenden, getrennte Abklingzeit pro Dolmetscher | 7.5 📋 |

**Die Ruf-Schwellen auf einen Blick**

| Ruf ab | Was sich ändert |
|---|---|
| −100 | Skala von −100 bis +100, Start −20 |
| unter **−25** | Der Widerstand kämpft für die Miliz (grünes Kopftuch statt blau) |
| **0** | Band „mittel“ statt „niedrig“: weniger Lügen, die ersten Konkreten Tipps |
| **25** | Band „hoch“ (viele Hinweise, wenige Lügen), Informanten erscheinen, Zugriffsaufträge entstehen, der Widerstand steht auf unserer Seite, Verstärkung ist abrufbar |
| **50** | Gefälligkeiten entstehen, Informanten doppelt so oft |

Fällt der Ruf wieder unter +25, ziehen aktive lokale Kämpfer ab.

---

## 9. Wo die Werte stehen

Alles in `Missionframework/coin/coin_config.sqf`. Wichtige Namen:

| Thema | Variablen |
|---|---|
| Ein/Aus | `COIN_enableQuestioning`, `COIN_enableInterrogation`, `COIN_enableMood`, `COIN_enableInformantFrequency`, `COIN_enableLies`, `COIN_enableWarnings`, `COIN_enableIEDWarnings`, `COIN_enableAmbushWarnings`, `COIN_enableUnsafeRefusal`, `COIN_enableCooldown`, `COIN_enableInformantTip`, `COIN_enablePopulation` |
| Reichweiten und Zeiten | `COIN_talkRange` (5 m), `COIN_talkHoldSeconds` (30 s), `COIN_questionDelay` ([1, 2] s), `COIN_answerReadSeconds`, `COIN_unsafeRadius` (100 m), `COIN_questionCooldown` (300 s), `COIN_intelNestRange` (4000 m) |
| Kreise | `COIN_intelRadiusRumor` (600), `COIN_intelRadiusHint` (300), `COIN_intelRadiusTip` (100), `COIN_intelRadiusMin` (50), `COIN_triangulationFactor` (0,5), `COIN_intelCenterOffset` ([0,2; 0,8]) |
| Gewichte | `COIN_intelWeightsLow` / `Mid` / `High`, `COIN_intelWeightsByBand`, `COIN_interrogationWeights`, `COIN_interrogationSecondChance` (0) |
| Warnungen | `COIN_warningKinds` (Art, Reichweite, Radius, Satz), `COIN_warningCheckInterval` (10 s) |
| Lügen | `COIN_lieTownShare` (0,5), `COIN_lieSpotTries` (40), `COIN_lieSearchDistance` (50 m), `COIN_lieSearchInterval` (3 s) |
| Ruf-Bänder | `COIN_repBandMid` (0), `COIN_repBandHigh` (25), `COIN_moodThresholds` ([−25, 0, 25, 50]), `COIN_reputationStart` (−20) |
| Sätze | `COIN_questionAnswers`, `COIN_questionAnswersByType`, `COIN_interrogationAnswers` und die Sätze für die Abklingzeit |
| Bevölkerung | `COIN_populationCount` ([4, 8]), `COIN_populationRadius` (80 m) |
| Hilfsaufträge | `COIN_enableAidTasks`, `COIN_aidTaskMaxActive` (2), `COIN_aidTaskCooldownMin` (60), `COIN_aidTaskTimeoutMin` (60), `COIN_repAidSupplies` (5), `COIN_aidSupplyDistance` (20), `COIN_aidSupplyMinValue` (100), Texte `COIN_aidTaskTexts`, `COIN_aidReasonTexts`, `COIN_elderSentences` |
| Ältester | `COIN_enableElder`, `COIN_enableElderLocate`, `COIN_elderLocateRange`, `COIN_elderMarkerSeconds`, `COIN_elderLocateAnswers`, `COIN_elderAbsenceMinutes` (60), `COIN_elderSearchRadius`, `COIN_elderBuildingKeywords`, `COIN_elderUniforms`, `COIN_elderHeadgear`, `COIN_elderNameFormat` |

---

## 10. Offene Punkte

Dinge, die in diesem Dokument noch nicht eindeutig sind und beim Bauen entschieden werden:

- **Gefangene und Intel-Punkte:** Mit ACE gefesselte Gefangene bringen heute **keine** Intel-Punkte an der FOB, nur Liberations
  Ergeben-Weg über CAPTURE. Ob das so bleiben soll, ist offen.
- **Gewichtung nach Art bei Warnungen:** Unter mehreren Bedrohungen entscheidet der reine Zufall. Ein IED-Gebiet drückt dadurch die
  Chance eines Hinterhalts; eine Gewichtung kommt nach mehr Spielerfahrung (ROADMAP 4.5).
- **Texte:** Die Sätze der Zivilisten und Gefangenen sind teils noch nicht im Spiel gesehen oder nur zum Teil abgestimmt.
- **Mehrspieler** (7.5): Alles in diesem Dokument ist lokal mit einem Spieler getestet, nicht mit zwei Dolmetschern auf dem
  Dedicated Server.
