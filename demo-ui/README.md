# AW40-hub-docker - Demo UI

## Overview

A Website built with [FastAPI](https://fastapi.tiangolo.com/) and
[Jinja Templates](https://jinja.palletsprojects.com/en/3.1.x/) for prototyping 
and demonstrating the end-user experience.

## Development

### 1. Run with docker
*(All commands run from repository root)*

The application can be started by using the dedicated compose file [demo_ui.yml](../demo_ui.yml).
```
docker compose --env-file dev.env -f docker-compose.yml -f demo_ui.yml up -d
```

The Demo UI can be accessed at http://localhost:8002/ui.

Note that the diagnostic backend needs to be set up (data in knowledge-graph, ml models),
for the diagnosis to work. The Demo UI will still work if this is not done and inform
the user about the failed diagnosis.  
If you want to set up the diagnostic backend, refer to [README](../diagnostics/README.md) 
and [examples](../diagnostics/examples) of the `diagnostics` service.

### 2. Use

The Demo UI can be accessed at http://localhost:8002/ui.  
In order to login, valid workshop credentials - e.g. keycloak user credentials
for a user with keycloak role `workshop` in the keycloak realm `werkstatt-hub` -
are required.

The keycloak development configuration applied via 
[keycloak/keycloak-config-dev.sh](../keycloak/keycloak-config-dev.sh) is
supposed to create such a user for local testing and development with credentials
`aw40hub-dev-workshop:dev`.

### 3. Code

[./demo_ui](./demo_ui) contains the actual source code. Changes are directly
applied in the running container.

Code style can be checked via
```
flake8 ./demo_ui
```

The demo UI uses the development keycloak client generated via 
[keycloak/keycloak-config-dev.sh](../keycloak/keycloak-config-dev.sh) to
authenticate users with a direct access grant.

### 4. Helpful Resources

https://fastapi.tiangolo.com/advanced/templates/  
https://jinja.palletsprojects.com/en/3.1.x/