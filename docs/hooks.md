# Hooks – Eingriffe in den Liberation-Code

Jede Stelle, an der unser Code in eine Liberation-Datei eingehängt ist, steht hier.
Im Code selbst ist sie mit `// COIN:` bzw. `// COIN BEGIN` … `// COIN END` markiert.

Zweck: Bei einem Merge aus dem Upstream wissen wir genau, wo Konflikte entstehen können.

| # | Datei | Funktion / Stelle | Zweck | Phase |
|---|---|---|---|---|
| 1 | `Missionframework/description.ext` | `class CfgFunctions`, nach dem KPPLM-Include | `#include "coin\CfgFunctions.hpp"`: registriert alle `COIN_fnc_*`. `COIN_fnc_init` startet das Modul per `postInit`, daher braucht `init.sqf` keinen Eingriff | 0 |
| 2 | `Missionframework/description.ext` | `author`, `overviewText`, `onLoadMission` | Eigener Autor-Zusatz und eigene Texte, damit die Mission in Arma von KP Liberation unterscheidbar ist. Liberations Autoren bleiben stehen | 0 |
| 3 | `_tools/gulpfile.ts`, `_tools/src/Config.ts` | Laden der Presets; `stringTableReplace`; Interface `Preset` | Build liest `_tools/_presets.coin.json` (eigene Datei, nur COIN-Missionen). `COIN_ALL_PRESETS=1` baut zusätzlich alle Liberation-Karten aus `_presets.json`. Optionales Preset-Feld `missionTitle` (Platzhalter `{map}`, `{version}`) für den Titel in der Missionsliste | 0 |
| 4 | `Missionframework/kp_liberation_config.sqf` | `GRLIB_save_key` | Eigener Save-Key `COIN_LIBERATION_<WORLD>_SAVEGAME` statt `KP_LIBERATION_<WORLD>_SAVEGAME`. Ein vorhandener Stand des normalen KP Liberation auf derselben Karte bleibt unberührt (ADR 0005) | 1 (#6) |
| 5 | `Missionframework/functions/fn_getSaveableParam.sqf` | `_saveKey` | Eigener Key `COIN_LIBERATION_<WORLD>_SAVE_PARAMS` für gespeicherte Lobby-Parameter. Sonst würden die Parameter des normalen KP Liberation unsere Lobby-Standardwerte überstimmen (Standard „Laden“) bzw. beim Speichern überschrieben | 1 (#6) |
| 6 | `Missionframework/ui/mission_params.hpp` | `default` von `ResourcesMultiplier` (6 = x2, ADR 0017), `VictoryCondition` (0 = alle Hauptstädte, ADR 0016), `LimitedZeus` (0 = aus), `ZeusAddEnemies` (1 = an, ADR 0010), `SuppMod` (0 = aus, ADR 0007) | Lobby-Standardwerte für unser Design. In der Lobby weiter änderbar. Fünf einzelne Zeilen, je mit `// COIN:` markiert | 1 (#6) |
| 7 | `Missionframework/presets/init_presets.sqf`, `Missionframework/kp_liberation_config.sqf` | `switch (KP_liberation_preset_blufor)`: neuer `case 31`; Kommentarliste der BLUFOR-Presets | Preset 31 = `presets/blufor/coin_light_brigade.sqf` (leichte Brigade, ADR 0007). Die Mission wählt es über `_tools/_presets.coin.json` (Build überschreibt `KP_liberation_preset_blufor`). Das Preset selbst ist eine neue Datei ohne Eingriff in Liberation-Dateien | 1 (#7) |
