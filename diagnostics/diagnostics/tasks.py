from celery import Celery
from vehicle_diag_smach.data_types.state_transition import StateTransition

from .hub_client import HubClient
from .interfaces import (
    HubDataAccessor,
    HubDataProvider,
    HubModelAccessor
)

# configuration
REDIS_HOST = "redis"
HUB_URL = "http://api:8000/v1"
DATA_POLL_INTERVAL = 1

# configuration is resolved
redis_uri = f"redis://{REDIS_HOST}:6379"
app = Celery("tasks", broker=redis_uri, backend=redis_uri)
app.conf.update(timezone="UTC")


def execute_smach(
        data_accessor: HubDataAccessor,
        data_provider: HubDataProvider,
        model_accessor: HubModelAccessor
):
    """Mocks execution of the actual state machine"""
    print(data_accessor.get_workshop_info())
    data_provider.provide_state_transition(
        StateTransition("GET_WORKSHOP_INFO", "GET_OBD_DATA", "LINK")
    )

    print(data_accessor.get_obd_data())
    data_provider.provide_state_transition(
        StateTransition("GET_OBD_DATA", "GET_OSCILLOGRAMS_DATA", "LINK")
    )

    print(data_accessor.get_oscillograms_by_components(["Batterie"]))
    data_provider.provide_state_transition(
        StateTransition("GET_OSCILLOGRAMS_DATA", "GET_MODEL", "LINK")
    )

    print(
        model_accessor.get_keras_univariate_ts_classification_model_by_component(
            "Batterie"
        )
    )
    data_provider.provide_state_transition(
        StateTransition("GET_MODEL", "FINISH_DIAG", "LINK")
    )

    # TODO: provider functions for images

    print(
        data_provider.provide_diagnosis(
            ["fault-path-step-1", "fault-path-step-2"]
        )
    )


@app.task
def diagnose(diag_id):
    """Main task for a diagnosis."""

    # api client to interact with the specified diagnosis
    hub_client = HubClient(
        hub_url=HUB_URL,
        diag_id=diag_id
    )

    # set up vehicle_diag_smach interfaces
    data_accessor = HubDataAccessor(
        hub_client=hub_client,
        data_poll_interval=DATA_POLL_INTERVAL
    )
    data_provider = HubDataProvider(
        hub_client=hub_client
    )
    model_accessor = HubModelAccessor()

    execute_smach(
        data_accessor,
        data_provider,
        model_accessor
    )
    hub_client.set_diagnosis_status("finished")