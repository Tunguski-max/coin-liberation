# Lokal testen

Ziel: Änderungen schnell im Spiel prüfen, ohne Server. Punkte mit **(Phase 0 prüfen)**
hängen von Details der Liberation-Codebasis ab und werden in Ticket 0.2/0.4 bestätigt.

## 1. Mod-Set im Arma-3-Launcher

Ein eigenes Preset „COIN Dev“ anlegen mit:

- CBA_A3
- ACE (plus ACE-Compat für RHS, falls ihr das nutzt)
- RHS USAF, RHS AFRF
- Project OPFOR
- CUP Terrains – Core, CUP Terrains – Maps
- **Jbad** und **Lythium**
- TFAR (optional; für Solo-Tests weglassen spart Ladezeit)

Startparameter (Launcher → Parameter → Erweitert):
- `-showScriptErrors` – Skriptfehler direkt im Spiel anzeigen
- `-noPause` – Spiel läuft weiter, wenn das Fenster nicht im Fokus ist
- `-skipIntro`, `-noSplash` – schnellerer Start

## 2. Mission bauen

Liberation setzt die Mission aus `Missionframework/` (Logik) und
`Missionbasefiles/<karte>/mission.sqm` (Karte, Slots, Marker) zusammen.

1. `build.bat` im Repo-Root ausführen.
2. Den erzeugten Lythium-Missionsordner finden **(Phase 0 prüfen: Ausgabeort und Ordnername)**.
3. Ordner nach `Dokumente\Arma 3 - Other Profiles\<Profilname>\mpmissions\` kopieren
   (bzw. `Dokumente\Arma 3\mpmissions\` beim Standardprofil).

**Schneller iterieren:** Sobald der Ablauf klar ist, schreibt Claude Code ein kleines
Skript `tools/dev-sync.ps1`, das nach jeder Änderung baut und in `mpmissions` kopiert.

## 3. Lokal hosten

1. Arma mit dem Preset starten.
2. **Mehrspieler → Server-Browser → Server hosten**, Netzwerk: LAN.
3. Karte Lythium, die COIN-Mission wählen.
4. Einen Slot wählen. Für Zeus-Tests den Kommandanten- bzw. Zeus-Slot **(Phase 0 prüfen)**.

Der lokale Host ist gleichzeitig Server und Client. Das deckt die meisten Fehler ab.
Fehler, die nur auf einem echten Dedicated Server auftreten, fallen erst in Phase 7 oder
mit einem lokalen Dedicated Server auf (siehe ADR 0006).

## 4. Logs lesen

- RPT-Dateien liegen in `%LOCALAPPDATA%\Arma 3\` (neueste Datei nach Datum).
- Unsere Zeilen beginnen mit `[COIN]`.
- Für Claude Code zurückschicken:
  - alle `[COIN]`-Zeilen
  - alle Zeilen mit `Error` in der Nähe davon (ein paar Zeilen davor und danach)
  - kurz beschreiben, was du im Spiel gemacht hast und was passiert ist

## 5. Spielstand zurücksetzen

Liberation speichert im Profil des Hosts (bei lokalem Test also in deinem Profil).
Zum Neustart der Kampagne gibt es einen Missionsparameter zum Löschen des Spielstands
**(Phase 0 prüfen: genauer Name)**.

## 6. Checkliste pro Test

- [ ] Mission startet ohne Skriptfehler-Popup
- [ ] `[COIN] init` im RPT
- [ ] Testanleitung aus dem Ticket Schritt für Schritt durchgespielt
- [ ] Speichern → Mission neu starten → Zustand noch da (wenn das Ticket Persistenz betrifft)
- [ ] Ergebnis und RPT-Auszug an Claude Code
