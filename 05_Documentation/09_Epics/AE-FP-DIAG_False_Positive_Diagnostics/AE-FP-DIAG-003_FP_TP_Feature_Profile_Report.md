# AE-FP-DIAG-003 FP vs TP Feature Profile Report

## Scope

This ticket compares CV false-positive and true-positive rows from
AE-FP-DIAG-002 where valid row-level sources are available. It does not read or
join test/OOS labels, outcomes, or feature rows; does not edit slides; and does
not edit protected code, input, presentation, or cloud-validation paths.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\shared-orchestration-loop.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\apply-to-project.md`

## Inputs Used

- `03_Data_Output/8_FalsePositiveDiagnostics/temporary_csi_cv_cohorts.parquet`
- `03_Data_Output/8_FalsePositiveDiagnostics/permanent_csi_cv_cohorts.parquet`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-002_source_manifest.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-001_CV_FP_Diagnostic_Design.md`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-001_source_inventory.csv`

The parquet source scan found no row-level engineered feature matrix with
`permno` and `year` plus feature columns under the ticket-allowed evidence
paths. The only `permno`/`year` parquet files found under `03_Data_Output/**`
were CV/test/OOS prediction files and the AE-FP-DIAG cohort files. VAE config
metadata references row-level feature parquet paths under protected
`02_Data/Features/**`, which this ticket is not allowed to read.

## Output Artifacts

- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-003_feature_source_inventory.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_cv_fp_tp_profile_contrasts.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_top_available_profile_differentiators.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_validation_checks.csv`

## Feature-Family Availability

| family | status | result |
|---|---|---|
| Raw input features | Blocked: missing row-level source | No FP-vs-TP raw input-feature distribution computed. |
| Fundamental input features | Blocked: missing row-level source | No FP-vs-TP fundamental input-feature distribution computed. |
| Latent input features | Blocked: missing row-level source | No FP-vs-TP latent input-feature distribution computed. |
| Combined raw plus latent input features | Blocked: missing row-level source | No FP-vs-TP combined input-feature distribution computed. |
| CV cohort score and key metadata | Available | Computed FP-vs-TP contrasts for `p_csi`, `year`, and `fold_id`. |

The available computed contrasts are not claimed as model input-feature
contrasts. They are CV-only cohort profile contrasts that validate the cohort
shape and provide a limited, non-leaking diagnostic profile while the required
row-level feature matrices remain unavailable.

## Temporary CSI Findings

Among available CV-only profile fields, the largest FP-vs-TP separation is the
out-of-fold score `p_csi`. For the `raw_plus_latent` Youden threshold, temporary
CSI false positives have lower mean scores than true positives
(`mean_fp = 0.119451`, `mean_tp = 0.163775`, `SMD = -0.644105`). The raw Youden
configuration shows the same direction (`SMD = -0.607290`).

At stricter FPR thresholds, `p_csi` remains the leading available profile
differentiator, with smaller absolute SMDs. Year also separates some FP/TP
groups modestly; for raw FPR3, false positives are earlier on average than true
positives (`mean_fp = 2006.653160`, `mean_tp = 2007.459644`,
`SMD = -0.193793`). `fold_id` has no material missingness and only weak
separation.

No temporary CSI raw, fundamental, latent, or combined input-feature group can
be ranked yet because no row-level CV feature matrix was available to join to
the AE-FP-DIAG-002 cohort keys.

## Permanent CSI Findings

Among available CV-only profile fields, `p_csi` is again the leading
differentiator. For the `raw_plus_latent` Youden threshold, permanent CSI false
positives have lower mean scores than true positives (`mean_fp = 0.100655`,
`mean_tp = 0.144158`, `SMD = -0.711183`). The raw Youden configuration shows
the same direction (`SMD = -0.669140`).

For FPR5 and FPR3 thresholds, `p_csi` remains the strongest available
differentiator. Year has a smaller separation; for `raw_plus_latent` FPR3,
false positives are earlier on average than true positives
(`mean_fp = 2006.577916`, `mean_tp = 2007.329653`, `SMD = -0.183463`).

No permanent CSI raw, fundamental, latent, or combined input-feature group can
be ranked yet because no row-level CV feature matrix was available to join to
the AE-FP-DIAG-002 cohort keys.

## Validation Summary

The validation table records:

- both AE-FP-DIAG-002 cohort sources carry only `split_source = cv`;
- forbidden test/OOS feature, label, outcome, and prediction rows used: `0`;
- FP, TP, FN, and TN cohort values are present in both track files;
- input-feature contrasts are blocked by missing row-level feature sources, not
  by a computation failure after a valid join.

## Worker Completion Report

status: completed_with_blocker

summary: Internal model-interpreter worker inspected the ticket-owned CV cohort
outputs, searched allowed evidence for row-level feature matrices, computed
CV-only available profile contrasts for score/key metadata, and documented that
true raw, fundamental, latent, and combined FP-vs-TP input-feature comparisons
are blocked until row-level CV feature matrices keyed by `permno` and `year`
are made available in allowed evidence.

next_recommended_role: validator

changed_files:

- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-003_FP_TP_Feature_Profile_Report.md`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-003_feature_source_inventory.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_cv_fp_tp_profile_contrasts.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_top_available_profile_differentiators.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/AE-FP-DIAG-003_validation_checks.csv`
- `epics/AE-FP-DIAG/ledger.md`

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- layer_touched: diagnostics
- layer_separation_preserved: true
