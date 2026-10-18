# ADR 0009: Ruf nutzt Liberations Civil Reputation

**Status:** Akzeptiert (2026-10-18)

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
- **Gefälligkeiten** ab etwa +50, endgültiger Wert im Spec zu Phase 5.
- **Gebäudeschäden:** Liberation rechnet nur bei der Einnahme ab. Zusätzlich kostet ein Gebäude in einer
  **befreiten** Ortschaft Ruf, wenn **BLUFOR** es zerstört hat (eigener Code, Phase 5).
- **Informanten:** Ihre Häufigkeit steigt mit dem Ruf. Unser Code setzt Liberations
  `KP_liberation_civinfo_*`-Werte je nach Band (kein Hook). Unter Ruf 25 gibt es weiterhin keine.
- Zivilisten töten kostet bereits bei Liberation Ruf. Wir ziehen dafür nicht zusätzlich ab.
- **Anzeige:** Die Zahl im Liberation-Overlay wird ausgeblendet (Hook). Spieler erfahren das Ruf-Band,
  indem der Dolmetscher Zivilisten fragt, wie sie zur Armee stehen (Ticket 5.3).

## Begründung
- Ein Wert statt zwei, Speicherung und Sync an Clients sind vorhanden.
- Ein verborgener Ruf, den man nur über die Bevölkerung erfährt, macht den Dolmetscher wichtiger.
- −20 liegt im Band „niedrig“ (viele Lügen, DESIGN 8 „Start: niedrig“), ohne den Widerstand feindlich
  zu machen. Bis „hoch“ sind es 45 Punkte, etwa neun befreite Ortschaften.
- Die Bänder fallen mit Liberations Schwelle +25 zusammen: „hoch“ = Informanten = freundlicher Widerstand.

## Folgen
- Bis Phase 4 legt Liberation bei −20 IEDs in feindlichen Sektoren (siehe ADR 0008).
- Der Ruf bleibt global. Ruf pro Ortschaft (E4) wäre eine spätere Erweiterung.
