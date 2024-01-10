from time import time

import httpx
from example_1 import example


def test_example():
    # Execute the example
    case_url = example.main(interactive=False)
    diag_url = f"{case_url}/diag"

    # After waiting for a short duration, we should be able to confirm that
    # the diagnosis is finished via the Hub API
    status = None
    timeout = 10
    start = time()
    while time() - start <= timeout and status != "finished":
        diag = httpx.get(diag_url)
        status = diag.json()["status"]

    assert status == "finished"

    # confirm reporting of used datasets
    smach_log = diag.json()["state_machine_log"]
    smach_log_messages = [entry["message"] for entry in smach_log]
    assert "RETRIEVED_DATASET: obd_data/0" in smach_log_messages
    assert "RETRIEVED_DATASET: timeseries_data/0" in smach_log_messages
    assert "RETRIEVED_DATASET: symptoms/0" in smach_log_messages
