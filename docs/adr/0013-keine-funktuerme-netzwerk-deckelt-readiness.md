# ADR 0013: Keine Funktürme, das Netzwerk deckelt die Readiness

**Status:** Akzeptiert (2026-10-18), ergänzt durch ADR 0025 (2026-10-28)

## Kontext
- Liberations Funktürme sind Quelle der feindlichen Verstärkung. In BLUFOR-Hand zeigen sie alle
  feindlichen Gruppen im Umkreis von 2,5 km als 500-m-Quadrate auf der Karte
  (`scripts/client/markers/hostile_groups.sqf`). Damit wären Nest-Wachen und Camps ohne Intel sichtbar.
- Liberations `combat_readiness` (0–100) steuert Besatzungen, Battlegroups und Patrouillen. Unsere
  Netzwerkstärke steuerte bisher nur Hauptstadt-Garnison und Camps.

## Entscheidung
- Auf der Karte gibt es **keine Funktürme** (`tower`-Sektoren), siehe auch ADR 0016. Quelle für Entsatz und Gegenangriffe
  werden ab Phase 6 die **Aufmarschräume**: Kommandoposten und Militärposten in Miliz-Hand (ADR 0025).
- Unser Server-Code begrenzt `combat_readiness` regelmäßig auf einen Höchstwert, der von den aktiven
  Nestern abhängt (Phase 6, kein Hook; Formel `25 + 75 × Netzwerkstärke`, ADR 0025).
- Zusätzlich senkt ein **zerstörtes Nest die Readiness sofort** um einen Wert je Nest-Typ (z. B. 10,
  Kommandoposten 20; ergänzt 2026-10-18). Einige Zugriffsaufträge senken sie um 10 Punkte, der Waffentransport um 20 (umbenannt 2026-10-23, ADR 0023; Waffentransport 2026-10-27).
  Die Readiness bleibt im Overlay sichtbar.

## Begründung
- Aufklärung läuft nur über Intel (Säule 1). Kein Eingriff in Liberation nötig.
- DESIGN 4 verspricht „Netzwerk schwächer → schwächere Gegenangriffe“. Der Deckel macht das auf der
  ganzen Karte spürbar, ohne Liberations Balancing zu ersetzen.
- Der Deckel allein wirkt erst, wenn die Readiness über ihm liegt. Der sofortige Abzug gibt direktes
  Feedback und übernimmt die Rolle der abgeschalteten Nebenmission „FOB Hunting“ (ADR 0011).

## Folgen
- Bis Phase 6 bekommen angegriffene feindliche Sektoren keine Verstärkung; die frühen Phasen sind etwas leichter.
- Die Formel für den Deckel wird im Spiel austariert.
