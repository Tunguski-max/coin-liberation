# ADR 0009: Ruf nutzt Liberations Civil Reputation

**Status:** Akzeptiert (2026-10-18, geändert am 2026-10-23 und 2026-10-25)

## Kontext
Liberation hat einen globalen, gespeicherten Ruf `KP_liberation_civ_rep` mit der Skala −100 … +100,
Start 0, geändert über `F_cr_changeCR` (`docs/kp-liberation-map.md` Abschnitt 7.1).
An festen Schwellen hängen Nebenwirkungen: Bei Ruf < −25 kämpft Liberations Widerstand auf Seiten der
Miliz, ab +25 auf unserer Seite und erst dann erscheinen Informanten.

## Entscheidung
- **Skala:** Wir übernehmen Liberations −100 … +100 ohne eigene Umrechnung. Unsere Ruf-Änderungen gehen
  über `F_cr_changeCR`.
- **Bänder** für ruf-abhängige Regeln (z. B. Intel-Gewichte):
  niedrig < 0 · mittel 0 bis < 25 · hoch ≥ 25.
- **Start:** Eine neue Kampagne beginnt bei **−20** (Hook, greift nur bei neuer Kampagne).
- **Gefälligkeiten** entstehen ab **+50** (endgültig seit 2026-10-23, ADR 0023).
- **Gebäudeschäden:** Kosten keinen Ruf (2026-10-25, Ticket 5.8 verworfen). Liberations Abrechnung bei der Einnahme (3 je
  fehlendem Haus) schalten wir ab (Lobby-Parameter „COIN: Disable building penalty“, Standard an): Die KI zerstört solche Häuser oft selbst. Nach der
  Einnahme lässt sich der Täter nicht sicher zuordnen, ein falscher Abzug wäre schlimmer als keiner.
- **Informanten:** Ihre Häufigkeit steigt mit dem Ruf. Unser Code setzt Liberations
  `KP_liberation_civinfo_*`-Werte (kein Hook): unter +25 weiterhin keine, von +25 bis unter +50 Liberations Werte,
  ab +50 doppelt so oft (2026-10-23).
- Zivilisten töten kostet bereits bei Liberation Ruf. Wir ziehen dafür nicht zusätzlich ab.
- **Anzeige:** Die ganze Ruf-Anzeige im Liberation-Overlay (Zahl und farbiges Symbol) wird ausgeblendet (Hook).
  Spieler erfahren die **Stimmung** in fünf Stufen, indem der Dolmetscher Zivilisten fragt, wie sie zur Armee stehen
  (Ticket 5.3; bis 2026-10-23 war das Ruf-Band gemeint, siehe ADR 0023).

## Begründung
- Ein Wert statt zwei, Speicherung und Sync an Clients sind vorhanden.
- Ein verborgener Ruf, den man nur über die Bevölkerung erfährt, macht den Dolmetscher wichtiger.
- −20 liegt im Band „niedrig“ (viele Lügen, DESIGN 8 „Start: niedrig“), ohne den Widerstand feindlich
  zu machen. Bis „hoch“ sind es 45 Punkte, etwa neun befreite Ortschaften.
- Die Bänder fallen mit Liberations Schwelle +25 zusammen: „hoch“ = Informanten = freundlicher Widerstand.

## Folgen
- Bis Phase 4 legt Liberation bei −20 IEDs in feindlichen Sektoren (siehe ADR 0008).
- Der Ruf bleibt global. Ruf pro Ortschaft (E4) wäre eine spätere Erweiterung.
