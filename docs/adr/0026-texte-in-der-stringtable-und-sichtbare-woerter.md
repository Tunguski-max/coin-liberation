# ADR 0026: COIN-Texte in der Stringtable, der Server schickt Keys, sichtbare Wörter „Versteck“ und „Aufständische“

**Status:** Akzeptiert (2026-10-29). Löst die Regel „COIN fasst Liberations `stringtable.xml` nicht an“ ab (Kommentar in `CfgNotifications.hpp`).

## Kontext
- Die COIN-Texte liegen heute in `coin_config.sqf` als etwa 160 Paare `[Deutsch, Englisch]`, in `CfgNotifications.hpp` als
  doppelte Klassen (`_de`, `_en`) und fest in etwa 26 Funktionen. Gewählt wird mit `language isEqualTo "German"`.
  Jede weitere Sprache hieße: jede Stelle anfassen.
- Liberation hält seine Texte in `stringtable.xml` (600 Keys, 6 Sprachen, `Original` Englisch). Arma fällt für eine
  Sprache ohne Eintrag auf `Original` zurück.
- Die Spieler sehen „Nest“ und „Miliz“, obwohl die Geschichte von Verstecken und Aufständischen handelt.
- Eine Mission hat nur eine Stringtable.

## Entscheidung
- **Stringtable:** Alle Texte, die ein Spieler liest, kommen in ein eigenes `<Package name="COIN">` in der
  bestehenden `stringtable.xml`. Keys heißen `STR_COIN_<Modul>_<Name>`, `Original` ist Englisch, dazu Deutsch.
  Weitere Sprachen fallen auf Englisch zurück. Das ist ein neuer Hook (`docs/hooks.md`).
- **Config und Klassen:** In der Config stehen Keys statt Paare, `CfgNotifications` hat eine Klasse je Meldung mit
  `$STR_…`. `COIN_fnc_getLanguageText` und die `language`-Prüfungen entfallen.
- **Mehrspieler:** Der Server schickt nur Keys (und Zahlen für die Platzhalter), nie fertige Texte. `localize` läuft auf dem
  Client, sonst gälte am Dedicated Server die Serversprache.
- **Sichtbare Wörter:** Deutsch **„Versteck“** statt Nest und **„Aufständische“** statt Miliz, englisch **„hideout“** und
  **„insurgents“**. Das gilt nur für Texte, die ein Spieler liest. Bezeichner im Code (`nest`, `militia`) und die Begriffe
  in `CONTEXT.md` bleiben, dort steht ein Hinweis auf das sichtbare Wort.
- **Liberations Texte** bleiben unverändert, außer dem Tutorial (ersetzt durch COIN-Seiten) und dem Missionstitel. Widersprüche,
  die beim Umbau auffallen, werden gesammelt (Ticket #145) und nicht still geändert.
- Die Umstellung läuft in Tickets nach Modul (Roadmap 7.0).

## Begründung
- Eine neue Sprache oder eine Korrektur ist dann eine Änderung in einer Datei, ohne Code.
- Der Fall-back auf Englisch kommt von Arma selbst und braucht keinen eigenen Code.
- Keys über das Netz verhindern Texte in der falschen Sprache; die Zahl der Platzhalter ist klein.
- Wir lassen Liberations Texte in Ruhe, damit Updates aus dem Upstream möglich bleiben (`docs/hooks.md`).

## Folgen
- Neuer Hook in `docs/hooks.md` (Stringtable-Package) und eine Pflicht für neuen Code: keine Texte mehr in der Config oder im Code.
- Alle Stellen, an denen ein Text über das Netz geht, müssen bei der Umstellung geprüft werden.
- Das Tutorial (Liberation `STR_TUTO_*`) wird durch COIN-Seiten ersetzt, die FOB-, Bau- und Logistik-Seiten bleiben, soweit sie stimmen.
