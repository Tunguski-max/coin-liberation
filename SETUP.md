# SETUP.md – Repo aufsetzen

Einmalige Schritte, um vom leeren Stand zum ersten Arbeitstag mit Claude Code zu kommen.
Annahme: Windows-PC mit Git, Arma 3 und Claude Code.

## 1. KP Liberation forken

1. Auf GitHub https://github.com/KillahPotatoes/KP-Liberation öffnen und **Fork** klicken.
   Name z. B. `coin-liberation`.
2. Lokal klonen:
   ```powershell
   git clone https://github.com/<dein-user>/coin-liberation.git
   cd coin-liberation
   ```
3. Upstream als zweite Quelle eintragen (für spätere Liberation-Updates):
   ```powershell
   git remote add upstream https://github.com/KillahPotatoes/KP-Liberation.git
   ```

## 2. Starter-Dateien einspielen

1. Die Original-README sichern, bevor sie überschrieben wird:
   ```powershell
   mkdir docs\upstream
   git mv README.md docs\upstream\KP-Liberation-README.md
   ```
2. Den Inhalt des Starter-Pakets (diesen Ordner) ins Repo-Root kopieren.
   Ergebnis: `CLAUDE.md`, `CONTEXT.md`, `SETUP.md`, `README.md`, `docs\…`, `Missionframework\coin\…`.
3. `LICENSE.md` von Liberation **nicht** anfassen.
4. Commit:
   ```powershell
   git add -A
   git commit -m "chore: COIN Liberation starter docs and module skeleton"
   git push
   ```

## 3. Claude Code einrichten

1. Im Repo-Ordner `claude` starten.
2. Skills wie im foundryvtt-Repo einrichten: die Schritte aus dessen `SETUP-SKILLS.md`
   (mattpocock/skills) hier genauso ausführen.
3. Erste Aufgabe an Claude Code (Phase 0):
   > Lies CLAUDE.md, CONTEXT.md, docs/DESIGN.md und docs/ROADMAP.md.
   > Dann arbeite Ticket 0.4 ab: Erkunde die Liberation-Codebasis und schreibe
   > docs/kp-liberation-map.md. Ändere dabei noch keinen Code.

## 4. Lokale Testumgebung

Siehe [`docs/TESTING.md`](docs/TESTING.md).

## 5. Liberation-Updates später übernehmen

```powershell
git fetch upstream
git merge upstream/master
```
Konflikte entstehen nur an den Stellen aus `docs/hooks.md`. Deshalb diese Liste pflegen.
