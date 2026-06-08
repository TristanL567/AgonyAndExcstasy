# AE-FEAT-IMPORT-006R Validation Report

## Status

status: pass

Validation is worker evidence only; no self-approval, staging, commit, push, merge, or future-ticket work was performed.

## Scope Validation

Allowed write areas used:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/**`
- `epics/AE-FEAT-IMPORT/**`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/**` for local-only generated outputs

Protected paths were not edited. Pre-existing dirty files in `06_Presentations/**`, untracked files in `07_CloudComputing/**`, and the untracked ticket envelope were left outside this worker's edits except for reading the ticket.

## Execution Validation

Allowed script executed:

```powershell
py -3.10 05_Documentation\09_Epics\AE-FEAT-IMPORT_Feature_Importance\AE-FEAT-IMPORT-006R_build_individual_feature_importance.py
```

The run completed all eight model-track combinations:

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

Required worker artifacts exist:

- `AE-FEAT-IMPORT-006R_Individual_Feature_Log_Odds_Importance_Report.md`
- `AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- `AE-FEAT-IMPORT-006R_validation_report.md`
- `AE-FEAT-IMPORT-006R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

The documentation artifacts are present on disk under `05_Documentation/**`, which is ignored by the repository-wide `.gitignore`; master commit preparation must force-add these ticket-owned docs if they are to be committed.

Local-only generated outputs exist under:

- `03_Data_Output/10_FeatureImportance/individual_feature_importance/`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/per_model_track/`

Output checks:

| check | result |
|---|---:|
| summary rows | 2,824 |
| coverage audit rows | 2,824 |
| model-track combinations | 8 |
| mapped rows | 2,716 |
| latent/VAE rows | 100 |
| unmapped rows | 8 |
| rows used per combination | 143,173 |

The full generated outputs are compact all-feature summaries and audits. Row-level deltas were not written because `404,320,552` row-delta records would be unsafe and unnecessary for the ticket's requested summary statistics.

## Mapping Validation

Every predictor-required feature was computed and audited as one of:

- `mapped`: feature matched the canonical 11-family taxonomy from AE-FEAT-IMPORT-001R and AE-FEAT-IMPORT-004R.
- `latent_vae`: VAE latent dimensions `z1`-`z24` or `vae_recon_error`.
- `unmapped`: required numeric predictor feature outside the canonical family rules, retained in computation and audit.

## Method Validation

The computation used:

- Fitted predictors loaded from the complete bounded GBM-only workspace.
- Training/CV-analysis rows only, selected by `split == train`.
- Baseline probabilities and clipped logits with `eps = 1e-06`.
- Deterministic individual-feature permutation within CV/training-analysis blocks using fixed seed `20260602`.
- `delta_log_odds = baseline_logit - perturbed_logit`.
- All predictor-required individual features.

## Residual Risk

The result is valid for bounded GBM-only perturbation evidence. It does not validate or replace final full model-suite feature importance.

The long-running shell command printed final metadata and wrote all required outputs, then the command wrapper returned a timeout after completion output. Completion is validated by the written metadata, all eight per-model CSVs, the summary/audit row counts, and generated reports.

The new documentation artifacts are present on disk but may be ignored by repository-wide documentation ignore rules; commit preparation must account for that without staging local generated `03_Data_Output/**` files.
