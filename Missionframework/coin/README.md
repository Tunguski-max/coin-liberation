# Modul `coin/`

Hier liegt der gesamte eigene Code der COIN-Schicht (siehe ADR 0003).
Der Build (`build.bat`) kopiert den Ordner automatisch mit in die Mission.

## Struktur

```
coin/
├── CfgFunctions.hpp       Registrierung aller COIN_fnc_* (in description.ext eingebunden, Hook #1)
├── coin_config.sqf        Balancing und Feature-Schalter, auf jeder Maschine geladen
├── CfgNotifications.hpp   Meldungen an die Spieler, eingebunden in ui\liberation_notifications.hpp (Hook 20)
├── coin_templates.sqf     Gebäude- und Gelände-Templates (ADR 0019, ADR 0020), nach coin_config.sqf geladen
├── init_server.sqf        Server-Teil des Moduls
├── init_client.sqf        Client-Teil des Moduls (Maschinen mit Interface)
└── functions/
    ├── core/
    │   ├── fn_init.sqf              COIN_fnc_init: Einstiegspunkt (postInit)
    │   ├── fn_applyRoleTraits.sqf   COIN_fnc_applyRoleTraits: ACE-Fähigkeiten der Slots (EOD, Sanitäter)
    │   ├── fn_markFactions.sqf      COIN_fnc_markFactions: Server-Schleife, farbiges Kopftuch für Miliz und Widerstand
    │   ├── fn_getSquadMixShare.sqf  COIN_fnc_getSquadMixShare: Anteil gepanzerter Islamic-State-Kämpfer nach Bereitschaft
    │   ├── fn_mixClass.sqf          COIN_fnc_mixClass: tauscht eine Miliz-Klasse gegen ihr Islamic-State-Gegenstück (Hook 10)
    │   ├── fn_mixSquad.sqf          COIN_fnc_mixSquad: tauscht eine ganze Squad (Hook 9)
    │   ├── fn_registerSquadTwins.sqf COIN_fnc_registerSquadTwins: Zwillingsklassen in KPLIB_o_inf_classes
    │   ├── fn_createDiary.sqf       COIN_fnc_createDiary: Karten-Tagebuch "COIN Liberation" für Spieler
    │   ├── fn_vehicleLimitStatus.sqf   COIN_fnc_vehicleLimitStatus: darf diese Klasse jetzt gekauft werden? (Kaufmenü und Server)
    │   ├── fn_vehicleLimitPurchase.sqf COIN_fnc_vehicleLimitPurchase: Server-Prüfung beim Kauf, startet die Sperre (Hook 12)
    │   ├── fn_vehicleLimitRelease.sqf  COIN_fnc_vehicleLimitRelease: Server hebt die Sperre eines abgebrochenen Kaufs auf
    │   ├── fn_vehicleLimitDeny.sqf     COIN_fnc_vehicleLimitDeny: Client bricht die Platzierung nach abgelehntem Kauf ab
    │   ├── fn_vehicleLimitCancel.sqf   COIN_fnc_vehicleLimitCancel: Client meldet einen abgebrochenen Kauf (Hook 13)
    │   ├── fn_guaranteeResources.sqf   COIN_fnc_guaranteeResources: gleicht die Sorten der Supply Points aus, bei 8 immer 3-3-2 (Hook 14)
    │   ├── fn_secondaryMissionStatus.sqf COIN_fnc_secondaryMissionStatus: darf diese Nebenmission starten? FOB Hunting ist abgeschaltet (Hooks 15 und 16)
    │   ├── fn_replacesLiberationThreats.sqf COIN_fnc_replacesLiberationThreats: sind Liberations IEDs und Ortschafts-Hinterhalte abgeschaltet? (Hooks 22 und 23)
    │   ├── fn_aiBudget.sqf             COIN_fnc_aiBudget: Server-Schleife, Liberations Gegner-Grenzen = 100 × Unitcap + COIN-Einheiten (ADR 0015)
    │   ├── fn_applyEnemyAICaps.sqf     COIN_fnc_applyEnemyAICaps: setzt Liberations drei Grenzen auf dieser Maschine (Server und Clients)
    │   ├── fn_markCoinUnits.sqf        COIN_fnc_markCoinUnits: kennzeichnet von COIN gespawnte Einheiten für das Budget
    │   ├── fn_countCoinUnits.sqf       COIN_fnc_countCoinUnits: zählt lebende COIN-Einheiten auf der Feindseite
    │   └── fn_campFitsBudget.sqf       COIN_fnc_campFitsBudget: darf ein Camp mit N Kämpfern jetzt spawnen? Ganz oder gar nicht (COIN_maxCampAI)
    ├── common/
    │   ├── fn_findByType.sqf           COIN_fnc_findByType: Zeile einer Config-Tabelle nach Nest-Typ
    │   ├── fn_getCapableFighters.sqf   COIN_fnc_getCapableFighters: Kämpfer unter gegebenen Objekten, die noch kämpfen können (Camp und Hinterhalt ausgehoben, Tickets 2.10, 4.5)
    │   ├── fn_isPrisoner.sqf           COIN_fnc_isPrisoner: Gefangener? Miliz-Kämpfer, gefesselt, ergeben oder per CAPTURE im Squad (Ticket 3.8, 5.1)
    │   ├── fn_getReputationBand.sqf    COIN_fnc_getReputationBand: Ruf-Band „low“, „mid“ oder „high“ (Ticket 3.4)
    │   ├── fn_addToCurators.sqf        COIN_fnc_addToCurators: alles, was COIN erzeugt, für jeden Zeus bearbeitbar
    │   ├── fn_curatorSync.sqf          COIN_fnc_curatorSync: Server-Schleife, auch für später erzeugte Kuratoren
    │   ├── fn_seededRandom.sqf         COIN_fnc_seededRandom: wiederholbarer Zufall aus dem gespeicherten Seed
    │   ├── fn_getPresence.sqf          COIN_fnc_getPresence: Spieler und Drohnen, die COIN-Inhalte spawnen lassen
    │   ├── fn_halfSize.sqf             COIN_fnc_halfSize: halbe Breite und Länge eines Objekts
    │   ├── fn_isDestructible.sqf       COIN_fnc_isDestructible: kann Arma Objekte dieser Klasse zerstören (Kernobjekte)?
    │   ├── fn_getFloorASL.sqf          COIN_fnc_getFloorASL: Höhe des Bodens unter einer Stelle (Gebäude oder Gelände)
    │   ├── fn_snapToFloor.sqf          COIN_fnc_snapToFloor: setzt ein Objekt auf den Boden darunter
    │   └── fn_isSpotFree.sqf           COIN_fnc_isSpotFree: ist an einer Stelle Platz (Wände, Objekte, Türen)?
    ├── debug/
    │   ├── fn_debugNestContent.sqf     COIN_fnc_debugNestContent: Kernobjekt, Requisiten und Fahrzeuge eines Typs nebeneinander (Abstimmung)
    │   ├── fn_exportNestTemplate.sqf   COIN_fnc_exportNestTemplate: Gebäude-Template des angeschauten Hauses in die Zwischenablage
    │   ├── fn_exportTerrainTemplate.sqf COIN_fnc_exportTerrainTemplate: Gelände-Template um den Richtungspfeil in die Zwischenablage
    │   └── fn_debugTerrainNest.sqf     COIN_fnc_debugTerrainNest: Gelände-Nest eines Typs vor dem Spieler, wie ein echtes
    ├── population/
    │   ├── fn_populationLoop.sqf       COIN_fnc_populationLoop: Server-Schleife, eigene Zivilisten in befreiten Ortschaften bei Spielernähe, Budget COIN_maxCivilians (Ticket 3.7), dazu der Älteste (Ticket 5.9a)
    │   ├── fn_spawnPopulation.sqf      COIN_fnc_spawnPopulation: die Zivilisten einer Ortschaft, wie Liberations, laufen im Ort umher
    │   ├── fn_findElderSpot.sqf        COIN_fnc_findElderSpot: Platz des Ältesten, Moschee oder größtes Haus nahe dem Ortskern (Ticket 5.9a)
    │   ├── fn_spawnElder.sqf           COIN_fnc_spawnElder: der Älteste einer Ortschaft, eigene Kleidung, Name „Ältester …“, steht fest (Ticket 5.9a)
    │   └── fn_markElder.sqf            COIN_fnc_markElder: Marker auf der Karte für den Ältesten, 5 min (Ticket 5.9a)
    ├── elder/
    │   ├── fn_askElderHelp.sqf         COIN_fnc_askElderHelp: Server, „Können wir helfen?“ beim Ältesten, schickt die Angebote an den Dolmetscher (Ticket 5.9b)
    │   ├── fn_getAidOffers.sqf         COIN_fnc_getAidOffers: Server, was der Älteste jetzt anbietet und warum etwas grau ist
    │   ├── fn_openElderDialog.sqf      COIN_fnc_openElderDialog: Client, Dialog mit Liste, Erklärung und „Annehmen“ (erbt Liberations Nebenmissions-Dialog)
    │   ├── fn_acceptElderOffer.sqf     COIN_fnc_acceptElderOffer: Server, prüft nochmal, startet den Hilfsauftrag
    │   ├── fn_runAidTask.sqf           COIN_fnc_runAidTask: Server, ein Hilfsauftrag von Start bis Ende, „Hilfsgüter liefern“, „Arzt-Einsatz“, „Infrastruktur reparieren“ (Tickets 5.10–5.12)
    │   ├── fn_spawnPatients.sqf        COIN_fnc_spawnPatients: Server, die Patienten des Arzt-Einsatzes mit Kreis auf der Karte (Ticket 5.11)
    │   ├── fn_addPatientAction.sqf     COIN_fnc_addPatientAction: Client, Aktion „Behandeln“ am Patienten, wie Liberations
    │   ├── fn_treatPatient.sqf         COIN_fnc_treatPatient: Server, Patient heilen, +1 Ruf
    │   ├── fn_healPatient.sqf          COIN_fnc_healPatient: Server, Patient heilen (Schutz kurz aus), Kreis weg, kniet und steht auf
    │   ├── fn_releasePatients.sqf      COIN_fnc_releasePatients: Server, Ende: Patienten stehen auf und verschwinden außer Sicht
    │   ├── fn_spawnInfrastructure.sqf  COIN_fnc_spawnInfrastructure: Server, die rauchenden Geräte des Reparatur-Auftrags (Ticket 5.12)
    │   ├── fn_addRepairAction.sqf      COIN_fnc_addRepairAction: Client, Aktion „Reparieren“ mit ACE-Fortschrittsbalken
    │   ├── fn_canRepairInfrastructure.sqf COIN_fnc_canRepairInfrastructure: Client und Server, ACE-Pionier mit Werkzeugkasten?
    │   ├── fn_repairInfrastructure.sqf COIN_fnc_repairInfrastructure: Server, Gerät repariert
    │   ├── fn_closeInfrastructure.sqf  COIN_fnc_closeInfrastructure: Server, Gerät wartet nicht mehr, Rauch aus
    │   ├── fn_removeWhenUnseen.sqf     COIN_fnc_removeWhenUnseen: Server, entfernt Patienten und Geräte, wenn niemand sie sieht
    │   ├── fn_secondaryAtElder.sqf     COIN_fnc_secondaryAtElder: Client und Server, bieten die Ältesten Nebenmissionen an? (Hook 30, Ticket 5.17)
    │   ├── fn_startSecondary.sqf       COIN_fnc_startSecondary: Server, startet Liberations Nebenmission über deren Server-Aufruf
    │   ├── fn_rateSites.sqf            COIN_fnc_rateSites: Server, Dörfer um eine Ortschaft mit dem Grund, warum eines kein Einsatzort ist (Ticket 5.20)
    │   ├── fn_findSite.sqf             COIN_fnc_findSite: Server, Einsatzort einer Ortschaft: nächstes Dorf außerhalb der Sektoren
    │   ├── fn_logSites.sqf             COIN_fnc_logSites: Server, schreibt Dörfer und Einsatzort jeder Ortschaft ins RPT (Prüfliste)
    │   ├── fn_findSiteAmbushSpot.sqf   COIN_fnc_findSiteAmbushSpot: Server, Platz des Hinterhalts am Einsatzort (Ticket 5.22)
    │   ├── fn_planSiteAmbush.sqf       COIN_fnc_planSiteAmbush: Server, Hinterhalt am Einsatzort? Nest in Reichweite, Chance, Platz
    │   ├── fn_spawnSiteAmbush.sqf      COIN_fnc_spawnSiteAmbush: Server, Kämpfer in Deckung und in Häusern des Dorfes
    │   ├── fn_runSiteAmbush.sqf        COIN_fnc_runSiteAmbush: Server, Leben des Hinterhalts: Spawn bei Spielernähe, Budget, Feuer, Entfernen
    │   ├── fn_clientTask.sqf           COIN_fnc_clientTask: Client, die Arma-Aufgabe in der Sprache des Spielers
    │   └── fn_showElderSentence.sqf    COIN_fnc_showElderSentence: Client, ein Satz des Ältesten als Untertitel
    ├── functions/strike/
    │   ├── fn_decideStrikeTask.sqf     COIN_fnc_decideStrikeTask: Server, entscheidet bei Befragung/Verhör über einen Zugriffsauftrag (Ticket 5.13)
    │   ├── fn_offerStrikeTask.sqf      COIN_fnc_offerStrikeTask: Server, der Sprecher erzählt davon, der Dialog öffnet sich
    │   ├── fn_acceptStrikeTask.sqf     COIN_fnc_acceptStrikeTask: Server, Dolmetscher nimmt an: Plan, Beginn und Ende würfeln, Start
    │   ├── fn_runStrikeTask.sqf        COIN_fnc_runStrikeTask: Server, ein Zugriffsauftrag von Start bis Ende, Aufgabe, Marker
    │   ├── fn_clockText.sqf            COIN_fnc_clockText: Uhrzeit im Spiel in n Sekunden als HH:MM
    │   ├── fn_canStrikeCourier.sqf     COIN_fnc_canStrikeCourier: Voraussetzung „Kurier abfangen“: ein aktives Nest (Ticket 5.14)
    │   ├── fn_planStrikeCourier.sqf    COIN_fnc_planStrikeCourier: zwei Ortschaften mit Straße, Nest des Kuriers
    │   ├── fn_runStrikeCourier.sqf     COIN_fnc_runStrikeCourier: Auto und Fahrer, Fahrt, gestoppt, durchsucht, angekommen
    │   ├── fn_canStrikeLeader.sqf      COIN_fnc_canStrikeLeader: Voraussetzung „Anführer festnehmen“: ein aktiver Kommandoposten (Ticket 5.15)
    │   ├── fn_planStrikeLeader.sqf     COIN_fnc_planStrikeLeader: Dorf (≥ 1000 m vom Kommandoposten), Haus und Platz des Anführers
    │   ├── fn_runStrikeLeader.sqf      COIN_fnc_runStrikeLeader: Anführer und Wachen, festgenommen, zur FOB gebracht, Readiness
    │   ├── fn_addCourierAction.sqf     COIN_fnc_addCourierAction: Client, Aktion „Dokumente durchsuchen“
    │   ├── fn_searchDocuments.sqf      COIN_fnc_searchDocuments: Server, die Suche am gestoppten Auto
    │   └── fn_showCourierFound.sqf     COIN_fnc_showCourierFound: Client, Untertitel nach der Suche
    ├── ui/
    │   └── CfgDialogs.hpp              Dialog-Klasse coin_elder_dialog (Include per Hook 29 in description.ext)
    ├── intel/
    │   ├── fn_initQuestioning.sqf      COIN_fnc_initQuestioning: Client, Dolmetscher-Slot erkennen, Aktionsmenü „Nach der Miliz fragen“ und „Verhören“ einrichten (Tickets 3.1, 3.8)
    │   ├── fn_addTalkAction.sqf        COIN_fnc_addTalkAction: Einträge im normalen Aktionsmenü (Scrollrad), nach jedem Respawn neu
    │   ├── fn_talkTargetLoop.sqf       COIN_fnc_talkTargetLoop: Client-Schleife, der Zivilist, den der Dolmetscher ansieht, bleibt stehen
    │   ├── fn_applyInterpreter.sqf     COIN_fnc_applyInterpreter: markiert die Einheit als Dolmetscher, nach jedem Respawn neu
    │   ├── fn_canQuestion.sqf          COIN_fnc_canQuestion: darf dieser Dolmetscher diesen Zivilisten jetzt befragen? (Menü und Server)
    │   ├── fn_holdCivilian.sqf         COIN_fnc_holdCivilian: der Zivilist bleibt stehen und schaut den Dolmetscher an (läuft, wo er lokal ist)
    │   ├── fn_questionCivilian.sqf     COIN_fnc_questionCivilian: Server, prüft die Regeln, wählt Nest und Stufe, antwortet nur dem Dolmetscher
    │   ├── fn_pickIntelNest.sqf        COIN_fnc_pickIntelNest: zufälliges aktives Nest im Umkreis, sonst das nächste
    │   ├── fn_createIntel.sqf          COIN_fnc_createIntel: Intel-Datensatz (Format von ADR 0021) und Kreis um das Nest, nicht in der Mitte
    │   ├── fn_isUnsafe.sqf             COIN_fnc_isUnsafe: bewaffnete Gegner in der Nähe, der Zivilist verweigert das Gespräch (Ticket 3.4)
    │   ├── fn_createLie.sqf            COIN_fnc_createLie: Lüge, Kreis um einen verborgenen Ersatzpunkt, sieht aus wie ein wahrer Marker (Ticket 3.4)
    │   ├── fn_findFakeSpot.sqf         COIN_fnc_findFakeSpot: glaubhafter Ersatzpunkt (Ortsrand oder freies Gelände, Regeln der Nester)
    │   ├── fn_intelSearchLoop.sqf      COIN_fnc_intelSearchLoop: Server-Schleife, eine Lüge verschwindet, wenn ein Spieler zu Fuß am Ersatzpunkt war
    │   ├── fn_getWarnableThreats.sqf   COIN_fnc_getWarnableThreats: alles, wovor ein Zivilist warnen kann: aktive Camps, gelegte IEDs, Hinterhalte (Tickets 4.8, 4.5)
    │   ├── fn_createWarning.sqf        COIN_fnc_createWarning: Warnung, Kreis um eine Bedrohung in der Nähe (Camp, IED, Hinterhalt), nicht gespeichert (Tickets 3.6, 4.8)
    │   ├── fn_warningLoop.sqf          COIN_fnc_warningLoop: Server-Schleife, eine Warnung verschwindet mit ihrer Bedrohung (Camp ausgehoben, umgezogen, entfernt; IED ausgelöst, entschärft, gelöscht)
    │   ├── fn_informantTip.sqf         COIN_fnc_informantTip: Server, Konkreter Tipp des Informanten bei der Ablieferung an der FOB (Ticket 3.10)
    │   ├── fn_removeIntel.sqf          COIN_fnc_removeIntel: entfernt ein Intel samt Markern
    │   ├── fn_getIntelRadius.sqf       COIN_fnc_getIntelRadius: Start-Radius nach Stufe
    │   ├── fn_offsetCenter.sqf         COIN_fnc_offsetCenter: Mitte eines Kreises um Nest oder Ersatzpunkt, nie auf dem Punkt
    │   ├── fn_shrinkIntel.sqf          COIN_fnc_shrinkIntel: Triangulation, weiterer wahrer Treffer verkleinert den Kreis des Nests (Ticket 3.3)
    │   ├── fn_drawIntelMarker.sqf      COIN_fnc_drawIntelMarker: globale Kartenmarker eines Intels
    │   ├── fn_loadIntel.sqf            COIN_fnc_loadIntel: Server, Intel aus dem Spielstand (Version 1: leere Liste), Marker neu zeichnen (Ticket 3.2)
    │   ├── fn_removeIntelOfNest.sqf    COIN_fnc_removeIntelOfNest: wahres Intel verschwindet mit dem zerstörten Nest (Ticket 3.2)
    │   ├── fn_interrogatePrisoner.sqf  COIN_fnc_interrogatePrisoner: Server, Verhör eines Gefangenen, 1–2 Ergebnisse mit eigenen Gewichten (Ticket 3.8)
    │   ├── fn_canInterrogate.sqf       COIN_fnc_canInterrogate: darf dieser Dolmetscher diesen Gefangenen jetzt verhören? (Menü und Server)
    │   ├── fn_pickInterrogationNest.sqf COIN_fnc_pickInterrogationNest: Camp-Kämpfer nennt das Nest seines Camps, Nest-Wache ein anderes
    │   ├── fn_rollOutcome.sqf          COIN_fnc_rollOutcome: würfelt ein Ergebnis nach Gewichten (Befragung und Verhör)
    │   ├── fn_resolveOutcome.sqf       COIN_fnc_resolveOutcome: macht das Intel zu einem Ergebnis (wahre Stufe, Lüge, Warnung)
    │   ├── fn_reserveAsking.sqf        COIN_fnc_reserveAsking: prüft die Abklingzeit des Dolmetschers, reserviert seine Beschäftigung
    │   ├── fn_finishAsking.sqf         COIN_fnc_finishAsking: startet die Abklingzeit nach einem Marker, sonst beendet die Beschäftigung
    │   ├── fn_showInterrogation.sqf    COIN_fnc_showInterrogation: Client, Antwort des Gefangenen, ein Satz je Ergebnis
    │   ├── fn_showSubtitle.sqf         COIN_fnc_showSubtitle: Client, Name und Sätze als Untertitel
    │   ├── fn_showAnswer.sqf           COIN_fnc_showAnswer: Client, Antwort des Zivilisten als Untertitel
    │   ├── fn_askMood.sqf              COIN_fnc_askMood: Server, „Wie steht ihr zu uns?“, die wahre Stimmung geht an den Dolmetscher (Ticket 5.3)
    │   ├── fn_showMood.sqf             COIN_fnc_showMood: Client, Stimmung als Untertitel
    │   ├── fn_askElder.sqf             COIN_fnc_askElder: Server, „Wo finde ich den Ältesten?“, der Älteste wird für Minuten markiert (Ticket 5.9a)
    │   └── fn_showElderLocation.sqf    COIN_fnc_showElderLocation: Client, die Antwort als Untertitel
    ├── persistence/
    │   ├── fn_receiveSaveBlock.sqf     COIN_fnc_receiveSaveBlock: merkt sich Eintrag 22 beim Laden des Spielstands (Hook 18)
    │   ├── fn_getSaveBlock.sqf         COIN_fnc_getSaveBlock: baut Eintrag 22 beim Speichern, [COIN_saveVersion, Nester, Intel] (Hook 17)
    │   └── fn_markNewCampaign.sqf      COIN_fnc_markNewCampaign: merkt sich beim Laden, dass es keinen Spielstand gibt (Hook 24)
    ├── reputation/
    │   ├── fn_initReputation.sqf       COIN_fnc_initReputation: Server, Start-Ruf einer neuen Kampagne nach dem Laden (Ticket 5.7)
    │   ├── fn_changeReputation.sqf     COIN_fnc_changeReputation: Server, die eine Stelle für Ruf-Änderungen (Logzeile, im Debug Systemchat), Ticket 5.1
    │   ├── fn_getMood.sqf              COIN_fnc_getMood: die Stimmung in fünf Stufen aus dem Ruf (Ticket 5.3)
    │   ├── fn_informantFrequencyLoop.sqf COIN_fnc_informantFrequencyLoop: Server-Schleife, Häufigkeit von Liberations Informanten nach Ruf über KP_liberation_civinfo_* (Ticket 5.2, kein Hook)
    │   ├── fn_initReputationEvents.sqf COIN_fnc_initReputationEvents: Server, Ruf-Änderungen nach COIN-Ereignissen, z. B. Nest zerstört (Ticket 5.1)
    │   ├── fn_captiveKilled.sqf        COIN_fnc_captiveKilled: Server, Ruf für einen von der Armee getöteten Gefangenen, aufgerufen vom Kill-Manager (Hook 25)
    │   ├── fn_civVehicleDestroyed.sqf  COIN_fnc_civVehicleDestroyed: Server, Ruf für ein von der Armee zerstörtes Zivilfahrzeug, aufgerufen vom Kill-Manager (Hook 25)
    │   ├── fn_initVehicleSeizure.sqf   COIN_fnc_initVehicleSeizure: Client, Einsteigen in ein Zivilfahrzeug beschlagnahmt es, Ruf nach Config (Liberations Handler hat einen Tippfehler)
    │   └── fn_hideReputationDisplay.sqf COIN_fnc_hideReputationDisplay: Client, blendet Ruf-Zahl und -Symbol im Overlay aus, außer mit COIN_debug (Hook 28)
    ├── threats/
    │   ├── fn_initIEDs.sqf             COIN_fnc_initIEDs: Server, jede aktive Werkstatt legt ihr IED-Budget, startet die Schleife (Ticket 4.1a)
    │   ├── fn_createIED.sqf            COIN_fnc_createIED: Server, legt ein IED für eine Werkstatt (Mine, Zeus, COIN_ieds)
    │   ├── fn_findIEDSpot.sqf          COIN_fnc_findIEDSpot: Platz auf einer Straße im Radius, nicht im Ortskern, nicht nahe Basis, FOB und anderen IEDs
    │   ├── fn_iedTriggered.sqf         COIN_fnc_iedTriggered: löst die Armee das IED aus? (BLUFOR-Fahrzeug oder zwei BLUFOR-Soldaten zu Fuß, Werte in der Config)
    │   ├── fn_iedWatch.sqf             COIN_fnc_iedWatch: genaue Prüfung eines IEDs (0,2 s), nur solange BLUFOR im Radius von 300 m ist, gestartet vom Trigger des IEDs
    │   ├── fn_removeIED.sqf            COIN_fnc_removeIED: nimmt ein IED aus COIN_ieds, löscht den Trigger, startet Entschärf-Prüfung und Nachschub
    │   ├── fn_replaceIED.sqf           COIN_fnc_replaceIED: ersetzt ein verbrauchtes IED nach der Wartezeit, nicht bei zerstörter Werkstatt
    │   ├── fn_checkDefused.sqf         COIN_fnc_checkDefused: wurde das IED entschärft? Ruf für ein echtes IED, löscht den Gegenstand des Entschärfens
    │   ├── fn_getFighterState.sqf      COIN_fnc_getFighterState: "free", "down" oder "out" – kann ein Kämpfer in Zivil noch handeln? (Ticket 4.2b)
    │   ├── fn_createCivilianFighter.sqf COIN_fnc_createCivilianFighter: Kämpfer in Zivil auf der Zivilisten-Seite, ohne Kill-Manager, unbewaffnet, markiert, Zeus
    │   ├── fn_findTriggermanSpot.sqf   COIN_fnc_findTriggermanSpot: Platz des Auslösers, 60–150 m vom IED mit Sichtlinie, am Haus oder erhöht
    │   ├── fn_createTriggerman.sqf     COIN_fnc_createTriggerman: stellt den Auslöser eines ferngezündeten IEDs hin (Telefon, Debug-Marker)
    │   ├── fn_triggermanLoop.sqf       COIN_fnc_triggermanLoop: Server-Schleife, Auslöser kommen bei 800 m und gehen wie Nest-Wachen
    │   ├── fn_getVBIEDTargets.sqf      COIN_fnc_getVBIEDTargets: FOBs und Spieler im Radius einer Garage (Ticket 4.3)
    │   ├── fn_findVBIEDSpot.sqf        COIN_fnc_findVBIEDSpot: Straße 800–1200 m vom Ziel, außer Sicht der Spieler
    │   ├── fn_createVBIED.sqf          COIN_fnc_createVBIED: ziviles Fahrzeug der Garage mit Fahrer (Kämpfer in Zivil), Zeus, Killed-Handler
    │   ├── fn_vbiedDrive.sqf           COIN_fnc_vbiedDrive: Fahrt eines VBIEDs zum Ziel, Zündung in 10 m, Ende, Aufräumen
    │   ├── fn_explodeVBIED.sqf         COIN_fnc_explodeVBIED: zündet die Ladung (nur einmal), zerstört das Fahrzeug
    │   ├── fn_vbiedLoop.sqf            COIN_fnc_vbiedLoop: Server-Schleife, alle 5 min Chance je bereiter aktiver Garage
    │   ├── fn_getSuicideBomberTargets.sqf COIN_fnc_getSuicideBomberTargets: Spieler zu Fuß im Radius einer Werkstatt (Ticket 4.4)
    │   ├── fn_findSuicideBomberSpot.sqf COIN_fnc_findSuicideBomberSpot: Punkt 100–200 m vom Ziel, außer Sicht der Spieler
    │   ├── fn_createSuicideBomber.sqf  COIN_fnc_createSuicideBomber: Kämpfer in Zivil mit Kleidung aus der Liste, Killed-Handler
    │   ├── fn_suicideBomberDrive.sqf   COIN_fnc_suicideBomberDrive: Weg zum nächsten Spieler, Schrei, Zündung in 5 m, Ende, Aufräumen
    │   ├── fn_explodeSuicideBomber.sqf COIN_fnc_explodeSuicideBomber: zündet die Weste (nur einmal)
    │   ├── fn_suicideBomberLoop.sqf    COIN_fnc_suicideBomberLoop: Server-Schleife, alle 5 min Chance je bereiter Werkstatt nach Ruf-Band
    │   ├── fn_findAmbushSpot.sqf       COIN_fnc_findAmbushSpot: Platz neben der nächsten Straße, 200–800 m vom Camp (Ticket 4.5)
    │   ├── fn_planAmbush.sqf           COIN_fnc_planAmbush: Kämpfer und Deckungsobjekte eines Hinterhalts aus dem Seed des Camps
    │   ├── fn_spawnAmbush.sqf          COIN_fnc_spawnAmbush: Kämpfer in Deckung neben der Straße und Deckungsobjekte, Feuer halten
    │   ├── fn_removeAmbush.sqf         COIN_fnc_removeAmbush: Inhalt eines Hinterhalts abbauen, wenn niemand in der Nähe ist
    │   ├── fn_ambushWatch.sqf          COIN_fnc_ambushWatch: Leben eines gespawnten Hinterhalts: Feuer bei 150 m, ausgehoben
    │   ├── fn_drawAmbushMarkers.sqf    COIN_fnc_drawAmbushMarkers: globale Debug-Marker der Hinterhalte mit Linie zum Camp
    │   └── fn_drawIEDMarkers.sqf       COIN_fnc_drawIEDMarkers: globale Debug-Marker der IEDs (Lobby-Parameter „COIN Debug“)
    └── nests/
        ├── fn_initNests.sqf            COIN_fnc_initNests: Server, Nester aus dem Spielstand oder neu, Debug-Karte (ADR 0018)
        ├── fn_createNests.sqf          COIN_fnc_createNests: Nester einer neuen Kampagne als Daten, Art pro Typ, „bester Kandidat“, Lockerung
        ├── fn_isNestSpotAllowed.sqf    COIN_fnc_isNestSpotAllowed: Regeln für jedes Nest (Kartenrand, Startbasis, Hauptstadt, Sektoren)
        ├── fn_collectNestHouses.sqf    COIN_fnc_collectNestHouses: Häuser am Ortsrand für Gebäude-Nester (250–600 m)
        ├── fn_findTerrainNestSpots.sqf COIN_fnc_findTerrainNestSpots: Kandidaten für Gelände-Nester (abseits von Orten und Straßen, eben)
        ├── fn_getNestRadius.sqf        COIN_fnc_getNestRadius: Einflussradius eines Nest-Typs aus COIN_nestSetup
        ├── fn_drawNestMarkers.sqf      COIN_fnc_drawNestMarkers: globale Debug-Marker der Nester (Lobby-Parameter „COIN Debug“)
        ├── fn_initMessages.sqf         COIN_fnc_initMessages: Server, Meldung an alle Spieler bei zerstörtem Nest und ausgehobenem Camp (Ticket 2.14)
        ├── fn_showNotification.sqf     COIN_fnc_showNotification: Client, zeigt die Meldung in der Spielsprache (CfgNotifications.hpp)
        ├── fn_updateNetworkStrength.sqf COIN_fnc_updateNetworkStrength: Server, Netzwerkstärke = aktive / alle Nester, an die Clients verteilt (Ticket 2.6)
        ├── fn_showNetworkStrength.sqf  COIN_fnc_showNetworkStrength: Client, Debug-Eintrag „Netzwerkstärke“ im Karten-Tagebuch
        ├── fn_validateNestContent.sqf  COIN_fnc_validateNestContent: prüft Kernobjekte (zerstörbar) und Requisiten beim Start
        ├── fn_spawnBuildingNest.sqf    COIN_fnc_spawnBuildingNest: Kernobjekt, Requisiten und Wachen eines Gebäude-Nests
        ├── fn_spawnTerrainNest.sqf     COIN_fnc_spawnTerrainNest: Kernobjekt, Requisiten und Wachen eines Gelände-Nests (ADR 0020)
        ├── fn_spawnOldVehicles.sqf     COIN_fnc_spawnOldVehicles: 1–2 besetzte, für Spieler gesperrte Altfahrzeuge eines Waffenlagers (ADR 0014)
        ├── fn_spawnNestGuards.sqf      COIN_fnc_spawnNestGuards: stehende und patrouillierende Wachen eines Nests, mit Herkunft (Nest oder Camp) für das Verhör
        ├── fn_placeNestTemplate.sqf    COIN_fnc_placeNestTemplate: Objekte nach Gebäude- oder Gelände-Template (ADR 0019, ADR 0020)
        ├── fn_placeNestFree.sqf        COIN_fnc_placeNestFree: freie Platzierung für Häuser ohne Template
        ├── fn_placeNestVehicle.sqf     COIN_fnc_placeNestVehicle: ziviles Fahrzeug der VBIED-Garage bei freier Platzierung
        ├── fn_initCamps.sqf            COIN_fnc_initCamps: Server, Camps als Daten (Kapazität, Eigentümer-Nest), nicht gespeichert (Entscheidung E8)
        ├── fn_getCampCapacity.sqf      COIN_fnc_getCampCapacity: Kapazität aus dem Gewicht der aktiven Nester
        ├── fn_getCampWeight.sqf        COIN_fnc_getCampWeight: Gewicht eines Nest-Typs für die Camps (COIN_campsPerNest)
        ├── fn_findCampSpot.sqf         COIN_fnc_findCampSpot: Platz für ein Camp nach den Platzierungsregeln (Sperrzone, Deckung, Abstände)
        ├── fn_checkTerrainSpot.sqf     COIN_fnc_checkTerrainSpot: gemeinsame Prüfung für Gelände-Nester und Camps (Ort, Straße, eben)
        ├── fn_getCampCover.sqf         COIN_fnc_getCampCover: Bäume, Büsche und Felsen um einen Campplatz
        ├── fn_describeCampSpot.sqf     COIN_fnc_describeCampSpot: Abstände eines Camps für die RPT-Zeile
        ├── fn_createCamp.sqf           COIN_fnc_createCamp: ein Camp als Daten (Platz, Eigentümer-Nest, Zustand)
        ├── fn_manageCamps.sqf          COIN_fnc_manageCamps: Ersatz, Wechsel und Auflösen der Camps (Ticket 2.10)
        ├── fn_checkCampCleared.sqf     COIN_fnc_checkCampCleared: Camp ausgehoben? plant den Ersatz
        ├── fn_getActiveCamps.sqf       COIN_fnc_getActiveCamps: Camps, die zur Kapazität zählen
        ├── fn_getCampExclusion.sqf     COIN_fnc_getCampExclusion: Mittelpunkte der Sperrzonen (Sektoren, FOBs)
        ├── fn_planCamp.sqf             COIN_fnc_planCamp: Camp-Template, Richtung, Kämpfer und Technical aus dem Seed des Camps
        ├── fn_spawnCamp.sqf            COIN_fnc_spawnCamp: Template-Objekte, Wachen und Technical eines Camps (Ticket 2.9)
        ├── fn_removeCamp.sqf           COIN_fnc_removeCamp: Camp abbauen, ein erbeuteter Technical bleibt
        ├── fn_findGuardRingSpots.sqf   COIN_fnc_findGuardRingSpots: Plätze der stehenden Wachen im Ring (Gelände-Nester und Camps)
        ├── fn_drawCampMarkers.sqf      COIN_fnc_drawCampMarkers: globale Debug-Marker der Camps mit Linie zu ihrem Nest
        ├── fn_nestSpawnLoop.sqf        COIN_fnc_nestSpawnLoop: Server-Schleife für Nester und Camps, Spawn ab 1000 m, Abbau nach 2 min außerhalb 1300 m, Zerstörung prüfen
        └── fn_destroyNest.sqf          COIN_fnc_destroyNest: Nest endgültig zerstört, sofort gespeichert, Ereignis COIN_nestDestroyed
```

## Ablauf beim Missionsstart

1. Arma startet `COIN_fnc_init` auf **jeder** Maschine (CfgFunctions `postInit`).
2. `COIN_fnc_init` lädt `coin_config.sqf` und `coin_templates.sqf`.
3. Es wartet, bis Liberations `init.sqf` auf dieser Maschine fertig ist (`KPLIB_init`), höchstens `COIN_initTimeout` Sekunden.
4. Auf dem Server läuft `init_server.sqf`, auf Maschinen mit Interface `init_client.sqf`.
   Beim lokalen Host laufen beide.

Spätere Synchronisationspunkte aus Liberation: `save_is_loaded` (Spielstand geladen, public).
Siehe `docs/kp-liberation-map.md` Abschnitt 2.

## Neue Funktion anlegen

1. Datei `functions/<kategorie>/fn_<name>.sqf` anlegen (Kopfkommentar wie in `fn_init.sqf`).
2. In `CfgFunctions.hpp` unter der Kategorie eintragen (`class <name> {};`), ggf. neue Kategorie mit `file = "coin\functions\<kategorie>";`.
3. Aufruf als `COIN_fnc_<name>`. Ein `CfgRemoteExec` gibt es nicht, für `remoteExec` ist kein Eintrag nötig.

## Logs

`diag_log format ["[COIN] <modul>: %1", ...]`. Debug-Ausgaben nur, wenn `COIN_debug` aktiv ist.
