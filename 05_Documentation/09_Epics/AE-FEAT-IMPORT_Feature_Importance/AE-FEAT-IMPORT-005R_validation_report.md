# AE-FEAT-IMPORT-005R Validation Report

## Status

status: pass

Validation is worker evidence only; no self-approval, staging, commit, push, merge, or future-ticket work was performed.

## Scope Validation

Allowed write areas used:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/**`
- `epics/AE-FEAT-IMPORT/**`
- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/**` for local-only generated outputs

Protected paths were not edited. Pre-existing dirty files in `06_Presentations/**`, untracked files in `07_CloudComputing/**`, and the untracked ticket envelope were left outside this worker's edits except for reading the ticket.

## Execution Validation

Allowed script executed:

```powershell
py -3.10 05_Documentation\09_Epics\AE-FEAT-IMPORT_Feature_Importance\AE-FEAT-IMPORT-005R_build_pit_ratio_importance.py
```

The run exited with code 0 and processed all eight audited combinations:

- `raw/dynamic_csi`
- `raw/permanent_csi`
- `fund/dynamic_csi`
- `fund/permanent_csi`
- `latent_raw/dynamic_csi`
- `latent_raw/permanent_csi`
- `raw_plus_latent/dynamic_csi`
- `raw_plus_latent/permanent_csi`

No `09C_AutoGluon.py` training, `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity script, pipeline regeneration, or presentation compile was run.

`pyreadr` emitted datetime cast warnings while loading RDS feature files; the script completed successfully and wrote all expected outputs.

## Output Validation

Required worker artifacts exist:

- `AE-FEAT-IMPORT-005R_PIT_Ratio_Log_Odds_Importance_Report.md`
- `AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv`
- `AE-FEAT-IMPORT-005R_pit_ratio_coverage_audit.csv`
- `AE-FEAT-IMPORT-005R_build_pit_ratio_importance.py`
- `AE-FEAT-IMPORT-005R_validation_report.md`
- `AE-FEAT-IMPORT-005R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only generated outputs exist under:

- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/`
- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/row_deltas/`

Output checks:

| check | result |
|---|---:|
| summary rows | 246 |
| coverage audit rows | 8 |
| applicable computed combinations | 6 |
| latent_raw not-applicable combinations | 2 |
| row-delta parquet files | 246 |
| expected PIT ratio features | 44 |
| present PIT ratio features per applicable predictor | 41 |
| missing PIT ratio features per applicable predictor | 3 |
| rows used per combination | 143,173 |

`git check-ignore -v` confirmed the generated `03_Data_Output/10_FeatureImportance/pit_ratio_importance/**` files are ignored by `.gitignore`.

`git check-ignore -v` also confirms new `05_Documentation/**` artifacts are ignored by the repository-wide documentation ignore rule. Existing AE-FEAT-IMPORT documentation artifacts are tracked from prior tickets, so the master/committer role will need to force-add the new compact 005R documentation artifacts if committing them. This worker did not stage or commit.

## Mapping Validation

The PIT-ratio list was derived from AE-FEAT-IMPORT-001R, 06B feature engineering, and AE-FEAT-IMPORT-004R evidence:

- Included base accounting, valuation, liquidity, leverage, quality, size, Altman, and zombie-precursor ratios.
- Included `cash_div_cf` because 06B constructs it as a point-in-time financial ratio and 004R included it in the point-in-time family block.
- Excluded macro point-in-time controls because 001R distinguishes them from the narrower accounting-ratio subset.

Missing expected ratio features were not silently dropped: `altman_z1`, `altman_z3`, and `altman_z5` are recorded in the coverage audit for every applicable predictor.

`latent_raw` is recorded as `not_applicable_no_point_in_time_ratio_features` for both tracks.

## Method Validation

The computation used:

- Fitted predictors loaded from the complete bounded GBM-only workspace.
- Training/CV-analysis rows only, selected by `split == train`.
- Baseline probabilities and clipped logits with `eps = 1e-6`.
- Deterministic individual-feature permutation within CV/training-analysis blocks using fixed seed `20260602`.
- `delta_log_odds = baseline_logit - perturbed_logit`.
- Individual point-in-time/base ratio features only.

No all-feature individual importance and no broader point-in-time macro-control perturbation was computed.

## Residual Risk

The result is valid for bounded GBM-only perturbation evidence. It does not validate or replace final full model-suite feature importance.

The new documentation artifacts are present on disk but ignored by `.gitignore`; commit preparation must account for that without staging local generated `03_Data_Output/**` files.
