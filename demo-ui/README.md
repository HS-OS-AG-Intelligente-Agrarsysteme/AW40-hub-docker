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
Currently, the Demo UI only shows the functionality of some services. Hence, it
can make sense to reduce startup times for the stack by only starting those services 
without dependencies via
```
docker compose --env-file dev.env -f docker-compose.yml -f demo_ui.yml up -d --no-deps api mongo diagnostics redis knowledge-graph demo-ui
```

The Demo UI can be accessed at http://localhost:8002/ui.

Note that the diagnostic backend needs to be set up (data in knowledge-graph, ml models),
for the diagnosis to work. The Demo UI will still work if this is not done and inform
the user about the failed diagnosis.  
If you want to set up the diagnostic backend, refer to [README](../diagnostics/README.md) 
and [examples](../diagnostics/examples) of the `diagnostics` service.


### 2. Code

[./demo_ui](./demo_ui) contains the actual source code. Changes are directly
applied in the running container.

Code style can be checked via
```
flake8 ./demo_ui
```

### 3. Helpful Resources

https://fastapi.tiangolo.com/advanced/templates/  
https://jinja.palletsprojects.com/en/3.1.x/