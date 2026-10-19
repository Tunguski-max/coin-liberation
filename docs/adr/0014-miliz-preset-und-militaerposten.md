# ADR 0014: Miliz auf Afghan-Militia-Basis, Militärposten als Belohnungsleiter

**Status:** Akzeptiert (2026-10-18), Details in Ticket 1.6. Ergänzt ADR 0007.; Gegenangriffe um Truppentransporter (Ural) ergänzt (2026-10-19)

## Kontext
- Die Lythium-Fassung nutzt das OPFOR-Preset „Islamic State“ (`presets/opfor/islamic_state.sqf`) mit
  T-72, Mi-24 und Su-25. Ihre Sektorverteidiger (`LOP_AM_OPF_*`) sehen aus wie Liberations Widerstand
  (`LOP_AM_*`), also wie unsere künftigen lokalen Kämpfer.
- Militärsektoren schalten je ein Elite-Fahrzeug frei. Die aktuelle Elite-Liste enthält fast nur Gerät,
  das ADR 0007 ausschließt.

## Entscheidung
- Die Miliz bekommt ein **eigenes Preset auf Basis von Project OPFOR „Afghan Militia“** (`LOP_AM_OPF_*`):
  Infanterie, Technicals, statische Waffen. Schweres Gerät nur im Rahmen von E10.
- **Rüstung der Miliz:** Afghan Militia hat keinen Schutz (Weste 0, Kopf 0), Islamic State Weste 16 und Helm 6. Die Feld-Squads (höhere Bereitschaft, Gegenangriffe) mischen
  Islamic-State-Zwillinge ein, Anteil linear von 25 % (Bereitschaft 30) bis 75 % (100), darunter 0 %, pro Spawn gewürfelt (Hooks 9 und 10: `COIN_fnc_mixSquad`, `COIN_fnc_mixClass`). Die Garnison bei niedriger
  Bereitschaft und Fahrzeugbesatzungen bleiben Afghan Militia (2026-10-19).
- Miliz und Widerstand bekommen ein **farbiges Kopftuch** als Erkennungszeichen (rot Miliz, grün feindlicher Widerstand, blau neutraler oder freundlicher
  Widerstand), gesetzt von `COIN_fnc_markFactions`, nicht über Kleidungslisten (2026-10-19, Ticket #9; ersetzt „Kleidungslisten im Widerstands-Preset“).
- Die **Elite-Liste** wird mit erlaubtem, aber wertvollem Gerät gefüllt. Militärposten werden damit
  zu lohnenden optionalen Zielen; E9 („wenige Schützenpanzer, teuer“) kann darüber freigeschaltet werden.

- **Verteilung des schweren Geräts (E10):**
  - Sektorverteidiger und Patrouillen: nur Technicals.
  - Gegenangriffe: Technicals und Truppentransporter (Ural), höchstens 1 Altfahrzeug (BTR-60/M113, auch als
    Truppentransporter nutzbar; zwei gleichzeitig wären zu viel). Bis Phase 6.2 nur über die Gewichtung
    der Liste, danach hart per Hook.
  - Waffenlager: 1–2 Altfahrzeuge, gespawnt von unserem Code; sie verschwinden mit dem Lager.
  - Hauptstadt: 2 T-72BA, 1 ZSU-23-4, Igla-Schützen, gespawnt von unserem Code (Klassen in `coin_config.sqf`,
    Ticket 6.3). Sie stehen nicht in Liberations Listen, damit Liberation sie nicht anderswo würfelt.
  - Liberations Flugzeug- und Hubschrauberlisten bleiben leer.

## Begründung
- Afghan Militia entspricht „Taliban-ähnlich, asymmetrisch“ (DESIGN 1) und bringt die passenden Fahrzeuge mit.
- Unterscheidbare Optik verhindert Teamkills an lokalen Kämpfern.

## Folgen
- Presets werden in `_tools/_presets.coin.json` ausgewählt, nicht in `kp_liberation_config.sqf`.
- Beim Ausdünnen `opfor_choppers` leer lassen oder einen Transporter behalten (Endlosschleife in
  `send_paratroopers.sqf`).
