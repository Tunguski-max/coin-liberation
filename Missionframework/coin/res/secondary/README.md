# Bilder der Hilfsaufträge

Hier liegen die Bilder, die der Dialog des Ältesten links neben der Erklärung zeigt (wie Liberations `res/secondary/*.jpg`
bei den Nebenmissionen).

- **Dateiname:** `<id>.jpg`, wobei `<id>` die erste Spalte von `COIN_aidTaskTexts` ist, also zum Beispiel `supplies.jpg`.
- **Format:** JPG, **512 × 512** Pixel (Liberations Bilder sind ebenso groß; Potenz von 2 vermeidet Ladeprobleme).
- **Pfad im Spiel:** `COIN_aidImagePath` in `coin_config.sqf` (`coin\res\secondary\%1.jpg`, `%1` = id).
- Fehlt die Datei, bleibt das Bildfeld leer, es gibt keine Fehlermeldung.
