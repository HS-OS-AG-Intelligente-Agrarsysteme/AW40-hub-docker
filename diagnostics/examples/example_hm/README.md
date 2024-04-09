# Beispiel fuer Hannover Messe 2024

## Dateien

| Datei                             | Beschreibung                                                                                                                        |
|-----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| 0-2024-03-26T12-34-sin-short.txt  | Gekuerzter Omniview export eines sin Signals.                                                                                       |
| 0-2024-03-26T12-35-sawu-short.txt | Gekuerzter Omniview export eines sawu Signals.                                                                                      |
| Batterie.h5                       | Modell zur Klassifikation von Batterie Signalen. Sin ist Gutbild, nicht-Sin ist Anomalie. Originaldatei hieß sin_final.h5.          |
| Batterie_meta_info.json           | Meta Infos für die State Machine zum Batterie Modell.                                                                               |
| Lichtmaschine.h5                  | Modell zur Klassifikation von Lichtmaschinen Signalen. SawU ist Gutbild, nicht-SawU ist Anomalie. Originaldatei hieß sawu_final.h5. |
| Lichtmaschine_meta_info.json      | Meta Infos für die State Machine zum Lichtmaschinen Modell.                                                                         |
| toy_kg.nq                         | Mini Wissensgraph `Fehlercode P0123 -> Scheinwerfer -> Batterie -> Lichtmaschine`                                                   |

## Setup

1. Services starten:
```
alias dc='docker compose -f docker-compose.yml -f demo_ui.yml --env-file dev.env --profile full'
dc up -d proxy mongo keycloak keycloak-config keycloak-db api docs redis diagnostics knowledge-graph demo-ui
```

2. Modelle (`Batterie.h5`, `Lichtmaschine.h5`) und Modell Meta Infos 
(`Batterie_meta_info.json`, `Lichtmaschine_meta_info.json`) nach 
[diagnostics/models](../../../diagnostics/models) kopieren.


3. Auf http://localhost:3030 einen neuen Datensatz `OBD` erstellen und die Datei
`toy_kg.nq` hochladen.

## Ausprobieren

Auf http://localhost:8002/ui gehen, einloggen (Credentials 
`aw40hub-dev-workshop:dev`), Fall anlegen und Diagnose starten.

Die Omniview exports `0-2024-03-26T12-34-sin-short.txt` und
`0-2024-03-26T12-35-sawu-short.txt` können als Oszillogramme hochgeladen werden.