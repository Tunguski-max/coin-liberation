# ADR 0005: Server ist Quelle der Wahrheit, Speichern über Liberation

**Status:** Akzeptiert (2026-10-18)

## Kontext
Neue Zustände (Nester, Intel-Marker, Budgets, Ruf) müssen im Multiplayer konsistent sein
und Server-Neustarts überleben. Liberation speichert ein einziges Array als String im
`profileNamespace` des Servers und bietet kein Speicher-Event an, an das man sich ohne Eingriff hängen
könnte (siehe `docs/kp-liberation-map.md` Abschnitt 3).

## Entscheidung
- Alle Spielzustände der COIN-Schicht leben auf dem **Server**. Clients fragen an, der Server entscheidet.
- Persistenz läuft über den **bestehenden Speichermechanismus von Liberation**:
  - Unser Block wird als **Eintrag 22** an Liberations Speicher-Array angehängt
    (Hook in `functions/fn_getSaveData.sqf`) und beim Laden mit `_saveData param [22, []]`
    gelesen (Hook in `scripts/server/game/save_manager.sqf`).
  - Der Block beginnt mit `COIN_saveVersion`.
- Die Mission bekommt einen **eigenen Save-Key** `"COIN_LIBERATION_" + toUpper worldName + "_SAVEGAME"`
  statt `KP_LIBERATION_<WORLD>_SAVEGAME` (Hook in `kp_liberation_config.sqf`).

## Begründung
- Ein Speichersystem statt zwei: weniger Fehlerquellen, ein Reset-Weg.
- Server-autoritativ verhindert Desync und Doppel-Ereignisse.
- Eintrag 22: Liberation hat die Einträge 19–21 genauso abwärtskompatibel nachgerüstet. Löschen per
  Lobby-Parameter und Löschen bei Kampagnensieg greifen automatisch auch für unsere Daten.
  Liberation- und COIN-Stand werden immer gemeinsam geschrieben.
- Eigener Key: Liberations Key hängt an der Karte, nicht an der Mission. Ohne eigenen Key würden sich
  unsere Mission und das normale KP Liberation Lythium auf demselben Profil gegenseitig überschreiben.

## Verworfene Alternative
- Eigene Profilvariable für COIN-Daten: Liberation-Array bliebe unberührt, aber es bräuchte drei
  Hooks (Speichern, Löschen per Parameter, Löschen bei Sieg), und es gäbe zwei getrennte Speicherstände.

## Folgen
- Drei Hooks in Liberation-Dateien, alle in `docs/hooks.md`.
- Gespeichert werden dürfen nur Zahlen, Strings, Booleans und Arrays (Liberation nutzt `str` und
  `parseSimpleArray`). Keine Objekte, Gruppen, Seiten, `nil` oder Code.
- Führt Upstream selbst einen Eintrag 22 ein, müssen wir umziehen.
- Spec für das Speicherformat ist Teil von Ticket 2.1.
