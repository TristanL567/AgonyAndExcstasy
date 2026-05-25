"""
Paths.py — Python-side path resolver for the AgonyAndExcstasy layout.

This is the Python equivalent of config.R. Both files must stay in sync.

Layout summary:
  AgonyAndExcstasy/
  ├── 01_Code/                       (scripts; this file lives in 01_Code/pipeline/)
  ├── 02_Data_Input/                 (external + derived pipeline data)
  │   ├── 01_CRSP/   {Necessary,Additional}/
  │   ├── 02_Compustat/ {Necessary,Additional}/
  │   ├── 03_FRED/  {Necessary,Additional}/
  │   ├── 04_Index_Replication/ {Necessary,Additional}/
  │   └── 05_PipelineResults/Necessary/{temporary_csi,permanent_csi}/{Labels,Features,Panel}/
  └── 03_Data_Output/                (results, organised by analysis category)
      ├── 1_Descriptive_Statistics/
      ├── 2_Robustness_Checks/
      ├── 3_Modelling_Results/
      └── 4_IndexConstruction_Results/

Track-folder naming note:
  RESPONSE_TRACK env var still uses "dynamic_csi" / "permanent_csi" (matches code).
  On disk, the dynamic_csi track lives under the folder named "temporary_csi".
"""

import os
from pathlib import Path

# ============================================================================
# 1. Repository root
# ============================================================================
DATA_ROOT = Path(
    os.environ.get(
        "MT_ROOT",
        r"C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy",
    )
)

# ============================================================================
# 2. Track switch
# ============================================================================
RESPONSE_TRACK = os.environ.get("RESPONSE_TRACK", "dynamic_csi")
CSI_USE_TERMINAL_FAILURE_INDICATORS = os.environ.get(
    "CSI_USE_TERMINAL_FAILURE_INDICATORS",
    "1",
).strip().lower() not in {"0", "false", "no", "off"}


def _track_folder(rt: str = RESPONSE_TRACK) -> str:
    """Map RESPONSE_TRACK value to on-disk folder name."""
    return "temporary_csi" if rt == "dynamic_csi" else rt


TRACK_FOLDER = _track_folder()

# ============================================================================
# 3. Root sub-trees
# ============================================================================
DIR_CODE        = DATA_ROOT / "01_Code"
DIR_DATA_INPUT  = DATA_ROOT / "02_Data_Input"
DIR_DATA_OUTPUT = DATA_ROOT / "03_Data_Output"

# ============================================================================
# 4. Input-data directories (02_Data_Input/)
# ============================================================================
DIR_CRSP_NEC   = DIR_DATA_INPUT / "01_CRSP"              / "Necessary"
DIR_CRSP_ADD   = DIR_DATA_INPUT / "01_CRSP"              / "Additional"
DIR_COMP_NEC   = DIR_DATA_INPUT / "02_Compustat"         / "Necessary"
DIR_COMP_ADD   = DIR_DATA_INPUT / "02_Compustat"         / "Additional"
DIR_FRED_NEC   = DIR_DATA_INPUT / "03_FRED"              / "Necessary"
DIR_FRED_ADD   = DIR_DATA_INPUT / "03_FRED"              / "Additional"
DIR_IDXREP_NEC = DIR_DATA_INPUT / "04_Index_Replication" / "Necessary"
DIR_IDXREP_ADD = DIR_DATA_INPUT / "04_Index_Replication" / "Additional"

# Pipeline results (derived) — track-aware
_PR_NEC            = DIR_DATA_INPUT / "05_PipelineResults" / "Necessary"
DIR_LABELS_DYN     = _PR_NEC / "temporary_csi" / "Labels"
DIR_LABELS_PERM    = _PR_NEC / "permanent_csi" / "Labels"
DIR_FEATURES_DYN   = _PR_NEC / "temporary_csi" / "Features"
DIR_FEATURES_PERM  = _PR_NEC / "permanent_csi" / "Features"
DIR_PANEL_DYN      = _PR_NEC / "temporary_csi" / "Panel"
DIR_PANEL_PERM     = _PR_NEC / "permanent_csi" / "Panel"

DIR_LABELS_TRACK   = _PR_NEC / TRACK_FOLDER / "Labels"
DIR_FEATURES_TRACK = _PR_NEC / TRACK_FOLDER / "Features"
DIR_PANEL_TRACK    = _PR_NEC / TRACK_FOLDER / "Panel"

# Alias matching the original variable name
DIR_FEATURES = DIR_FEATURES_TRACK

# ============================================================================
# 5. Output directories (03_Data_Output/)
# ============================================================================
DIR_DESCRIPTIVE = DIR_DATA_OUTPUT / "1_Descriptive_Statistics"
DIR_ROBUSTNESS  = DIR_DATA_OUTPUT / "2_Robustness_Checks"
DIR_MODELLING   = DIR_DATA_OUTPUT / "3_Modelling_Results"
DIR_INDEX       = DIR_DATA_OUTPUT / "4_IndexConstruction_Results"

# Track-aware modelling output (where 09C_AutoGluon, 08B_Autoencoder write)
DIR_MODELLING_TRACK = DIR_MODELLING / "Necessary" / TRACK_FOLDER
DIR_AUTOGLUON_TRACK = DIR_MODELLING_TRACK / "AutoGluon"
DIR_XGBOOST_TRACK   = DIR_MODELLING_TRACK / "XGBoost"
DIR_VAE_TRACK       = DIR_MODELLING_TRACK / "VAE"
DIR_EVAL_TRACK      = DIR_MODELLING_TRACK / "evaluation"
DIR_FIGURES_TRACK   = DIR_MODELLING_TRACK / "figures"

# Aliases matching the original variable names
DIR_MODELS  = DIR_VAE_TRACK
DIR_FIGURES = DIR_FIGURES_TRACK

# ============================================================================
# 6. File paths
# ============================================================================
PATH_FEATURES_RAW    = DIR_FEATURES / "features_raw.rds"
PATH_FEATURES_FUND   = DIR_FEATURES / "features_fund.rds"
PATH_SPLITS          = DIR_FEATURES / "splits.rds"

# 08B_Autoencoder outputs (parquets consumed by 09C)
PATH_FEATURES_LATENT_FUND     = DIR_FEATURES / "features_latent_fund.parquet"
PATH_FEATURES_LATENT_RAW      = DIR_FEATURES / "features_latent_raw.parquet"
PATH_FEATURES_RAW_PLUS_LATENT = DIR_FEATURES / "features_raw_plus_latent.parquet"
PATH_FEATURES_LATENT          = PATH_FEATURES_LATENT_FUND  # back-compat alias

# ============================================================================
# 7. Create output dirs lazily on import (matches previous behaviour)
# ============================================================================
DIR_FIGURES.mkdir(parents=True, exist_ok=True)
DIR_VAE_TRACK.mkdir(parents=True, exist_ok=True)

# ============================================================================
# 8. Self-check (executed when run as a script)
# ============================================================================
if __name__ == "__main__":
    print(f"DATA_ROOT      = {DATA_ROOT}")
    print(f"RESPONSE_TRACK = {RESPONSE_TRACK}  (folder: {TRACK_FOLDER})")
    print(f"DIR_FEATURES   = {DIR_FEATURES}")
    print(f"DIR_MODELS     = {DIR_MODELS}")
    print()
    print(f"features_raw.rds exists?   {PATH_FEATURES_RAW.exists()}")
    print(f"splits.rds exists?         {PATH_SPLITS.exists()}")
    print(f"Files in DIR_FEATURES:     {sorted(p.name for p in DIR_FEATURES.glob('*'))}")
