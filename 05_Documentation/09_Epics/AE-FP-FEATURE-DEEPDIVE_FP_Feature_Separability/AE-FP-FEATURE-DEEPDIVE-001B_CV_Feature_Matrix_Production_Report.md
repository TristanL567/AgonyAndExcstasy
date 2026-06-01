# AE-FP-FEATURE-DEEPDIVE-001B CV Feature Matrix Production Report

## Scope

Ticket `AE-FP-FEATURE-DEEPDIVE-001B` was assigned to produce or expose
CV/training-only row-level feature evidence keyed by `permno/year`, without
editing production code, presentation files, model outputs, or protected input
paths.

The worker used only allowed evidence under `03_Data_Output/**` and
`05_Documentation/09_Epics/**`. No source under `01_Code/**`, `02_Data_Input/**`,
`06_Presentations/**`, or `07_CloudComputing/**` was edited or read as a source
for exported feature rows.

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
- `epics/AE-FP-FEATURE-DEEPDIVE/tickets/AE-FP-FEATURE-DEEPDIVE-001B.yaml`

All required AEGIS materials listed in the assignment were found. No files under
`C:\Users\Tristan Leiter\Documents\aegis-core` were edited.

## Produced Artifacts

The ticket produced one limited row-level training feature extract from existing
allowed evidence:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/robust_recovery_training_raw_fundamental_features.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_source_manifest.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_feature_family_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_join_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_validation_checks.csv`

The extract is sourced from:

`03_Data_Output/2_Robustness_Checks/Necessary/shared/robust_recovery_classifier.rds:train_data`

Only the `train_data` object was exported. The paired `test_data` object in the
same source RDS was intentionally not exported.

## Extract Schema

The exposed extract has:

- rows: `911`
- columns: `18`
- key columns: `permno`, `year`
- duplicate `permno/year` keys: `0`
- split marker: `split_source = training_only`
- source track marker: `track = shared_robustness`
- feature-value columns: `altman_z2`, `leverage`, `ocf_margin`,
  `roll_min_3y_earn_yld`, `roll_min_3y_roic`, `peak_drop_log_mkvalt`,
  `acct_mom_roa`, `roll_sd_5y_earn_yld`, `yoy_leverage`

`p_csi` and `y_zombie` are retained as source metadata/label columns from the
robustness classifier source, not as model-suite input feature values.

## Family Coverage

| Feature family | Status | Evidence |
|---|---|---|
| Auxiliary raw/fundamental training extract | Produced limited extract | 911 training rows keyed by `permno/year`; 9 feature-value columns. |
| Raw model-suite CV matrix | Blocked: missing source | Allowed ModelSuite and modelling parquet files contain only `fold_id`, `permno`, `year`, `y`, `p_csi`. |
| Fundamental model-suite CV matrix | Blocked: missing source | Feature names/importances exist, but row-level feature values are not present in allowed evidence. |
| Latent model-suite CV matrix | Blocked: missing source | Latent feature values are not exposed in allowed output evidence. |
| Combined raw plus latent model-suite CV matrix | Blocked: missing source | Combined raw plus latent row-level values are not exposed in allowed output evidence. |

## Joinability To AE-FP-DIAG Cohorts

Joinability was tested against AE-FP-DIAG CV FP/TP cohort keys using
`permno/year`.

| Cohort track | FP/TP key rows | Matched feature rows | Coverage |
|---|---:|---:|---:|
| `dynamic_csi` | 58,921 | 2,963 | 5.0288% |
| `permanent_csi` | 56,592 | 2,918 | 5.1562% |

Both AE-FP-DIAG cohort sources were confirmed as CV-only via `split_source = cv`.
No ModelSuite test/OOS prediction files were read into the export, and no
robustness `test_data` rows were exported.

## Leakage Assessment

The produced extract is training-only and does not contain test/OOS rows from
the inspected allowed evidence. It is therefore safe as a limited auxiliary
training extract.

It is not safe to treat this extract as the feature basis for the full FP-vs-TP
model-suite separability analysis because:

- it lacks `fold_id`;
- it is not tied to `raw`, `fund`, `latent_raw`, or `raw_plus_latent` model-suite
  feature-set construction;
- it has only about 5% coverage against FP/TP CV cohort keys;
- it does not include latent or combined raw-plus-latent feature values.

## Downstream State

`AE-FP-FEATURE-DEEPDIVE-002` remains blocked for the primary objective:
identifying which model-suite raw/fundamental/latent/combined features separate
false positives from true positives without test/OOS leakage.

The narrower blocker is now precise: existing allowed evidence contains one
small auxiliary training feature extract, but no full model-suite CV feature
matrix keyed by `track`, `feature_set`, `fold_id`, `permno`, and `year`.

The next remediation should either:

- explicitly approve reading the protected feature source referenced by model
  metadata, or
- create a narrowly scoped exporter ticket that may read the feature source and
  write CV-only matrices under
  `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/`.

## Worker Completion Report

status: completed

summary: Internal model-interpreter/data worker exposed the only permitted
row-level training feature extract found in existing allowed evidence, wrote
source/coverage/validation artifacts, and documented that full model-suite CV
feature matrices remain unavailable.

artifacts:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/robust_recovery_training_raw_fundamental_features.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_source_manifest.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_feature_family_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_join_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001B_CV_Feature_Matrix_Production_Report.md`

findings:

- Produced only a limited auxiliary training extract; no full raw, fundamental,
  latent, or combined model-suite CV feature matrix exists in allowed evidence.
- No test/OOS rows were exported.
- `AE-FP-FEATURE-DEEPDIVE-002` remains blocked pending approved access to or
  production of full model-suite CV feature values.

next_recommended_role: validator

changed_files:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/robust_recovery_training_raw_fundamental_features.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_source_manifest.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_feature_family_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_join_coverage.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001B_CV_Feature_Matrix_Production_Report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

verification:

- `git status --short`: showed the in-scope ledger modification plus ignored
  in-scope output/documentation artifacts; known unrelated presentation and
  cloud-validation dirty files remain unstaged and untouched.
- `git diff --name-only`: showed the in-scope ledger among tracked files plus
  known unrelated presentation files; ignored in-scope output/documentation
  artifacts require forced staging for commit inclusion.
- Feature extract validation: passed key, uniqueness, split-source, no-test/OOS,
  and join-attempt checks in `AE-FP-FEATURE-DEEPDIVE-001B_validation_checks.csv`.

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Exposes the only allowed row-level training feature extract,
  documents coverage against AE-FP-DIAG cohorts, and narrows the remaining
  blocker for full model-suite CV feature matrices.
- layer_touched: discipline
- layer_separation_preserved: true

## Validator Completion Report

status: completed

summary: Internal DS validator approved the ticket output as a partial
remediation: the exposed extract is row-level, training-only, keyed by
`permno/year`, and validated against AE-FP-DIAG CV cohorts; the report clearly
states that full model-suite CV raw/fundamental/latent/combined matrices remain
missing.

artifacts:

- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_validation_checks.csv`
- `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-001B_join_coverage.csv`
- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001B_CV_Feature_Matrix_Production_Report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

findings:

- Approved: exposed extract is unique on `permno/year` and marked
  `split_source = training_only`.
- Approved: no ModelSuite test/OOS rows and no robustness `test_data` rows were
  exported.
- Approved: joinability to both AE-FP-DIAG CV cohort files was tested and the
  low coverage is documented.
- Approved with residual blocker: `AE-FP-FEATURE-DEEPDIVE-002` remains blocked
  for full feature separability until model-suite CV feature values are produced
  or approved source access is granted.

next_recommended_role: master
