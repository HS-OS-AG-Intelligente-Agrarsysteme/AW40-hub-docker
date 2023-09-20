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
