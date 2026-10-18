# Hooks – Eingriffe in den Liberation-Code

Jede Stelle, an der unser Code in eine Liberation-Datei eingehängt ist, steht hier.
Im Code selbst ist sie mit `// COIN:` bzw. `// COIN BEGIN` … `// COIN END` markiert.

Zweck: Bei einem Merge aus dem Upstream wissen wir genau, wo Konflikte entstehen können.

| # | Datei | Funktion / Stelle | Zweck | Phase |
|---|---|---|---|---|
| 1 | `Missionframework/description.ext` | `class CfgFunctions`, nach dem KPPLM-Include | `#include "coin\CfgFunctions.hpp"`: registriert alle `COIN_fnc_*`. `COIN_fnc_init` startet das Modul per `postInit`, daher braucht `init.sqf` keinen Eingriff | 0 |
| 2 | `Missionframework/description.ext` | `author`, `overviewText`, `onLoadMission` | Eigener Autor-Zusatz und eigene Texte, damit die Mission in Arma von KP Liberation unterscheidbar ist. Liberations Autoren bleiben stehen | 0 |
| 3 | `_tools/gulpfile.ts`, `_tools/src/Config.ts` | Laden der Presets; `stringTableReplace`; Interface `Preset` | Build liest `_tools/_presets.coin.json` (eigene Datei, nur COIN-Missionen). `COIN_ALL_PRESETS=1` baut zusätzlich alle Liberation-Karten aus `_presets.json`. Optionales Preset-Feld `missionTitle` (Platzhalter `{map}`, `{version}`) für den Titel in der Missionsliste | 0 |
