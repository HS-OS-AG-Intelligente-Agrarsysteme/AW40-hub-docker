from typing import List
from tempfile import TemporaryFile

from PIL.Image import Image
from vehicle_diag_smach.data_types.state_transition import StateTransition
from vehicle_diag_smach.interfaces.data_provider import DataProvider

from ..hub_client import HubClient


class HubDataProvider(DataProvider):

    def __init__(self, hub_client: HubClient):
        self.hub_client = hub_client

    def _log(self, message: str, attachment: Image = None):
        if attachment is not None:
            with TemporaryFile() as file:
                attachment.save(file, format="png")
                file.seek(0)
                self.hub_client.add_to_state_machine_log(message, file)
        else:
            self.hub_client.add_to_state_machine_log(message)

    def provide_causal_graph_visualizations(
            self, visualizations: List[Image]
    ) -> None:
        for i, im in enumerate(visualizations):
            self._log(f"CAUSAL_GRAPH_VISUALIZATIONS: {i}", im)

    def provide_heatmaps(self, heatmaps: Image, title: str) -> None:
        self._log(f"HEATMAPS: {title}", heatmaps)

    def provide_diagnosis(self, fault_paths: List[str]) -> None:
        self._log(f"FAULT_PATHS: {fault_paths}")

    def provide_state_transition(
            self, state_transition: StateTransition
    ) -> None:
        self._log(f"STATE_TRANSITION: {str(state_transition)}")
