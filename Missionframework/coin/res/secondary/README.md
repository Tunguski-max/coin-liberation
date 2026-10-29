# Bilder der Hilfs- und Zugriffsaufträge

Hier liegen die Bilder, die der Dialog des Ältesten links neben der Erklärung zeigt (wie Liberations `res/secondary/*.jpg`
bei den Nebenmissionen).

- **Dateiname:** `<id>.jpg`, wobei `<id>` die erste Spalte von `COIN_aidTaskTexts` (Hilfsaufträge) oder die Art des Zugriffsauftrags
  ist (`COIN_strikeKinds`), also zum Beispiel `supplies.jpg` oder `courier.jpg`.
- **Vorhanden:** Hilfsaufträge `supplies`, `medical`, `repair`; Gefälligkeit `reinforcement`; Zugriffsaufträge `courier`, `leader`,
  `convoy`, `export`.
- **Stil:** fotorealistisch, goldenes Abendlicht, afghanisches Lehmziegeldorf mit Minarett vor Bergen, US-Soldaten in Wüstentarn im
  Anschnitt oder von hinten, geringe Schärfentiefe, quadratisch, ohne Text und Logos. Die vier Bilder der Zugriffsaufträge zeigen den
  Moment des Auftrags (Auto durchsuchen, Anführer festnehmen, Hinterhalt auf den Konvoi, Flugplatz beobachten), ohne Gewalt.
- **Format:** JPG, **512 × 512** Pixel (Liberations Bilder sind ebenso groß; Potenz von 2 vermeidet Ladeprobleme).
- **Pfad im Spiel:** `COIN_aidImagePath` in `coin_config.sqf` (`coin\res\secondary\%1.jpg`, `%1` = id).
- Fehlt die Datei, bleibt das Bildfeld leer, es gibt keine Fehlermeldung.
