# ADR 0025: Aufmarschräume: Gegenangriffe, Entsatz und Mörserangriffe kommen aus Kommandoposten und Militärposten

**Status:** Akzeptiert (2026-10-28). Ergänzt ADR 0013.

## Kontext
- ADR 0013 hat die Funktürme entfernt und als künftige Quelle der feindlichen Verstärkung „den Kommandoposten“ genannt.
  Seitdem bekommt kein angegriffener Miliz-Sektor Entsatz (`reinforcements_manager.sqf` sucht nur Funktürme).
- Liberation spawnt Gegenangriffe an einem `opfor_point` 2–3 km vom Ziel (`KPLIB_fnc_getOpforSpawnPoint`), ohne Bezug
  zu Nestern.
- Es gibt nur 2 Kommandoposten mit je 2500 m Einflussradius, zusammen etwa 10 % von Lythium.
- Der Readiness-Deckel aus ADR 0013 hatte noch keine Formel.

## Entscheidung
- **Aufmarschraum** (CONTEXT.md): der Einflussradius eines aktiven Kommandopostens **oder** der Umkreis (Startwert 2000 m)
  eines Militärpostens, den die Miliz hält. Er endet, wenn das Nest zerstört oder der Militärposten eingenommen ist.
  Erobert die Miliz einen Militärposten zurück, ist er wieder ein Aufmarschraum (wir folgen Liberations Besitz).
- **Gegenangriffe:** Der Gegenangriff nach einer Einnahme und die zufälligen Battlegroups starten nur an einem Spawnpunkt
  im Aufmarschraum. Gibt es keinen, entfällt der Gegenangriff. Der Gegenangriff nach der Einnahme der Hauptstadt bleibt
  ohne Bedingung. Patrouillen bleiben unverändert, sie folgen der gedeckelten Readiness.
- **Entsatz:** Der nächste Aufmarschraum, der den angegriffenen Sektor enthält, ersetzt den Funkturm in Liberations Ablauf
  (Wartezeit nach Abstand, laufende Patrouillen werden umgeleitet). Fallschirmjäger gibt es keine (keine Hubschrauber, ADR 0014).
- **Mörserangriff:** nur auf eine FOB in einem Aufmarschraum (DESIGN 9).
- **Readiness-Deckel:** `25 + 75 × Netzwerkstärke` (Boden in der Config), ein Server-Loop prüft regelmäßig.

## Begründung
- Mit dem Filter am Spawnpunkt reicht ein Aufmarschraum etwa 5 km über seinen Rand hinaus. Die Geografie zählt: Wer einen
  Kommandoposten zerstört oder einen Militärposten einnimmt, macht eine ganze Gegend spürbar ruhiger.
- Militärposten sind sichtbare Ziele und werden so zu mehr als einer Fahrzeug-Freischaltung. Kalae Barracks an der
  Hauptstadt hält deren Umgebung bis zum Endkampf aktiv.
- Der Boden von 25 verhindert, dass Liberation am Ende nur noch schwache „militia“-Trupps schickt.

## Verworfene Alternativen
- **Ziel im Radius eines Kommandopostens:** Es würden nur etwa 10 % der Karte angegriffen, also praktisch nie.
- **Global, solange ein Kommandoposten aktiv ist:** einfach, aber die Geografie zählt nicht.
- **Nur Kommandoposten:** zu wenig Fläche, Militärposten blieben ohne Wirkung auf die Miliz.
- **Deckel rein proportional (`100 × Netzwerkstärke`):** Die Readiness fiele am Ende auf 0.

## Folgen
- Hooks in `spawn_battlegroup.sqf` (Spawnpunkt, dazu höchstens 1 Altfahrzeug) und `reinforcements_manager.sqf` (Entsatz).
- Ohne Aufmarschraum in der Nähe gibt es weder Gegenangriff noch Entsatz noch Mörserangriff. Ob das zu ruhig wird, zeigt das Balancing (Phase 7).
