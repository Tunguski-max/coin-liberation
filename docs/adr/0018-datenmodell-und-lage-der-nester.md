# ADR 0018: Datenmodell und Lage der Nester

**Status:** Akzeptiert (2026-10-19)

## Kontext
- Nester sind der erste persistente Zustand der COIN-Schicht (Eintrag 22, ADR 0005). Was einmal im Spielstand steht,
  lässt sich nur über eine neue `COIN_saveVersion` und eine Umwandlung alter Stände ändern.
- Nest-Objekte und Wachen spawnen nur bei Spielernähe und werden wieder abgebaut. Objekte lassen sich nicht speichern
  (`str` und `parseSimpleArray`, ADR 0005).
- Liberation wertet einen Sektor im Radius von 175 m aus (`KPLIB_fnc_getSectorOwnership`): Eingenommen wird er nur,
  wenn kaum Gegner darin sind. Ein befreiter Sektor gilt als angegriffen, sobald darin kein Spieler und mehr als
  3 Gegner sind; nach 20 Minuten ist er verloren (`lose_sectors.sqf`).

## Entscheidung
- **Ein Nest im Spielstand:** `[id, type, kind, pos, seed, state]`, der Block lautet `[COIN_saveVersion, [nest, ...]]`.
  `kind` ist `"building"` oder `"terrain"`, `state` ist `"active"` oder `"destroyed"`.
- **Aussehen über einen Zufallswert:** `seed` bestimmt Template, Ausrichtung und die Plätze von Kernobjekt und Requisiten.
  Ein Nest sieht bei jedem Besuch gleich aus, ohne dass Objekte gespeichert werden.
- **Werte nach Typ aus der Config:** Einflussradius und Bewachung stehen nicht im Spielstand, sondern kommen nach Typ
  aus `coin_config.sqf`.
- **Gebäude-Nester am Ortsrand:** nur in Ortschaften, in Häusern 250–600 m vom Sektormittelpunkt, also außerhalb
  von Liberations 175-m-Radius. Ein Gebäude-Nest bleibt aktiv, wenn die Armee seine Ortschaft einnimmt.

## Begründung
- Der Zufallswert hält den Spielstand klein und erlaubt trotzdem einen wiedererkennbaren Ort, an dem Spieler sich
  nach einem Rückzug orientieren können.
- Radius und Bewachung aus der Config: Balancing nach Testabenden (Phase 7) wirkt sofort auch in laufenden Kampagnen,
  ohne Umwandlung des Spielstands.
- Ortsrand: Wachen im 175-m-Radius würden die Einnahme blockieren. Nach der Einnahme würde ein spawnendes Nest den Ort
  als „angegriffen“ markieren, sobald Spieler sich nähern, ohne den Ortskern zu betreten, und die Ortschaft könnte
  verloren gehen.
- Aktiv nach Einnahme: Die Armee hält den Ort, das Netzwerk sitzt noch darin. Das passt zu Säule 1 und gibt der
  Bevölkerung in befreiten Ortschaften (Phase 3) etwas zu erzählen.

## Verworfene Alternativen
- **Objekte und Plätze einzeln speichern:** großer Spielstand, jede Änderung an Templates bricht alte Stände.
- **Radius und Bewachung im Spielstand:** jede Balancing-Änderung bräuchte eine Umwandlung oder gälte nur für neue Kampagnen.
- **Gebäude-Nester überall im Ort:** kollidiert mit Liberations Einnahme- und Verlust-Logik, ein Hook dort wäre ein tiefer Eingriff.
- **Gebäude-Nester in jeder Siedlung, auch ohne Sektor:** mehr Verstecke, aber dort gibt es keine Zivilisten und damit
  keine Befragung in der Nähe.
- **Einnahme der Ortschaft zerstört ihr Nest:** einfacher, entwertet aber Intel und Suche.

## Folgen
- Der Seed muss auf derselben Karte immer zum selben Ergebnis führen. Wer Templates nachträglich ändert, ändert das
  Aussehen bestehender Gelände-Nester; das ist erlaubt, weil nur `pos` und `state` für das Spiel zählen.
- Intel-Felder (Phase 3) kommen mit `COIN_saveVersion` 2 und einer Umwandlung von Version 1.
- Kleine Ortschaften ohne passende Häuser im Ring von 250–600 m bekommen kein Gebäude-Nest; die Verteilung weicht dann
  auf andere Ortschaften oder ein Gelände-Nest aus.
