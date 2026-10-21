# Templates bauen

Anleitung für Niklas (ADR 0019, ADR 0020, Tickets #44, #31 und #32). Ein Gebäude-Template legt fest, wie ein Nest
eines Typs in einem Haus einer Klasse aussieht. Es gilt für jedes Haus dieser Klasse auf der Karte, egal wie das Haus
gedreht ist. Ein Gelände-Template legt fest, wie ein Gelände-Nest oder ein Camp aussieht (Abschnitt
[Gelände-Templates](#gelände-templates)).

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

1. In Eden ein neues Szenario auf Lythium anlegen, zu einem echten Haus der Klasse springen und eine spielbare
   Einheit daneben stellen. Viele Kartengebäude sind versteckt (`scope = 1`) und fehlen im Objekt-Browser, deshalb
   das Haus auf der Karte nehmen. Kamera hinsetzen (Eden-Debug-Konsole, Strg+D), Position aus dem Katalog:
   ```sqf
   move3DENCamera [[16323, 6749, 40], false];
   ```
   Alternativ ein Haus setzen: `create3DENEntity ["Object", "Land_CarService_F", screenToWorld [0.5, 0.5]];`
2. Objekte im Haus platzieren, dem Kernobjekt den Variablennamen `core` geben.
3. Szenario starten (Vorschau), zum Haus schauen, Esc, Debug-Konsole, den Befehl unten einfügen,
   in der ersten Zeile den Nest-Typ eintragen, **Lokal ausführen**.
4. Der Hint nennt die Zahl der Objekte und ob ein Kernobjekt dabei ist. Die fertige Zeile liegt in der Zwischenablage.
5. Die Zeile in `Missionframework/coin/coin_templates.sqf` unter `// Building templates` einfügen oder an Claude schicken.

```sqf
private _type = "vbiedGarage"; private _house = [nearestBuilding player, cursorObject] select (cursorObject isKindOf "House"); (boundingBoxReal _house) params ["_c1", "_c2"]; private _hx = abs ((_c2 select 0) - (_c1 select 0)) / 2 + 3; private _hy = abs ((_c2 select 1) - (_c1 select 1)) / 2 + 3; private _in = { private _l = _house worldToModel (ASLToAGL (getPosASL _x)); abs (_l select 0) <= _hx && {abs (_l select 1) <= _hy} }; private _objs = (nearestObjects [_house, [], vectorMagnitude [_hx, _hy, 0]]) select { !(_x isEqualTo _house) && {getObjectType _x == 8} && {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "Logic")} && {!(_x isKindOf "WeaponHolder")} && {isClass (configFile >> "CfgVehicles" >> typeOf _x)} && {((typeOf _x) find "Fx") != 0} && {!(_x isEqualTo (vehicle player))} && _in }; _objs append (allMines select _in); private _e = _objs apply { private _l = _house worldToModel (ASLToAGL (getPosASL _x)); private _r = ["prop", "vehicle"] select (_x isKindOf "LandVehicle"); if (_x in allMines) then {_r = "mine"}; if ((vehicleVarName _x) isEqualTo "core") then {_r = "core"}; format ["[""%1"",[%2,%3,%4],%5,""%6""]", typeOf _x, (_l select 0) toFixed 3, (_l select 1) toFixed 3, (_l select 2) toFixed 3, (((getDir _x) - (getDir _house) + 360) mod 360) toFixed 1, _r] }; private _t = format ["COIN_nestBuildingTemplates pushBack [""%1"",""%2"",[%3]];", _type, typeOf _house, _e joinString ","]; copyToClipboard _t; hint format ["%1 in %2: %3 objects, %4 core object(s), copied", _type, typeOf _house, count _objs, {(vehicleVarName _x) isEqualTo "core"} count _objs];
```

## Weg 2: in der Mission mit Zeus (schneller, weniger genau)

1. Mission auf dem lokalen Host starten, mit Zeus Objekte in ein Haus der Klasse setzen.
2. Zum Haus schauen, Debug-Konsole, **Lokal ausführen**:
   ```sqf
   ["vbiedGarage"] call COIN_fnc_exportNestTemplate;
   ```
   Kernobjekt ist das Objekt mit der Klasse aus `COIN_nestCores` für diesen Typ.
3. Die Zeile liegt in der Zwischenablage und steht im RPT (`[COIN] debug: template …`).

## Gelände-Templates

Ein Gelände-Template gilt für jedes Gelände-Nest seines Typs (oder für Camps, Typ `camp`). Der Seed des Nests wählt
eines der Templates des Typs und dreht es beliebig um die Nest-Position. Jedes Objekt behält seine Höhe über dem Boden
und kippt mit dem Gelände unter ihm (ADR 0020). Pro Nest-Typ sind 2–3 Templates geplant, dazu 2–3 für Camps.

- **Richtungspfeil als Mitte:** einen `Sign_Arrow_Direction_F` in die Mitte des Lagers setzen, die Spitze zeigt nach
  „vorne“. Er wird nicht exportiert. Variablenname `centre` ist optional; ohne ihn nimmt der Export den nächsten Pfeil
  im Umkreis von 50 m um den Spieler.
- **Umkreis:** erfasst wird alles bis 15 m um den Pfeil. So groß ist die freie, ebene Fläche, die ein Gelände-Nest
  bekommt (höchstens 15 % Steigung).
- **Kernobjekt** wie bei Gebäuden mit Variablenname `core`, genau eines. **Camps haben kein Kernobjekt.**
- **Keine Wachen**, die stehen dynamisch in einem Ring 6–12 m um die Mitte, der Rest patrouilliert.
- Am besten auf einer ebenen Stelle bauen. Gestapeltes (Dinge auf Tischen) geht, es kippt am Hang mit.
- Weil das Lager beliebig gedreht wird, nichts bauen, was nur zu einer bestimmten Himmelsrichtung passt.

### In Eden

1. Leeres Szenario auf Lythium, freie ebene Stelle, spielbare Einheit daneben, Pfeil in die Mitte, Objekte drumherum.
2. Vorschau starten, Esc, Debug-Konsole, den Befehl unten einfügen, in der ersten Zeile den Typ eintragen
   (`command`, `iedWorkshop`, `cache`, `vbiedGarage`, `recruitment` oder `camp`), **Lokal ausführen**.
3. Der Hint nennt die Zahl der Objekte und Kernobjekte. Die Zeile liegt in der Zwischenablage.
4. Die Zeile an Claude schicken oder in `coin_templates.sqf` unter `// Terrain templates` (am Ende) einfügen.

```sqf
private _type = "cache"; private _c = missionNamespace getVariable ["centre", objNull]; if (isNull _c) then {_c = (nearestObjects [player, ["Sign_Arrow_Direction_F"], 50]) param [0, objNull]}; if (isNull _c) exitWith {hint "No centre arrow (Sign_Arrow_Direction_F) within 50 m"}; private _d = getDir _c; private _objs = (nearestObjects [_c, [], 15]) select { !(_x isEqualTo _c) && {getObjectType _x == 8} && {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "Logic")} && {!(_x isKindOf "WeaponHolder")} && {isClass (configFile >> "CfgVehicles" >> typeOf _x)} && {((typeOf _x) find "Fx") != 0} && {!(_x isEqualTo (vehicle player))} }; _objs append (allMines select {(_x distance2D _c) <= 15}); private _e = _objs apply { ((getPosASL _x) vectorDiff (getPosASL _c)) params ["_dx", "_dy"]; private _r = ["prop", "vehicle"] select (_x isKindOf "LandVehicle"); if (_x in allMines) then {_r = "mine"}; if ((vehicleVarName _x) isEqualTo "core" && {_type != "camp"}) then {_r = "core"}; format ["[""%1"",[%2,%3,%4],%5,""%6""]", typeOf _x, (_dx * cos _d - _dy * sin _d) toFixed 3, (_dx * sin _d + _dy * cos _d) toFixed 3, ((getPosATL _x) select 2) toFixed 3, (((getDir _x) - _d + 360) mod 360) toFixed 1, _r] }; private _t = format ["COIN_terrainTemplates pushBack [""%1"",[%2]];", _type, _e joinString ","]; copyToClipboard _t; hint format ["Terrain %1: %2 objects, %3 core object(s), copied", _type, count _objs, {(vehicleVarName _x) isEqualTo "core"} count _objs];
```

### In der Mission mit Zeus

Pfeil und Objekte mit Zeus setzen, neben den Pfeil stellen, Debug-Konsole, **Lokal ausführen**:
```sqf
["cache"] call COIN_fnc_exportTerrainTemplate;
```
Kernobjekt ist dort das Objekt mit der Klasse aus `COIN_nestCores` für diesen Typ.

## Prüfen

Nach dem Einfügen und einem neuen Build meldet der Server beim Start
`[COIN] nests: N of N building templates usable` und
`[COIN] nests: N of N terrain templates usable (M for camps), nest types without one: []`. Fehler stehen darüber
(fehlende Klassen, falsche Zahl an Kernobjekten). Ein Gebäude-Nest mit Template meldet beim Spawn
`… template with N objects …`, eines ohne `… free placement …`. Ein Gelände-Nest meldet
`… spawned in the terrain … terrain template 1 of 1 turned to … degrees …`.
Camp-Templates werden schon geprüft, spawnen aber erst mit dem Camp-Ticket.

## Hinweise

- Umgebungseffekte (`FxWindGrass…`, `HouseFly`) nimmt der Export nicht mit.
- **Keine ACE-Sanitätskisten** (`ACE_medicalSupplyCrate…`): Liberation zeigt sie auf der Karte an, das verrät das Nest.
- **Minen** übernimmt der Export mit der Rolle `mine`. Sie spawnen scharf (entschieden 2026-10-20): Spieler können
  sie mit ACE entschärfen, ein Schuss kann sie auslösen. Liberation speichert jede Mine nahe einer FOB mit, eine FOB
  näher als etwa 150 m an so einem Nest verdoppelt sie nach einem Neustart.
- Nur Klassen aus unserer Mod-Liste verwenden (CLAUDE.md). Fehlt eine Klasse auf dem Server, verwirft die Prüfung
  das Objekt mit einer Logzeile, das Template bleibt sonst nutzbar.
