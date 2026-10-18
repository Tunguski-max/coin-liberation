# ADR 0005: Server ist Quelle der Wahrheit, Speichern über Liberation

**Status:** Vorgeschlagen

## Kontext
Neue Zustände (Nester, Intel-Marker, Budgets, Ruf) müssen im Multiplayer konsistent sein
und Server-Neustarts überleben.

## Entscheidung
- Alle Spielzustände der COIN-Schicht leben auf dem **Server**. Clients fragen an, der Server entscheidet.
- Persistenz läuft über den **bestehenden Speichermechanismus von Liberation**.
  Unsere Daten werden dort mit eingehängt, mit eigener Versionsnummer (`COIN_saveVersion`).

## Begründung
- Ein Speichersystem statt zwei: weniger Fehlerquellen, ein Reset-Weg.
- Server-autoritativ verhindert Desync und Doppel-Ereignisse.

## Folgen
- Der Einstiegspunkt in Liberations Speichern/Laden ist ein Hook (`docs/hooks.md`).
- Spec für das Speicherformat ist Teil von Ticket 2.1.
