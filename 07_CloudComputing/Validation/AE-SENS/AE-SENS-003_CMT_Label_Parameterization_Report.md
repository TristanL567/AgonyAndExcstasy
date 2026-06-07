# AE-SENS-003 CMT Label Parameterization Report

## status

Specification complete. No pipeline code was changed.

This ticket defines the C/M/T parameter interface, run ID convention, per-run output layout, and overwrite-prevention contract needed by later AE-SENS workers. The current pipeline does not yet expose a safe single-run C/M/T interface; implementing it would require a dedicated raw-only sensitivity runner or a scoped config/output-routing change in a later ticket.

## summary

AE-SENS runs must be driven by explicit environment variables, not by ad hoc script edits or worker-selected paths. Every run must carry a validated `AE_SENS_RUN_ID`, `AE_SENS_C`, `AE_SENS_M`, and `AE_SENS_T`. Output must be rooted under:

```text
<MT_ROOT>/03_Data_Output/3_Modelling_Results/Necessary/sensitivity
```

Each run ID owns its own subdirectories under `labels/`, `raw_features/by_config/`, `raw_models/`, `raw_predictions/`, `evaluation/`, `index_construction/`, and `logs/`. The baseline `C080_M020_T018` is only another isolated run directory and must never share a writable directory with a variant.

AE-SENS-002 remains binding: the current `features_raw.rds` is label-attached and cannot be reused whole across the grid. Later workers must either materialize a shared covariate-only base plus per-run labels/splits, or rebuild a full label-attached raw dataset per run ID.

## parameter_interface

Required environment variables for every AE-SENS run:

| name | example | required meaning |
|---|---|---|
| `MT_ROOT` | `/root/AgonyAndExcstasy` | Absolute project root on the execution host. |
| `RESPONSE_TRACK` | `dynamic_csi` | Must be `dynamic_csi` for this epic. |
| `MODEL` | `raw` | Must be `raw`; no latent, fund, bucket, structural, or VAE model family is in scope. |
| `AE_SENS_RUN_ID` | `C080_M020_T018` | Canonical run ID. Must match C/M/T values. |
| `AE_SENS_C` | `-0.80` | CSI drawdown trigger threshold. Allowed values: `-0.60`, `-0.80`, `-0.90`. |
| `AE_SENS_M` | `-0.20` | CSI recovery ceiling. Allowed values: `0.00`, `-0.20`, `-0.30`. |
| `AE_SENS_T` | `18` | CSI confirmation horizon in months. Allowed values: `12`, `18`, `28`. |
| `AE_SENS_OUTPUT_ROOT` | `$MT_ROOT/03_Data_Output/3_Modelling_Results/Necessary/sensitivity` | Absolute sensitivity output root. |

Derived values:

```text
AE_SENS_RUN_ROOT=<AE_SENS_OUTPUT_ROOT>/<category>/<AE_SENS_RUN_ID>
```

Run ID validation rule:

```text
^C(060|080|090)_M(000|020|030)_T(012|018|028)$
```

The run ID must be derived from absolute parameter magnitudes:

```text
C=-0.60 -> C060
C=-0.80 -> C080
C=-0.90 -> C090
M= 0.00 -> M000
M=-0.20 -> M020
M=-0.30 -> M030
T=12    -> T012
T=18    -> T018
T=28    -> T028
```

Example baseline environment:

```bash
export MT_ROOT=/root/AgonyAndExcstasy
export RESPONSE_TRACK=dynamic_csi
export MODEL=raw
export AE_SENS_RUN_ID=C080_M020_T018
export AE_SENS_C=-0.80
export AE_SENS_M=-0.20
export AE_SENS_T=18
export AE_SENS_OUTPUT_ROOT="$MT_ROOT/03_Data_Output/3_Modelling_Results/Necessary/sensitivity"
```

Example variant environment:

```bash
export MT_ROOT=/root/AgonyAndExcstasy
export RESPONSE_TRACK=dynamic_csi
export MODEL=raw
export AE_SENS_RUN_ID=C090_M020_T028
export AE_SENS_C=-0.90
export AE_SENS_M=-0.20
export AE_SENS_T=28
export AE_SENS_OUTPUT_ROOT="$MT_ROOT/03_Data_Output/3_Modelling_Results/Necessary/sensitivity"
```

## run_grid

Baseline: `C080_M020_T018`.

| C | M | T | run_id |
|---:|---:|---:|---|
| -0.60 | 0.00 | 12 | `C060_M000_T012` |
| -0.60 | 0.00 | 18 | `C060_M000_T018` |
| -0.60 | 0.00 | 28 | `C060_M000_T028` |
| -0.60 | -0.20 | 12 | `C060_M020_T012` |
| -0.60 | -0.20 | 18 | `C060_M020_T018` |
| -0.60 | -0.20 | 28 | `C060_M020_T028` |
| -0.60 | -0.30 | 12 | `C060_M030_T012` |
| -0.60 | -0.30 | 18 | `C060_M030_T018` |
| -0.60 | -0.30 | 28 | `C060_M030_T028` |
| -0.80 | 0.00 | 12 | `C080_M000_T012` |
| -0.80 | 0.00 | 18 | `C080_M000_T018` |
| -0.80 | 0.00 | 28 | `C080_M000_T028` |
| -0.80 | -0.20 | 12 | `C080_M020_T012` |
| -0.80 | -0.20 | 18 | `C080_M020_T018` |
| -0.80 | -0.20 | 28 | `C080_M020_T028` |
| -0.80 | -0.30 | 12 | `C080_M030_T012` |
| -0.80 | -0.30 | 18 | `C080_M030_T018` |
| -0.80 | -0.30 | 28 | `C080_M030_T028` |
| -0.90 | 0.00 | 12 | `C090_M000_T012` |
| -0.90 | 0.00 | 18 | `C090_M000_T018` |
| -0.90 | 0.00 | 28 | `C090_M000_T028` |
| -0.90 | -0.20 | 12 | `C090_M020_T012` |
| -0.90 | -0.20 | 18 | `C090_M020_T018` |
| -0.90 | -0.20 | 28 | `C090_M020_T028` |
| -0.90 | -0.30 | 12 | `C090_M030_T012` |
| -0.90 | -0.30 | 18 | `C090_M030_T018` |
| -0.90 | -0.30 | 28 | `C090_M030_T028` |

## output_layout

Canonical sensitivity root:

```text
03_Data_Output/
  3_Modelling_Results/
    Necessary/
      sensitivity/
        manifest/
        logs/
          <run_id>/
        labels/
          <run_id>/
        raw_features/
          shared/
          by_config/
            <run_id>/
        raw_models/
          <run_id>/
        raw_predictions/
          <run_id>/
        evaluation/
          <run_id>/
        index_construction/
          <run_id>/
        comparisons/
```

Required per-run files or file groups:

| category | directory | required use |
|---|---|---|
| `logs` | `logs/<run_id>/` | Script stdout/stderr, run manifest, package/session metadata. |
| `labels` | `labels/<run_id>/` | Event table, annual labels, label diagnostics for that C/M/T only. |
| `raw_features/shared` | `raw_features/shared/` | Optional immutable covariate-only base with no `y`, `censored`, `param_id`, event date/year, label year, or response-track label columns. |
| `raw_features/by_config` | `raw_features/by_config/<run_id>/` | Label-attached `features_raw`, split artifacts, and run-specific raw feature metadata. |
| `raw_models` | `raw_models/<run_id>/` | Raw AutoGluon predictor artifacts for this run only. |
| `raw_predictions` | `raw_predictions/<run_id>/` | Raw model CV/test/OOS predictions and leaderboard exports. |
| `evaluation` | `evaluation/<run_id>/` | Run-specific raw-model evaluation summaries. |
| `index_construction` | `index_construction/<run_id>/` | Run-specific 11C outputs derived from that run's raw predictions. |
| `comparisons` | `comparisons/` | Cross-run comparison outputs only; never a staging area for per-run mutable outputs. |

## overwrite_prevention

Workers must enforce these checks before running any output-producing step:

1. `AE_SENS_RUN_ID` must match the regex and must match `AE_SENS_C`, `AE_SENS_M`, and `AE_SENS_T`.
2. `AE_SENS_OUTPUT_ROOT` must be absolute and must end in `03_Data_Output/3_Modelling_Results/Necessary/sensitivity`.
3. All output writes for a run must be under one of the approved `<category>/<run_id>/` directories, except `raw_features/shared/` and `comparisons/`.
4. Baseline paths for `C080_M020_T018` must be treated as existing protected paths once created. A variant must never write to any baseline directory.
5. Existing non-empty `<category>/<run_id>/` directories must not be overwritten unless a later ticket explicitly authorizes resume or replacement semantics for that same run ID.
6. No AE-SENS worker may write canonical local model outputs under `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw` for a sensitivity run.

## findings

- `01_Code/pipeline/config.R` already supports `MT_ROOT`, absolute `MT_OUTPUT_DIR`, `RESPONSE_TRACK`, `CSI_RUN_GRID`, and `CSI_GRID_WORKERS`.
- `01_Code/pipeline/config.R` does not expose single-run C/M/T environment variables or `AE_SENS_RUN_ID`.
- `01_Code/pipeline/05A_Dynamic_CSI_Label.R` uses `CSI_BASE` for base label generation and the optional `CSI_RUN_GRID` branch for a full grid; it does not accept a single run ID.
- Current `CSI_GRID` in `config.R` uses `T = c(12L, 18L, 24L)`, while the refreshed AE-SENS grid requires `T = c(12L, 18L, 28L)`. Later execution must not rely on the current built-in grid branch without a follow-up change.
- Current Python raw-model code honors `MODEL=raw`, `RESPONSE_TRACK=dynamic_csi`, and absolute `MT_OUTPUT_DIR`, but its native output tree is still the standard modelling tree under `.../temporary_csi/AutoGluon/ag_raw`, not the AE-SENS per-run layout.
- Current `10_Evaluation.R` evaluates all registered model families and is not a raw-only sensitivity evaluator.
- Current `11C_IndexConstruction_Revised.R` is raw-prediction focused, but its output path is the standard track output path, not the AE-SENS per-run `index_construction/<run_id>/` path.

## next_worker_commands

The next implementation worker should create a dedicated raw-only sensitivity runner or equivalent scoped code path that consumes the interface above. The command form for every run must be:

```bash
export MT_ROOT=/root/AgonyAndExcstasy
export RESPONSE_TRACK=dynamic_csi
export MODEL=raw
export AE_SENS_OUTPUT_ROOT="$MT_ROOT/03_Data_Output/3_Modelling_Results/Necessary/sensitivity"

export AE_SENS_RUN_ID=C080_M020_T018
export AE_SENS_C=-0.80
export AE_SENS_M=-0.20
export AE_SENS_T=18

# Future runner to implement in a later ticket:
# bash 01_Code/shell/run_ae_sens_raw_one.sh
```

Pilot variant command form:

```bash
export MT_ROOT=/root/AgonyAndExcstasy
export RESPONSE_TRACK=dynamic_csi
export MODEL=raw
export AE_SENS_OUTPUT_ROOT="$MT_ROOT/03_Data_Output/3_Modelling_Results/Necessary/sensitivity"

export AE_SENS_RUN_ID=C090_M020_T028
export AE_SENS_C=-0.90
export AE_SENS_M=-0.20
export AE_SENS_T=28

# Future runner to implement in a later ticket:
# bash 01_Code/shell/run_ae_sens_raw_one.sh
```

That runner must validate paths before output-producing work and should fail closed if any destination directory for the same run ID already contains files and no explicit resume flag is provided.

## artifacts

- Created: `07_CloudComputing/Validation/AE-SENS/AE-SENS-003_CMT_Label_Parameterization_Report.md`

## changed_files

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-003_CMT_Label_Parameterization_Report.md`

No pipeline code, canonical output, data, remote file, or model artifact was changed.

## verification

Commands run:

```powershell
rg -n "CMT|C/M/T|run.?id|RUN_ID|param_id|features_raw|output|out_dir|results|CSI|csi|threshold|censor|maturity|T0|horizon|C080|M020|T018" 01_Code 07_CloudComputing/Validation/AE-SENS 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/Tickets
Get-Content -LiteralPath "05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/Tickets/AE-SENS-003_CMT_Label_Parameterization.md"
git status --short
rg -n "CSI_BASE|CSI_GRID|CSI_RUN_GRID|PATH_|DIR_|OUTPUT|RESULT|FEATURES|SPLIT|LABEL|PARAM_C|PARAM_M|PARAM_T|Sys.getenv|commandArgs|optparse|argparse|run_id|RUN_ID|CMT" 01_Code/pipeline/config.R 01_Code/pipeline/05A_Dynamic_CSI_Label.R 01_Code/pipeline/06_Merge.R 01_Code/pipeline/06B_FeatureEngineering.R 01_Code/pipeline/08_Split.R
Get-Content -LiteralPath "05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/AE-SENS_Epic.md"
rg -n "dry|plan|preflight|SENS|sensitivity|CSI_RUN|MT_OUTPUT_DIR|C080|C060|C090" 01_Code 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid 07_CloudComputing
git branch --show-current
git rev-parse --short HEAD
Test-Path -LiteralPath "03_Data_Output/3_Modelling_Results/Necessary/sensitivity"
& "C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "parse('01_Code/pipeline/config.R'); parse('01_Code/pipeline/05A_Dynamic_CSI_Label.R'); parse('01_Code/pipeline/06_Merge.R'); parse('01_Code/pipeline/06B_FeatureEngineering.R'); parse('01_Code/pipeline/08_Split.R'); cat('R parse OK\n')"
py -3.10 -m py_compile 01_Code/pipeline/09C_preflight.py 01_Code/pipeline/09C_AutoGluon.py
<PowerShell dry-run path planner for all 27 run IDs>
```

Verification results:

- Branch: `development-sensitivity`.
- HEAD: `91e6c99`.
- R syntax parse passed for `config.R`, `05A_Dynamic_CSI_Label.R`, `06_Merge.R`, `06B_FeatureEngineering.R`, and `08_Split.R`; command ended with `R parse OK`.
- Python syntax compilation passed for `09C_preflight.py` and `09C_AutoGluon.py`.
- Dry-run path planner returned `DRY_RUN_PATH_PLAN_OK rows=27 unique_run_ids=27 baseline=C080_M020_T018`.
- Existing sensitivity root presence was read only: `03_Data_Output/3_Modelling_Results/Necessary/sensitivity` exists.
- No model, grid, pipeline, evaluation, index-construction, upload, download, or remote command was run.

## git_status_summary

Pre-report status contained the unrelated untracked file:

```text
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

Expected post-report status adds this ticket report only:

```text
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-003_CMT_Label_Parameterization_Report.md
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

The unrelated AE-VALIDATE report was not edited, staged, or included.

## canonical_outputs

Confirmed: no canonical outputs were touched. The existing `03_Data_Output/3_Modelling_Results/Necessary/sensitivity` path was inspected only for path-planning context and was not modified.

## next_recommended_role

Implementation worker for a dedicated raw-only AE-SENS runner that:

1. Validates `AE_SENS_RUN_ID`, `AE_SENS_C`, `AE_SENS_M`, and `AE_SENS_T`.
2. Generates or attaches labels for exactly one run ID.
3. Uses a shared immutable covariate base or rebuilds per-run label-attached raw features as required by AE-SENS-002.
4. Routes raw model, prediction, evaluation, 11C, and log outputs into the per-run sensitivity layout.
5. Refuses overwrite of existing non-empty run directories unless a later ticket explicitly authorizes resume behavior.

## human_readability

This report is intended to be directly executable as a handoff spec: future workers should not choose parameter names, run ID formatting, baseline identity, output root, or per-run subdirectories.
