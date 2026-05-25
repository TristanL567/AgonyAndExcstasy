# Load the saved predictor and print hyperparameters for all child models.
import os
from pathlib import Path

from autogluon.tabular import TabularPredictor

root = Path(os.environ.get("MT_ROOT", r"C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy"))
track = os.environ.get("RESPONSE_TRACK", "dynamic_csi")
track_folder = "temporary_csi" if track == "dynamic_csi" else track
model = os.environ.get("MODEL", "fund")

# MT_OUTPUT_DIR is obsolete (single output tree); honoured only if absolute.
_override = os.environ.get("MT_OUTPUT_DIR")
if _override and Path(_override).is_absolute():
    data_output = Path(_override)
else:
    data_output = root / "03_Data_Output"

predictor_dir = (
    data_output
    / "3_Modelling_Results" / "Necessary" / track_folder
    / "AutoGluon" / f"ag_{model}" / "ag_predictor"
)
predictor = TabularPredictor.load(predictor_dir)

# Print hyperparameters for all models
for model_name in predictor.model_names():
    info = predictor.info()["model_info"][model_name]
    print(f"\n{'='*50}")
    print(f"Model: {model_name}")
    print(f"Hyperparameters: {info.get('hyperparameters', 'N/A')}")
