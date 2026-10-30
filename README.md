# COIN Liberation

**Counterinsurgency – Liberate Lythium.** A persistent co-op counterinsurgency mission for Arma 3 on **Lythium**, for 5 to 10 players.

COIN Liberation is a fork of **[KP Liberation](https://github.com/KillahPotatoes/KP-Liberation)** (MIT license). It keeps Liberation's logistics, FOB building, resources, sectors and save system, and puts an asymmetric counterinsurgency layer on top of it. The layer is inspired by *Hearts and Minds*: interpreter, intel from civilians, reputation, hidden insurgent hideouts, IEDs, VBIEDs and ambushes. Only ideas were taken from *Hearts and Minds*, no code (see ADR 0002).

> **Disclaimer: AI-generated content.** Large parts of this project were created with the help of AI (Anthropic's Claude, via Claude Code): SQF code, configuration, stringtable texts (German and English), documentation, the in-game tutorial, and the artwork (mission picture and task images, generated with an AI image generator from prompts written by the AI). The design decisions, the direction, the testing in the game and the final approval are by a human (Niklas, GitHub `Tunguski-max`). Nothing here comes with a guarantee: see [Status](#status) and the [License](#license-and-credits) section.

> The documentation under `docs/` is written in **German**; code, code comments and this README are in English. In-game texts of the COIN layer exist in **German and English**; other languages fall back to English.

## The story

An insurgent militia has made **Kalae Noowi** its capital and dug in across all of Lythium with a network of hidden hideouts: IED workshops, weapons caches, command posts, VBIED garages and recruitment points. You are the army. You cannot beat them by firepower alone. You have to win over the population, collect intel, find and destroy the hideouts, weaken the network, and only then storm the capital.

## How it differs from KP Liberation

KP Liberation is a conventional "liberate every sector" campaign against a regular army. COIN Liberation keeps its engine and changes what the campaign is about.

| | KP Liberation | COIN Liberation |
|---|---|---|
| **Enemy** | Regular army (NATO, CSAT, …) with bases, radio towers and a USS Freedom story | Insurgent militia (Project OPFOR "Afghan Militia" / Islamic State look), asymmetric, with a hidden network |
| **Goal** | Liberate **all** major cities | Take **one** capital, Kalae Noowi. Its defence depends on how much of the network is still alive |
| **Map** | Very many sectors (COIN removed 157 sector markers from Lythium) | The whole of Lythium, thinned out: 29 towns, 8 supply points, 6 military posts, 12 hideouts (hand-picked list, ADR 0016) |
| **Enemy bases** | FOBs, radio towers, "FOB hunting" | No radio towers (they would reveal hideouts). **Hideouts** instead: invisible until you find them with intel |
| **Information** | The map shows the enemy | You get **intel** from civilians and prisoners as circles on the map. Circles shrink with every true lead. Lies look identical |
| **Player roles** | Commander and squad roles | Plus a dedicated **interpreter** (two slots). Only the interpreter can talk to civilians and prisoners |
| **Civilians** | Mostly scenery, reputation as a score | Civilians are the intel source. **Reputation** (−100 to +100, starts at −20) decides whether they tell the truth, lie or refuse. The number is hidden, the interpreter asks "How do you feel about us?" |
| **Threats on the road** | Enemy patrols, battlegroups | IEDs (buried, remote, decoys), VBIEDs, suicide bombers, ambushes from camps, mortar fire on your FOBs |
| **Aggression** | Readiness rises with your progress | Readiness is **capped by the network strength**. Every destroyed hideout lowers it at once |
| **Counterattacks** | Come from anywhere | Come from **staging areas** (around active command posts and enemy military posts), asymmetric: technicals and infantry, at most one old APC, no tanks |
| **Side missions** | Bought with intel points | Still there, now started at the **village elder**. In addition **aid tasks** (supplies, medical mission, repair) and **strike tasks** (intercept a courier, arrest a leader, stop an arms transport, stop an export) |
| **Support from locals** | Occasional guerrilla help | At very high reputation: **favours** that bring **local fighters** you lead by radio. At low reputation the resistance turns on you |
| **Who is who** | Faction colours | Headscarf colours: **red** insurgents, **green** hostile resistance, **blue** neutral or friendly resistance (live, follows the reputation) |
| **Capital** | Normal garrison | Garrison grows with every living hideout, plus tanks, an AA tank and Igla gunners |
| **Equipment** | Full BLUFOR preset | **Light brigade**: infantry, protected wheeled vehicles, light support. Elite vehicles are unlocked by military posts. Some expensive vehicles have limits and a lock time |
| **Texts** | Liberation's stringtable | A COIN package in the stringtable, German and English, visible words "hideout" and "insurgents" (ADR 0026) |
| **Tutorial** | Liberation's story | Rewritten for COIN (11 pages) |
| **Zeus** | Zeus interface for the commander | Same, and everything the COIN layer spawns is registered with Zeus, who can see, change and delete it |

What stays from Liberation: resources and supply points, FOB building and logistics, the build menu, AI logistics convoys, side-mission mechanics, sector capture and garrisons, the save system (the COIN state is stored in the same save), and the Zeus integration.

## How a round plays

```
Visit a town / patrol
   -> interpreter questions civilians  ->  intel circle on the map
   -> more intel shrinks the circle    ->  find and destroy the hideout
   -> network gets weaker: fewer IEDs, weaker counterattacks, smaller capital garrison
   -> reputation rises: better intel, informants, strike tasks, favours
   -> build FOBs, extend logistics, capture towns
   -> final phase: storm the capital
```

### Roles (15 slots)

- **Command group:** commander (Zeus) and two interpreters.
- **Squad A and squad B:** squad leader, medic, EOD, two riflemen each.
- **Helicopter pilots:** two.

### Main systems

- **Insurgent network:** hideouts of five types (command post, IED workshop, weapons cache, VBIED garage, recruitment point), either in existing buildings at the edge of towns or as small field camps built from templates. Destroying the core object or collapsing the house destroys the hideout for good. Small mobile camps lead you to the hideouts.
- **Interpreter and intel:** questioning civilians, interrogating prisoners, the mood question, finding the elder. Rumour, lead and concrete tip, warnings, lies, triangulation. A waiting time between questions (1.5 minutes) keeps a town from being farmed.
- **Reputation:** rises with liberated towns, destroyed hideouts, defused IEDs, aid tasks and treated wounded. Falls with dead civilians and dead prisoners.
- **Elder and tasks:** every liberated town has an elder. Aid tasks give reputation, strike tasks give intel or lower the readiness. Aid sites lie in villages outside the sectors, where an ambush can wait.
- **Reinforcement:** local fighters at very high reputation, led by radio commands ("Follow us", "Go there", "Attack"), withdrawing after 30 minutes.
- **Counterattacks, relief and mortars:** all come from staging areas. FOBs inside a staging area can be shelled by a mortar squad that can be found and killed.
- **Capital:** a garrison that scales with the living network, plus heavy equipment for the final assault.
- **Localization:** all COIN player texts are stringtable keys (`STR_COIN_*`), German and English.

## Requirements

| Required | Optional |
|---|---|
| CBA_A3, ACE, RHS USAF, RHS AFRF, Project OPFOR, Jbad, Lythium, CUP Terrains (Core and Maps), CUP Vehicles, CUP Weapons, Drongos Map Population | TFAR |

The exact mod list for the server is in [`docs/TESTING.md`](docs/TESTING.md).

## Build and install

The build needs Node.js.

1. Run `build.bat` in the repository root.
2. The result is the mission folder `_tools/build/coin_liberation.lythium/`, a PBO in `_tools/build/pbo/` and a ZIP in `_tools/build/`.
3. Copy the folder (or the PBO) to `mpmissions/` and start it on Lythium.

Local testing: [`docs/TESTING.md`](docs/TESTING.md). Dedicated server (G-Portal): [`docs/DEPLOY.md`](docs/DEPLOY.md). **Back up the server profile (the `.vars.Arma3Profile` save) before every mission update**, the save format is versioned (`COIN_saveVersion`).

## Status

- The COIN layer was developed in phases (see [`docs/ROADMAP.md`](docs/ROADMAP.md)) and most features were tested in the game by the maintainer, mostly on a local host.
- **Not yet tested:** longer sessions on a dedicated server, the behaviour of late-joining players and the view of other players (Roadmap 7.5), and several features in English. Some items in the roadmap are still marked as untested.
- Optional: an end screen with COIN statistics (tickets #162 and #163) is not implemented.
- Expect bugs. Please report them as issues and attach the relevant `[COIN]` lines of the RPT file.

## Documentation (German)

| File | Content |
|---|---|
| `docs/DESIGN.md` | Game design |
| `docs/ROADMAP.md` | Phases and tickets |
| `CONTEXT.md` | Glossary |
| `docs/adr/` | Architecture decisions |
| `docs/hooks.md` | Where COIN code hooks into Liberation (for upstream updates) |
| `docs/TESTING.md`, `docs/DEPLOY.md` | Testing locally, deploying to a server |
| `docs/befragung-und-intel.md` | Questioning and intel in detail |
| `CHANGELOG-COIN.md` | Changes of the COIN layer (Liberation's own changes: `CHANGELOG.md`) |
| `CLAUDE.md`, `SETUP.md` | Rules and setup for working with Claude Code |

The original README of KP Liberation is kept in [`docs/upstream/README.md`](docs/upstream/README.md).

The COIN code lives in `Missionframework/coin/`. Changes inside Liberation files are marked with `// COIN` comments and listed in `docs/hooks.md`.

## License and credits

- **KP Liberation** by the KP Liberation Dev Team, based on work by GreuhZbug (GREUH) and Wyqer, is licensed under the **MIT License** (see [`LICENSE.md`](LICENSE.md)). The original license text and copyright notice are kept, as the license requires. One copyright line for COIN Liberation was added below them.
- **COIN Liberation** additions (`Missionframework/coin/`, the Liberation hooks, the documentation and the artwork) are by Tunguski with AI assistance (see the disclaimer above) and are released under the same MIT License as the rest of this repository.
- **Hearts and Minds** (Vdauphin) is an inspiration only. No code was taken from it.
- **Not included:** the mods listed above and the map Lythium are separate works under their own licenses. This repository does not contain them. You need them to run the mission.
- The software is provided "as is", without warranty of any kind (see `LICENSE.md`).
