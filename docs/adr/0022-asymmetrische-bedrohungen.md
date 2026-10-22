# ADR 0022: Asymmetrische Bedrohungen: nicht gespeichert, Kämpfer in Zivil auf der Zivilisten-Seite, eigene Umsetzung

**Status:** Akzeptiert (2026-10-22)

## Kontext
- Phase 4 bringt IEDs, VBIEDs, Selbstmordattentäter und Hinterhalte, alle gespeist aus Budgets aktiver Nester (DESIGN 6).
  Die DoD verlangt: Nach Zerstörung der Werkstatt kommen in ihrer Region keine neuen IEDs mehr hinzu.
- Auslöser, VBIED-Fahrer und Attentäter sollen wie Zivilisten wirken. ACE zeigt „Get Down!“ und „Go Away!“ nur an Einheiten
  der Zivilisten-Seite (`side group _target == civilian`), eine Miliz-Einheit in Zivil fehlte also im Menü und wäre erkannt.
- Liberation zieht Ruf für getötete Zivilisten nur bei Einheiten ab, die den Kill-Manager tragen
  (`KPLIB_fnc_createManagedUnit`, `MPKilled`).
- Drongos Map Population (erlaubte Mod) hat Module für Selbstmordattentäter und VBIED.

## Entscheidung
- **Nicht gespeichert:** IEDs sind echte Objekte auf der Karte, VBIEDs, Attentäter und Hinterhalte entstehen zur Laufzeit.
  Weder sie noch ihre Wartezeiten kommen in den Spielstand. Nach einem Neustart legen die aktiven Nester ihr Budget neu,
  wie bei Camps bleibt der Fortschritt über die Nester erhalten. `COIN_saveVersion` bleibt unverändert.
- **Kämpfer in Zivil auf der Zivilisten-Seite:** Auslöser, VBIED-Fahrer und Attentäter stehen technisch auf der
  Zivilisten-Seite, ohne Liberations Kill-Manager. Ihr Tod kostet keinen Ruf. Wer einen echten Zivilisten für einen von
  ihnen hält und erschießt, verliert Ruf wie bisher.
- **Eigene Umsetzung:** Attentäter und VBIED bauen wir selbst. Von Drongos Map Population nutzen wir nur die Sounddatei für
  den Ruf vor der Explosion, ohne die Mod bleibt er still.

## Begründung
- 25 IED-Objekte kosten kaum Leistung. Gespeichert wäre ein neues Speicherformat mit Umwandlung nötig, ohne spielerischen
  Gewinn: Wer neu startet, bekommt neue IEDs an anderen Stellen, das Netzwerk dahinter ist dasselbe.
- Die Zivilisten-Seite ist die einzige Möglichkeit, dass sich ein Kämpfer in Zivil im ACE-Menü nicht verrät. Ohne Ruf-Abzug
  wird das Ausschalten einer echten Bedrohung nicht bestraft.
- Das DMP-Modul braucht eine feindliche Seite (es sucht Ziele über `targets`) und läuft über einen internen Skriptpfad
  (`DMP\Scripts\SuicideBomber\AI.sqf`), keine angebotene Funktion. Budget, Nest-Bezug, Ruf-Band und Spawn außer Sicht
  müssten wir ohnehin selbst bauen; das Verhalten selbst ist klein.

## Verworfene Alternativen
- **IEDs als gespeicherte Datensätze, die bei Spielernähe spawnen** (wie Nester): mehr Code und eine neue Speicherversion
  für wenige kleine Objekte.
- **Kämpfer in Zivil auf der Miliz-Seite:** einfacher (keine Sonderregel beim Ruf), aber das ACE-Menü verrät sie.
- **DMP-Module nutzen:** passt nicht zur Zivilisten-Seite und bricht unbemerkt, wenn DMP sein Skript ändert.

## Folgen
- Ein Neustart füllt alle IED-Budgets wieder auf. Das nehmen wir in Kauf, Neustarts mitten in einer Region sind selten.
- Code, der Zivilisten zählt oder auswählt (Befragung, Bevölkerungs-Budget, Liberations Zivilisten), darf Kämpfer in Zivil
  nicht als Zivilisten behandeln. Sie tragen eine eigene Markierung.
- Explosionen von IEDs und VBIEDs sollen keinen Ruf kosten, auch wenn sie Zivilisten töten: Der Täter ist nicht die Armee.
  Ob Liberations Kill-Manager das bei einer per Skript gezündeten Ladung so sieht, prüfen wir im Test von 4.1.
