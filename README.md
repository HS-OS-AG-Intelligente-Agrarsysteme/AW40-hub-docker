# AW40-hub-docker

## Overview

Prototype implementation of the AW40 HUB Architecture on Docker\
Currently included services:

| Service (see [docker-compose.yml](docker-compose.yml)) | Description                                                              |
|--------------------------------------------------------|--------------------------------------------------------------------------|
| proxy                                                  | Proxy based on traefik                                                   |
| mongo                                                  | A MongoDB for for persistence of business and vehicle data.              |
| keycloak                                               | User and access management                                               |
| keycloak-db                                            | A PostgreSQL database used by keycloak.                                  |
| minio                                                  | Object Storage for datasets shared with external dataspace participants. |
| edc                                                    | Eclipse Dataspace Connector                                              |
| edc-db                                                 | A PostgreSQL database used by the EDC.                                   |
| api                                                    | HTTP interface to the stored data.                                       |
| frontend                                               | Webfronted based on Flutter                                              |
| docs                                                   | Documentation and background information                                 |
| redis                                                  | Broker / Task queue for communication between api and diagnostics        |
| diagnostics                                            | Celery worker that applies the DFKI State Machine for vehicle diagnosis. |
| knowledge-graph                                        | Apache Jena Fuseki server queried by the state machine.                  |



## Usage

### Start the developement HUB
**WARNING: DO NOT RUN THE DEVELOPEMENT HUB ON PUBLIC SERVER**\
To start the HUB in developer mode use:\
```docker compose --env-file=dev.env up -d```

The interactive docs of the API service can now be accessed via
http://api.werkstatthub.docker.localhost/v1/docs.  

The Hub documentation website is accessible via
http://docs.werkstatthub.docker.localhost.


### Access services of developement HUB
The services of the developement HUB are locally reachable via Webbrowser:

| Service         | Address                                             |
|-----------------|-----------------------------------------------------|
| frontend        | http://werkstatthub.docker.localhost                |
| proxy           | http://traefik.werkstatthub.docker.localhost        |
| keycloak        | http://keycloak.werkstatthub.docker.localhost       |
| minio           | http://minio.werkstatthub.docker.localhost          |
| api             | http://api.werkstatthub.docker.localhost            |
| docs            | http://docs.werkstatthub.docker.localhost           |
| edc(api)        | http://edc.werkstatthub.docker.localhost/api        |
| edc(management) | http://edc.werkstatthub.docker.localhost/management |
| edc(protocol)   | http://edc.werkstatthub.docker.localhost/protocol   |
| edc(control)    | http://edc.werkstatthub.docker.localhost/control    |
| edc(pulbic)     | http://edc.werkstatthub.docker.localhost/public     |
| edc(identidy)   | http://edc.werkstatthub.docker.localhost/identity   |

Known issues with the local addresses:
- The addresses might not resolve when using WSL. A quick fix is to add
entries such as `127.0.0.1 api.werkstatthub.docker.localhost` to `/etc/hosts`.

### Use TLS
To use TLS set ```PROXY_DEFAULT_ENTRYPOINTS=websecure``` and 
```PROXY_DEFAULT_SCHEME=https```. The frontend container has to be rebuild since
it does not recognize the change in URLs by itself.

Known Issues with TLS are:
- Frontend can't use api if api address has not been visited and before since
the self signed certificate has to be accepted by the browser.
- All links have to start with https. There is no http &rarr; https redirect in 
place yet.
- Libraries like httpx have to be instructed to not verify the certificate.

### Stop the HUB
To stop the HUB use:
```docker compose --env-file=dev.env down``` \
To stop the HUB and **clear all Databases** use:\
```docker compose --env-file=dev.env down -v ```
