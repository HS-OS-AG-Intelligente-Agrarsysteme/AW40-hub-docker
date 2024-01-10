from time import sleep
from typing import List

from vehicle_diag_smach.data_types.customer_complaint_data import (
    CustomerComplaintData
)
from vehicle_diag_smach.data_types.onboard_diagnosis_data import (
    OnboardDiagnosisData
)
from vehicle_diag_smach.data_types.oscillogram_data import OscillogramData
from vehicle_diag_smach.data_types.workshop_data import WorkshopData
from vehicle_diag_smach.interfaces.data_accessor import DataAccessor

from ..hub_client import HubClient


class HubDataAccessor(DataAccessor):

    def __init__(self, hub_client: HubClient, data_poll_interval: int):
        self.hub_client = hub_client
        self.data_poll_interval = data_poll_interval

    def get_workshop_info(self) -> WorkshopData:
        diag = self.hub_client.get_diag()
        return WorkshopData(
            num_of_parallel_rec=1,
            diag_date=diag["timestamp"]
        )

    @staticmethod
    def _select_latest_dataset(datasets: list) -> dict:
        return datasets[-1]

    def _wait_for_hub_obd_data(self) -> List:
        print("Waiting for Hub OBD Data ...")
        hub_obd_data = []
        while hub_obd_data == []:
            sleep(self.data_poll_interval)
            hub_obd_data = self.hub_client.get_obd_data()
        return hub_obd_data

    def _get_dtcs(self) -> List[str]:
        hub_obd_data = self.hub_client.get_obd_data()
        if hub_obd_data == []:
            self.hub_client.require_obd_data()
            self.hub_client.set_diagnosis_status("action_required")
            hub_obd_data = self._wait_for_hub_obd_data()
            self.hub_client.set_diagnosis_status("processing")
            self.hub_client.unrequire_obd_data()

        selected_hub_obd_data = self._select_latest_dataset(hub_obd_data)
        self.hub_client.add_to_state_machine_log(
            f"RETRIEVED_DATASET: obd_data/{selected_hub_obd_data['data_id']}"
        )
        return selected_hub_obd_data["dtcs"]

    def get_obd_data(self) -> OnboardDiagnosisData:
        dtcs = self._get_dtcs()
        vehicle = self.hub_client.get_vehicle()
        return OnboardDiagnosisData(
            dtc_list=dtcs,
            model=vehicle.get("model", ""),
            hsn=vehicle.get("hsn", ""),
            tsn=vehicle.get("tsn", ""),
            vin=vehicle.get("vin")
        )

    def _wait_for_oscillogram(self, component: str) -> List:
        print(
            f"Waiting for Hub Oscillogram signal for '{component}' ..."
        )
        oscillograms = []
        while oscillograms == []:
            sleep(self.data_poll_interval)
            oscillograms = self.hub_client.get_oscillograms(component)
        return oscillograms

    def _get_oscillogram_by_component(
            self, component: str
    ) -> OscillogramData:
        oscillograms = self.hub_client.get_oscillograms(component)
        if oscillograms == []:
            self.hub_client.require_oscillogram(component)
            self.hub_client.set_diagnosis_status("action_required")
            oscillograms = self._wait_for_oscillogram(component)
            self.hub_client.set_diagnosis_status("processing")
            self.hub_client.unrequire_oscillogram(component)

        selected_oscillogram = self._select_latest_dataset(oscillograms)
        self.hub_client.add_to_state_machine_log(
            f"RETRIEVED_DATASET: timeseries_data/"
            f"{selected_oscillogram['data_id']}"
        )
        selected_signal = selected_oscillogram["signal"]
        return OscillogramData(
            time_series=selected_signal, comp_name=component
        )

    def get_oscillograms_by_components(
            self, components: List[str]
    ) -> List[OscillogramData]:
        oscillograms = []
        for component in components:
            oscillograms.append(
                self._get_oscillogram_by_component(component)
            )
        return oscillograms

    def get_customer_complaints(self) -> CustomerComplaintData:
        return CustomerComplaintData()

    def _wait_for_symptom(self, component: str) -> List:
        print(
            f"Waiting for Hub symptom for '{component}' ..."
        )
        symptoms = []
        while symptoms == []:
            sleep(self.data_poll_interval)
            symptoms = self.hub_client.get_symptoms(component)
        return symptoms

    def _get_symptom(self, component: str) -> dict:
        symptoms = self.hub_client.get_symptoms(component)
        if symptoms == []:
            self.hub_client.require_symptom(component)
            self.hub_client.set_diagnosis_status("action_required")
            symptoms = self._wait_for_symptom(component)
            self.hub_client.set_diagnosis_status("processing")
            self.hub_client.unrequire_symptom(component)

        selected_symptom = self._select_latest_dataset(symptoms)
        self.hub_client.add_to_state_machine_log(
            f"RETRIEVED_DATASET: symptoms/{selected_symptom['data_id']}"
        )
        return selected_symptom

    def get_manual_judgement_for_component(self, component: str) -> bool:
        symptom = self._get_symptom(component=component)
        label = symptom["label"]
        if label == "defect":
            return True
        elif label in ["ok", "unknown"]:
            return False
        else:
            raise ValueError(f"Unknown symptom label '{label}'")

    def get_manual_judgement_for_sensor(self) -> bool:
        return False
