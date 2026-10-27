# ADR 0023: Ruf, Aufträge und Gefälligkeiten: Stimmung, Zugriffsaufträge ab +25, Verstärkung per Funk, alles mit Intel-Punkten beim Ältesten

**Status:** Akzeptiert (2026-10-23, geändert am 2026-10-25)

## Kontext
- Phase 5 macht den Ruf spürbar (DESIGN 8): neue Ruf-Änderungen, Stimmung über den Dolmetscher, Älteste, Hilfs- und
  Zugriffsaufträge, Gefälligkeiten (E12). Festgelegt beim Grilling am 2026-10-23.
- Liberation schickt den Widerstand ab |Ruf| ≥ 25 schon von sich aus in Sektorkämpfe (`sector_guerilla.sqf`, 35 %,
  ab +50 größere Gruppen).
- Liberation aktiviert einen Sektor nur bei BLUFOR in Reichweite (`manage_one_sector.sqf`). Seine Besatzungen hängen an
  dieser Sektor-Logik.
- Liberation speichert jede BLUFOR-Infanteriegruppe nahe einer FOB mit ihrer KI, auch KI in Spielergruppen
  (`fn_getSaveData.sqf`).
- Liberations Nebenmissionen startet man an einer FOB mit Berechtigung Nr. 5 und bezahlt sie mit Intel-Punkten.
- Gefangene aus Liberations Ergeben-Skript stehen in einer Zivilisten-Gruppe. Ihr Tod kostet bei Liberation schon −5.

## Entscheidung
- **Ablenkungsangriff gestrichen.** Die einzige Gefälligkeit ist die **Verstärkung** (E12, Schwelle +50).
- **Gefälligkeiten kosten doppelt:** Vorrat (ab +50 eine je 120 min mit Spieler online, höchstens 2, gespeichert)
  **und** 10 Intel-Punkte beim Einlösen. Einlösen geht ab Ruf +25.
- **Verstärkung bleibt Widerstand** (ADR 0012): 10 lokale Kämpfer in einer eigenen Gruppe, nicht in einer Spielergruppe.
  Gesteuert wird sie über das Kommunikationsmenü (0-8) mit „Folgt uns“, „Geht dorthin“, „Greift an“. Kein Hook in
  Liberations Sektor-Aktivierung: „Greift an“ trifft nur auf Miliz, wenn Spieler die Ortschaft aktivieren.
- **Der Älteste ist die eine Stelle für alles, was Intel-Punkte kostet:** Sein Dialog enthält Hilfsaufträge,
  Liberations Nebenmissionen (Konvoi-Überfall, Rettung) und die Verstärkung. Liberations Eintrag an der FOB entfällt
  (Hook mit Schalter). Starten darf nur der Dolmetscher.
- **Zugriffsaufträge** (statt „Aufklärungsaufträge“) entstehen nur ab Ruf +25, auch beim Verhör, weil sie die Readiness
  senken. Readiness −10 heißt 10 Punkte (Waffentransport: −20, geändert am 2026-10-27).
- **Stimmung in fünf Stufen** statt der drei Ruf-Bänder für die Antwort auf „Wie steht ihr zu uns?“: Die Stufen liegen auf
  den Schwellen, an denen sich im Spiel etwas ändert (−25, 0, +25, +50). Die Antwort ist immer wahr.
- **Ruf-Regeln:** Gefangener getötet kostet insgesamt immer −10 (bei Liberations Gefangenen −5 von Liberation und −5
  von uns). Von COIN erzeugte Fahrzeuge und Kämpfer in Zivil kosten keinen Ruf. Ein Haus, das nach der Einnahme einer
  Ortschaft zerstört wird, kostet nichts (2026-10-25, Täter nicht sicher zuzuordnen). Unsere Ruf-Änderungen erscheinen nur
  im Debug-Modus.

## Begründung
- Den Ablenkungsangriff gibt es schon fast in Form von Liberations Guerilla. Das Abziehen von Besatzungen würde Liberations
  Sektor-Logik aushebeln (Sektor gilt schneller als eingenommen) und bräuchte eigene Absicherung.
- Intel-Punkte als gemeinsame Währung beim Ältesten machen den Dolmetscher zur Drehscheibe und verhindern, dass die
  Verstärkung bei hohem Ruf zur Dauereinrichtung wird.
- Der Widerstand auf eigener Seite folgt dem Ruf von selbst (Abzug unter +25) und landet nicht in Liberations Save.
  Mit dem Funk lässt sich die Gruppe trotzdem führen.
- Zugriffsaufträge ab +25 binden das Senken der Readiness an Vertrauen: Wer die Bevölkerung nicht gewinnt, kommt nicht
  an die Miliz heran.
- Fünf Stufen zeigen den Spielern genau das, was sie wissen müssen: wann der Widerstand kippt und wann Informanten und
  Gefälligkeiten kommen.

## Verworfene Alternativen
- **Ablenkungsangriff gegen Liberations Guerilla tauschen:** Hook in `sector_guerilla.sqf` plus Abziehen von Besatzungen,
  zu viel Eingriff in Liberations Kern.
- **Verstärkung tritt der Spielergruppe bei:** mit Arma-Befehlen gut steuerbar, aber BLUFOR, braucht einen Filter-Hook im
  Save und kippt ADR 0012.
- **Sektor-Aktivierung durch lokale Kämpfer:** Hook in Liberations Sektor-Logik, abgelehnt.
- **Nebenmissionen an FOB und beim Ältesten:** zwei Wege für dasselbe, verwirrend.
- **„Grundloses Schießen nahe Zivilisten“ (−1), „Zivilist verletzt“:** gestrichen, schwer fair zu erkennen, Liberation
  bestraft getötete Zivilisten schon.

## Folgen
- Vor der ersten befreiten Ortschaft gibt es keinen Ältesten, also keine Nebenmissionen.
- Gefälligkeiten erweitern das Speicherformat (`COIN_saveVersion` 3). Aufträge und eine laufende Verstärkung werden
  nicht gespeichert.
- Die Zahl der Hilfsaufträge ist nur durch Wartezeit pro Ortschaft und 2 gleichzeitige begrenzt. Ob der Ruf damit zu
  schnell steigt, zeigt das Balancing (7.4).
