# AE-FP-FEATURE-DEEPDIVE-002R Worker Completion Report

## status

completed, pending independent validator approval.

## summary

The worker rebuilt CV/training-only row-level feature evidence from approved local model input artifacts, joined those rows to existing AE-FP-DIAG CV cohorts, computed FP-vs-TP feature separability metrics for temporary and permanent CSI, and documented the matched-family and auxiliary/component feature-family limitations.

## artifacts

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_FP_TP_Feature_Separability_Report.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_validation_report.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_build_feature_separability.R`
- `epics/AE-FP-FEATURE-DEEPDIVE/tickets/AE-FP-FEATURE-DEEPDIVE-002R.yaml`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`
- Local ignored outputs under `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R*`

## findings

- Row-level feature sources were available for `raw`, `fund`, `latent_raw`, and `raw_plus_latent` for both CSI tracks.
- Existing AE-FP-DIAG CV cohort labels are available for `raw` and `raw_plus_latent`; `fund` and standalone `latent_raw` were reported as auxiliary/component profiles, not standalone matched cohort evidence.
- All feature discovery rows were CV/training-only. RDS sources were filtered with `splits.rds` `oot$train_idx`; parquet sources were filtered with `split == train`; AE-FP-DIAG cohort rows required `split_source = cv`.
- No causal claim is supported or made by the analysis.
- Generated `03_Data_Output/**` files are local analysis artifacts and must remain unstaged.

## next_recommended_role

validator

## changed_files

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_FP_TP_Feature_Separability_Report.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_validation_report.md`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_build_feature_separability.R`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_worker_completion_report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/tickets/AE-FP-FEATURE-DEEPDIVE-002R.yaml`
- `epics/AE-FP-FEATURE-DEEPDIVE/envelope.yaml`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`
- Local ignored `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R*` outputs

## verification

- `git status --short --branch` confirmed the branch was `Development`.
- `Rscript 05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_build_feature_separability.R` completed successfully.
- `AE-FP-FEATURE-DEEPDIVE-002R_validation_checks.csv` reported pass for branch, CV-only cohorts, training-only feature sources, feature-key uniqueness, no test/OOS rows used, contrast creation, and FP/TP/FN/TN coverage.
- `git diff --name-only --cached` returned empty; no files were staged.
- `git status --short --ignored` showed generated `03_Data_Output/**` files as ignored/local and known unrelated dirty paths under `06_Presentations/**` and `07_CloudComputing/**` left untouched.

## human_readability

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Added ticket-scoped reproducibility, analytical, validation, process, and ledger evidence for the CV-only FP/TP feature separability rebuild while keeping generated data local and unstaged.
- layer_touched: discipline
- layer_separation_preserved: true
