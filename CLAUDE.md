# CLAUDE.md

Anweisungen für Claude Code in diesem Repository.

## Projekt

**COIN Liberation** (Arbeitstitel): Fork von [KP Liberation](https://github.com/KillahPotatoes/KP-Liberation)
für Arma 3, erweitert um eine Counterinsurgency-Schicht im Stil von Hearts and Minds.
Karte: **Lythium**. Gruppe: 5–10 Spieler. Server: G-Portal Dedicated (noch nicht aufgesetzt).

Lies vor jeder Aufgabe:
1. `CONTEXT.md` – Fachbegriffe. Benutze genau diese Begriffe in Code-Kommentaren, Specs und Tickets.
2. `docs/DESIGN.md` – Was wir bauen und warum.
3. `docs/ROADMAP.md` – Wo wir stehen.
4. `docs/adr/` – Getroffene Entscheidungen. ADRs mit Status „Akzeptiert“ sind bindend.
5. `docs/kp-liberation-map.md` – Wie Liberation intern funktioniert (entsteht in Phase 0, Ticket 0.4).

## Arbeitsweise

- **Erst erklären, dann entscheiden.** Architekturentscheidungen nie eigenmächtig treffen.
  Optionen mit Vor- und Nachteilen vorlegen, Niklas entscheidet. Danach ADR schreiben.
- **Komplexität begründen.** Bevorzuge die einfachste Lösung, die das Design erfüllt.
  Wenn etwas aufwendiger wird als gedacht, vorher Bescheid geben.
- **Dokumentation erst nach Bestätigung aktualisieren.** `DESIGN.md` und ADRs nur ändern,
  wenn Niklas die Richtung bestätigt hat.
- **Workflow:** `grill-with-docs` → `to-spec` / `to-tickets` → `implement`
  (mattpocock/skills, siehe `SETUP.md`).
- Sprache: Doku und Gespräche **Deutsch**, Code, Bezeichner und Code-Kommentare **Englisch**.

## Du kannst Arma nicht starten

Jede Änderung wird von Niklas lokal getestet. Deshalb gilt für **jede** Implementierung:

1. Am Ende eine kurze **Testanleitung** ausgeben: Was starten, was tun, was sollte passieren,
   welche `[COIN]`-Logzeilen im RPT erscheinen sollten.
2. Kleine, einzeln testbare Schritte liefern. Lieber drei Runden mit je einem Feature als eine Runde mit dreien.
3. Fehler kommen als Auszug aus der `.rpt`-Datei zurück. Lies sie genau, bevor du Änderungen vorschlägst.
4. Nichts als „funktioniert“ bezeichnen, was nicht im Spiel getestet wurde. Status nach dem
   Schreiben ist „implementiert, ungetestet“.

## Code-Regeln (SQF)

### Ablage und Benennung
- Eigener Code liegt in `Missionframework/coin/`. Struktur siehe `Missionframework/coin/README.md`.
- Funktions-Tag: `COIN` → `COIN_fnc_<name>`, registriert über `CfgFunctions`.
- Globale Variablen: Präfix `COIN_` (z. B. `COIN_nests`). Keine globalen Variablen ohne Präfix.
- Logs: `diag_log format ["[COIN] <modul>: %1", ...]`. Debug-Ausgaben nur, wenn `COIN_debug` aktiv ist.

### Liberation-Code anfassen
- So wenig wie möglich. Bevorzugt: eigene Funktion, die an **einer** Stelle aus Liberation aufgerufen wird.
- Jede Änderung in Liberation-Dateien mit einem Kommentar markieren:
  `// COIN: <kurze Begründung>` (bzw. Block mit `// COIN BEGIN` … `// COIN END`).
- Jeder solche Einstiegspunkt wird in `docs/hooks.md` eingetragen (Datei, Zeile/Funktion, Zweck).
  So bleiben Updates aus dem Liberation-Upstream möglich.

### Multiplayer und Lokalität
- **Der Server ist die Quelle der Wahrheit** für Nester, Intel, Budgets und Ruf.
  Clients fragen an, der Server entscheidet und verteilt das Ergebnis.
- Code muss auf **Dedicated Server** und **lokalem Host** laufen. Prüfe `isServer`, `hasInterface`, `local`.
- Netzwerkverkehr sparsam: `remoteExec` gezielt statt an alle, `publicVariable` nur für kleine Zustände.
- Prüfe, ob Liberation ein `CfgRemoteExec` nutzt. Wenn ja, neue Funktionen dort eintragen.
- Schleifen mit `sleep` statt `onEachFrame`. Keine Schleife ohne Abbruchbedingung.

### Konfiguration und Persistenz
- Alle Balancing-Werte stehen in `Missionframework/coin/coin_config.sqf`. Keine Magic Numbers im Code.
- Jedes Feature hat einen Schalter in der Config (an/aus), damit wir Fehler eingrenzen können.
- Neue persistente Zustände werden über den **Liberation-Speichermechanismus** gespeichert,
  nicht über ein eigenes System. Speicherformat versionieren (`COIN_saveVersion`).

### Zeus
- Alles, was der Code erzeugt (Einheiten, Fahrzeuge, Objekte), geht über
  `COIN_fnc_addToCurators`, damit Zeus es sehen und löschen kann.

### Mods
Erlaubte Abhängigkeiten: CBA, ACE, RHS, CUP Terrains, CUP Vehicles, Project OPFOR, TFAR, Jbad, Lythium.
ACE-Funktionen sind ausdrücklich erwünscht (Interaktionsmenü, Fesseln, Sprengstoff).
Keine neuen Mod-Abhängigkeiten ohne Rückfrage.

## Nicht tun

- Keinen Code aus **Hearts and Minds** kopieren. Das Repo hat keine Lizenzdatei, also gilt
  „alle Rechte vorbehalten“. Nur Ideen und Konzepte übernehmen (siehe ADR 0002).
- Die MIT-Lizenz von KP Liberation (`LICENSE.md`) nicht entfernen oder ändern.
- Keine großflächigen Umformatierungen von Liberation-Dateien (macht Diffs unlesbar).
- Keine Features außerhalb der aktuellen Roadmap-Phase anfangen, ohne zu fragen.

## Agent skills

### Issue tracker

Issues leben in GitHub Issues (`Tunguski-max/coin-liberation`, `gh` CLI). Siehe `docs/agents/issue-tracker.md`.

### Triage labels

Standard-Vokabular (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). Siehe `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` (Glossar) + `docs/adr/` im Repo-Root. Siehe `docs/agents/domain.md`.
