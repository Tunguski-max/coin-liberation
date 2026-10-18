# ADR 0007: Die Armee ist eine leichte Brigade

**Status:** Akzeptiert (2026-10-17), Teilfragen offen (E9, E10, E11)

## Kontext
Liberation bietet in den Standard-Presets nahezu alles bis hin zu Jets und Artillerie.
Das passt nicht zu einem asymmetrischen Konflikt gegen eine leicht bewaffnete Miliz
und nimmt der Aufklärung durch Dolmetscher und Intel ihren Sinn.

## Entscheidung
- Die Spieler rüsten sich als **leichte Brigade** aus. Die Bau- und Kauflisten werden über
  ein eigenes BLUFOR-Preset stark reduziert.
- **Ausgeschlossen:** fahrbare Artillerie (Panzerhaubitzen, Raketenwerfer) und Jets.
- **Offen:** Kampf- und Schützenpanzer (E9), abhängig davon, was die Miliz darf (E10);
  Mörser und Hubschrauber (E11).

## Begründung
- Die Asymmetrie soll spürbar bleiben: Probleme werden durch Aufklärung gelöst, nicht durch Feuerkraft.
- Weniger Fahrzeuge bedeuten auch weniger Last auf dem Server.

## Folgen
- Eigenes BLUFOR-Preset (Ticket 1.6), abgeleitet vom Liberation-Lythium-Preset.
- Liberation-Funktionen für Artillerieunterstützung und Luftangriffe prüfen und passend abschalten.
- Vorschlag zur Kopplung: Die Panzerfrage wird an die Ausrüstung der Miliz gebunden (`DESIGN.md` Abschnitt 10).
