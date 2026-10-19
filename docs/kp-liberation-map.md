# KP Liberation – Code-Landkarte

> Ergebnis von Ticket 0.4 und 0.5 (Phase 0). Stand: 2026-10-18, Liberation-Version `0.96.7a`
> (`Missionframework/init.sqf`, Zeile 5).
> Begriffe nach [`CONTEXT.md`](../CONTEXT.md). Pfade relativ zum Repo-Root, sofern nicht anders angegeben.
> Mit **unsicher** markierte Aussagen ließen sich nicht sicher aus dem Code ablesen.
> Die daraus abgeleiteten Entscheidungen stehen in ADR 0003, 0005 und 0008–0015.

---

## 1. Überblick

### 1.1 Ordnerstruktur `Missionframework/` (Missionslogik, für alle Karten gleich)

| Pfad | Zweck |
|---|---|
| `init.sqf` | Einziger Einstiegspunkt beim Missionsstart (Server und Client). Siehe Abschnitt 2. |
| `description.ext` | Missions-Config: Header, Respawn, `CfgFunctions`, `CfgDebriefing`, Dialoge, Parameter (bindet `ui/mission_params.hpp` ein). |
| `CfgFunctions.hpp` | Registriert alle `KPLIB_fnc_*` (Klasse `KPLIB`). |
| `kp_liberation_config.sqf` | Zentrale Liberation-Config: Preset-Auswahl, Save-Key, Seiten, Sektorradien, Ruf-Werte, Informanten, Guerilla, Arsenal-Blacklist. |
| `kp_objectInits.sqf` | Init-Code, der beim Erzeugen bestimmter Klassen ausgeführt wird (`KPLIB_fnc_addObjectInit`). |
| `onPlayerRespawn.sqf` | Respawn-Handling der Spieler. |
| `whitelist.sqf` | Whitelist für Kommandanten-Slot (Parameter `Whitelist`). |
| `stringtable.xml` | Alle Texte (inkl. Deutsch). Missionsname wird beim Build ersetzt (siehe 1.3). |
| `KPLIB_debriefs.hpp` | Debriefing-Klassen. |
| `functions/` | Neuere Funktionen als `fn_<name>.sqf` → `KPLIB_fnc_<name>`. Unterordner `curator/` (Zeus) und `ui/`. |
| `scripts/client/` | Client-Code: Aktionen, Bau, Marker, UI, Tutorial, Informanten-Eskorte, Remote-Calls an Clients. |
| `scripts/server/` | Server-Code: `ai/`, `asymmetric/`, `base/`, `battlegroup/`, `civinformant/`, `civrep/`, `game/` (Speichern, Zeus-Sync, Siegbedingung), `highcommand/`, `offloading/` (HC), `patrols/`, `remotecall/`, `resources/`, `secondary/`, `sector/`, `support/`. |
| `scripts/shared/` | Auf allen Maschinen: `fetch_params.sqf`, `init_shared.sqf`, `kill_manager.sqf`, `defines.hpp`. |
| `scripts/fob_templates/` | Bauvorlagen für feindliche FOBs der Nebenmission „FOB Hunting“. |
| `presets/` | Fraktions-Presets: `blufor/`, `opfor/`, `resistance/`, `civilians/` und `init_presets.sqf` (Auswahl + Aufbereitung). |
| `arsenal_presets/` | Arsenal-Whitelists (nur aktiv, wenn `KP_liberation_arsenal` ≠ 0). |
| `ui/` | Dialog-Definitionen (`liberation_*.hpp`) und `mission_params.hpp` (Lobby-Parameter). |
| `res/` | Bilder, Sounds, Benachrichtigungs-Icons. |
| `GREUH/` | Altes Spielermenü (Fallback ohne CBA). |
| `KP/` | `KPGUI` (UI-Basis) und `KPPLM` (Spielermenü, eigene `CfgFunctions` mit Tag `KPPLM`). |
| `coin/` | **Unser Modul** (noch nicht eingebunden). Wird vom Build automatisch mitkopiert (siehe 1.3). |

### 1.2 Ordnerstruktur `Missionbasefiles/` (eine `mission.sqm` pro Karte)

Je Karte ein Ordner `kp_liberation.<worldName>/` mit **nur** einer `mission.sqm`
(Slots, Sektor-Marker, Startbasis, Zeus-Modul). 17 Karten plus `kp_liberation_devkit.VR`.
Für uns relevant: `Missionbasefiles/kp_liberation.lythium/mission.sqm` (33 005 Zeilen).
COIN baut aus einer eigenen Kopie `Missionbasefiles/coin_liberation.lythium/mission.sqm` (ADR 0016, Ticket 1.2).
Kartenänderungen (Sektoren, Slots) nur dort, das Original bleibt als Referenz unverändert. Die Sektoren schreibt
`_tools/coin/sectors/write.js` (Ticket 1.3): 1 Hauptstadt, 29 Ortschaften (davon 7 als `capture_bigtown_N`),
8 Supply Points, 6 Militärposten, keine Funktürme, Miliz-Spawnpunkte unverändert.

### 1.3 Build (`build.bat` → `_tools/`)

- `build.bat` prüft, ob Node.js installiert ist, wechselt nach `_tools/` und führt `npm install` und `npx gulp` aus.
- `npx gulp` ohne Task = Task `default` = **`build` → `pbo` → `zip`** (`_tools/gulpfile.ts`, Ende der Datei).
- Eingaben (`_tools/gulpfile.ts`, `paths`):
  - `Missionframework/` (komplett, `**/*`)
  - `Missionbasefiles/<sourceFolder>/mission.sqm`
  - `_tools/_presets.json` – eine Liste mit **18 Einträgen**, für jeden wird eine Mission gebaut (alle Karten, nicht nur Lythium).
- Schritte pro Mission (`gulpfile.ts`, Task `mission_<name>.<map>`):
  1. `Missionframework/` nach `_tools/build/<missionName>.<map>/` kopieren
  2. `mission.sqm` dazukopieren
  3. In `kp_liberation_config.sqf` per Regex die Preset-Variablen aus `_presets.json` setzen
  4. In `stringtable.xml` `STR_MISSION_TITLE` auf „CTI 34 KP Liberation Lythium 0.96.7a“ setzen
- **Ausgabe Lythium:**
  - Missionsordner: `_tools/build/kp_liberation.lythium/` (`MissionPaths.getOutputDir()` in `_tools/src/MissionPaths.ts`; `missionName` = `kp_liberation`, `map` = `lythium` in `_tools/_presets.json`)
  - **PBO: ja.** `_tools/build/pbo/kp_liberation.lythium.pbo` (Task `pack_*`, unkomprimiert: `compress: []`)
  - ZIP: `_tools/build/kp_liberation.lythium.zip` (PBO + `userconfig/`, `LICENSE.md`, `README.md`, `CHANGELOG.md`)
- `_tools/build/` und `_tools/node_modules/` stehen in `.gitignore`.
- **COIN-Änderung (Hook #3, `docs/hooks.md`):** Der Build liest standardmäßig nur `_tools/_presets.coin.json`
  (Ausgabe `coin_liberation.lythium`, Titel „COIN Liberation Lythium dev (KP v0.96.7a)“, Quelle
  `Missionbasefiles/coin_liberation.lythium/` über `sourceFolder` in `_presets.coin.json`, kein Hook). Die Liberation-Karten aus
  `_presets.json` kommen nur mit `COIN_ALL_PRESETS=1` dazu. Die Beschreibung oben gilt für den Upstream-Stand.
- Wichtig: Die Preset-Nummern in `kp_liberation_config.sqf` werden beim Build **überschrieben**. Wer Presets
  für Lythium ändern will, muss `_tools/_presets.json` anpassen (oder dort und in der Config gleich halten).

---

## 2. Ablauf beim Missionsstart

### 2.1 Init-Reihenfolge

Liberation nutzt **kein** `initServer.sqf` / `initPlayerLocal.sqf`. Alles läuft über `Missionframework/init.sqf`
(scheduled, auf jeder Maschine):

| Zeile | Was | Wo |
|---|---|---|
| 11 | `KPLIB_fnc_initSectors` – Sektor-Marker nach Präfix einsortieren | alle |
| 12 | Clients warten auf `KPLIB_initServer` (Server ist fertig) | nur Clients |
| 13 | `scripts/shared/fetch_params.sqf` – Lobby-Parameter lesen, auf Server per `publicVariable` verteilen | alle |
| 14 | `kp_liberation_config.sqf` | alle |
| 15 | `presets/init_presets.sqf` – Presets laden, fehlende Klassen filtern, abgeleitete Listen bauen | alle |
| 16 | `kp_objectInits.sqf` | alle |
| 18–23 | Spielermenü (KPPLM mit CBA, sonst GREUH) | alle |
| 25 | `scripts/shared/init_shared.sqf` – `kill_manager`, Remote-Call-Funktionen kompilieren | alle |
| 27–29 | `scripts/server/init_server.sqf` (per `call`) | Server |
| 31–33 | Headless-Client-Manager | nur HC |
| 35–49 | `CuratorObjectPlaced`-EH, `waitUntil {alive player}`, `scripts/client/init_client.sqf` | Clients mit Interface |
| 58 | `KPLIB_init = true` | alle |
| 61–64 | `KPLIB_initServer = true; publicVariable` | Server |

Beim **lokalen Host** laufen Server- **und** Client-Zweig nacheinander auf derselben Maschine.

`scripts/server/init_server.sqf` kompiliert zuerst globale Skript-Funktionen (`manage_one_sector`, `spawn_battlegroup`, …)
und startet dann per `execVM` die Server-Schleifen, u. a.:
`save_manager.sqf` (Z. 51), `zeus_synchro.sqf` (Z. 55), Battlegroups (Z. 42–44), `KPLIB_fnc_createSuppModules` (Z. 41),
Sektor-Monitor-FSM (Z. 68), Ruf-Modul (Z. 108), Informanten (Z. 111), Asymmetrie (Z. 114).

`scripts/client/init_client.sqf`: Marker, Arsenal, Aktionsmanager, UI; am Ende Kommandanten-Init mit Zeus-Anforderung (Z. 96–106).

**Synchronisationspunkte**, auf die eigener Code warten kann:
- `KPLIB_init` (lokal, nach Ende von `init.sqf`)
- `KPLIB_initServer` (public, Server fertig mit `init.sqf`)
- `save_is_loaded` (public, gesetzt in `scripts/server/game/save_manager.sqf` Z. 547, nachdem der Spielstand geladen ist)

CfgFunctions-`postInit` läuft **vor** `init.sqf`. Im lokalen Test (2026-10-18) stand `[postInit] COIN_fnc_init` im RPT
vor den ersten `[KPLIB] [PARAM]`-Zeilen. Liberation nutzt `postInit` nur für `KPLIB_fnc_initCuratorHandlers`.
Eigener `postInit`-Code muss deshalb auf `KPLIB_init` warten (so macht es `COIN_fnc_init`).

### 2.2 CfgFunctions

- `description.ext`, `class CfgFunctions`: bindet `CfgFunctions.hpp` und `KP/KPPLM/KPPLM_functions.hpp` ein.
- `CfgFunctions.hpp`: `class KPLIB` → Präfix **`KPLIB_fnc_`**, Dateien `functions/fn_<name>.sqf`.
  Darin per `#include` auch `scripts/client/CfgFunctions.hpp` und `scripts/server/CfgFunctions.hpp` (FSMs, Sektor, Support).
- Zweites Präfix: `KPPLM_fnc_` (Spielermenü).
- **Viel älterer Code ist nicht in CfgFunctions**, sondern globale Variablen mit kompiliertem Code, z. B.
  `F_cr_changeCR`, `manage_one_sector`, `kill_manager`, `spawn_battlegroup` (`init_server.sqf`, `init_shared.sqf`, `civrep/init_module.sqf`).
- Weitere Liberation-Präfixe für globale Variablen: `KPLIB_`, `KP_liberation_`, `GRLIB_`, `GREUH_`, dazu viele **ohne** Präfix
  (`blufor_sectors`, `combat_readiness`, `civilians`, `active_sectors`, …).
- `allowFunctionsRecompile` ist außerhalb des Editors `0` (`description.ext`). CfgFunctions-Funktionen lassen sich also zur Laufzeit
  nicht überschreiben – Wrappen von Liberation-Funktionen ohne Hook geht nicht.

### 2.3 CfgRemoteExec

**Gibt es nicht.** Weder in `description.ext` noch irgendwo sonst unter `Missionframework/` (Suche nach `CfgRemoteExec`).
Damit sind laut BI-Wiki alle Funktionen und Befehle per `remoteExec` erlaubt. Liberation nutzt das auch so, z. B.
`[_sector] remoteExec ["reinforcements_remote_call", 2]` (`manage_one_sector.sqf`) oder
`[KP_liberation_cr_vehicle_penalty, true] remoteExec ["F_cr_changeCR", 2]` (`functions/fn_setVehicleSeized.sqf` Z. 32).
→ Neue `COIN_fnc_*` müssen nirgends eingetragen werden.

### 2.4 Logging

`KPLIB_fnc_log` (`functions/fn_log.sqf`) schreibt `[KPLIB] [<TAG>] <Text>` per `diag_log`. Unser Format `[COIN] <modul>: …`
lässt sich im RPT sauber davon trennen. Debug-Ausgaben steuert Liberation über Lobby-Parameter (`DebugCivRep`, `DebugAsymmetric`, …).

---

## 3. Speichern und Laden

### 3.1 Wo und wie

| | |
|---|---|
| Ort | `profileNamespace` **des Servers** (lokal: Profil des Hosts). Datei `<Profil>.vars.Arma3Profile`. |
| Variable Spielstand | `GRLIB_save_key = "KP_LIBERATION_" + (toUpper worldName) + "_SAVEGAME"` → **`KP_LIBERATION_LYTHIUM_SAVEGAME`** (`kp_liberation_config.sqf` Z. 191) |
| Variable Parameter | `KP_LIBERATION_LYTHIUM_SAVE_PARAMS` (`functions/fn_getSaveableParam.sqf`), nur genutzt bei Parameter „Save/Load“ = SAVE |
| Format | Array, gespeichert als **String** (`str _saveData`, `functions/fn_doSave.sqf`), geladen mit `parseSimpleArray` (`save_manager.sqf`) |
| Intervall | alle 60 s (`KP_liberation_save_interval`, Config Z. 193), zusätzlich nach Sektor-Einnahme/-Verlust, beim Verlassen des letzten Spielers bzw. des Hosts |
| Schreiben | `KPLIB_fnc_doSave` → `KPLIB_fnc_getSaveData` → `profileNamespace setVariable` + `saveProfileNamespace` |
| Laden | `scripts/server/game/save_manager.sqf` (einmal beim Start, danach Speicherschleife) |
| Ende | Bei Kampagnensieg wird der Spielstand gelöscht (`save_manager.sqf` Z. 561 ff.). |

Aufbau des Arrays (`functions/fn_getSaveData.sqf` ab Z. 185; Laden in `save_manager.sqf` Z. 176–198):

| Index | Inhalt | Index | Inhalt |
|---|---|---|---|
| 0 | Version `[0,96,"7a"]` | 11 | Fahrzeug↔Militärbasis-Freischaltungen |
| 1 | Datum | 12 | **`KP_liberation_civ_rep`** (Ruf) |
| 2 | Objekte bei FOBs | 13 | Clearances (entfernte Geländeobjekte) |
| 3 | FOB-Lager mit Ressourcen | 14 | `KP_liberation_guerilla_strength` |
| 4 | Statistiken (39 Werte) | 15 | Logistik |
| 5 | Gewichte Inf/Panzer/Luft | 16 | Produktion |
| 6 | BLUFOR-KI-Gruppen | 17 | Produktionsmarker |
| 7 | `blufor_sectors` | 18 | `resources_intel` |
| 8 | `combat_readiness` | 19 | Minen um FOBs (`param [19, []]`) |
| 9 | `GRLIB_all_fobs` | 20 | Kisten in Sektoren (`param [20, []]`) |
| 10 | Berechtigungen | 21 | Funktürme (`param [21, []]`) |

**Einschränkung für unsere Daten:** Wegen `str` + `parseSimpleArray` sind nur Zahlen, Strings, Booleans und Arrays
erlaubt. Keine Objekte, Gruppen, Seiten, `nil` oder Code. Positionen und Markernamen gehen.

**Neue Kampagne erkennen:** Wenn kein Spielstand existiert, läuft der Zweig `["Save nil", "SAVE"]` (`save_manager.sqf`),
alle Startwerte kommen aus dem Block „Globals“ (Z. 62–101), u. a. `KP_liberation_civ_rep = 0` (Z. 83).

### 3.2 Kandidaten für unseren Speicher-Hook (noch nicht umsetzen)

Es gibt kein Speicher-Event, an das man sich ohne Eingriff hängen könnte (und Recompile ist gesperrt, siehe 2.2).

| Option | Eingriff | Vorteile | Nachteile |
|---|---|---|---|
| **A: Index 22 im Liberation-Array** | `fn_getSaveData.sqf`: COIN-Block als letztes Element anhängen. `save_manager.sqf`: nach Z. 198 `_saveData param [22, []]` an eine COIN-Ladefunktion geben. | Genau das Muster, mit dem Liberation selbst Index 19–21 nachgerüstet hat. Löschen per Parameter und Löschen bei Sieg funktionieren automatisch. Passt wörtlich zu ADR 0005. | Zwei Liberation-Dateien. Konflikt, falls Upstream selbst Index 22 einführt (dann umziehen). |
| **B: Eigener Key im selben Profil** | `fn_doSave.sqf`: eigenen Key (z. B. `COIN_LYTHIUM_SAVEGAME`) mitschreiben. Plus Hooks beim Löschen per Parameter und beim Sieg. | Liberation-Array bleibt unangetastet. | Drei bis vier Hook-Stellen, sonst laufen Liberation- und COIN-Stand auseinander. Weicht vom Wortlaut der ADR 0005 ab. |

Bei beiden: Laden ist erst sinnvoll, wenn `save_is_loaded` true ist. Unser Server-Init kann darauf warten.

### 3.3 Spielstand löschen

Zwei Lobby-Parameter, **beide** auf „Ja“ (`ui/mission_params.hpp` Z. 380–391, ausgewertet in `save_manager.sqf` Z. 7):

| Klasse | Titel (Englisch / Deutsch) |
|---|---|
| `WipeSave1` | „Wipe Save Data“ / „Spielstand löschen“ |
| `WipeSave2` | „Confirm: Wipe Save Data“ / „Bestätige: Spielstand löschen“ |

Danach beim nächsten Start wieder auf „Nein“ stellen, sonst wird bei jedem Start gelöscht.

---

## 4. Sektoren

### 4.1 Definition

Marker in der `mission.sqm`, einsortiert nach **Namenspräfix** (`functions/fn_initSectors.sqf`):

| Präfix | Liste | Bedeutung | Anzahl Lythium* |
|---|---|---|---|
| `bigtown` | `sectors_bigtown` | Hauptstadt („capital“) | 9 |
| `capture` | `sectors_capture` | Stadt/Dorf (unsere **Ortschaft**) | 73 |
| `factory` | `sectors_factory` | Fabrik, Produktion (unser **Supply Point**) | 38 |
| `military` | `sectors_military` | Militärbasis, schaltet Elite-Fahrzeuge frei, enthält Intel-Gegenstände | 38 |
| `tower` | `sectors_tower` | Funkturm: in Feindeshand Quelle feindlicher Verstärkung, in BLUFOR-Hand Feindanzeige auf der Karte (siehe 10) | 43 |
| `opfor_point` | `sectors_opfor` | **kein Sektor**: Spawnpunkt für Battlegroups, Patrouillen, Nebenmissionen | 235 |
| `opfor_airspawn` | `sectors_airspawn` | **kein Sektor**: Spawnpunkt für Flugzeuge/Hubschrauber | 32 |

\* gezählt per `grep` auf `name="<präfix>(_N)"` in `Missionbasefiles/kp_liberation.lythium/mission.sqm`.
Die 9 Hauptstädte auf Lythium: Arobster, Afsher, Kalae Noowi, Mikis, Nefer, Mafaraz, Amir City, Karift, Kinduf.

Weitere Marker: `startbase_marker` / `startbase` (Startbasis bei ca. [4150, 840], Südwesten), `respawn`, `huronspawn`,
`base_boxspawn`, `ghost_spot`.

### 4.2 Aktivierung

`scripts/server/sector/fn_sectorMonitor.fsm` (Server, startet nach `save_is_loaded`):
- Geht reihum alle **nicht befreiten** Sektoren durch.
- Aktiviert einen Sektor, wenn die OPFOR-Anzahl unter `GRLIB_sector_cap` liegt und eine BLUFOR-Einheit innerhalb von
  `KPLIB_fnc_getSectorRange` ist (Basis `GRLIB_sector_size = 1000` m, schrumpft bei vielen aktiven Gegnern auf bis zu 750 m).
- Startet `manage_one_sector` (Server oder HC), spawnt Ressourcenkisten (Fabrik/Stadt) bzw. Intel-Gegenstände (Militär).

`scripts/server/sector/manage_one_sector.sqf`:
- Besatzung je nach Typ, `combat_readiness` und Parameter `Unitcap`. Bei niedriger Readiness „militia“-Trupps statt „army“.
- Zivilisten nur in `bigtown` und `capture` (`KPLIB_fnc_spawnCivilians`).
- IEDs nur, wenn Ruf < 0 (siehe 7.3). Guerilla-Chance (siehe 7.4). Verstärkung anfordern (`reinforcements_remote_call`).
- Abbau, wenn 60 s lang (bis zu `DelayDespawnMax` Minuten länger) kein BLUFOR in Reichweite + 300 m ist.

### 4.3 Einnahme

- Prüfung alle 5 s mit `KPLIB_fnc_getSectorOwnership` im Radius `GRLIB_capture_size = 175` m (Hauptstadt ×1,4):
  BLUFOR gewinnt, wenn BLUFOR > 0 und (OPFOR ≤ 3 und Anteil > 51 %) oder Anteil > 85 % (`functions/fn_getSectorOwnership.sqf`).
- Dann `scripts/server/remotecall/sector_liberated_remote_call.sqf`: Readiness steigt, Sektor in `blufor_sectors`,
  Produktion für Fabriken, Ruf-Gewinn (`F_cr_liberatedSector`), evtl. verwundete Zivilisten, Asymmetrie-Sperre 30 min,
  Siegprüfung, Speichern, nach 45 s evtl. Gegenangriff (Battlegroup, siehe 7.5).
- Übrige Gegner im Radius ergeben sich mit 80 % Chance (`prisonner_ai.sqf`, `GRLIB_surrender_chance`).

### 4.4 Gegenangriff und Verlust

- `scripts/server/sector/lose_sectors.sqf` prüft jede Sekunde alle befreiten Sektoren und FOBs.
- Hat OPFOR die Mehrheit, startet `attack_in_progress_sector.sqf`: optional BLUFOR-Verteidiger (Parameter `BluforDefenders`),
  Warnung, dann `GRLIB_vulnerability_timer = 1200` s. Hält OPFOR den Sektor so lange, ist er verloren.
- Woher Angreifer kommen: siehe 7.5.

### 4.5 Siegbedingung

- `scripts/server/game/check_victory_conditions.sqf` ruft `KP_liberation_victoryCheck` auf (nach jeder Einnahme).
- Definiert in `scripts/shared/fetch_params.sqf` Z. 172–210 nach Lobby-Parameter `VictoryCondition`
  (`ui/mission_params.hpp` Z. 134, **Standard 1**):
  0 = alle Hauptstädte · 1 = alle Hauptstädte + Militärbasen · 2/3 = alle Hauptstädte + 60/80 % der Sektoren · 4 = alle Sektoren
- Bei Sieg: Endbildschirm mit Statistik, Spielstand wird gelöscht.

---

## 5. Presets und Config

### 5.1 Ablage

| Seite | Ordner | Auswahlvariable |
|---|---|---|
| BLUFOR | `Missionframework/presets/blufor/` | `KP_liberation_preset_blufor` |
| OPFOR | `Missionframework/presets/opfor/` | `KP_liberation_preset_opfor` |
| Widerstand | `Missionframework/presets/resistance/` | `KP_liberation_preset_resistance` |
| Zivilisten | `Missionframework/presets/civilians/` | `KP_liberation_preset_civilians` |

Zuordnung Nummer → Datei: `presets/init_presets.sqf` (Z. 11–90). `init_presets.sqf` filtert danach alle Klassen heraus,
die im geladenen Modset nicht existieren (`KPLIB_fnc_checkClass`, Z. 169–205).

### 5.2 Lythium-Standard (`_tools/_presets.json`, Eintrag `kp_liberation.lythium`)

| Variable | Wert | Datei |
|---|---|---|
| BLUFOR | 7 | `presets/blufor/rhs_usaf_des.sqf` (RHS USAF Desert) |
| OPFOR | **4** | `presets/opfor/islamic_state.sqf` (**Project OPFOR „Islamic State“**, nicht „Takistan“ = 3) |
| Widerstand | 3 | `presets/resistance/middle_eastern.sqf` (Project OPFOR, `LOP_AM_*` = Afghan Militia) |
| Zivilisten | 2 | `presets/civilians/middle_eastern.sqf` (Project OPFOR) |
| Arsenal | 0 | Blacklist-Methode (`blacklisted_from_arsenal` in `kp_liberation_config.sqf`) |

Hinweis: Die OPFOR-Sektorverteidiger `militia_squad` in `islamic_state.sqf` sind `LOP_AM_OPF_*`, die Guerilla in
`middle_eastern.sqf` `LOP_AM_*` – also dieselbe Afghan-Militia-Optik auf zwei Seiten (siehe Risiken).

### 5.3 Bau- und Kauflisten

Im BLUFOR-Preset (z. B. `presets/blufor/rhs_usaf_des.sqf`), Format `["klasse", Supplies, Munition, Treibstoff]`:
`infantry_units`, `light_vehicles`, `heavy_vehicles` (u. a. M1A1/M1A2, M109A6), `static_vehicles`, `air_vehicles`
(u. a. AH-64, A-10, F-22, F-35), `buildings`, `support_vehicles`, Trupps `blufor_squad_*`.
`elite_vehicles` sind gesperrt, bis die zugeloste Militärbasis eingenommen ist. Trupp-Preise: `init_presets.sqf` (`KPLIB_b_allSquads`).
Klassen aus nicht geladenen Mods (z. B. `USAF_*`, `FIR_*`) fallen automatisch weg.

### 5.4 Luftangriffe, Artillerie, schwere Gegnerverbände

| Funktion | Gesteuert durch | Abschalten |
|---|---|---|
| **OPFOR-Luftangriff** (Su-25) | `scripts/server/battlegroup/spawn_air.sqf`, aufgerufen von `counter_battlegroup.sqf` (Spieler in Panzer/Luftfahrzeug, Readiness ≥ 70) und `spawn_battlegroup.sqf` (wenn Aggressivität > 0,9) | `opfor_air = []` im OPFOR-Preset → `spawn_air` bricht sofort ab (Z. 3) |
| **OPFOR-Hubschrauber** (Fallschirmjäger, Heli-Patrouillen, Battlegroup-Helis) | `opfor_choppers`, `opfor_troup_transports`, `opfor_battlegroup_vehicles*` | `opfor_choppers = []` und Helis aus `opfor_battlegroup_vehicles*` / `opfor_troup_transports` entfernen. **Achtung:** `send_paratroopers.sqf` Z. 17–19 hängt in einer Endlosschleife, wenn `opfor_choppers` nicht leer ist, aber keinen Transporter enthält. |
| **OPFOR-Panzer/Schützenpanzer** | `opfor_vehicles`, `opfor_vehicles_low_intensity` (Sektorverteidiger, Patrouillen über `KPLIB_fnc_getAdaptiveVehicle`), `opfor_battlegroup_vehicles*` | Einträge im OPFOR-Preset streichen (aktuell T-34, T-55, T-72, BMP-1/2, BTR-60, ZSU-23-4) |
| **Zufällige Battlegroups** | `random_battlegroups.sqf`, nur wenn Aggressivität > 0,9 | Lobby-Parameter `Aggressivity` auf „Anemic“ oder „Weak“ (intern 0,25 / 0,5) – schaltet auch Luftangriffe ab, verlängert aber zugleich Verstärkungs-Timer |
| **Gegenangriff nach Einnahme** | `sector_liberated_remote_call.sqf` (Ende) | Kein Schalter; nur über Readiness/Aggressivität beeinflussbar oder per Hook |
| **BLUFOR-Artillerie** | BI-Support-Modul, `scripts/server/support/fn_createSuppModules.sqf`, Fahrzeugliste `KP_liberation_suppMod_artyVeh` (Config) | Lobby-Parameter `SuppMod` = 0 („Deaktiviert“); zusätzlich M109 aus `heavy_vehicles`/`elite_vehicles` streichen |
| **BLUFOR-Jets** | `air_vehicles` im BLUFOR-Preset, Hangar `KP_liberation_plane_slot_building` | Jets aus `air_vehicles` und `elite_vehicles` streichen |

---

## 6. Zeus

- In der `mission.sqm` steht ein Zeus-Modul `zm1` mit Besitzer `commandant` (Z. 1309–1330). **Es wird beim Start gelöscht**
  (`functions/curator/fn_initCuratorHandlers.sqf`, `deleteVehicle zm1`).
- Stattdessen erzeugt der Server pro Spieler ein `ModuleCurator_F` über das Scripted-EH `KPLIB_createZeus` (gleiche Datei).
- **Zeus-Slot:** „**Platoon Leader (Commander)**“, Variablenname `commandant` (`mission.sqm` Z. 2084–2085,
  `functions/fn_getCommander.sqf`). Der Kommandant bekommt 5 s nach dem Spawn Zeus, wenn Parameter `CommanderZeus` an ist
  (`init_client.sqf` Z. 96–106), und hat eine Aktion „Zeus neu zuweisen“ (`functions/fn_addActionsPlayer.sqf` Z. 337 ff.).
- Parameter (`ui/mission_params.hpp` Z. 296–313):
  - `CommanderZeus` (Standard an)
  - `LimitedZeus` (**Standard an**): Platzieren/Bearbeiten/Zerstören gesperrt (`setCuratorCoef … -1e8`), Löschen erlaubt, keine Addons.
    Für „Zeus darf alles“ muss dieser Parameter **aus** sein.
  - `ZeusAddEnemies` (**Standard aus** laut `mission_params.hpp`): Gegner werden Zeus nicht hinzugefügt.
- **Vorhandene Hinzufügen-Logik:** `scripts/server/game/zeus_synchro.sqf` (Schleife alle ~10 s, für **alle** Kuratoren):
  - fügt hinzu: lebende Einheiten der BLUFOR-Seite (mit `ZeusAddEnemies` alle außer Zivilisten), Fahrzeuge aus den
    BLUFOR-Klassenlisten, Kisten, erbeutete/beschlagnahmte Fahrzeuge, spielbare Einheiten
  - fügt **nicht** hinzu: Zivilisten, beliebige Objekte (Kisten, Möbel, Zelte, IEDs), Fahrzeuge außerhalb der Listen
  - **entfernt** bei jedem Durchlauf alles Tote **und alles per `attachTo` Befestigte** aus allen Kuratoren – auch Objekte,
    die wir selbst hinzugefügt haben.
- Es gibt **keine** allgemeine Funktion „Objekt allen Kuratoren hinzufügen“. `KPLIB_fnc_handlePlacedZeusObject` ist das
  Gegenstück (von Zeus platzierte Objekte bekommen Kill-Manager und Object-Init). → `COIN_fnc_addToCurators` wird gebraucht.

---

## 7. Vorhandene Features, die uns betreffen (Ticket 0.5)

### 7.1 Civil Reputation → Empfehlung: **nutzen und erweitern**

**Wo:** `scripts/server/civrep/` (Init `init_module.sqf`, Änderung `fnc/f_kp_cr_changeCR.sqf`, Sektor-Bonus
`fnc/f_kp_cr_liberatedSector.sqf`, Verwundete `wounded/civrep_wounded_civs.sqf`), Anzeige `functions/ui/fn_overlayUpdateResources.sqf`.

**Wert:** eine globale Zahl `KP_liberation_civ_rep`, Skala **−100 bis +100**, Start **0**, gespeichert (Index 12),
an Clients über `sync_vars` (`scripts/server/game/synchronise_vars.sqf`). Anzeige im Overlay als „x %“, grün ab +25, rot ab −25.

**Ändern:** nur auf dem Server über `[betrag, negativ?] call F_cr_changeCR` (Clients: `remoteExec ["F_cr_changeCR", 2]`).
Die Funktion begrenzt auf ±100 und setzt dabei **jedes Mal die Seitenbeziehungen des Widerstands neu** (siehe 7.4).

| Ereignis | Änderung | Wo |
|---|---|---|
| Zivilist von BLUFOR getötet | −5 (`KP_liberation_cr_kill_penalty`) | `scripts/shared/kill_manager.sqf` Z. 120–130 |
| Befreundeter Widerstandskämpfer von BLUFOR getötet | −3 (`…_resistance_penalty`) | `kill_manager.sqf` Z. 104–112 |
| Ziviles Fahrzeug beschlagnahmt (Einsteigen) | −2 (`…_vehicle_penalty`) | `functions/fn_setVehicleSeized.sqf` |
| Gebäude zerstört | −3 je Gebäude (`…_building_penalty`), **nur bei Einnahme** von Stadt/Hauptstadt verrechnet (Vergleich mit Zählung beim Missionsstart) | `f_kp_cr_liberatedSector.sqf` |
| Stadt befreit / Hauptstadt befreit | +5 / +10 (`…_sector_gain`) | `f_kp_cr_liberatedSector.sqf` |
| Verwundeten Zivilisten behandelt | +2 (`…_wounded_gain`); 35 % Chance auf 2–3 Verwundete nach Einnahme | `civrep_wounded_civs.sqf` |
| Informant an FOB gebracht | +2 | `scripts/server/civinformant/civinfo_delivered.sqf` |

Werte stehen in `kp_liberation_config.sqf` Z. 228–234.

**Was der Ruf in Liberation bewirkt (Schwellen bei ±25):**

| Ruf | Wirkung | Wo |
|---|---|---|
| < 0 | IEDs in **feindlichen** Stadt-/Hauptstadt-/Fabrik-Sektoren bei Aktivierung | `manage_one_sector.sqf` |
| ≤ −25 | Hinterhalte + IEDs in **befreiten** Städten, Konvoi-Hinterhalte | `asymmetric_loop.sqf`, `manage_logistics.sqf` Z. 294 |
| < −25 | Widerstand feindlich zu BLUFOR | `f_kp_cr_changeCR.sqf` Z. 16–22 |
| \|Ruf\| ≥ 25 | Guerilla kann in Sektorkämpfe eingreifen (`KPLIB_fnc_crGetMulti` = `floor(|Ruf|/25)`, max. 3) | `manage_one_sector.sqf`, `fn_crGetMulti.sqf` |
| ≥ 25 | Informanten erscheinen; Widerstand feindlich zu OPFOR | `civinfo_loop.sqf`, `f_kp_cr_changeCR.sqf` |

**Begründung:** Eine globale Skala, server-autoritativ, schon gespeichert, mit Anzeige – passt zu E4 („global starten“).
Unsere Ereignisse (IED entschärft, Nest zerstört, …) rufen einfach `F_cr_changeCR` auf, dafür braucht es **keinen** Hook.
Zu beachten:
- Zivilisten töten kostet bereits −5. `COIN_repCivilianKilled` darf das nicht doppelt abziehen.
- „Start: niedrig“ (DESIGN 8) braucht einen Hook für den Startwert bei neuer Kampagne. Jeder Startwert unter 0 schaltet Liberations
  IEDs ein, unter −25 zusätzlich Hinterhalte und einen feindlichen Widerstand. Das ist eine Designentscheidung.
- Die Skala ist −100…+100, unsere Config rechnet mit 0…100 (siehe Abschnitt 10).

### 7.2 Zivile Informanten → Empfehlung: **nutzen, später erweitern**

**Wo:** `scripts/server/civinformant/` (`civinfo_loop.sqf`, `civinfo_delivered.sqf`, `tasks/civinfo_task.sqf`),
Client `scripts/client/civinformant/` (Eskorte, Benachrichtigungen). Werte: Config Z. 236–242.

**Ablauf:**
1. Erst wenn mindestens eine Stadt/Hauptstadt befreit ist. Danach alle 90–180 min ein Versuch, der wartet, bis Ruf ≥ 25.
2. Mit 75 % Chance erscheint ein Informant in einem Gebäude einer befreiten Stadt, ergibt sich (ACE-Captive) und wird mit einem
   ungefähren Kreis (±200 m) angekündigt.
3. Er wartet 20 min (nur wenn kein Spieler in 150 m ist, läuft die Zeit ab). Spieler müssen ihn zu einem FOB (< 30 m) bringen.
4. An der FOB: +5 `resources_intel`, +2 Ruf, 40 % Chance auf eine zeitkritische Aufgabe (HVT-Offizier mit Eskorte an einer Straße,
   `civinfo_task.sqf`).

**Begründung:** Das ist ein fertiger, gut lesbarer Ablauf, der zu „Zivilist meldet sich selbst“ passt. Er zeigt aber auf kein Nest, sondern
liefert nur Liberation-Intel-Punkte. Später (Phase 3/5) einen Hook in `civinfo_delivered.sqf`, der zusätzlich einen COIN-Hinweis auf ein Nest
erzeugt. DESIGN 8: „Ruf wirkt auf Anzahl Informanten“ geht über die Config-Werte (Intervall, Chance), nicht dynamisch – das wäre ein weiterer Hook.

### 7.3 Asymmetrische Bedrohungen → Empfehlung: **IEDs und Hinterhalte ersetzen, Konvoi-Hinterhalt nutzen**

**Wo:** `scripts/server/sector/ied_manager.sqf`, `scripts/server/asymmetric/` (`asymmetric_loop.sqf`, `ied/manage_asymIED.sqf`,
`random/asym_sector_ambush.sqf`, `convoy/logistic_convoy_ambush.sqf`). Debug-Parameter `DebugAsymmetric`.

| Teil | Wann | Was |
|---|---|---|
| IEDs in feindlichen Sektoren | bei Aktivierung, wenn Ruf < 0; Anzahl ≈ `ceil(random 4) × round(-Ruf/33) × Schwierigkeit`, max. 16/12/8 | Vanilla-Minen (`IEDLandBig_F` usw.) bis 7 m neben einer Straße im Sektor. Explodieren per Skript, wenn 1–3 BLUFOR-Infanteristen in 6,66 m oder ein Fahrzeug in 10 m sind. 12 % „ultra strong“ (`Bomb_04_F`). Gelöscht 30 min nach Sektor-Abbau. |
| IEDs + Hinterhalt in befreiten Städten | Ruf ≤ −25, BLUFOR im Sektor, nicht in den ersten 30 min nach Einnahme, 25 % Chance | `crGetMulti × Schwierigkeit` IEDs im 200-m-Umkreis; Guerilla-Gruppe (Widerstand, hier feindlich) versteckt in Gebäuden im 75-m-Umkreis, greift bei BLUFOR in 140 m an. |
| Konvoi-Hinterhalt | nur mit KI-Logistik, Ruf ≤ −25 | Beschädigte Lkw + Guerilla an der Route. |

Es gibt **keine** Auslöser, keine VBIEDs, keine Attentäter, keine Attrappen, keine Hinweise für Spieler und keine Budgets. Nichts davon ist
mit Nestern verknüpft. Liberation-IEDs werden nicht an Zeus gegeben.

**Begründung:** Unser Kernprinzip ist „Bedrohung kommt aus einem Nest, Gefahr ist lesbar“ (DESIGN 2 und 6). Liberations IEDs hängen am Ruf
und sind zufällig. Doppelt laufen lassen hieße zwei IED-Quellen mit unterschiedlicher Logik. Ersetzen bedeutet: Liberation-IEDs und
-Hinterhalte per Hook abschaltbar machen (kein Config-Schalter vorhanden; Kandidaten: `_iedcount` in `manage_one_sector.sqf`,
`execVM` in `init_server.sqf` Z. 114). Das Muster „Mine + Näherungsprüfung“ und `BIS_fnc_nearestRoad` an Straßen taugt als Vorlage.
Der Konvoi-Hinterhalt ist ein eigenes, passendes Ereignis und kann bleiben. Entscheidung offen, siehe Fragen am Ende.

### 7.4 Guerilla / Widerstand → Empfehlung: **erweitern (Basis für lokale Kämpfer)**

**Wo:** Preset `presets/resistance/middle_eastern.sqf`, Spawn `functions/fn_spawnGuerillaGroup.sqf`, Stufe `functions/fn_getResistanceTier.sqf`,
Einsätze `scripts/server/asymmetric/random/sector_guerilla.sqf` und `asym_sector_ambush.sqf`, Seiten in `f_kp_cr_changeCR.sqf`.

- Seite `GRLIB_side_resistance` (RESISTANCE). Einheiten `KP_liberation_guerilla_units` (`LOP_AM_*`), Ausrüstung wird beim Spawn
  ersetzt, abhängig von der Stufe 1–3.
- Stufe aus `KP_liberation_guerilla_strength` (gespeichert): Stufe 2 ab 30, Stufe 3 ab 70 (Config Z. 247–251).
  +2 je überlebendem Kämpfer nach einem Sektorkampf, + Gewinn aus Konvoi-Hinterhalten, −1 je gefallenem.
- **Haltung abhängig vom Ruf:**

  | Ruf | zu BLUFOR | zu OPFOR |
  |---|---|---|
  | ≥ 25 | freundlich | feindlich |
  | −25 … < 25 | freundlich | freundlich (kämpft mit niemandem) |
  | < −25 | feindlich | freundlich |

- Einsatz `sector_guerilla`: Bei Aktivierung von Stadt/Hauptstadt/Fabrik mit 35 % Chance, wenn |Ruf| ≥ 25. Eine Gruppe
  (6 + Zufall nach Ruf und Stufe) läuft aus 1,2–1,6 km auf den Sektor zu, mit Meldung „Guerilla aus Richtung …“, 25 % Chance auf ein Technical.
  Bei negativem Ruf kämpft diese Gruppe **auf OPFOR-Seite**.

**Taugt das für „lokale Kämpfer“ (DESIGN 8.1)?** Ja, als Grundlage:
- `KPLIB_fnc_spawnGuerillaGroup [pos, anzahl]` liefert fertig ausgerüstete Gruppen; die Stufen geben eine natürliche Steigerung.
- Bei unserer hohen Ruf-Schwelle für Gefälligkeiten (≥ 25 auf Liberation-Skala) sind sie automatisch freundlich zu uns und feindlich zur Miliz.
- `sector_guerilla.sqf` ist schon fast ein „Ablenkungsangriff“ (Gruppe zieht zu einem Ziel und kämpft dort). Für die Verstärkung kann eine
  Gruppe per `joinSilent` einem Spieler-Gruppenführer folgen.

Einschränkungen:
- Die Haltung ist **global** an den Ruf gekoppelt. Fällt der Ruf unter 25, sind laufende Verstärkungen plötzlich neutral zur Miliz.
- Optik: Freundliche Guerilla (`LOP_AM_*`) und Miliz-Verteidiger (`LOP_AM_OPF_*`) sehen gleich aus → Verwechslungsgefahr, Teamkill-Strafe −3 Ruf.
- DESIGN 8.1: „Sterben lokale Kämpfer, kein Ruf-Abzug“ – Liberation zieht aber −3 ab, wenn **Spieler** sie töten. Das passt (Abzug nur bei Teamkill).
- Liberations eigene `sector_guerilla`-Einsätze laufen weiter und konkurrieren mit unseren Gefälligkeiten (Abschaltung nur per Hook oder `KP_liberation_resistance_sector_chance = 0`).

### 7.5 Gegenangriffe (Battlegroups) → Empfehlung: **erweitern**

**Wo:** `scripts/server/battlegroup/` (`spawn_battlegroup.sqf`, `random_battlegroups.sqf`, `counter_battlegroup.sqf`, `readiness_increase.sqf`,
`spawn_air.sqf`), `scripts/server/patrols/reinforcements_manager.sqf`, `send_paratroopers.sqf`, KI `scripts/server/ai/battlegroup_ai.sqf`.

**Zentrale Größe `combat_readiness` (0–100, gespeichert):** steigt bei Einnahmen (je nach Typ), bei Kills nahe einer nicht befreiten
Hauptstadt (+0,5) und langsam über Zeit bis zu einer Grenze abhängig von der Zahl befreiter Sektoren (`readiness_increase.sqf`).
Sinkt, wenn eine Battlegroup losgeschickt wird, und wenn ≥ 90 % aller Sektoren befreit sind.

| Quelle | Auslöser | Wo |
|---|---|---|
| Gegenangriff nach Einnahme | 45 s nach Einnahme, außer Funkturm; Chance steigt mit Readiness, **Hauptstadt immer** | `sector_liberated_remote_call.sqf` |
| Zufällige Battlegroup | alle 30–60 min (skaliert), nur bei Aggressivität > 0,9, ≥ 6 Spielern (bei Aggressivität 1), Readiness ≥ 55, Server-FPS > 15 | `random_battlegroups.sqf` |
| Luftangriff gegen Panzer/Luftfahrzeuge | Readiness ≥ 70 und Gewicht Panzer/Luft ≥ 50 | `counter_battlegroup.sqf` |
| Verstärkung für angegriffene Feindsektoren | aus dem nächsten feindlichen **Funkturm** (≤ 3,5 km), Fallschirmjäger bei hoher Readiness | `reinforcements_manager.sqf` |
| Patrouillen | ab 3 befreiten Sektoren, je nach Readiness-Schwellen | `manage_patrols.sqf`, `manage_one_patrol.sqf` |

Zusammensetzung: `spawn_battlegroup.sqf` – Spawnpunkt ist ein `opfor_point`-Marker 2–3 km (Infanterie: 1–3 km) vom Ziel;
Fahrzeuge aus `opfor_battlegroup_vehicles` (Readiness < 50: `…_low_intensity`), Größe aus `GRLIB_battlegroup_size` × Spielerfaktor × Aggressivität,
max. 16; 45 % reine Infanterie. Ziel ist das nächste BLUFOR-Objekt.

**Begründung:** Der Mechanismus (Readiness, Spawnpunkte, Verlust nach 20 min) ist solide und spart viel Arbeit. Für DESIGN 9 braucht es:
- Preset: keine Panzer, keine Luft (siehe 5.4) → asymmetrische Zusammensetzung ohne Code.
- „Nur aus Regionen mit Kommandoposten“: Hook beim Spawnpunkt (`KPLIB_fnc_getOpforSpawnPoint`-Aufruf in `spawn_battlegroup.sqf`).
- Mörser auf FOBs und Konvoi-Überfälle: neu.

---

## 8. Antworten auf offene Punkte aus `docs/TESTING.md` und `docs/DEPLOY.md`

| # | Fundstelle | Frage | Antwort | Beleg |
|---|---|---|---|---|
| 1 | `TESTING.md` 2., Schritt 2 | Ausgabeort und Ordnername | `_tools/build/kp_liberation.lythium/` (gebaut werden alle 18 Karten) | `_tools/gulpfile.ts` (`workDir`), `_tools/src/MissionPaths.ts` (`getOutputDir`), `_tools/_presets.json` |
| 2 | `TESTING.md` 2., Schritt 3 | Zielordner | Bei deinem Profil „Tunguski“: `Dokumente\Arma 3 - Other Profiles\Tunguski\mpmissions\` (Profil lokal gefunden) | – |
| 3 | `TESTING.md` 3., Schritt 4 | Zeus-Slot | „Platoon Leader (Commander)“ (`commandant`). Für vollen Zeus Parameter `LimitedZeus` = Deaktiviert, für Gegner `ZeusAddEnemies` = Aktiviert | `mission.sqm` Z. 2084; `init_client.sqf` Z. 96–106; `ui/mission_params.hpp` Z. 296–313 |
| 4 | `TESTING.md` 5. | Parameter zum Löschen | „Wipe Save Data“ **und** „Confirm: Wipe Save Data“ (deutsch „Spielstand löschen“ / „Bestätige: …“), beide auf Ja, danach zurückstellen | `ui/mission_params.hpp` Z. 380–391; `save_manager.sqf` Z. 7 |
| 5 | `TESTING.md` 5. | Speichert im Profil des Hosts? | Ja, `profileNamespace` des Servers, Key `KP_LIBERATION_LYTHIUM_SAVEGAME` | `fn_doSave.sqf`; Config Z. 191 |
| 6 | `DEPLOY.md` 1. | Erzeugt `build.bat` PBOs? | **Ja**: `_tools/build/pbo/kp_liberation.lythium.pbo` (unkomprimiert), dazu ZIP. Für den Namen `coin_liberation.lythium.pbo` müsste `missionName` in `_presets.json` geändert werden | `gulpfile.ts` (Task `default`, `pack_*`) |
| 7 | `DEPLOY.md` 5. | Spielstand-Datei | `<Profil>.vars.Arma3Profile` im Server-Profil, Variablen `KP_LIBERATION_LYTHIUM_SAVEGAME` (+ ggf. `…_SAVE_PARAMS`) | wie 5 |

Nebenbefund zu `TESTING.md` 1.: „ACE-Compat für RHS“ ist in deiner ACE-Version (3.21.2) schon enthalten (`@ace/addons/ace_compat_rhs_*.pbo`).
Die separaten Workshop-Compats in deinem `!Workshop`-Ordner sind tote Verknüpfungen.

Aus `DESIGN.md` / `CONTEXT.md` markierte Punkte („in Phase 0 prüfen“): Ruf → 7.1, Informanten → 7.2, asymmetrische Bedrohungen → 7.3,
Guerilla → 7.4.

---

## 9. Präfix-Check `COIN`

**Liberation:** nutzt `KPLIB_`, `KP_liberation_`, `GRLIB_`, `GREUH_`, `KPPLM_` und unpräfixierte Globale. Keine Fundstelle für `COIN`
außerhalb von `Missionframework/coin/` (Suche nach `coin`, Groß-/Kleinschreibung egal, in `*.sqf`, `*.hpp`, `*.ext`).

**Mods:** Durchsucht wurden die lokal installierten PBOs in `E:\Steam\steamapps\common\Arma 3\!Workshop\` von
CBA_A3, ACE (3.21.2), RHS USAF, RHS AFRF, RHS GREF, Project OPFOR, CUP Terrains – Core, CUP Terrains – Maps,
TFAR (`@task_force_radio` und `@Task Force Arrowhead Radio (BETA!!!)`), Jbad und Lythium.
Gesucht: Bezeichner `coin_…` (Groß-/Kleinschreibung egal), `class COIN`, `"COIN"`, `COIN_fnc_`, `tag = "COIN"`.
**Ergebnis: 0 Treffer.** Gegenprobe: `ace_common_fnc` in 109 ACE-PBOs, `cba_fnc_` in 30 CBA-PBOs, `rhs_fnc_` in 31 RHS-USAF-PBOs,
`TFAR_fnc_` in 6 TFAR-PBOs gefunden – die Suche greift also auch in gepackte Configs.

**Einschränkungen (unsicher):** Nur die installierten Versionen; andere Mods im Ordner (z. B. ALiVE, MCC) nicht geprüft, da nicht in der
erlaubten Liste. Eine Kollision wäre nur möglich, wenn ein Mod eine `CfgFunctions`-Klasse `COIN` oder globale `COIN_*`-Variablen definiert.

**Fazit:** Das Präfix `COIN` ist nach diesem Stand kollisionsfrei. ADR 0003 kann aus meiner Sicht auf „Akzeptiert“ – Entscheidung bei dir.

---

## 10. Risiken und Überraschungen

### Vereinfacht unsere Pläne

1. **Siegbedingung ohne Code:** Liberations `bigtown` ist genau unsere Hauptstadt. Mit nur **einem** `bigtown`-Marker und Parameter
   `VictoryCondition` = 0 („alle Hauptstädte“) ist „Hauptstadt eingenommen = Sieg“ erfüllt (4.5). Ticket 1.7 wird damit vermutlich
   zur Parameter- und Marker-Frage.
2. **Speichern hat ein Vorbild:** Liberation hat Index 19–21 mit `param [i, []]` abwärtskompatibel nachgerüstet. Option A in 3.2 ist dasselbe Muster.
3. **Kein `CfgRemoteExec`:** neue Funktionen müssen nirgends eingetragen werden.
4. **Ruf ist fertig:** Skala, Speicherung, Sync an Clients, Overlay-Anzeige, Ändern per `F_cr_changeCR` (Ticket 5.3 „Anzeige“ ist schon da).
5. **Guerilla-Spawn ist fertig:** `KPLIB_fnc_spawnGuerillaGroup` mit Ausrüstungsstufen für lokale Kämpfer.
6. **Build kopiert `coin/` automatisch** mit (ganzes `Missionframework/`), kein Build-Eingriff nötig.
7. **Ausrüstung über Presets:** Panzer, Jets, Artillerie, OPFOR-Luft lassen sich weitgehend über Preset-Listen und Lobby-Parameter abschalten (5.4).
8. **Gefangene:** Liberation hat Ergeben (80 %) und ACE-Captive schon drin (`prisonner_ai.sqf`). Abgeführte Gefangene bringen Intel-Punkte (`prisonner_remote_call.sqf`) – Anknüpfungspunkt für Verhöre (Ticket 3.5).

### Erschwert unsere Pläne

1. **Ruf-Skala ≠ Config-Annahme.** Liberation: −100…+100, Start 0. `coin_config.sqf` nimmt 0…100 an (`COIN_favorRepThreshold = 75`, Ruf-Bänder).
2. **„Niedriger Start-Ruf“ hat Nebenwirkungen.** Unter 0 starten Liberations IEDs, unter −25 Hinterhalte, Konvoi-Überfälle und ein **feindlicher
   Widerstand** (bei negativem Ruf kämpft die Guerilla mit der Miliz). Ein Startwert braucht einen Hook in `save_manager.sqf`.
3. **Doppelte Ruf-Abzüge:** Liberation zieht für getötete Zivilisten schon −5 ab. Unsere geplanten Werte würden sich addieren.
4. **Begriffskollision „Intel“.** Liberation hat eine Ressource `resources_intel` (Punkte für Nebenmissionen, aus Informanten, Gefangenen,
   Intel-Gegenständen in Militärbasen). Unser „Intel“ ist ein Hinweis auf ein Nest. Vorschlag: im Code `COIN_intel…` konsequent, in Doku/UI unterscheiden.
5. **Keine Zivilisten in befreiten Ortschaften.** Sektor-Zivilisten spawnen nur in **nicht befreiten** Sektoren (`sectorMonitor` betrachtet nur
   `sectors_allSectors - blufor_sectors`). In befreiten Orten gibt es nur durchziehende zivile Patrouillen (`manage_one_civilian_patrol.sqf`:
   nur in Sektoren ohne BLUFOR im 1-km-Umkreis). Für Befragungen und den Ältesten brauchen wir eigene Zivilisten. Außerdem sind
   Patrouillen-Zivilisten per `HandleDamage` gegen Schaden von Nicht-BLUFOR/Nicht-OPFOR geschützt.
6. **Kartenausschnitt betrifft auch Spawnpunkte.** Neben Sektoren müssen auch `opfor_point` (235) und `opfor_airspawn` (32) außerhalb des
   Ausschnitts entfernt werden, sonst kommen Battlegroups, Patrouillen und Nebenmissionen von außerhalb.
7. **Zeus-Standard passt nicht zu Säule 5.** `LimitedZeus` ist an, `ZeusAddEnemies` aus, Zivilisten und Objekte werden nie hinzugefügt. Zusätzlich entfernt
   `zeus_synchro.sqf` alle per `attachTo` befestigten Objekte aus den Kuratoren – trifft z. B. Sprengwesten oder angehängte IED-Teile.
8. **Save-Key gilt pro Karte, nicht pro Mission.** `KP_LIBERATION_LYTHIUM_SAVEGAME` teilen sich unsere Mission und das normale
   KP Liberation Lythium (das du abonniert hast, Workshop-ID 1226882826). Wer beide auf demselben Profil/Server spielt, überschreibt den
   anderen Spielstand. In deinem lokalen Profil liegt derzeit **kein** solcher Spielstand. Ein eigener Key wäre ein kleiner Hook in der Config.
9. **Presets kommen aus `_tools/_presets.json`**, nicht aus der Config (1.3). Leicht zu übersehen bei Ticket 1.6.
10. **OPFOR-Preset ist „Islamic State“**, nicht „Takistan“. Die DESIGN-Annahme „Lythium-Fassung = RHS USAF gegen Project OPFOR“ stimmt,
    aber die Fraktion ist schwer ausgerüstet (T-72, Mi-24, Su-25) und muss für die Miliz deutlich abgespeckt werden.
11. **Gleiche Optik Miliz/Guerilla** (`LOP_AM_OPF_*` vs. `LOP_AM_*`), siehe 7.4.
12. **Endlosschleife** in `send_paratroopers.sqf`, wenn `opfor_choppers` keinen Transporter enthält (5.4) – beim Ausdünnen des Presets beachten.
13. **Gebäudeschäden zählen nur bei Einnahme** und werden mit dem Stand beim Missionsstart verglichen. Zerstörung in bereits befreiten Orten kostet keinen Ruf.
    DESIGN 8 („Gebäude zerstört → Ruf sinkt“) braucht dafür eigenen Code.
14. **Befreite Funktürme zeigen Gegner auf der Karte.** `scripts/client/markers/hostile_groups.sqf` markiert alle 60–120 s
    jede feindliche Gruppe im Umkreis von `GRLIB_radiotower_size = 2500` m um einen BLUFOR-Funkturm als 500×500-m-Quadrat.
    Nest-Wachen und Camps wären damit ohne Intel sichtbar. → ADR 0013: keine Funktürme im Kartenausschnitt.
15. **Liberation-Funktionen sind gegen Überschreiben geschützt** (`allowFunctionsRecompile` = 0, `compileFinal`). Jede Verhaltensänderung braucht einen
    markierten Hook in der Liberation-Datei.
