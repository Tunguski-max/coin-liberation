# COIN Liberation (Arbeitstitel)

Persistente Counterinsurgency-Coop-Mission für Arma 3 auf **Lythium**, für 5–10 Spieler.

Basiert auf **[KP Liberation](https://github.com/KillahPotatoes/KP-Liberation)** (MIT-Lizenz)
und ergänzt eine asymmetrische Schicht, inspiriert von **Hearts and Minds**:
Dolmetscher, Intel von Zivilisten, Ruf, verdeckte Miliz-Nester, IEDs, VBIEDs und Hinterhalte.

> Die Original-README von KP Liberation liegt unter `docs/upstream/KP-Liberation-README.md`.

## Kurzfassung

- Die Miliz hat Kalae Noowi zu ihrer **Hauptstadt** gemacht und sich auf ganz Lythium eingegraben.
- Über die Karte verteilt: 25 **Ortschaften**, 5 **Supply Points**, 4 **Militärposten** und verdeckte **Nester**.
- Die Spieler sammeln über den **Dolmetscher** Intel, zerschlagen das Netzwerk und stürmen am Ende die Hauptstadt.

Details: [`docs/DESIGN.md`](docs/DESIGN.md) · Fortschritt: [`docs/ROADMAP.md`](docs/ROADMAP.md)

## Mods

| Pflicht | Optional |
|---|---|
| CBA_A3, ACE, RHS USAF, RHS AFRF, Project OPFOR, Jbad, Lythium, CUP Terrains (Core + Maps) | TFAR |

Die genaue Mod-Liste für den Server wird in Phase 7 festgeschrieben.

## Dokumentation

| Datei | Inhalt |
|---|---|
| `SETUP.md` | Repo aufsetzen, Claude Code einrichten |
| `CLAUDE.md` | Regeln für Claude Code |
| `CONTEXT.md` | Glossar |
| `docs/DESIGN.md` | Spieldesign |
| `docs/ROADMAP.md` | Phasen und Tickets |
| `docs/TESTING.md` | Lokal testen |
| `docs/DEPLOY.md` | Auf den G-Portal-Server bringen |
| `docs/adr/` | Architekturentscheidungen |
| `docs/hooks.md` | Wo unser Code in Liberation eingehängt ist |
| `CHANGELOG-COIN.md` | Änderungen der COIN-Schicht |

## Lizenz

KP Liberation steht unter der MIT-Lizenz (`LICENSE.md`), die erhalten bleibt.
[Hearts and Minds](https://github.com/Vdauphin/HeartsAndMinds) (Vdauphin) dient nur als Ideengeber,
es wird kein Code daraus übernommen (ADR 0002).
