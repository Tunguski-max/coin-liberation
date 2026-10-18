# ADR 0001: KP Liberation als Basis (Fork)

**Status:** Akzeptiert (2026-10-17)

## Kontext
Wir wollen Liberation-Logistik (Ressourcen, FOB-Bau, Sektoren, Speichern) mit einer
asymmetrischen Schicht im Stil von Hearts and Minds verbinden. Optionen:
1. KP Liberation forken und erweitern
2. Hearts and Minds forken und Liberation-Logistik nachbauen
3. Komplett neu schreiben

## Entscheidung
Option 1: Fork von KP Liberation.

## Begründung
- Niklas will den größten Teil von Liberation übernehmen.
- MIT-Lizenz erlaubt Fork und Veränderung, solange die Lizenz erhalten bleibt.
- Lythium wird von Liberation bereits unterstützt (Missionsbasis vorhanden).
- Liberation enthält laut Changelog schon Ansätze für Ruf, Informanten und asymmetrische
  Bedrohungen, auf die wir aufbauen können (Prüfung in Phase 0).

## Folgen
- Wir müssen die Liberation-Codebasis verstehen (Ticket 0.4).
- Eingriffe in Liberation-Code minimal halten und in `docs/hooks.md` führen, damit Upstream-Updates möglich bleiben.
