# API

HTTP Schnittstelle für das standardisierte Management der gespeicherten Daten.

Erstellt mit [FastAPI](https://fastapi.tiangolo.com/).

## Übersicht

Die API hat mehrere Teilbereiche (Router)

<font size=1>

| Bereich     | Pfad             | Beschreibung                                                                                 | Authentifizierung |
|-------------|------------------|----------------------------------------------------------------------------------------------|-------------------|
| Diagnostics | `/diagnostics`   | Zugriffspunkte für das Diagnosebackend.                                                      | *WIP*             |
| Health      | `/health`        | Funktionskontrolle                                                                           | *WIP*             |
| MinIO       | `/minio`         | *WIP*                                                                                        | *WIP*             |
| Shared      | `/shared`        | Lesezugriff auf geteilte Ressourcen innerhalb einer Betreiberfirma.                          | Keycloak          |
| Workshops   | `/{workshop_id}` | Verwaltung eigener Daten und Diagnosen durch Endnutzer Anwendungen in einzelnen Werkstätten. | Keycloak          |

</font>

## Details
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