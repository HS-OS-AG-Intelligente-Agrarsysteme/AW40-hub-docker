# API

HTTP Schnittstelle für das standardisierte Management der gespeicherten Daten.

Erstellt mit [FastAPI](https://fastapi.tiangolo.com/).

## Übersicht

Die API hat mehrere Teilbereiche (Router)

<font size=1>

| Bereich     | Pfad             | Beschreibung                                                                                 | Authentifizierung |
|-------------|------------------|----------------------------------------------------------------------------------------------|-------------------|
| Diagnostics | `/diagnostics`   | Zugriffspunkte für das Diagnosebackend.                                                      | API Key           |
| Health      | `/health`        | Funktionskontrolle                                                                           | keine             |
| MinIO       | `/minio`         | *WIP*                                                                                        | API Key           |
| Shared      | `/shared`        | Lesezugriff auf geteilte Ressourcen innerhalb einer Betreiberfirma.                          | Keycloak          |
| Workshops   | `/{workshop_id}` | Verwaltung eigener Daten und Diagnosen durch Endnutzer Anwendungen in einzelnen Werkstätten. | Keycloak          |
| Knowledge   | `/knowledge`     | Vereinfachter Zugriff auf Informationen, die im [Wissensgraph](./ai.md) gespeichert sind.    | Keycloak          |

</font>

## Details

Die oben beschriebenen Router können grob in zwei Gruppen unterteilt werden.

Die erste Gruppe bilden die Bereiche Diagnostics, Health und MinIO. Alle in
diesen Routern bereitgestellten Endpunkte sind für die M2M Kommunikation 
zwischen verschiedenen Services "im Hintergrund" vorgesehen.

Die zweite Gruppen bilden die Bereiche Shared, Workshops und Knowledge welche
für die Kommunikation mit (menschlichen) Endnutzern vorgesehen sind.

### Workshop Router

Wie in [Hintergrund](../background.md) beschrieben, ist der Hub als Plattform
für mehrere, zu einer *Betreiberfirma* gehörenden *Werkstätten* vorgesehen.

Im Hub Prototypen ist es daher vorgesehen, dass jede Werkstatt einen eigenen
Nutzeraccount hat. Diese Accounts werden mittels [Keycloak](https://www.keycloak.org/)
verwaltet. Dabei ist jedem Werkstattaccount die Rolle `workshop` zuzuweisen, die
für den Zugriff auf Ressourcen unter `/{workshop_id}` vorausgesetzt wird.

Jede Client Applikation für Endanwender (e.g. das im
Hub integrierte Web Frontend oder Messgeräte mit integrierter Verbindung zur 
Hub API) muss bei Zugriff auf die Endpunkte unter `/{workshop_id}` nachweisen,
dass die Anfrage durch die Werkstatt mit dieser `{workshop_id}` berechtigt ist.

### Shared Router

Die `/shared` Endpunkte der Hub API ermöglichen Lesezugriff auf die in der
Hub Datenbank gespeicherten Daten zu Fällen, Fahrzeugen etc., beispielsweise
zu Analysezwecken.

Auch für die zu diesem Bereich gehörenden Endpunkte wird eine Authentifizierung
mittels eines von Keycloak ausgestellten Tokens vorausgesetzt. Dem Nutzeraccount
muss dabei die Rolle `shared` zugewiesen sein.

### Knowledge Router

Die unter `/knowledge` bereitgestellten Endpunkte ermöglichen den Zugriff
auf ausgewählte Fakten zu im Wissensgraph beinhalteten Informationen, wie z.B.
die Namen der gespeicherten Fahrzeugbauteile.  
Der Zugriff ist mit einem von Keycloak ausgestellten Token möglich, wobei sowohl
die Rollen `workshop` als auch `shared` autorisiert sind.