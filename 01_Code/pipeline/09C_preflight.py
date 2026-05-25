"""
09C_preflight.py
================
Diagnostic checks to run on the vast.ai instance BEFORE starting 09C_AutoGluon.py.
Verifies environment, data files, label integrity, and GPU availability.

Run from /workspace/MT/01_Code/Data:
    python 09C_preflight.py

A clean run prints only [OK] lines and a final READY summary.
Any [FAIL] or [WARN] must be resolved before running 09C.
"""

import os
import re
import sys
from pathlib import Path

PASS = "[OK]  "
WARN = "[WARN]"
FAIL = "[FAIL]"
failures = []
warnings = []

def ok(msg):   print(f"{PASS} {msg}")
def warn(msg): print(f"{WARN} {msg}"); warnings.append(msg)
def fail(msg): print(f"{FAIL} {msg}"); failures.append(msg)

# ==============================================================================
# 1. Paths
# ==============================================================================
print("\n── 1. Environment & Paths ─────────────────────────────────────────────")

_env_root = os.environ.get("MT_ROOT")
is_vast = "VAST_CONTAINERLABEL" in os.environ
if _env_root:
    DATA_ROOT = Path(_env_root)
    ok(f"MT_ROOT provided: {DATA_ROOT}")
elif is_vast:
    DATA_ROOT = Path("/workspace/AgonyAndExcstasy")
    ok("vast.ai environment detected")
else:
    if os.name == "nt":
        DATA_ROOT = Path(r"C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy")
    else:
        DATA_ROOT = Path("./AgonyAndExcstasy")
    warn(f"Not on vast.ai — using local DATA_ROOT: {DATA_ROOT}")

if DATA_ROOT.exists():
    ok(f"DATA_ROOT exists: {DATA_ROOT}")
else:
    fail(f"DATA_ROOT not found: {DATA_ROOT}")

# AgonyAndExcstasy layout
DIR_DATA_INPUT    = DATA_ROOT / "02_Data_Input"
DIR_DATA_OUTPUT   = DATA_ROOT / "03_Data_Output"
DIR_CODE          = DATA_ROOT / "01_Code" / "pipeline"
DIR_PR_NEC        = DIR_DATA_INPUT / "05_PipelineResults" / "Necessary"
DIR_FEATURES_BASE = DIR_PR_NEC   # parent of {track}/Features/
DIR_LABELS_BASE   = DIR_PR_NEC   # parent of {track}/Labels/

def _env_flag(name, default=True):
    value = os.environ.get(name, "1" if default else "0")
    return value.strip().lower() in {"1", "true", "t", "yes", "y", "on"}

def _track_folder(rt):
    return "temporary_csi" if rt == "dynamic_csi" else rt

def resolve_output_dir():
    # MT_OUTPUT_DIR is obsolete (single output tree); honoured only if absolute.
    override = os.environ.get("MT_OUTPUT_DIR")
    if override:
        p = Path(override)
        if p.is_absolute():
            return p
    return DIR_DATA_OUTPUT

DIR_OUTPUT   = resolve_output_dir()
print(f"[09C_preflight] Output folder: {DIR_OUTPUT}")

LABEL_TRACKS = {"dynamic_csi", "permanent_csi"}

def read_response_track():
    env_track = os.environ.get("RESPONSE_TRACK")
    if env_track:
        return env_track
    config_path = DIR_CODE / "config.R"
    if config_path.exists():
        text = config_path.read_text(encoding="utf-8", errors="ignore")
        match = re.search(r'RESPONSE_TRACK\s*<-\s*"([^"]+)"', text)
        if match:
            return match.group(1)
    return "dynamic_csi"

RESPONSE_TRACK = read_response_track()
if RESPONSE_TRACK not in LABEL_TRACKS:
    fail(f"Invalid RESPONSE_TRACK: {RESPONSE_TRACK}; expected one of {sorted(LABEL_TRACKS)}")
else:
    ok(f"RESPONSE_TRACK: {RESPONSE_TRACK}")
TRACK_FOLDER = _track_folder(RESPONSE_TRACK)

# AgonyAndExcstasy layout
DIR_FEATURES        = DIR_FEATURES_BASE / TRACK_FOLDER / "Features"
DIR_LABELS          = DIR_LABELS_BASE   / TRACK_FOLDER / "Labels"
DIR_MODELLING_TRACK = DIR_OUTPUT / "3_Modelling_Results" / "Necessary" / TRACK_FOLDER
DIR_MODELS          = DIR_MODELLING_TRACK / "AutoGluon"  # trained predictor binaries
DIR_TABLES          = DIR_MODELLING_TRACK / "AutoGluon"  # predictions / leaderboard
# Legacy bucket/structural labels live in Additional/legacy_flat_pre_track_split/
DIR_LABELS_LEGACY_FLAT = DIR_DATA_INPUT / "05_PipelineResults" / "Additional" \
    / "legacy_flat_pre_track_split" / "Labels"

# ==============================================================================
# 2. Required input files
# ==============================================================================
print("\n── 2. Required Input Files ────────────────────────────────────────────")

PHASE1_FILES = {
    "split_labels_oot.parquet" : DIR_FEATURES / "split_labels_oot.parquet",
    "features_fund.rds"        : DIR_FEATURES / "features_fund.rds",
    "features_raw.rds"         : DIR_FEATURES / "features_raw.rds",
    "labels_model_ready.rds"   : DIR_LABELS   / "labels_model_ready.rds",
}

LEGACY_LABEL_FILES = {
    "labels_bucket.rds"     : DIR_LABELS_LEGACY_FLAT / "labels_bucket.rds",
    "labels_structural.rds" : DIR_LABELS_LEGACY_FLAT / "labels_structural.rds",
}

PHASE2_FILES = {
    "features_latent_fund.parquet" : DIR_FEATURES / "features_latent_fund.parquet",
    "features_latent_raw.parquet"  : DIR_FEATURES / "features_latent_raw.parquet",
}

phase1_ready = True
for name, path in PHASE1_FILES.items():
    if path.exists():
        size_mb = path.stat().st_size / 1e6
        ok(f"{name}  ({size_mb:.1f} MB)")
    else:
        fail(f"{name} MISSING — {path}")
        phase1_ready = False

for name, path in LEGACY_LABEL_FILES.items():
    if path.exists():
        size_mb = path.stat().st_size / 1e6
        ok(f"{name} legacy label present ({size_mb:.1f} MB)")
    else:
        warn(f"{name} legacy label not present; bucket/structural models only")

phase2_ready = True
for name, path in PHASE2_FILES.items():
    if path.exists():
        size_mb = path.stat().st_size / 1e6
        ok(f"{name}  ({size_mb:.1f} MB)")
    else:
        warn(f"{name} not yet present — Phase 2 models will fail until 08B completes")
        phase2_ready = False

# ==============================================================================
# 3. Imports
# ==============================================================================
print("\n── 3. Python Imports ──────────────────────────────────────────────────")

import importlib
REQUIRED_PACKAGES = ["numpy", "pandas", "pyreadr", "pyarrow", "sklearn"]
for pkg in REQUIRED_PACKAGES:
    try:
        importlib.import_module(pkg)
        ok(pkg)
    except ImportError:
        fail(f"{pkg} not installed — run: pip install {pkg}")

try:
    from autogluon.tabular import TabularDataset, TabularPredictor
    ok("autogluon.tabular")
except ImportError:
    fail("autogluon not installed — run: pip install autogluon.tabular")

# ==============================================================================
# 4. GPU
# ==============================================================================
print("\n── 4. GPU / CUDA ──────────────────────────────────────────────────────")

try:
    import torch
    if torch.cuda.is_available():
        gpu_name = torch.cuda.get_device_name(0)
        vram_gb  = torch.cuda.get_device_properties(0).total_memory / 1e9
        ok(f"CUDA available — {gpu_name}  ({vram_gb:.1f} GB VRAM)")
    else:
        warn("CUDA not available — AutoGluon will run on CPU (slower but functional)")
except ImportError:
    warn("torch not installed — cannot check GPU. AutoGluon will auto-detect.")

# ==============================================================================
# 5. Disk space
# ==============================================================================
print("\n── 5. Disk Space ──────────────────────────────────────────────────────")

import shutil
total, used, free = shutil.disk_usage(DATA_ROOT if DATA_ROOT.exists() else "/")
free_gb = free / 1e9
if free_gb >= 20:
    ok(f"Free disk space: {free_gb:.1f} GB")
elif free_gb >= 5:
    warn(f"Low disk space: {free_gb:.1f} GB free — AutoGluon model artifacts can be large")
else:
    fail(f"Very low disk space: {free_gb:.1f} GB — likely to fail during training")

# ==============================================================================
# 6. Data integrity spot-checks
# ==============================================================================
print("\n── 6. Data Integrity ──────────────────────────────────────────────────")

if phase1_ready:
    try:
        import pyreadr
        import pandas as pd

        # Check split file
        splits = pd.read_parquet(DIR_FEATURES / "split_labels_oot.parquet")
        expected_cols = {"permno", "year", "eval_split"}
        missing = expected_cols - set(splits.columns)
        if missing:
            fail(f"split_labels_oot.parquet missing columns: {missing}")
        else:
            ok(f"split_labels_oot.parquet  shape={splits.shape}  splits={sorted(splits['eval_split'].unique())}")

        # Check features_fund
        fund_rds = pyreadr.read_r(str(DIR_FEATURES / "features_fund.rds"))
        fund = list(fund_rds.values())[0]
        if fund.shape[0] < 1000:
            warn(f"features_fund.rds has only {fund.shape[0]} rows — unexpectedly small")
        else:
            ok(f"features_fund.rds  shape={fund.shape}")

        # Check y column exists; 06_Merge already aligns event year t+1 to row t.
        if "y" in fund.columns:
            vc = fund["y"].value_counts(dropna=False)
            ok(f"y ({RESPONSE_TRACK}, paper-aligned) counts: {vc.to_dict()}")
        else:
            fail("y column not found in features_fund.rds — CSI models will fail")

        # Check features_raw
        raw_rds = pyreadr.read_r(str(DIR_FEATURES / "features_raw.rds"))
        raw = list(raw_rds.values())[0]
        ok(f"features_raw.rds  shape={raw.shape}")

        # Check bucket labels
        lbl_path = DIR_LABELS_BASE / "labels_bucket.rds"
        if lbl_path.exists():
            lbl = list(pyreadr.read_r(str(lbl_path)).values())[0]
            if "y_loser" in lbl.columns:
                ok(f"labels_bucket.rds — y_loser counts: {lbl['y_loser'].value_counts(dropna=False).to_dict()}")
            else:
                fail("y_loser column not found in labels_bucket.rds")

        # Check structural labels
        lbl_path = DIR_LABELS_BASE / "labels_structural.rds"
        if lbl_path.exists():
            lbl = list(pyreadr.read_r(str(lbl_path)).values())[0]
            if "y_structural" in lbl.columns:
                ok(f"labels_structural.rds — y_structural counts: {lbl['y_structural'].value_counts(dropna=False).to_dict()}")
            else:
                fail("y_structural column not found in labels_structural.rds")

    except Exception as e:
        fail(f"Data integrity check error: {e}")
else:
    warn("Skipping data integrity checks — Phase 1 files incomplete")

if phase2_ready:
    try:
        import pandas as pd
        for name, path in PHASE2_FILES.items():
            df = pd.read_parquet(path)
            ok(f"{name}  shape={df.shape}")
    except Exception as e:
        fail(f"Phase 2 parquet check error: {e}")

# ==============================================================================
# 7. Output directory writability
# ==============================================================================
print("\n── 7. Output Directories ──────────────────────────────────────────────")

for d in [DIR_MODELS, DIR_TABLES]:
    try:
        d.mkdir(parents=True, exist_ok=True)
        test_file = d / ".write_test"
        test_file.touch()
        test_file.unlink()
        ok(f"Writable: {d}")
    except Exception as e:
        fail(f"Cannot write to {d}: {e}")

# ==============================================================================
# Summary
# ==============================================================================
print("\n" + "=" * 70)
if not failures:
    phase_str = "Phase 1 + Phase 2" if phase2_ready else "Phase 1 only (Phase 2 awaits 08B)"
    print(f"READY — {phase_str} models can run.")
    if warnings:
        print(f"  {len(warnings)} warning(s) noted above — review before proceeding.")
else:
    print(f"NOT READY — {len(failures)} failure(s) must be resolved:")
    for f in failures:
        print(f"  • {f}")
print("=" * 70)
sys.exit(0 if not failures else 1)
