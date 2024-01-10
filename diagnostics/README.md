# AW40-hub-docker - Diagnostics

A background service that integrates the DFKI State Machine.

<hr>

In addition to the `diagnostics` service, running a diagnosis requires the
following services from [../docker-compose.yml](../docker-compose.yml):

- `api`
- `mongo`
- `knowledge-graph`
- `redis`

*(All commands below from repo root)*

# Basic Usage

Start the required services via

```
docker compose --env-file dev.env up -d diagnostics api mongo knowledge-graph redis
```

(or just `docker compose --env-file dev.env up -d` if you don't mind waiting
for the other services not required for diagnostic functionality).

Once the "bare" services are up, the diagnostic system also requires different
types of data to execute vehicle diagnosis:

1. Knowledge Graph Data about DTCs
2. Trained TensorFlow models to evaluate oscillograms

Knowledge Graph data can be added via the Apache Jena Fuseki UI accessible
via http://127.0.0.1:3030. The dataset has to be named `/OBD`. Models need
to be placed into the [models/](models/) directory, which is mounted into the
`diagnostics` container. Currently, model files are required to exactly follow
the naming convention `<COMPONENT>.h5`. This data setup can also be achieved
programmatically, as illustrated in the examples (see below).

A user can interact via the workshop part of the API and start
a diagnosis via a POST request to
`http://127.0.0.1:8000/v1/<WORKSHOP_ID>/cases/<CASE_ID>/diag`.
To get an overview about the current state of the diagnosis and (intermediate)
results the demo ui can be accessed at
`http://127.0.0.1:8002/ui/<WORKSHOP_ID>/cases/<CASE_ID>/diag`.

**Note:** The demo ui must be explicitly included when starting the HUB.
See instructions [here](../demo-ui/README.md).

# Examples

## Example 1

The first example illustrates a successful diagnosis.

After installing the development requirements
via `pip install -r requirements.txt`
(preferably into a virtualenv) and starting the docker compose stack, run the
first example via

```
python diagnostics/examples/example_1
```

The console output will show an URL, that you can access to view a report of
the example diagnosis.  
Use the `-i` flag to run the example in "interactive" mode. In this case data
will only be added to the example case after manual confirmation and the report
page will show the todo instructions for the user. If the report page shows
that the diagnosis status is "processing", this means that the diagnostic
backend
is currently running. To view new intermediate results refresh the page.

The first example is specified
in [examples/example_1/example.py](examples/example_1/example.py).
Refer to this file to learn more about the different steps that a basic
diagnosis might
comprise.

## Example 2

In the second example a failed diagnosis is provoked, by providing an
oscillogram
with a signal length, incompatible with the model used by the state machine.

It can be run via

```
python diagnostics/examples/example_2
```

## Using the examples for testing

The examples can also be used for basic QA. Running

```
pytest diagnostics
```

will run the (integration) tests defined in [examples/tests](examples/tests).