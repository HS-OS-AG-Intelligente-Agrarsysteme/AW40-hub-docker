import smach
from celery import Celery
from pydantic import BaseSettings
from vehicle_diag_smach.high_level_smach import VehicleDiagnosisStateMachine

from .hub_client import HubClient
from .interfaces import (
    HubDataAccessor,
    HubDataProvider,
    HubModelAccessor
)


class Settings(BaseSettings):
    redis_password: str
    api_key_diagnostics: str
    redis_host: str = "redis"
    redis_port: str = "6379"
    hub_url: str = "http://api:8000/v1"
    data_poll_interval: int = 1
    models_dir: str = "models"
    knowledge_graph_url: str = "http://knowledge-graph:3030"


settings = Settings()


# Make smach less verbose by disabling non-error logging
def dont_log(msg):
    pass


def log_err(msg):
    print("[ ERROR ] : " + str(msg))


smach.set_loggers(
    info=dont_log, warn=dont_log, debug=dont_log, error=log_err
)


# set up celery app
redis_uri = f"redis://:{settings.redis_password}@{settings.redis_host}" \
            f":{settings.redis_port}"
app = Celery("tasks", broker=redis_uri, backend=redis_uri)
app.conf.update(timezone="UTC")


@app.task
def diagnose(diag_id):
    """Main task for a diagnosis."""
    # api client to interact with the specified diagnosis
    hub_client = HubClient(
        hub_url=settings.hub_url,
        diag_id=diag_id,
        api_key=settings.api_key_diagnostics
    )

    # set up vehicle_diag_smach interfaces
    data_accessor = HubDataAccessor(
        hub_client=hub_client,
        data_poll_interval=settings.data_poll_interval
    )
    data_provider = HubDataProvider(
        hub_client=hub_client
    )
    model_accessor = HubModelAccessor(models_dir=settings.models_dir)

    # instantiate state machine
    sm = VehicleDiagnosisStateMachine(
        data_accessor=data_accessor,
        data_provider=data_provider,
        model_accessor=model_accessor,
        kg_url=settings.knowledge_graph_url
    )

    # execute diagnosis
    hub_client.set_diagnosis_status("processing")
    try:
        sm.execute()
        hub_client.set_diagnosis_status("finished")
    except Exception as e:
        hub_client.add_to_state_machine_log(
            "DIAGNOSIS_FAILED: Unexpected error during execution of the state "
            "machine."
        )
        hub_client.set_diagnosis_status("failed")
        raise e
