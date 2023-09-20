from typing import List

import httpx


class HubClient:
    """
    Interacts with the /diagnostics/{diag_id} Hub API to retrieve ressources
    needed to run a specific diagnosis and to provide (intermediate) results.
    """

    def __init__(self, hub_url, diag_id):
        self.hub_url = hub_url
        self.diag_id = diag_id
        self.test_connection()

    @property
    def ping_url(self) -> str:
        return f"{self.hub_url}/health/ping"

    @property
    def diag_url(self) -> str:
        return f"{self.hub_url}/diagnostics/{self.diag_id}"

    @property
    def obd_url(self) -> str:
        return f"{self.diag_url}/obd_data"

    @property
    def vehicle_url(self) -> str:
        return f"{self.diag_url}/vehicle"

    @property
    def oscillograms_url(self) -> str:
        return f"{self.diag_url}/oscillograms"

    @property
    def symptoms_url(self) -> str:
        return f"{self.diag_url}/symptoms"

    @property
    def todos_url(self) -> str:
        return f"{self.diag_url}/todos"

    @property
    def state_machine_log_url(self) -> str:
        return f"{self.diag_url}/state-machine-log"

    def test_connection(self):
        httpx.get(self.ping_url).raise_for_status()

    @staticmethod
    def _get_from_url(url: str, query_params: dict = {}):
        response = httpx.get(url, params=query_params)
        response.raise_for_status()
        return response.json()

    def get_diag(self) -> dict:
        return self._get_from_url(self.diag_url)

    def get_obd_data(self) -> List[dict]:
        return self._get_from_url(self.obd_url)

    def get_vehicle(self) -> dict:
        return self._get_from_url(self.vehicle_url)

    def get_oscillograms(self, component: str) -> List[List[float]]:
        return self._get_from_url(
            self.oscillograms_url, query_params={"component": component}
        )

    def get_symptoms(self, component: str) -> List[dict]:
        return self._get_from_url(
            self.symptoms_url, query_params={"component": component}
        )

    def _require_action(self, action_id) -> dict:
        url = f"{self.todos_url}/{action_id}"
        response = httpx.post(url)
        response.raise_for_status()
        return response.json()

    def _unrequire_action(self, action_id) -> dict:
        url = f"{self.todos_url}/{action_id}"
        response = httpx.delete(url)
        response.raise_for_status()
        return response.json()

    def require_obd_data(self):
        return self._require_action("add-data-obd")

    def unrequire_obd_data(self):
        return self._unrequire_action("add-data-obd")

    def require_oscillogram(self, component: str):
        action_id = f"add-data-oscillogram-{component.lower()}"
        return self._require_action(action_id)

    def unrequire_oscillogram(self, component: str):
        action_id = f"add-data-oscillogram-{component.lower()}"
        return self._unrequire_action(action_id)

    def require_symptom(self, component: str):
        action_id = f"add-data-symptom-{component.lower()}"
        return self._require_action(action_id)

    def unrequire_symptom(self, component: str):
        action_id = f"add-data-symptom-{component.lower()}"
        return self._unrequire_action(action_id)

    def clear_state_machine_log(self):
        raise NotImplementedError

    def add_to_state_machine_log(self, message: str, attachment=None):
        files = None
        if attachment is not None:
            files = {"attachment": attachment}
        httpx.post(
            self.state_machine_log_url,
            data={"message": message},
            files=files
        ).raise_for_status()

    def set_diagnosis_status(self, status: str):
        url = f"{self.diag_url}/status"
        httpx.put(url, json=status).raise_for_status()
