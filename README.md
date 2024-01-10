# AW40-hub-docker

## Overview

Prototype implementation of the AW40 HUB Architecture on Docker\
Currently included services:

| Service (see [docker-compose.yml](docker-compose.yml)) | Description                                                              |
|--------------------------------------------------------|--------------------------------------------------------------------------|
| mongo                                                  | A MongoDB for for persistence of business and vehicle data.              |
| keycloak                                               | User and access management                                               |
| keycloak-db                                            | A PostgreSQL database used by keycloak.                                  |
| minio                                                  | Object Storage for datasets shared with external dataspace participants. |
| edc                                                    | Eclipse Dataspace Connector                                              |
| edc-db                                                 | A PostgreSQL database used by the EDC.                                   |
| api                                                    | HTTP interface to the stored data.                                       |
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
http://127.0.0.1:8000/v1/docs.  

The Hub documentation website is accessible via
http://127.0.0.1:8001.

### Stop the HUB
To stop the HUB use:\
```docker compose --env-file=dev.env down``` \
To stop the HUB and **clear all Databases** use:\
```docker compose --env-file=dev.env down -v ```
