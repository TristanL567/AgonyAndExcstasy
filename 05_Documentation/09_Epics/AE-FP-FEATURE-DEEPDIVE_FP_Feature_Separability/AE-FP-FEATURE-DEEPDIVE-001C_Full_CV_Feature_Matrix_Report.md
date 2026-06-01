# AE-FP-FEATURE-DEEPDIVE-001C Full CV Feature Matrix Report

## Scope

Ticket `AE-FP-FEATURE-DEEPDIVE-001C` attempted to produce full CV-only
model-suite feature matrices for FP-vs-TP separability while keeping generated
data local and ignored by git. The ticket explicitly forbids staging or
committing any `03_Data_Output/**` files.

The worker inspected only allowed evidence under `03_Data_Output/**` and
`05_Documentation/09_Epics/**`. It did not read or edit `01_Code/**`,
`02_Data_Input/**`, `06_Presentations/**`, or `07_CloudComputing/**`.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\multi-master-dispatch.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\clean-commit\SKILL.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/envelope.yaml`
- `epics/AE-FP-FEATURE-DEEPDIVE/tickets/AE-FP-FEATURE-DEEPDIVE-001C.yaml`

All required AEGIS materials listed in the assignment were found. No files under
`C:\Users\Tristan Leiter\Documents\aegis-core` were edited.

## Local Generated Artifacts

These artifacts were written under the allowed data-output area and intentionally
remain local/ignored. They must not be staged or committed for this ticket:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_source_audit.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_join_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_validation_summary.csv`

No new full model-suite feature matrix file was produced because no inspected
allowed source contained row-level feature values.

## Source Audit Result

The local audit inspected the current model-suite CV prediction parquet files
and XGBoost RDS model objects for raw, fundamental, latent, and raw-plus-latent
families across temporary and permanent CSI.

| Candidate class | Count | Decision |
|---|---:|---|
| ModelSuite CV prediction parquet | 8 | Rejected: score-only files with `fold_id`, `permno`, `year`, `y`, `p_csi`; no feature-value columns. |
| XGBoost RDS model object | 8 | Rejected: model objects with feature names, importances, predictions, and metrics; no row-level feature-value matrix. |
| 001B auxiliary training extract | 1 | Available but limited; not a full model-suite matrix and only about 5% FP/TP cohort coverage. |

The raw-preservation archive under `03_Data_Output/7_IndexConstructionValidation`
was also checked by file listing. It contains raw prediction/index/threshold
artifacts, not row-level input feature matrices.

## Matrix Paths And Coverage

Full matrix paths:

- raw model-suite CV matrix: not produced, missing source
- fundamental model-suite CV matrix: not produced, missing source
- latent model-suite CV matrix: not produced, missing source
- raw-plus-latent model-suite CV matrix: not produced, missing source

The only local matrix-like artifact remains the limited extract from 001B:

`03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/robust_recovery_training_raw_fundamental_features.csv`

Join coverage for that limited extract:

| Cohort track | FP/TP key rows | Matched feature rows | Coverage |
|---|---:|---:|---:|
| `dynamic_csi` | 58,921 | 2,963 | 5.0288% |
| `permanent_csi` | 56,592 | 2,918 | 5.1562% |

This extract is insufficient for full FP-vs-TP model-suite separability because
it lacks `fold_id`, model-suite feature-family identity, latent values, combined
raw-plus-latent values, and broad cohort coverage.

## Validation Summary

Local validation summary:

- full raw matrix: blocked, missing row-level source
- full fundamental matrix: blocked, missing row-level source
- full latent matrix: blocked, missing row-level source
- full raw-plus-latent matrix: blocked, missing row-level source
- test/OOS rows used for generation: `0`
- AE-FP-DIAG temporary and permanent cohort files: all rows have
  `split_source = cv`
- 001C git policy: no `03_Data_Output/**` files are staged or committed

## Downstream State

`AE-FP-FEATURE-DEEPDIVE-002` remains blocked. The actionable blocker is now:

Full model-suite row-level feature values are not present in the allowed local
output evidence. The next ticket must either receive explicit approval to read
the protected prepared-feature source or receive a producer scope that can
reconstruct/export the CV matrices from the original feature-building inputs.

Minimum required output for an unblocking producer remains one local matrix per
available model-suite family and track, keyed by:

`track`, `feature_set`, `fold_id`, `permno`, `year`

Each matrix must include only CV/training rows and must exclude test/OOS rows.

## Worker Completion Report

status: completed

summary: Internal model-interpreter/data worker inspected allowed model-suite,
XGBoost, archive, and prior local feature-extract evidence. It generated local
source-audit, join-coverage, and validation-summary files under
`03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/`, but did not
produce full model-suite feature matrices because the required row-level feature
values are absent from allowed evidence.

artifacts:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_source_audit.csv` (local, ignored, not committed)
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_join_coverage.csv` (local, ignored, not committed)
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_validation_summary.csv` (local, ignored, not committed)
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001C_Full_CV_Feature_Matrix_Report.md`

findings:

- Full raw, fundamental, latent, and raw-plus-latent model-suite CV matrices
  are blocked by missing row-level feature sources in allowed evidence.
- No test/OOS rows were used to create full matrices; no full matrices were
  created.
- No `03_Data_Output/**` files may be committed under this ticket.

next_recommended_role: validator

changed_files:

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001C_Full_CV_Feature_Matrix_Report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

local_uncommitted_outputs:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_source_audit.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_join_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_validation_summary.csv`

verification:

- `git status --short`: showed only the in-scope ledger among tracked ticket
  changes plus known unrelated presentation/cloud-validation dirty entries; the
  001C documentation report and local `03_Data_Output` audit files are ignored.
- `git diff --name-only`: showed the in-scope ledger among tracked ticket
  changes plus known unrelated presentation files. No `03_Data_Output/**` file
  is staged or committed by this ticket.
- Local validation summary written to
  `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_validation_summary.csv`.

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Documents the failed full-matrix production attempt, records
  local generated audit paths, and narrows the remaining blocker to missing
  allowed row-level model-suite feature values.
- layer_touched: discipline
- layer_separation_preserved: true

## Validator Completion Report

status: completed

summary: Internal DS validator approved the 001C output as a precise technical
blocker report. The validator confirmed that the local audit did not use
test/OOS rows to construct matrices, no full matrices were fabricated, and the
ticket's no-`03_Data_Output` commit policy is preserved.

artifacts:

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001C_Full_CV_Feature_Matrix_Report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001C_validation_summary.csv` (local only, ignored, not committed)

findings:

- Approved: source audit proves available model-suite CV parquet files are
  score-only and XGBoost RDS files do not contain row-level feature matrices.
- Approved: local validation records zero test/OOS rows used for matrix
  generation.
- Approved: no generated `03_Data_Output/**` files are to be staged or
  committed for this ticket.
- Residual blocker: `AE-FP-FEATURE-DEEPDIVE-002` remains blocked until approved
  access to prepared feature inputs or a scoped producer can export full CV
  feature matrices.

next_recommended_role: master
