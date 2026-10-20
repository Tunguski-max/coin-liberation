# Templates bauen

Anleitung für Niklas (ADR 0019, Tickets #44 und #32). Ein Gebäude-Template legt fest, wie ein Nest eines Typs
in einem Haus einer Klasse aussieht. Es gilt für jedes Haus dieser Klasse auf der Karte, egal wie das Haus gedreht ist.

## Hausklassen pro Nest-Typ

| Nest-Typ | Hausklassen |
|---|---|
| `vbiedGarage` | `Land_i_Shed_Ind_F`, `Land_CarService_F`, `Land_Jbad_Ind_Garage01` |
| `iedWorkshop` | `Land_jbad_House_8_old`, `Land_jbad_House_7_old`, `Land_jbad_House_c_5_v2` |
| `cache` | `Land_jbad_House_3_old`, `land_ffaa_casa_af_7`, `Land_jbad_House_1` |
| `command` | `Land_jbad_House6`, `Land_jbad_House7`, `Land_jbad_House3` |
| `recruitment` | `Land_jbad_House8`, `Land_jbad_terrace`, `Land_jbad_House_c_11` |

Ein Beispielhaus jeder Klasse findest du im Katalog im RPT (COIN Debug an, neue Kampagne: Zeilen `[COIN] nests: catalog …`).

## Was ins Template gehört

- **Genau ein Kernobjekt:** ein zerstörbares Objekt (Kisten gehen, die Satellitenschüssel nicht). Im Eden-Attribut
  „Variablenname“ den Namen `core` eintragen. Ohne Namen nimmt der Export im Spiel das Objekt mit der Klasse aus
  `COIN_nestCores`.
- **Requisiten** nach Belieben, gern auch auf Tischen oder Regalen.
- **VBIED-Garage:** ein ziviles Fahrzeug an der richtigen Stelle. Es wird für Spieler gesperrt.
- **Keine Wachen**, die setzt der Code selbst (Gebäudepositionen und Patrouille).
- Nur Objekte innerhalb des Hausumrisses (bis 3 m davor) werden erfasst.

## Weg 1: Eden-Editor (genau)

1. In Eden ein neues Szenario auf Lythium anlegen, eine spielbare Einheit neben das Haus stellen.
2. Objekte im Haus platzieren, dem Kernobjekt den Variablennamen `core` geben.
3. Szenario starten (Vorschau), zum Haus schauen, Esc, Debug-Konsole, den Befehl unten einfügen,
   in der ersten Zeile den Nest-Typ eintragen, **Lokal ausführen**.
4. Der Hint nennt die Zahl der Objekte und ob ein Kernobjekt dabei ist. Die fertige Zeile liegt in der Zwischenablage.
5. Die Zeile in `Missionframework/coin/coin_templates.sqf` unter `// Templates` einfügen oder an Claude schicken.

```sqf
private _type = "vbiedGarage"; private _house = [nearestBuilding player, cursorObject] select (cursorObject isKindOf "House"); (boundingBoxReal _house) params ["_c1", "_c2"]; private _hx = abs ((_c2 select 0) - (_c1 select 0)) / 2 + 3; private _hy = abs ((_c2 select 1) - (_c1 select 1)) / 2 + 3; private _objs = (nearestObjects [_house, [], vectorMagnitude [_hx, _hy, 0]]) select { private _l = _house worldToModel (ASLToAGL (getPosASL _x)); !(_x isEqualTo _house) && {getObjectType _x == 8} && {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "Logic")} && {!(_x isKindOf "WeaponHolder")} && {!(_x isEqualTo (vehicle player))} && {abs (_l select 0) <= _hx} && {abs (_l select 1) <= _hy} }; private _e = _objs apply { private _l = _house worldToModel (ASLToAGL (getPosASL _x)); private _r = ["prop", "vehicle"] select (_x isKindOf "LandVehicle"); if ((vehicleVarName _x) isEqualTo "core") then {_r = "core"}; format ["[""%1"",[%2,%3,%4],%5,""%6""]", typeOf _x, (_l select 0) toFixed 3, (_l select 1) toFixed 3, (_l select 2) toFixed 3, (((getDir _x) - (getDir _house) + 360) mod 360) toFixed 1, _r] }; private _t = format ["COIN_nestBuildingTemplates pushBack [""%1"",""%2"",[%3]];", _type, typeOf _house, _e joinString ","]; copyToClipboard _t; hint format ["%1 in %2: %3 objects, %4 core object(s), copied", _type, typeOf _house, count _objs, {(vehicleVarName _x) isEqualTo "core"} count _objs];
```

## Weg 2: in der Mission mit Zeus (schneller, weniger genau)

1. Mission auf dem lokalen Host starten, mit Zeus Objekte in ein Haus der Klasse setzen.
2. Zum Haus schauen, Debug-Konsole, **Lokal ausführen**:
   ```sqf
   ["vbiedGarage"] call COIN_fnc_exportNestTemplate;
   ```
   Kernobjekt ist das Objekt mit der Klasse aus `COIN_nestCores` für diesen Typ.
3. Die Zeile liegt in der Zwischenablage und steht im RPT (`[COIN] debug: template …`).

## Prüfen

Nach dem Einfügen und einem neuen Build meldet der Server beim Start
`[COIN] nests: N of N building templates usable`. Fehler stehen darüber (fehlende Klassen, kein oder mehrere
Kernobjekte). Ein Nest mit Template meldet beim Spawn `… template with N objects …`, eines ohne `… free placement …`.
