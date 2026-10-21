# ADR 0020: Gelände-Nester nach Templates

**Status:** Akzeptiert (2026-10-21)

## Kontext
- Gelände-Nester standen bisher nur als Daten im Spielstand und spawnten nichts (#30). Ticket #31 bringt die
  Template-Mechanik für Gelände-Nester, die später auch Camps nutzen.
- Gebäude-Templates (ADR 0019) beziehen sich auf das Hausmodell. Im Gelände gibt es kein Haus, also braucht das
  Template einen eigenen Bezugspunkt.
- Gelände-Nester liegen an einer freien Stelle mit höchstens 15 % Steigung auf 15 m (#29). Ganz eben ist sie selten.
- Das Ticket nannte `BIS_fnc_objectsGrabber`. DESIGN 5 legt schon fest, dass Gelände-Templates mit demselben Export
  entstehen wie Gebäude-Templates.

## Entscheidung
- **Format wie bei Gebäuden:** `COIN_terrainTemplates pushBack [Typ, [[Klasse, [rechts, vorne, Höhe über dem Boden],
  Richtung, Rolle], ...]]` in `coin_templates.sqf`. Typ ist ein Nest-Typ oder `"camp"`. Nest-Templates haben genau ein
  Kernobjekt, Camp-Templates keines. Rollen wie in ADR 0019 (`core`, `prop`, `vehicle`, `mine`).
- **Bezugspunkt ist ein Richtungspfeil** (`Sign_Arrow_Direction_F`) in der Mitte des Lagers, seine Spitze ist „vorne“.
  Niklas setzt ihn in Eden, der Export nimmt alles bis 15 m um ihn und lässt ihn selbst weg (entschieden 2026-10-21).
- **Ausrichtung und Auswahl über den Seed:** Der Seed wählt eines der Templates des Typs und dreht es beliebig um die
  Nest-Position. Ein Nest sieht bei jedem Besuch gleich aus.
- **Geländeanpassung:** Jedes Objekt behält seine Höhe über dem Boden und kippt mit dem Gelände unter ihm
  (Oberflächennormale), behält dabei seine Richtung (entschieden 2026-10-21).
- **Wachen dynamisch:** etwa die Hälfte steht an freien Stellen in einem Ring 6–12 m um die Mitte und schaut nach
  außen, der Rest patrouilliert wie beim Gebäude-Nest (entschieden 2026-10-21). Keine Wachenplätze im Template.
- Ein Nest-Typ ohne gültiges Gelände-Template spawnt als Gelände-Nest nicht (eine Fehlerzeile), bis eines eingetragen
  ist. Für den Anfang gibt es je ein Platzhalter-Template von Claude.

## Begründung
- Gleiches Format und gleiche Prüfung wie bei Gebäuden: ein Weg zum Bauen, eine Platzierungsfunktion.
- Der Pfeil ist in Eden sichtbar und genau, die Mitte und „vorne“ lassen sich später wiederfinden. Die Spielerposition
  wäre ungenau und nicht wiederholbar.
- Mit der Hangneigung liegen Zelte, Netze und Kisten auch an der zulässigen Steigung auf, ohne eigene Bodensuche.
  Gestapeltes kippt mit seiner Unterlage.
- Die dynamischen Wachen haben sich bei Gebäude-Nestern bewährt (ADR 0019) und machen keine Arbeit pro Template.

## Verworfene Alternativen
- **`BIS_fnc_objectsGrabber`:** anderes Format als die Gebäude-Templates, kein Kernobjekt, eigene Umwandlung nötig.
- **Spielerposition als Bezug:** kein Hilfsobjekt, aber ungenau und nicht wiederholbar.
- **Nur Höhe, aufrecht:** einfacher, am Hang schwebt eine Kante großer Objekte.
- **Wachenplätze im Template:** mehr Kontrolle, mehr Arbeit pro Template, bei Gebäuden schon verworfen.

## Folgen
- Niklas baut 2–3 Gelände-Templates pro Nest-Typ und 2–3 Camp-Templates in Eden (#32), Anleitung in `docs/templates.md`.
- Camp-Templates werden beim Start schon geprüft, spawnen aber erst mit dem Ticket „Camp-Inhalt spawnen“.
- Ändert sich ein Template, sieht jedes Gelände-Nest dieses Typs beim nächsten Spawn anders aus. Das ist erlaubt
  (ADR 0018).
