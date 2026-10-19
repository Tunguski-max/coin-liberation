# ADR 0007: Die Armee ist eine leichte Brigade

**Status:** Akzeptiert (2026-10-17), E9 und E11 entschieden (2026-10-18), M113A3 (M2, Mk19) als Elite-Fahrzeuge und M113A3 Medical als freie Ausnahme ergänzt (2026-10-19)

## Kontext
Liberation bietet in den Standard-Presets nahezu alles bis hin zu Jets und Artillerie.
Das passt nicht zu einem asymmetrischen Konflikt gegen eine leicht bewaffnete Miliz
und nimmt der Aufklärung durch Dolmetscher und Intel ihren Sinn.

## Entscheidung
- Die Spieler rüsten sich als **leichte Brigade** aus (Preset RHS USAF Desert). Die Bau- und Kauflisten
  werden über ein eigenes BLUFOR-Preset stark reduziert.
- **Ausgeschlossen:** jede Artillerie außer Mörsern (Panzerhaubitzen, Raketenwerfer, gezogenes Geschütz
  M119A2), Jets und Transportflugzeuge, AH-64D, große Drohnen, Kettenfahrzeuge (Ausnahme: Bergepanzer
  CRV-6e Bobcat als Reparaturfahrzeug, und der M113A3: Medical frei kaufbar, M2 und Mk19 als Elite-Fahrzeug), Luftabwehrsystem MIM-145, Boote.
- **Erlaubt:** Radfahrzeuge, statische Waffen inklusive Mörser, kleine Drohnen (Darter, Pelican),
  Hubschrauber außer AH-64D (inklusive UH-1Y Ground Suppression).
- **Elite-Fahrzeuge** (je eines pro Militärposten, freigeschaltet durch dessen Einnahme):
  M113A3 (M2), M113A3 (Mk19), Stryker M1126, Stryker M1134 (TOW), AH-1Z, AH-6M. Das sind genau die 6 Militärposten.
- **AH-1Z und AH-6M:** je höchstens einer gleichzeitig, 30 Minuten Sperre ab Kauf, Sperre wird nicht
  gespeichert. Werte pro Klasse in `coin_config.sqf` (Hook im Kaufmenü, Ticket 1.9).
- Keine Kampfpanzer für die Spieler. Gegen die Kampfpanzer der Hauptstadt helfen Panzerabwehr der
  Infanterie und der Stryker M1134.

## Begründung
- Die Asymmetrie soll spürbar bleiben: Probleme werden durch Aufklärung gelöst, nicht durch Feuerkraft.
- Weniger Fahrzeuge bedeuten auch weniger Last auf dem Server.
- Die ganze Karte ist Einsatzgebiet (ADR 0016): Hubschrauber sind für die Wege nötig, bewaffnete nur
  begrenzt und als Belohnung.

## Folgen
- Eigenes BLUFOR-Preset (Ticket 1.6), abgeleitet vom Liberation-Lythium-Preset.
- Liberations Artillerieunterstützung ist per Lobby-Standard aus (`SuppMod` = 0, Ticket 1.8).
- Kopplung an die Miliz: Die Miliz hat Kampfpanzer nur in der Hauptstadt (ADR 0014), die Spieler
  bekommen dafür Radpanzer über die Elite-Liste.
