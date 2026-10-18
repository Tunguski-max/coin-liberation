# Deployment auf G-Portal

> Wird ab Phase 7 relevant (oder früher, sobald der Server steht).
> G-Portal-spezifische Menüpunkte sind hier bewusst allgemein gehalten und werden beim
> ersten Deployment konkret nachgetragen.

## 1. Mission als PBO packen

Ein Server lädt Missionen als `.pbo`-Datei.

- Prüfen, ob `build.bat` von Liberation bereits PBOs erzeugt **(Phase 0 prüfen)**.
- Falls nicht: den Missionsordner mit **Arma 3 Tools → Addon Builder** oder einem PBO-Tool packen.
- Dateiname: `coin_liberation.lythium.pbo` (Name vor dem Punkt frei, nach dem Punkt der Kartenname).

## 2. Hochladen

- Per G-Portal-Dateimanager oder FTP in den Ordner `mpmissions/` des Servers.

## 3. Server-Konfiguration (`server.cfg`)

```cpp
class Missions
{
    class coin_liberation
    {
        template = "coin_liberation.lythium";
        difficulty = "custom";
    };
};
```

Schwierigkeitsgrad: Die von Liberation empfohlenen Werte stehen in
`docs/upstream/KP-Liberation-README.md` und sind ein guter Startpunkt.

## 4. Mods auf dem Server

- Dieselbe Mod-Liste wie lokal (siehe `docs/TESTING.md`), über die G-Portal-Modverwaltung.
- Bei Signaturprüfung (`verifySignatures`): die `.bikey`-Dateien aller Mods in den `keys/`-Ordner des Servers.
- TFAR: Server-Plugin bzw. TeamSpeak-Einstellungen nach TFAR-Doku.

## 5. Spielstand sichern

Liberation speichert im Profil des Servers. Die Datei endet auf `.vars.Arma3Profile`
und liegt im Profilordner des Servers.

- **Vor jedem Mission-Update herunterladen und aufheben.**
- Wenn wir das Speicherformat ändern (`COIN_saveVersion`), steht in den Release-Notizen, ob ein alter Stand weiterläuft.

## 6. Checkliste pro Release

- [ ] Lokal: Definition of Done der Phase erfüllt
- [ ] Version und Änderungen in `CHANGELOG-COIN.md` eingetragen
- [ ] Spielstand vom Server gesichert
- [ ] PBO hochgeladen, `server.cfg` zeigt auf die neue Version
- [ ] Server neu gestartet, einmal eingeloggt, RPT des Servers auf `[COIN]`-Fehler geprüft
