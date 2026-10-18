# ADR 0014: Miliz auf Afghan-Militia-Basis, Militärposten als Belohnungsleiter

**Status:** Akzeptiert (2026-10-18), Details in Ticket 1.6. Ergänzt ADR 0007.

## Kontext
- Die Lythium-Fassung nutzt das OPFOR-Preset „Islamic State“ (`presets/opfor/islamic_state.sqf`) mit
  T-72, Mi-24 und Su-25. Ihre Sektorverteidiger (`LOP_AM_OPF_*`) sehen aus wie Liberations Widerstand
  (`LOP_AM_*`), also wie unsere künftigen lokalen Kämpfer.
- Militärsektoren schalten je ein Elite-Fahrzeug frei. Die aktuelle Elite-Liste enthält fast nur Gerät,
  das ADR 0007 ausschließt.

## Entscheidung
- Die Miliz bekommt ein **eigenes Preset auf Basis von Project OPFOR „Afghan Militia“** (`LOP_AM_OPF_*`):
  Infanterie, Technicals, statische Waffen. Schweres Gerät nur im Rahmen von E10.
- Lokale Kämpfer bekommen über die Kleidungslisten im Widerstands-Preset eine **erkennbare Kleidung**.
- Die **Elite-Liste** wird mit erlaubtem, aber wertvollem Gerät gefüllt. Militärposten werden damit
  zu lohnenden optionalen Zielen; E9 („wenige Schützenpanzer, teuer“) kann darüber freigeschaltet werden.

## Begründung
- Afghan Militia entspricht „Taliban-ähnlich, asymmetrisch“ (DESIGN 1) und bringt die passenden Fahrzeuge mit.
- Unterscheidbare Optik verhindert Teamkills an lokalen Kämpfern.

## Folgen
- Presets werden in `_tools/_presets.coin.json` ausgewählt, nicht in `kp_liberation_config.sqf`.
- Beim Ausdünnen `opfor_choppers` leer lassen oder einen Transporter behalten (Endlosschleife in
  `send_paratroopers.sqf`).
