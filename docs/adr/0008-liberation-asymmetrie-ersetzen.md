# ADR 0008: Liberations IEDs und Hinterhalte werden ersetzt

**Status:** Akzeptiert (2026-10-18)

## Kontext
Liberation bringt drei asymmetrische Bedrohungen mit (`docs/kp-liberation-map.md` Abschnitt 7.3):
1. IEDs in **feindlichen** Sektoren bei Ruf < 0 (`scripts/server/sector/ied_manager.sqf`)
2. IEDs und Guerilla-Hinterhalt in **befreiten** Ortschaften bei Ruf ≤ −25 (`scripts/server/asymmetric/asymmetric_loop.sqf`)
3. Überfälle auf KI-Logistikkonvois bei Ruf ≤ −25 (`scripts/server/asymmetric/convoy/`)

Teil 1 und 2 hängen nur am Ruf, sind zufällig, ohne Hinweise für Spieler und ohne Bezug zu Nestern.
Laufen sie weiter, ist die DoD von Phase 4 nicht erreichbar („nach Zerstörung der Werkstatt kommen dort
keine neuen IEDs mehr hinzu“).

## Entscheidung
- Teil 1 und 2 werden über einen Schalter in `coin_config.sqf` **abschaltbar** (Hooks in Phase 4).
  Standard: aus, sobald unsere nest-gespeisten Bedrohungen laufen.
- Teil 3 (Konvoi-Überfall) bleibt unverändert.
- Unsere Bedrohungen (DESIGN Abschnitt 6) werden neu gebaut. Liberations Muster „Mine + Näherungsprüfung
  an Straßen“ dient als Vorlage.

## Verworfene Alternativen
- **Behalten:** zwei IED-Quellen mit unterschiedlicher Logik, widerspricht „Gefahr ist lesbar“.
- **Umbauen** (Liberation-Skripte holen ihre Anzahl aus dem Nest-Budget): tiefere Eingriffe in
  Liberation-Logik, Hinweise und Auslöser müssten trotzdem neu gebaut werden.

## Folgen
- Bis Phase 4 läuft Liberations Verhalten unverändert (IEDs in feindlichen Sektoren bei Ruf < 0).
- Zwei Hooks: `_iedcount` in `manage_one_sector.sqf` und Start des Asymmetrie-Moduls in `init_server.sqf`.
