# AE-FEAT-IMPORT-004R Validation Report

## Status

status: pass

Validation is worker evidence only; no self-approval, staging, commit, push, merge, or future-ticket work was performed.

## Scope Validation

Allowed write areas used:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/**`
- `epics/AE-FEAT-IMPORT/**`
- `03_Data_Output/10_FeatureImportance/family_importance/**` for local-only generated outputs

Protected paths were not edited. Pre-existing dirty files in `06_Presentations/**` and untracked files in `07_CloudComputing/**` were left untouched.

## Execution Validation

Allowed script executed:

```powershell
py -3.10 05_Documentation\09_Epics\AE-FEAT-IMPORT_Feature_Importance\AE-FEAT-IMPORT-004R_build_family_importance.py
```

The first run wrote complete outputs but the command wrapper timed out after AutoGluon left runtime threads alive. The script was patched with an explicit process exit after successful writes and rerun. The rerun exited with code 0 and processed all eight combinations:

- `raw/dynamic_csi`
- `raw/permanent_csi`
- `fund/dynamic_csi`
- `fund/permanent_csi`
- `latent_raw/dynamic_csi`
- `latent_raw/permanent_csi`
- `raw_plus_latent/dynamic_csi`
- `raw_plus_latent/permanent_csi`

No `09C_AutoGluon.py` training, `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity script, pipeline regeneration, or presentation compile was run.

## Output Validation

Required committed/evidence artifacts exist:

- `AE-FEAT-IMPORT-004R_Family_Log_Odds_Importance_Report.md`
- `AE-FEAT-IMPORT-004R_family_importance_summary.csv`
- `AE-FEAT-IMPORT-004R_unmapped_feature_audit.csv`
- `AE-FEAT-IMPORT-004R_build_family_importance.py`
- `AE-FEAT-IMPORT-004R_validation_report.md`
- `AE-FEAT-IMPORT-004R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only generated outputs exist under:

- `03_Data_Output/10_FeatureImportance/family_importance/`
- `03_Data_Output/10_FeatureImportance/family_importance/row_deltas/`

Output checks:

| check | result |
|---|---:|
| summary rows | 98 |
| canonical 11-family attempts | 88 |
| computed perturbation rows | 76 |
| row-delta parquet files | 76 |
| unmapped audit rows | 108 |
| model-track combinations | 8 |
| rows used per combination | 143,173 |

## Mapping Validation

The 11-family mapping from `AE-FEAT-IMPORT-001R_feature_family_mapping.csv` was used for raw and engineered features.

Features outside that mapping were audited:

- `siccd` for raw and fund predictors.
- `fyear` and `siccd` for raw-plus-latent predictors.
- `z1`-`z24` plus `vae_recon_error` for latent predictors, recorded as latent features outside the canonical 11 raw/engineered families.

No unmapped required predictor feature was silently dropped.

## Method Validation

The computation used:

- Fitted predictors loaded from the complete bounded GBM-only workspace.
- Training/CV-analysis rows only, selected by `split == train`.
- Baseline probabilities and clipped logits with `eps = 1e-6`.
- Deterministic per-feature permutation within CV/training-analysis blocks using a fixed seed.
- `delta_log_odds = baseline_logit - perturbed_logit`.
- Family-level blocks only, plus non-canonical audit blocks for latent and unmapped required features.

No point-in-time ratio importance and no individual-feature importance were computed.

## Residual Risk

The result is valid for bounded GBM-only perturbation evidence. It does not validate or replace the final full model-suite feature importance.
