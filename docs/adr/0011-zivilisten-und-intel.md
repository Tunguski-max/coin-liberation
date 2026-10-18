# ADR 0011: Zivilisten, Informanten und Intel-Punkte

**Status:** Akzeptiert (2026-10-18)

## Kontext
- Liberation spawnt Zivilisten nur in **nicht befreiten**, aktiven Sektoren und als Patrouillen fern von
  BLUFOR. Befreite Ortschaften sind leer, sobald die Armee dort steht.
- Liberations Informanten liefern nur die Ressource `resources_intel`, keinen Bezug zu Nestern.
- `resources_intel` bezahlt Liberations Nebenmissionen. Eine davon, „FOB Hunting“, baut eine feindliche
  Basis, also genau das „OPFOR-FOB“, das wir durch Nester ersetzt haben.

## Entscheidung
- **Jeder Zivilist ist befragbar**, auch Liberations. Zusätzlich spawnt COIN eine eigene Bevölkerung
  (inklusive Ältestem) in **befreiten** Ortschaften bei Spielernähe.
- **Informanten** bleiben Liberations Ablauf. Bei Ablieferung entsteht zusätzlich ein Intel zu einem
  aktiven Nest (Hook in `civinfo_delivered.sqf`).
- **Begriffe:** „Intel“ ist unser Hinweis auf ein Nest oder eine Bedrohung. Liberations Ressource heißt
  **„Intel-Punkte“**.
- **Nebenmission FOB Hunting** wird abgeschaltet (Hook). Konvoi-Überfall und Rettungsmission bleiben und
  werden weiter mit Intel-Punkten bezahlt.

## Begründung
- Befragungen, Ältester und Attentäter brauchen Menschen in den Orten, die die Armee hält.
- Informanten mit Nest-Bezug passen zu DESIGN 7 („Zivilist meldet sich selbst“).
- Feindbasen neben den Nestern würden das Netzwerk verwässern.

## Folgen
- Eigener Zivilisten-Spawner (Phase 3), muss sich das Budget aus ADR 0015 teilen.
