import os
import json
from typing import Union, Tuple

import keras
from vehicle_diag_smach.interfaces.model_accessor import ModelAccessor


class HubModelAccessor(ModelAccessor):

    def __init__(self, models_dir: str):
        self.models_dir = models_dir

    def _load_model(self, path: str):
        try:
            model = keras.models.load_model(path)
            return model
        except IOError:
            return None

    def get_keras_univariate_ts_classification_model_by_component(
            self, component: str
    ) -> Union[Tuple[keras.models.Model, dict], None]:
        model_filename = component + ".h5"
        model_path = os.path.join(self.models_dir, model_filename)

        model = self._load_model(model_path)
        meta_info = None

        if model is None:
            print(
                f"Could not retrieve model meta info for component "
                f"'{component}'."
            )
        else:
            model_meta_info_filename = component + "_meta_info.json"
            model_meta_info_path = os.path.join(
                self.models_dir, model_meta_info_filename
            )
            # if there is a model, there has to be meta info
            with open(model_meta_info_path, "r") as file:
                meta_info = json.load(file)
            print(f"Successfully retrieved model for component '{component}'.")

        return model, meta_info
