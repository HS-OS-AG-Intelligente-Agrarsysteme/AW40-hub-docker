import os
import shutil

import httpx

EXAMPLE_DIR = os.path.dirname(__file__)


def setup_knowledge_graph():
    """Prepare the knowledge graph with data for this example."""
    kg_url = "http://127.0.0.1:3030"
    # first create the dataset '/OBD'
    httpx.post(
        url=f"{kg_url}/$/datasets",
        data={
            "dbType": "mem",
            "dbName": "/OBD",
        }
    )
    # second load data provided by dfki into the OBD graph
    knowledge_graph_file = os.path.join(EXAMPLE_DIR, "minimalistic_kg.ttl")
    with open(knowledge_graph_file, "rb") as file:
        response = httpx.put(
            url=f"{kg_url}/OBD",
            content=file,
            headers={"Content-Type": "text/turtle"}
        )
        response.raise_for_status()


def setup_model():
    """
    Put the model for this example into diagnostics/models, which is mounted
    into the diagnostics container.
    The model was provided by DFKI and is supposed to detect anomalies for
    the battery, however, we act as if this model was designed to detect
    anomalies for boost_pressure_control_valve, which is in the example
    knowledge-graph.
    """
    model_destination_folder = os.path.join(
        os.path.dirname(os.path.dirname(EXAMPLE_DIR)),
        "models"
    )
    model_destination_path = os.path.join(
        model_destination_folder, "boost_pressure_control_valve.h5"
    )
    meta_info_destination_path = os.path.join(
        model_destination_folder, "boost_pressure_control_valve_meta_info.json"
    )
    model_src_path = os.path.join(
        EXAMPLE_DIR, "boost_pressure_control_valve.h5"
    )
    meta_info_src_path = os.path.join(
        EXAMPLE_DIR, "boost_pressure_control_valve_meta_info.json"
    )
    shutil.copy(src=model_src_path, dst=model_destination_path)
    shutil.copy(src=meta_info_src_path, dst=meta_info_destination_path)


def create_case(workshop_id, api_token):
    """
    Create a new case for this example. Returns the url that allows managing
    the case via the Hub API.
    """
    cases_url = f"http://127.0.0.1:8000/v1/{workshop_id}/cases"
    response = httpx.post(
        url=cases_url,
        json={
            "vehicle_vin": "1234567890ABCDEFGHJKLMNPRSTUVWXYZ",
            "customer_id": "anonymous",
            "occasion": "service_routine",
            "milage": 42
        },
        headers={"Authorization": f"Bearer {api_token}"}
    )
    response.raise_for_status()
    case_id = response.json()["_id"]
    case_url = f"{cases_url}/{case_id}"
    return case_url


def start_diagnosis(case_url, api_token):
    """Start the diagnosis process for a case."""
    response = httpx.post(
        url=f"{case_url}/diag",
        headers={"Authorization": f"Bearer {api_token}"}
    )
    response.raise_for_status()


def provide_obd_data(case_url, api_token):
    """
    Load OBD data into a case. The DTC provided is present in the knowledge
    graph data for this example.
    """
    response = httpx.post(
        url=f"{case_url}/obd_data",
        json={
            "dtcs": [
                "P0123"
            ]
        },
        headers={"Authorization": f"Bearer {api_token}"}
    )
    response.raise_for_status()


def provide_oscillogram(case_url, api_token):
    """
    Upload an oscillogram that causes the state machine to fail with an
    exception.
    """
    response = httpx.post(
        url=f"{case_url}/timeseries_data",
        json={
            "signal": [1, 2, 3],  # fewer values than expected by model
            "component": "boost_pressure_control_valve",
            "label": "unknown",
            "sampling_rate": 1,
            "duration": 3
        },
        headers={"Authorization": f"Bearer {api_token}"}
    )
    response.raise_for_status()


def provide_symptom(case_url, api_token):
    """
    Provide the information, that the boost pressure solenoid valve is broken.
    """
    response = httpx.post(
        url=f"{case_url}/symptoms",
        json={
            "component": "boost_pressure_solenoid_valve",
            "label": "defect"
        },
        headers={"Authorization": f"Bearer {api_token}"}
    )
    response.raise_for_status()


def main(interactive, api_token):
    # Setup steps required before a user interacts with the system
    setup_knowledge_graph()
    setup_model()

    # User creates a new case and starts the diagnosis process
    case_url = create_case(
        workshop_id="aw40hub-dev-workshop", api_token=api_token
    )
    start_diagnosis(case_url, api_token=api_token)

    # Progress of the example diagnosis can be followed via the demo ui
    report_url = ((case_url + "/diag")
                  .replace("v1", "ui")
                  .replace(":8000", ":8002"))
    print(
        f"For a graphical report of the diagnosis process go to: {report_url}"
    )

    # User provides data for the diagnostic process
    for func in [provide_obd_data, provide_oscillogram, provide_symptom]:
        if interactive:
            input(f"Press enter to {func.__name__}")
        func(case_url, api_token=api_token)

    return case_url
