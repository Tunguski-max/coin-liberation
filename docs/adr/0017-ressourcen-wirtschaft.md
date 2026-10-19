# ADR 0017: Ressourcen-Wirtschaft auf der ausgedünnten Karte

**Status:** Akzeptiert (2026-10-19)

## Kontext
Liberations Ressourcen kommen vor allem aus Supply Points (`scripts/server/resources/manage_resources.sqf`):
Jeder eingenommene Supply Point mit Lager erzeugt eine Kiste (100) pro Intervall, und zwar nur **eine**
Sorte (Supplies, Munition oder Treibstoff). Das Intervall beträgt 30 Minuten geteilt durch den
Lobby-Parameter „Ressourcen-Multiplikator“. Dazu kommen einmalig 1–3 Kisten pro Ortschaft und Supply Point
beim ersten Aktivieren (mal Multiplikator, `fn_spawnSectorCrates.sqf`), Recycling (50 %) und Konvoi-Überfälle.

Die ausgedünnte Karte (ADR 0016) hätte nur 5 Supply Points und etwa 30 Sektoren mit Kisten statt 37 bzw. 110.
Bei unveränderten Preisen (AH-1Z: 500/500/200) zieht sich das Sammeln stark in die Länge.

Außerdem lost Liberation beim Kampagnenstart für jeden Supply Point **zufällig** eine Sorte aus
(`scripts/server/game/synchronise_eco.sqf`). Bei 5 Supply Points fehlt mit etwa 38 % Wahrscheinlichkeit
eine Sorte ganz (bei 8 noch etwa 12 %). Eine fehlende Sorte nachzubauen kostet 100 der beiden anderen
Sorten und 50 der fehlenden.

## Entscheidung
- **8 Supply Points** statt 5: 5 per Regel verteilt, 3 von Niklas ergänzt (Kandar Factory, Zarath Windpark,
  Kalae Factory). Siehe ADR 0016.
- **Lobby-Standard Ressourcen-Multiplikator x2** (Wert 6, Ticket 1.8): Intervall 15 Minuten, doppelt so
  viele Kisten in Sektoren. Der Multiplikator bleibt der Regler, falls es im Test zu zäh oder zu leicht ist.
- **Sorten ausgeglichen:** Nach Liberations Auslosung gleicht COIN die Sorten aus (Hook, Ticket 1.11): Solange die
  häufigste Sorte mehr als einen Supply Point mehr hat als die seltenste, stellt COIN einen zufälligen Supply Point der
  häufigsten auf die seltenste um. Bei 8 Supply Points ergibt das immer 3-3-2, jede Sorte kommt also mindestens
  zweimal vor. Geändert am 2026-10-19 nach dem ersten Test (Auslosung 5-2-1), vorher nur „jede Sorte mindestens einmal“.
- **Preise bleiben unverändert.**

## Begründung
- Der Multiplikator ist ein vorhandener Lobby-Parameter: kein Code, gilt für alle Quellen gleichmäßig.
- Mehr Supply Points geben Einkommen, Sortenvielfalt und lohnende Ziele.
- Preise einzeln zu senken hieße Dutzende Werte im Preset anzufassen, mit demselben Effekt wie der Multiplikator.

## Verworfene Alternativen
- Nur Multiplikator, 5 Supply Points: zu wenige Ziele, Sortenrisiko bleibt hoch.
- Preise im BLUFOR-Preset senken: aufwendig, schwer zu überblicken.

## Folgen
- Der Multiplikator verdoppelt auch Liberations Infanterie-Limit für die KI der Spieler (Grundwert 50 → 100).
- Mehr Supply Points heißen mehr Punkte, die Gegenangriffe abbekommen können.
- Ein weiterer Hook in Liberation (Auslosung der Sorten), Eintrag in `docs/hooks.md`.
