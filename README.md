# AW40-HUB

<p align="left">
  <a href="https://editor.swagger.io/?url=https://raw.githubusercontent.com/FieldRobotEvent/REST-API-24/main/docs/static/openapi.json"><img src="https://img.shields.io/badge/open--API-V3.1-brightgreen.svg?style=flat&label=OpenAPI" alt="OpenAPI"/></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.12-3776AB.svg?style=flat&logo=python&logoColor=white" alt="Python 3.11"/></a>
  <a href="https://fastapi.tiangolo.com/"><img src="https://img.shields.io/badge/FastAPI-0.112.2-009688.svg?style=flat&logo=FastAPI&logoColor=white" alt="FastAPI"/></a>
  <a href="https://www.gnu.org/licenses/gpl-3.0"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: GPL v3"/></a>
</p>

## Description
This is the prototype implementation of the AW4.0 HUB architecture and part of the [Car Repair 4.0](https://www.autowerkstatt40.org/en/) research project. The purpose of the HUB is to enable car workshops to use AI driven diagnostics, persist acquired data from cars in a database as well as to participate alongside other car workshops as well as AI model providers in an [Gaia-X](https://gaia-x.eu/) compatible Dataspace to sell data and aquire new AI models.
The name AW40 is a shortened version of the german project title "Autowerkstatt 4.0".
## Requirements

- Docker v25.0 or later (run `docker --version`)
- Docker buildx v0.12.5 or later (run `docker buildx version`)

Please refer to the [official docs](https://docs.docker.com/engine/install/) for instructions on installing Docker.
If you just need to update buildx, see [this section](#updating-docker-buildx-builder).

## Overview

This is the prototype implementation of the AW4.0 HUB Architecture.\
Currently included services:

| Service (see [docker-compose.yml](docker-compose.yml)) | Description                                                              |
|--------------------------------------------------------|--------------------------------------------------------------------------|
| proxy                                                  | Proxy based on traefik                                                   |
| mongo                                                  | A MongoDB for for persistence of business and vehicle data.              |
| keycloak                                               | User and access management                                               |
| keycloak-db                                            | A PostgreSQL database used by keycloak.                                  |
| api                                                    | HTTP interface to the stored data.                                       |
| frontend                                               | Webfronted based on Flutter                                              |
| docs                                                   | Documentation and background information                                 |
| redis                                                  | Broker / Task queue for communication between api and diagnostics        |
| diagnostics                                            | Celery worker that applies the DFKI State Machine for vehicle diagnosis. |
| knowledge-graph                                        | Apache Jena Fuseki server queried by the state machine.                  |



## Usage

### Start the development HUB
**WARNING: DO NOT RUN THE DEVELOPMENT HUB ON PUBLIC SERVER**\
To start the HUB in developer mode use:\
```docker compose --env-file=dev.env --profile full up -d```

The interactive docs of the API service can now be accessed via
http://api.werkstatthub.docker.localhost/v1/docs.

The Hub documentation website is accessible via
http://docs.werkstatthub.docker.localhost.

#### Updating docker buildx builder

You may need to update your buildx builder for the `--start-interval` flag to be recognised.
Versions below 0.12.5 _may_ still work, but the `--start-interval` flag will be ignored.

1. Create a new builder with `docker buildx create`. This returns the name of the new builder.
2. Use the new builder with `docker buildx use <BUILDER_NAME>`.
3. If you want/need to save space, you can clean your old builder's cache with `docker buildx prune`.

### Access services of developement HUB
The services of the developement HUB are locally reachable via Webbrowser:

| Service         | Address                                             |
|-----------------|-----------------------------------------------------|
| frontend        | http://werkstatthub.docker.localhost                |
| proxy           | http://traefik.werkstatthub.docker.localhost        |
| keycloak        | http://keycloak.werkstatthub.docker.localhost       |
| api             | http://api.werkstatthub.docker.localhost            |
| docs            | http://docs.werkstatthub.docker.localhost           |

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
```docker compose --env-file=dev.env --profile full down``` \
To stop the HUB and **clear all Databases** use:\
```docker compose --env-file=dev.env --profile full down -v ```
