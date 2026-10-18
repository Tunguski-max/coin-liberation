# ADR 0002: Hearts and Minds nur als Ideengeber

**Status:** Vorgeschlagen

## Kontext
Hearts and Minds (Vdauphin/HeartsAndMinds) hat ausgereifte Systeme für Dolmetscher, Intel,
Ruf und IEDs. Das Repository enthält jedoch keine Lizenzdatei. Ohne Lizenz gilt rechtlich
„alle Rechte vorbehalten“, auch wenn der Code öffentlich einsehbar ist.

## Entscheidung
Wir übernehmen **Konzepte und Spielideen**, aber **keinen Code** aus Hearts and Minds.
Alle Systeme der asymmetrischen Schicht werden neu geschrieben, auf Basis von `docs/DESIGN.md`.

## Begründung
- Rechtlich sauber, auch wenn die Mission später geteilt wird (z. B. Steam Workshop).
- Unser Design weicht ohnehin ab (Nester mit Einflussradius, Kopplung an Liberation-Sektoren).

## Folgen
- Mehr Eigenentwicklung bei Intel und IEDs.
- Claude Code darf Hearts-and-Minds-Code nicht als Vorlage kopieren (steht in `CLAUDE.md`).
- Falls später eine Lizenz hinzukommt oder der Autor zustimmt, kann diese ADR überarbeitet werden.
