from typing import List

import httpx


class HubClient:
    """
    Interacts with the /diagnostics/{diag_id} Hub API to retrieve ressources
    needed to run a specific diagnosis and to provide (intermediate) results.
    """

    def __init__(self, hub_url, diag_id, api_key):
        self.hub_url = hub_url
        self.diag_id = diag_id
        self.http_client = httpx.Client(headers={"x-api-key": api_key})
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
        self.http_client.get(self.ping_url).raise_for_status()

    def _get_from_url(self, url: str, query_params: dict = {}):
        response = self.http_client.get(url, params=query_params)
        response.raise_for_status()
        return response.json()

    def get_diag(self) -> dict:
        return self._get_from_url(self.diag_url)

    def get_obd_data(self) -> List[dict]:
        return self._get_from_url(self.obd_url)

    def get_vehicle(self) -> dict:
        return self._get_from_url(self.vehicle_url)

    def get_oscillograms(self, component: str) -> List[dict]:
        return self._get_from_url(
            self.oscillograms_url, query_params={"component": component}
        )

    def get_symptoms(self, component: str) -> List[dict]:
        return self._get_from_url(
            self.symptoms_url, query_params={"component": component}
        )

    def _create_action_add_oscillogram(self, component: str) -> dict:
        return {
            "id": f"add-data-oscillogram-{component.lower()}",
            "instruction": f"Bitte ein Oszillogramm für das Bauteil '"
                           f"{component}' "
                           f"erstellen und hochladen.",
            "action_type": "add_data",
            "data_type": "oscillogram",
            "component": f"{component}"
        }

    def _create_action_add_obd(self) -> dict:
        return {
            "id": "add-data-obd",
            "instruction": "Bitte OBD Daten erstellen und hochladen.",
            "action_type": "add_data",
            "data_type": "obd",
        }

    def _create_action_add_symptom(self, component: str) -> dict:
        return {
            "id": f"add-data-symptom-{component.lower()}",
            "instruction": f"Bitte manuelle Untersuchung des Bauteils "
                           f"'{component}' durchführen und als Symptom "
                           f"bereitstellen.",
            "data_type": "symptom",
            "action_type": "add_data",
            "component": f"{component}"
        }

    def _require_action(self, action: dict) -> dict:
        action_id = action["id"]
        url = f"{self.todos_url}/{action_id}"
        response = self.http_client.put(url, json=action)
        response.raise_for_status()
        return response.json()

    def _unrequire_action(self, action: dict) -> dict:
        action_id = action["id"]
        url = f"{self.todos_url}/{action_id}"
        response = self.http_client.delete(url)
        response.raise_for_status()
        return response.json()

    def require_obd_data(self):
        action = self._create_action_add_obd()
        return self._require_action(action)

    def unrequire_obd_data(self):
        action = self._create_action_add_obd()
        return self._unrequire_action(action)

    def require_oscillogram(self, component: str):
        action = self._create_action_add_oscillogram(component)
        return self._require_action(action)

    def unrequire_oscillogram(self, component: str):
        action = self._create_action_add_oscillogram(component)
        return self._unrequire_action(action)

    def require_symptom(self, component: str):
        action = self._create_action_add_symptom(component)
        return self._require_action(action)

    def unrequire_symptom(self, component: str):
        action = self._create_action_add_symptom(component)
        return self._unrequire_action(action)

    def clear_state_machine_log(self):
        raise NotImplementedError

    def add_to_state_machine_log(self, message: str, attachment=None):
        files = None
        if attachment is not None:
            files = {"attachment": attachment}
        self.http_client.post(
            self.state_machine_log_url,
            data={"message": message},
            files=files
        ).raise_for_status()

    def set_diagnosis_status(self, status: str):
        url = f"{self.diag_url}/status"
        self.http_client.put(url, json=status).raise_for_status()
