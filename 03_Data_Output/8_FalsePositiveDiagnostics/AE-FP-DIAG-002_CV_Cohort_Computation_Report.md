# AE-FP-DIAG-002 CV False-Positive Cohort Computation Report

## Scope

Computed CV-only FP/TP/FN/TN cohorts for temporary and permanent CSI using only out-of-fold CV prediction rows and CV-derived thresholds. No test, OOS, presentation, cloud validation, input-data, or code paths were read for cohort construction.

## Selected Configurations

- `dynamic_csi` / `raw_plus_latent`: priority-1 temporary main non-raw model.
- `dynamic_csi` / `raw`: priority-1 temporary raw comparator.
- `permanent_csi` / `raw_plus_latent`: priority-1 permanent primary non-raw challenger.
- `permanent_csi` / `raw`: priority-1 permanent conservative/reporting baseline.

Threshold methods: `fpr3`, `fpr1`, `fpr5`, and `youden`, all from CV threshold files.

## Outputs

- `temporary_csi_cv_cohorts.parquet`: all temporary CSI CV rows labelled FP/TP/FN/TN for selected models and thresholds.
- `permanent_csi_cv_cohorts.parquet`: all permanent CSI CV rows labelled FP/TP/FN/TN for selected models and thresholds.
- `temporary_csi_cv_fp_tp_identifiers.csv` and `permanent_csi_cv_fp_tp_identifiers.csv`: firm-year identifiers for follow-up FP/TP analysis.
- `cv_cohort_counts.csv`: confusion counts, prevalence, flag rate, precision, recall, FPR, and specificity.
- `cv_score_distributions.csv`: cohort-level score distribution summaries.
- `AE-FP-DIAG-002_source_manifest.csv`: source paths and row counts.
- `AE-FP-DIAG-002_validation_checks.csv`: reconciliation and leakage guard evidence.

## Validation Summary

- Reconciliation status: PASS.
- Every output row carries `split_source = cv`.
- Test/OOS rows used: 0.
- Cohort counts reconcile to CV prediction row counts, positive/negative label counts, and threshold-file flagged counts for every selected track/model/threshold.
- Threshold comparison uses `p_csi >= threshold - 1e-12` only to reproduce persisted CV threshold boundary rows where CSV threshold precision and parquet score precision differ at machine scale.

## Worker Completion Report

status: completed

summary: Created CV-only FP/TP/FN/TN cohort outputs, summaries, source manifest, and validation checks for temporary and permanent CSI selected main configurations.

artifacts: `03_Data_Output/8_FalsePositiveDiagnostics/*`

findings: Row-level feature matrices remain a handoff item for AE-FP-DIAG-003; this ticket produced firm-year cohort identifiers but did not perform feature comparisons.

next_recommended_role: validator

verification: computation asserted required CV columns, read only `ag_cv_results.parquet` prediction sources and CV threshold files, and produced reconciliation checks with no test/OOS rows used.
