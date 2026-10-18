# Lokal testen

Ziel: Änderungen schnell im Spiel prüfen, ohne Server.
Details zu Build, Zeus und Spielstand: `docs/kp-liberation-map.md`.

## 1. Mod-Set im Arma-3-Launcher

Ein eigenes Preset „COIN Dev“ anlegen mit:

- CBA_A3
- ACE (die RHS-Kompatibilität ist in aktuellen ACE-Versionen schon enthalten)
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
Die COIN-Mission nutzt die eigene Kopie `Missionbasefiles/coin_liberation.lythium/mission.sqm`.

1. `build.bat` im Repo-Root ausführen (braucht Node.js).
   Schneller, nur der Missionsordner ohne PBO/ZIP: im Ordner `_tools` `npx gulp mission_coin_liberation.lythium`.
2. Ergebnis:
   - Missionsordner `_tools\build\coin_liberation.lythium\`
   - PBO `_tools\build\pbo\coin_liberation.lythium.pbo`, ZIP `_tools\build\coin_liberation.lythium.zip`
3. Ordner nach `Dokumente\Arma 3 - Other Profiles\<Profilname>\mpmissions\` kopieren
   (bzw. `Dokumente\Arma 3\mpmissions\` beim Standardprofil).

Gebaut werden nur die Missionen aus `_tools\_presets.coin.json`. Mit der Umgebungsvariable
`COIN_ALL_PRESETS=1` baut der Build zusätzlich alle KP-Liberation-Karten aus `_tools\_presets.json`
(z. B. in PowerShell: `$env:COIN_ALL_PRESETS = '1'; .\build.bat`).

**Schneller iterieren:** Sobald der Ablauf klar ist, schreibt Claude Code ein kleines
Skript `tools/dev-sync.ps1`, das nach jeder Änderung baut und in `mpmissions` kopiert.

## 3. Lokal hosten

1. Arma mit dem Preset starten.
2. **Mehrspieler → Server-Browser → Server hosten**, Netzwerk: LAN.
3. Karte Lythium, Mission „COIN Liberation Lythium dev (KP v0.96.7a)“ wählen.
4. Einen Slot wählen. Zeus ist der Slot „Platoon Leader (Commander)“ (ADR 0010).

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
Zum Neustart der Kampagne in der Lobby unter den Parametern **„Wipe Save Data“ und
„Confirm: Wipe Save Data“** beide auf Ja stellen. Beim nächsten Start wieder auf Nein,
sonst wird bei jedem Start gelöscht.

## 6. Checkliste pro Test

- [ ] Mission startet ohne Skriptfehler-Popup
- [ ] `[COIN] init` im RPT
- [ ] Testanleitung aus dem Ticket Schritt für Schritt durchgespielt
- [ ] Speichern → Mission neu starten → Zustand noch da (wenn das Ticket Persistenz betrifft)
- [ ] Ergebnis und RPT-Auszug an Claude Code
