# AE-FP-FEATURE-DEEPDIVE-002R FP/TP Feature Separability Report

## Scope

Ticket `AE-FP-FEATURE-DEEPDIVE-002R` rebuilt CV/training-only feature evidence from the now-approved local model input artifacts and joined it to the existing AE-FP-DIAG CV false-positive and true-positive cohorts.

The analysis used only training/CV rows:

- RDS raw/fund sources were filtered with `splits.rds` `oot$train_idx`.
- Parquet latent/raw-plus-latent sources were filtered with `split == train`.
- AE-FP-DIAG cohort rows were required to have `split_source = cv`.
- Model-suite test and OOS prediction files were not used for feature discovery.

## Source Feature Artifacts

| track | feature_family | source | rows used | feature columns | years |
|---|---|---|---:|---:|---|
| `dynamic_csi` / temporary CSI | `raw` | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_raw.rds` | 143,173 | 478 | 1993-2015 |
| `dynamic_csi` / temporary CSI | `fund` | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_fund.rds` | 143,173 | 459 | 1993-2015 |
| `dynamic_csi` / temporary CSI | `latent_raw` | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_latent_raw.parquet` | 143,173 | 25 | 1993-2015 |
| `dynamic_csi` / temporary CSI | `raw_plus_latent` | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_raw_plus_latent.parquet` | 143,173 | 503 | 1993-2015 |
| `permanent_csi` / permanent CSI | `raw` | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/features_raw.rds` | 143,173 | 478 | 1993-2015 |
| `permanent_csi` / permanent CSI | `fund` | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/features_fund.rds` | 143,173 | 459 | 1993-2015 |
| `permanent_csi` / permanent CSI | `latent_raw` | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/features_latent_raw.parquet` | 143,173 | 25 | 1993-2015 |
| `permanent_csi` / permanent CSI | `raw_plus_latent` | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Features/features_raw_plus_latent.parquet` | 143,173 | 503 | 1993-2015 |

All eight source tables were unique on `permno/year` after the CV/training filter.

## Cohort Availability

The existing AE-FP-DIAG CV cohorts contain model-family cohort labels for `raw` and `raw_plus_latent` only. Therefore:

- `raw` and `raw_plus_latent` contrasts are matched model-family FP-vs-TP comparisons.
- `latent_raw` contrasts are available as a component profile against `raw_plus_latent` cohorts, but no standalone AE-FP-DIAG `latent_raw` FP/TP cohort exists.
- `fund` contrasts are auxiliary cross-family profiles against the existing `raw` and `raw_plus_latent` FP/TP cohorts; no standalone AE-FP-DIAG `fund` FP/TP cohort exists.

## Local Generated Outputs

Generated data remains local and must not be staged or committed:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_source_schema_manifest.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_cv_feature_matrix_keys.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_cv_cohort_join_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_fp_tp_feature_contrasts.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_top_separating_features.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_feature_group_summary.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_validation_checks.csv`

The reproducibility script is a documentation artifact for validator/master commit consideration:

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_build_feature_separability.R`

## Join Coverage

Join coverage was 100% for every `track`, AE-FP-DIAG cohort feature set, threshold, source feature family, and confusion-matrix cohort (`FP`, `TP`, `FN`, `TN`). This means every AE-FP-DIAG CV cohort row had a matching CV/training feature row by `permno/year`.

The coverage evidence is in:

`03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_cv_cohort_join_coverage.csv`

## Metrics

For each track, cohort feature set, threshold, source feature family, and numeric feature, the contrast table reports:

- FP and TP counts.
- FP and TP mean and median.
- standardized mean difference, FP minus TP.
- mean rank-percentile gap, FP minus TP.
- missingness gap, FP minus TP.
- distributional overlap, computed as `1 - two-sample KS distance`.

The full contrast table contains 23,440 feature contrast rows.

## Top Matched-Family Separators

The strongest matched model-family separator in each CV threshold slice is:

| track | cohort feature set | threshold | top feature | group | FP | TP | SMD FP-TP | rank gap | KS overlap |
|---|---|---|---|---|---:|---:|---:|---:|---:|
| dynamic_csi | raw | fpr1 | `roll_min_5y_cash_pct_act` | fundamental | 690 | 286 | 0.254 | 0.072 | 0.857 |
| dynamic_csi | raw | fpr3 | `hy_spread` | macro | 2,073 | 731 | 0.324 | 0.070 | 0.866 |
| dynamic_csi | raw | fpr5 | `hy_spread` | macro | 3,446 | 1,065 | 0.332 | 0.078 | 0.857 |
| dynamic_csi | raw | youden | `max_dd_12m` | other | 18,265 | 2,682 | 0.371 | 0.094 | 0.859 |
| dynamic_csi | raw_plus_latent | fpr1 | `expvol_altman_z` | market_raw | 690 | 306 | -0.272 | -0.050 | 0.873 |
| dynamic_csi | raw_plus_latent | fpr3 | `interact_ret_vix` | macro | 2,059 | 773 | -0.194 | -0.053 | 0.902 |
| dynamic_csi | raw_plus_latent | fpr5 | `hy_spread` | macro | 3,453 | 1,117 | 0.280 | 0.063 | 0.884 |
| dynamic_csi | raw_plus_latent | youden | `max_dd_12m` | other | 18,568 | 2,717 | 0.332 | 0.085 | 0.880 |
| permanent_csi | raw | fpr1 | `vol_12m` | market_raw | 697 | 270 | 0.257 | 0.071 | 0.886 |
| permanent_csi | raw | fpr3 | `hy_spread` | macro | 2,092 | 641 | 0.294 | 0.074 | 0.870 |
| permanent_csi | raw | fpr5 | `hy_spread` | macro | 3,482 | 909 | 0.299 | 0.079 | 0.865 |
| permanent_csi | raw | youden | `lifetime_years` | other | 17,473 | 2,127 | 0.329 | 0.094 | 0.854 |
| permanent_csi | raw_plus_latent | fpr1 | `lifetime_years` | other | 696 | 294 | 0.282 | 0.079 | 0.872 |
| permanent_csi | raw_plus_latent | fpr3 | `hy_spread` | macro | 2,092 | 634 | 0.298 | 0.073 | 0.886 |
| permanent_csi | raw_plus_latent | fpr5 | `hy_spread` | macro | 3,478 | 905 | 0.321 | 0.083 | 0.870 |
| permanent_csi | raw_plus_latent | youden | `max_dd_12m` | other | 18,639 | 2,163 | 0.376 | 0.095 | 0.860 |

## Interpretation

The strongest matched-family FP-vs-TP differences are moderate, not large. Absolute SMDs generally peak around 0.19-0.38 depending on track, feature set, and threshold.

Across both temporary and permanent CSI, false positives tend to separate from true positives on market stress/size and macro-credit variables more than on a single stable accounting variable. Common separators include `hy_spread`, drawdown variables such as `max_dd_12m`, volatility variables such as `vol_12m`, market-value history variables, and firm-age/scale variables such as `lifetime_years`.

The latent-only component evidence is weaker than the raw/raw-plus-latent matched-family evidence in most threshold slices. The strongest latent component contrasts typically involve individual `z*` dimensions or `vae_recon_error`, but those are component profiles rather than standalone AE-FP-DIAG latent-model FP/TP evidence.

No causal claim is supported by this ticket. The evidence shows CV-only associations between observed feature values and FP-vs-TP cohort membership under existing AE-FP-DIAG model/threshold definitions.

## Limitations

- AE-FP-DIAG did not provide standalone CV FP/TP cohort labels for `fund` or `latent_raw`.
- The script compares numeric feature columns only and excludes obvious identifiers, labels, split markers, and event metadata.
- The source feature matrix key export records `track`, `feature_family`, `split_source`, `permno`, and `year`; the wide row-level feature values are used to compute contrasts but are not duplicated into committed artifacts.
- All generated CSV outputs under `03_Data_Output/**` are local analysis artifacts and are excluded from commit scope by ticket policy.
