# AW40-hub-docker - API

## Overview

A [FastAPI](https://fastapi.tiangolo.com/) application to interact with Hub
ressources.  


## Contribute
*(All commands run from repository root)*

### 1. Set up python development environment


Assuming [virtualenv](https://virtualenv.pypa.io/en/latest/) is installed use
```
virtualenv venv
source venv/bin/activate
```
to set up your environment and install requirements for the api package plus
additional requirements for linting and testing via
```
pip install -r requirements.txt
```

### 2. Code

[./api](./api) contains the actual API source code and [./tests](./tests)
the respective tests.

Some suggestions to keep things clean:
- Write tests.
- Adhere to [PEP 8](https://peps.python.org/pep-0008/)
(e.g. just do what flake8 tells you to do).
- Environment variables are read in one place only:
[`api.settings.Settings`](./api/settings.py)
- All configuration specified through environment variables is resolved in the
main entrypoint of the api, which is [`api.main`](./api/main.py). E.g.
`from .settings import settings` happens only in
[`api.main`](./api/main.py) which creates and injects all dependencies
for lower level code.

### 3. Run tests and check code style

Before a commit test via
```
pytest ./api
```
and check code via
```
flake8 ./api
```

## How authentication works

### Workshop authentication

Any client (web frontend, measurement devices etc.) that wants to access
the workshop router (`/{workshop_id}/...`) first needs to obtain a bearer token from keycloak, to proof
that access is on behalf of the workshop with this id.

This section is intended to illustrate this process with the dev stack. So
keycloak and the hub api are available at `keycloak.werkstatthub.docker.localhost` and `api.werkstatthub.docker.localhost`.

Prerequisites: Both the client and the workshop (=user) need to be configured
in keycloak's `werkstatt-hub` realm. In addition, the (keycloak)user has to have
the role `workshop`.
Here we will use a client and workshop that should automatically be configured
in a development environment (they are created by service `keycloak-config`
using [keycloak/keycloak-config-dev.sh](../keycloak/keycloak-config-dev.sh))
```
CLIENT_ID=aw40hub-dev-client
CLIENT_SECRET=N5iImyRP1bzbzXoEYJ6zZMJx0XWiqhCw
WORKSHOP_ID=aw40hub-dev-workshop
PASSWORD=dev
```

Attempting to access the workshop's cases will fail without a token:
```
curl http://api.werkstatthub.docker.localhost/v1/$WORKSHOP_ID/cases
```

So, first the client has to send a request to keycloak like so:
```
TOKEN_RESPONSE=$( \
    curl http://keycloak.werkstatthub.docker.localhost/realms/werkstatt-hub/protocol/openid-connect/token \
        -X POST \
        -H "Content-Type=application/x-www-form-urlencoded" \
        -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$WORKSHOP_ID&password=$PASSWORD&grant_type=password" \
)
```
**Note:** The client here uses a *direct access grant* to obtain the token. This is
the most basic option to obtain the token, but should only be used for trusted
clients as the workshops (=users) credentials are exposed to the client. More
complex flows without client credential exposure would be supported by keycloak, 
but are likely not required in the research project, as all clients will be first party.

The above retrieved `TOKEN_RESPONSE` is a json string containing the access token
(as well as a refresh token and other information).

Next, the client needs the access token. E.g. like this using [jq](https://jqlang.github.io/jq/):
```
ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r .access_token)
```

Now the client can access the API by passing the access token in an authorization
header:
```
curl -H "Authorization: Bearer $ACCESS_TOKEN" http://api.werkstatthub.docker.localhost/v1/$WORKSHOP_ID/cases
```

### Shared authentication

Just as with the workshop router described in the previous section, access to
the shared router at `/shared` requires a bearer token obtained from keycloak
and the user needs to be assigned the role `shared`.  
The account `aw40hub-dev-workshop` created with
[keycloak/keycloak-config-dev.sh](../keycloak/keycloak-config-dev.sh)
does also have this role. So the example in the previous section also applies
to shared resources, e.g. after obtaining the token, a list of all cases from
the shared router can be retrieved via
```
curl -H "Authorization: Bearer $ACCESS_TOKEN" http://api.werkstatthub.docker.localhost/v1/shared/cases
```