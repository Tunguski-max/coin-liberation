# ADR 0021: Intel-Datenmodell, ein Kreis pro Nest und Lügen mit Ersatzpunkt

**Status:** Akzeptiert (2026-10-22)

## Kontext
- Intel-Marker sind nach den Nestern der zweite persistente Zustand der COIN-Schicht (Eintrag 22, ADR 0005, ADR 0018).
  Was im Spielstand steht, lässt sich nur über eine neue `COIN_saveVersion` und eine Umwandlung ändern.
- Triangulation (DESIGN 7) soll mehrere wahre Hinweise auf dasselbe Nest zu einem kleineren Kreis machen.
- Lügen sollen wie echte Marker aussehen. Wahre Marker verschwinden mit ihrem Nest, Lügen erst, wenn Spieler das
  Gebiet durchsucht haben (ADR 0011). „Durchsucht“ braucht einen Ort, an dem man nachgesehen hat.

## Entscheidung
- **Speicherformat Version 2:** `[2, [nest, ...], [intel, ...]]` mit `intel = [id, nestId, center, radius, level, shownType, fakePos]`.
  Bei einer Lüge ist `nestId` −1 und `fakePos` der Ersatzpunkt, bei wahren Markern ist `fakePos` leer.
  Ein Spielstand mit Version 1 wird beim Laden umgewandelt und bekommt eine leere Intel-Liste.
- **Nicht gespeichert:** Warnungen (sie zeigen auf Camps, die nicht persistent sind), „schon befragt“ (die Einheiten
  verschwinden ohnehin) und die Abklingzeit des Dolmetschers.
- **Ein Kreis pro Nest:** Jeder weitere wahre Treffer verkleinert den vorhandenen Kreis (alter Radius × Faktor, nie größer
  als die Stufe des neuen Treffers, nie kleiner als ein Mindestwert). Das Nest liegt immer im Kreis, aber nicht in der Mitte;
  der neue Kreis liegt möglichst im alten.
- **Lügen** sind einzelne Kreise und schrumpfen nie. Jede Lüge hat einen verborgenen **Ersatzpunkt** auf glaubhaftem Gelände
  (Ortsrand oder freies Gelände), um den ihr Kreis gebaut wird wie bei einem echten Nest. Sie verschwindet ohne Meldung,
  sobald ein Spieler zu Fuß nahe am Ersatzpunkt war.

## Begründung
- Ein Kreis pro Nest hält die Karte lesbar und setzt die Triangulation aus dem Design direkt um.
- Dass ein geschrumpfter Kreis sicher wahr ist, ist gewollt („zwei Quellen bestätigen“): Wer mehr fragt, weiß mehr (Säule 1).
- Der Ersatzpunkt macht „durchsucht“ eindeutig und entspricht dem, was ein Spieler bei einem wahren Marker tut: Er geht
  dorthin, wo das Nest wäre, und findet nichts.
- Warnungen und Abklingzeiten gehören zu einer Sitzung, ihr Speichern brächte nur Format-Ballast.

## Verworfene Alternativen
- **Jedes Ergebnis ein eigener Kreis**, Spieler triangulieren selbst: weniger Code, aber eine volle Karte, und Lügen wären
  kaum zu erkennen.
- **Lügen schrumpfen ebenfalls** (mehrere Lügen auf denselben Ersatzpunkt): Lügen wären nie zu entlarven, das würde den Ruf
  als Stellgröße entwerten und bräuchte ein „Phantom-Nest“ im Spielstand.
- **Lüge verschwindet nach Zeit** oder beim Betreten des Kreises: Zeit verrät die Lüge, und ein Kreis von 600 m wäre schon
  beim Durchfahren „durchsucht“.

## Folgen
- Die Umwandlung von Version 1 auf 2 ist der erste Fall dieser Art; spätere Versionen folgen demselben Muster.
- Wer `COIN_triangulationFactor` oder die Radien ändert, ändert nur neue Treffer, gespeicherte Kreise bleiben, wie sie sind.
- Die Debug-Anzeige zeigt bei Intel-Markern wahr oder gelogen, die Nest-ID und den Ersatzpunkt, sonst wäre eine Lüge im Test
  nicht zu erkennen.
