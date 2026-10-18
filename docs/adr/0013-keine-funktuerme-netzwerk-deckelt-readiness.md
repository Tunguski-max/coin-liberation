# ADR 0013: Keine Funktürme, das Netzwerk deckelt die Readiness

**Status:** Akzeptiert (2026-10-18)

## Kontext
- Liberations Funktürme sind Quelle der feindlichen Verstärkung. In BLUFOR-Hand zeigen sie alle
  feindlichen Gruppen im Umkreis von 2,5 km als 500-m-Quadrate auf der Karte
  (`scripts/client/markers/hostile_groups.sqf`). Damit wären Nest-Wachen und Camps ohne Intel sichtbar.
- Liberations `combat_readiness` (0–100) steuert Besatzungen, Battlegroups und Patrouillen. Unsere
  Netzwerkstärke steuerte bisher nur Hauptstadt-Garnison und Camps.

## Entscheidung
- Im Kartenausschnitt gibt es **keine Funktürme** (`tower`-Sektoren). Die Verstärkungsquelle wird ab
  Phase 6 der Kommandoposten.
- Unser Server-Code begrenzt `combat_readiness` regelmäßig auf einen Höchstwert, der von den aktiven
  Nestern abhängt (Phase 6, kein Hook).

## Begründung
- Aufklärung läuft nur über Intel (Säule 1). Kein Eingriff in Liberation nötig.
- DESIGN 4 verspricht „Netzwerk schwächer → schwächere Gegenangriffe“. Der Deckel macht das auf der
  ganzen Karte spürbar, ohne Liberations Balancing zu ersetzen.

## Folgen
- Bis Phase 6 bekommen angegriffene feindliche Sektoren keine Verstärkung; die frühen Phasen sind etwas leichter.
- Die Formel für den Deckel wird im Spiel austariert.
