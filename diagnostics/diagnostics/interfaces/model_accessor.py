import os
from typing import Union, Tuple

import keras
from vehicle_diag_smach.interfaces.model_accessor import ModelAccessor


class HubModelAccessor(ModelAccessor):

    def __init__(self, models_dir: str):
        self.models_dir = models_dir

    def get_keras_univariate_ts_classification_model_by_component(
            self, component: str
    ) -> Union[Tuple[keras.models.Model, dict], None]:
        model_filename = component + ".h5"
        model_path = os.path.join(self.models_dir, model_filename)
        try:
            model = keras.models.load_model(model_path)
            print(f"Successfully retrieved model for component '{component}'.")
            return model, {"model_id": component}
        except IOError:
            print(f"Could not retrieve model for component '{component}'.")
            return None
