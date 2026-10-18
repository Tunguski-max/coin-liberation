# ADR 0002: Hearts and Minds nur als Ideengeber

**Status:** Akzeptiert (2026-10-18)

## Kontext
Hearts and Minds (Vdauphin/HeartsAndMinds) hat ausgereifte Systeme für Dolmetscher, Intel,
Ruf und IEDs. Das Repository enthält jedoch keine Lizenzdatei. Ohne Lizenz gilt rechtlich
„alle Rechte vorbehalten“, auch wenn der Code öffentlich einsehbar ist.

## Entscheidung
Wir übernehmen **Konzepte und Spielideen**, aber **keinen Code** aus Hearts and Minds.
Alle Systeme der asymmetrischen Schicht werden neu geschrieben, auf Basis von `docs/DESIGN.md`.

## Begründung
- Rechtlich sauber, auch wenn die Mission später geteilt wird (z. B. Steam Workshop). Forks des Repos
  ändern daran nichts: Auch geforkte Fassungen haben keine Lizenz (geprüft 2026-10-18).
- Unser Design weicht ohnehin ab (Nester mit Einflussradius, Kopplung an Liberation-Sektoren).
- H&M ist ein eigenständiges Framework (eigener Ruf, eigene Städte, eigenes Speichern). Übernommener Code
  müsste so stark an Liberation angepasst werden, dass der Vorteil gegenüber einem Neubau klein ist.
  Die Mechaniken selbst sind einfach; ACE liefert die schweren Teile (Interaktion, Fesseln, Entschärfen).

## Verworfene Alternative
- Code mit Nennung übernehmen: Eine Nennung ersetzt keine Lizenz. Bei einem öffentlichen Repo droht im
  schlimmsten Fall eine DMCA-Meldung, die das ganze Repo betrifft.

## Folgen
- Mehr Eigenentwicklung bei Intel und IEDs. Am meisten Testaufwand erwartet bei KI-Verhalten
  (Attentäter, VBIED, Hinterhalt) und glaubwürdiger IED-Platzierung.
- Hearts and Minds wird in der README als Inspiration genannt.
- Claude Code darf Hearts-and-Minds-Code nicht als Vorlage kopieren (steht in `CLAUDE.md`).
- Falls später eine Lizenz hinzukommt oder der Autor zustimmt, kann diese ADR überarbeitet werden.
