# AE-FP-FEATURE-DEEPDIVE-001 Feature Evidence Availability Report

## Scope

Ticket `AE-FP-FEATURE-DEEPDIVE-001` asks whether CV-only row-level feature
matrices keyed by `permno` and `year` are available for FP-vs-TP analysis, and
if not, what minimal data-production work is required. This report inventories
existing evidence only. It does not produce data, edit code, edit presentation
files, or read protected input paths.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\multi-master-dispatch.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\model-output-interpretation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\clean-commit\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\shared-orchestration-loop.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\apply-to-project.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/envelope.yaml`
- `epics/AE-FP-FEATURE-DEEPDIVE/tickets/AE-FP-FEATURE-DEEPDIVE-001.yaml`

All required AEGIS materials listed in the assignment were found. No files under
`C:\Users\Tristan Leiter\Documents\aegis-core` were edited.

## Evidence Scanned

The worker inspected only permitted evidence under `03_Data_Output/**` and
`05_Documentation/09_Epics/**`.

Primary files and directories checked:

- `03_Data_Output/8_FalsePositiveDiagnostics/*`
- `03_Data_Output/6_ModelSuite/**`
- `03_Data_Output/3_Modelling_Results/Necessary/**`
- `03_Data_Output/7_IndexConstructionValidation/**`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/*`
- `05_Documentation/09_Epics/AE-PANEL_Labelled_Firm_Year_Panel/*`

Mechanical inventory checks:

- Scanned 357 parquet files under `03_Data_Output/**`.
- Among parquet files with both `permno` and `year`, the only files with more
  than key/label/score columns were AE-FP-DIAG cohort assignment files.
- Scanned CSV headers under `03_Data_Output/**`; only two CSV files had both
  `permno` and `year`, and both were AE-FP-DIAG identifier exports with score
  and cohort columns only.
- Confirmed the current AE-FP-DIAG report already recorded the same blocker:
  row-level raw, fundamental, latent, and combined feature matrices were not
  found in allowed evidence.

## Artifact Inventory

| Artifact family | Representative paths | Keyed by `permno/year` | Split scope | Row-level feature values? | Status |
|---|---|---:|---|---:|---|
| AE-FP-DIAG CV cohorts | `03_Data_Output/8_FalsePositiveDiagnostics/temporary_csi_cv_cohorts.parquet`; `permanent_csi_cv_cohorts.parquet` | Yes, plus `fold_id`, `track`, `feature_set`, `threshold_method` | CV only via `split_source = cv` | No | Join anchor available |
| AE-FP-DIAG FP/TP identifiers | `temporary_csi_cv_fp_tp_identifiers.csv`; `permanent_csi_cv_fp_tp_identifiers.csv` | Yes, plus `fold_id`, `track`, `feature_set`, `threshold_method`, `cohort` | CV only | No | Identifier export available |
| ModelSuite CV predictions | `03_Data_Output/6_ModelSuite/{raw,fund,latent_raw,raw_plus_latent}/{temporary_csi,permanent_csi}/ag_cv_results.parquet` | Yes, plus `fold_id` | CV only | No | Scores/labels only |
| ModelSuite test/OOS predictions | `ag_preds_test*.parquet`, `ag_preds_oos*.parquet` under ModelSuite and validation output folders | Yes | Test/OOS | No | Not usable for this ticket because they are not CV-only |
| Historical canonical model predictions | `03_Data_Output/3_Modelling_Results/Necessary/{temporary_csi,permanent_csi}/AutoGluon/*/ag_cv_results.parquet` | Yes, plus `fold_id` | CV only | No | Scores/labels only; also different row count from current ModelSuite |
| Feature importance summaries | `03_Data_Output/3_Modelling_Results/Necessary/shared/feature_importance/*/ag_feature_importance.csv` | No | Model-level aggregate | No | Useful context only, not row-level FP/TP evidence |
| Predictor metadata and feature names | `03_Data_Output/3_Modelling_Results/Necessary/shared/settings/*predictor_info_compact.json` | No | Model metadata | No | Feature names only |
| Descriptive and robustness summaries | `03_Data_Output/1_Descriptive_Statistics/**`; `03_Data_Output/2_Robustness_Checks/**` | Generally no row key, often aggregate | Mixed full/CV/test/OOS depending file | No | Not joinable to FP/TP cohorts |

## Join And Leakage Assessment

The CV cohort files are safe join anchors because they carry:

- `split_source = cv`
- `fold_id`
- `permno`
- `year`
- `track`
- `feature_set`
- `threshold_method`
- `cohort`

A valid feature matrix for FP-vs-TP analysis must be joined to these cohorts on
at least `permno`, `year`, and the relevant model/feature-set context, with
`fold_id` preserved when fold-specific feature exports are produced. The join
must use only rows whose source split is CV or whose construction is independent
of test/OOS outcomes.

No available artifact satisfies that requirement today. The available keyed CV
files contain `y` and `p_csi` only, so joining them would reproduce prediction
profile analysis, not feature separability. The available feature-importance and
predictor metadata files contain feature names or model-level importances, not
row-level values. Test/OOS prediction files are explicitly excluded because using
them to explain CV FP/TP cohorts would mix split evidence and create leakage
risk.

## Conclusion

No valid CV-only row-level feature matrix keyed by `permno/year` exists in the
permitted evidence reviewed for this ticket.

The next FP-vs-TP feature-separability ticket is blocked until an in-scope data
production ticket exports row-level feature values for the CV rows. The blocker
is evidence availability, not an analytical limitation of the cohort keys.

## Minimal Data-Production Ticket To Unblock Analysis

Proposed follow-up ticket:

```yaml
ticket_id: AE-FP-FEATURE-DEEPDIVE-002A
goal: "Produce CV-only row-level feature matrices keyed by permno/year/fold_id for FP-vs-TP feature separability."
allowed_areas:
  - "03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/**"
  - "05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/**"
  - "epics/AE-FP-FEATURE-DEEPDIVE/**"
may_read:
  - "03_Data_Output/8_FalsePositiveDiagnostics/**"
  - "03_Data_Output/6_ModelSuite/**"
  - "03_Data_Output/3_Modelling_Results/**"
  - "02_Data_Input/** or 02_Data/Features/** only if explicitly approved by planner/human"
must_not_touch:
  - "01_Code/** unless this ticket is explicitly expanded to add a reproducible exporter"
  - "06_Presentations/**"
  - "07_CloudComputing/**"
requirements:
  - "Export one CV-only matrix per feature family and track: raw, fund, latent_raw, raw_plus_latent for temporary_csi and permanent_csi where available."
  - "Each row must include track, feature_set, fold_id, permno, year, y, split_source, and feature columns."
  - "Prove row counts and key coverage against AE-FP-DIAG CV cohort anchors."
  - "Prove no test/OOS feature, label, prediction, threshold-selection, or outcome rows are included."
  - "Write a source manifest with input paths, row counts, join keys, split filters, and leakage guard checks."
acceptance_criteria:
  - "At least the primary raw_plus_latent and raw comparator CV matrices exist for both CSI tracks, or precise source blockers are documented."
  - "Every exported matrix is uniquely keyed by track/feature_set/fold_id/permno/year."
  - "Validation checks show split_source=cv only and zero test/OOS rows used."
  - "A downstream FP-vs-TP separability ticket can join matrices to AE-FP-DIAG cohorts without using test/OOS evidence."
verification_commands:
  - "git status --short"
  - "git diff --name-only"
```

This ticket is intentionally not executed here because `AE-FP-FEATURE-DEEPDIVE-001`
is scoped to inventory and report only.

## Worker Completion Report

status: completed

summary: Internal model-interpreter worker inventoried the available CV cohort,
prediction, metadata, and feature-importance artifacts; confirmed that joinable
CV keys exist only on cohort/prediction score files; and documented that no
valid CV-only row-level feature-value matrix is currently available for
FP-vs-TP feature separability.

artifacts:

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001_Feature_Evidence_Availability_Report.md`

findings:

- Blocking evidence gap for downstream separability analysis: row-level feature
  values keyed by `permno/year/fold_id` are missing from reviewed allowed
  evidence.
- No test/OOS rows were joined or used for this inventory.

next_recommended_role: validator

changed_files:

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001_Feature_Evidence_Availability_Report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

verification:

- `git status --short`: showed only the in-scope ledger modification plus
  known unrelated dirty presentation/cloud-validation entries; this ignored
  documentation report requires forced staging for commit inclusion.
- `git diff --name-only`: showed only the in-scope ledger among tracked files
  plus known unrelated presentation files; no data-output, code, or
  presentation file was modified by this ticket.

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Adds a scoped evidence-availability report and carries forward
  the precise data-production blocker without producing data or changing model,
  presentation, or output artifacts.
- layer_touched: discipline
- layer_separation_preserved: true

## Validator Completion Report

status: completed

summary: Internal DS validator approved the inventory report after checking the
ticket envelope, changed-path scope, CV/test/OOS split hygiene, and the
follow-up blocker. The validator did not edit implementation artifacts and did
not self-approve as the worker.

artifacts:

- `05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-001_Feature_Evidence_Availability_Report.md`
- `epics/AE-FP-FEATURE-DEEPDIVE/ledger.md`

findings:

- Approved: report documents that CV cohorts and predictions are keyed by
  `permno/year/fold_id` but contain scores/labels rather than row-level feature
  values.
- Approved: report excludes test/OOS prediction files from the proposed join
  path and documents leakage risk explicitly.
- Approved: no `must_not_touch` path was modified by ticket-owned work.
- Residual risk: the documentation report is ignored by `.gitignore`, so commit
  preparation must force-add it while continuing to avoid unrelated dirty files.

next_recommended_role: master
