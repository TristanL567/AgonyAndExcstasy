# AE-FP-DIAG-001 CV False-Positive Diagnostic Design

## Scope

This planning artifact defines the CV-only false-positive diagnostic design and
source inventory for AE-FP-DIAG. It does not compute false-positive cohorts,
does not create feature comparisons, does not rerun models, and does not edit
slides, code, input data, model output, presentation output, or cloud validation
artifacts.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ticket-planner-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\ml-evaluation\README.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\ml-evaluation\sections\data-split-integrity.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\ml-evaluation\sections\threshold-and-decision-risk.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\references\ml-evaluation\sections\segment-evaluation.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\shared-orchestration-loop.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\apply-to-project.md`

## Read-Only Evidence Inspected

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- `05_Documentation/09_Epics/AE-PRES-JUNE_Final_Presentation_Update/AE-PRES-JUNE-003_Model_Result_Source_Map.md`
- `05_Documentation/09_Epics/AE-PRES-FINAL-REV2_Final_Presentation_Revisions/AE-PRES-FINAL-REV2-006_Feature_Engineering_Groups_Evidence.md`
- `05_Documentation/09_Epics/AE-PRES-FINAL-REV2_Final_Presentation_Revisions/AE-PRES-FINAL-REV2-007_Model_Hyperparameters_Evidence.md`
- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_Model_Suite_Comparison_Report.md`
- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_suite_best_by_track.csv`
- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_suite_metrics_long.csv`
- `03_Data_Output/6_ModelSuite/derived_metrics/complete_threshold_metrics_long.csv`
- `03_Data_Output/6_ModelSuite/raw/derived_metrics/raw_complete_threshold_metrics.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_threshold_family.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/full_grid_manifest.csv`
- Representative `ag_cv_results.parquet`, `ag_preds_*`, `index_thresholds_by_crsp_universe.csv`, and label-count files listed in `AE-FP-DIAG-001_source_inventory.csv`.

## Leakage Guard

Diagnostic discovery for AE-FP-DIAG must use cross-validation/training evidence
only. The diagnostic cohorts must be built from `ag_cv_results.parquet` rows or
their exact CV-equivalent preserved copies. Test, OOS, full-sample, index OOS,
future-period labels, and test/OOS feature rows are explicitly excluded from:

- threshold selection;
- cohort definition;
- feature discovery;
- deciding which features separate false positives from true positives;
- deciding whether false positives were plausibly undetectable.

Test and OOS artifacts may be referenced only as read-only context for existing
deck/source-map traceability, not as evidence for feature discovery or threshold
choice in this epic's diagnostic computation tickets.

## Cohort Definitions

All definitions are row-level and must be keyed by at least `track`,
`feature_set`, `permno`, `year`, `fold_id`, `y`, `p_csi`, `threshold_method`,
and `threshold`.

Use only CV rows:

- False positive: `split == "cv"`, `y == 0`, and `p_csi >= threshold`.
- True positive: `split == "cv"`, `y == 1`, and `p_csi >= threshold`.
- False negative and true negative are out of scope for AE-FP-DIAG-001, though
  later tickets may compute them if explicitly assigned.

The threshold must be a CV-derived operating point already materialized in the
existing model or index evidence. The allowed first-pass threshold methods are:

- `fpr1`: CV FPR <= 1%.
- `fpr3`: CV FPR <= 3%.
- `fpr5`: CV FPR <= 5%.
- `youden`: CV Youden J.

No threshold may be selected because it performs well on test/OOS metrics or
index alpha.

## First-Pass Model And Configuration Scope

The first pass should start with the model/configuration rows already used in
the final deck and index-source maps.

Priority 1:

- Temporary CSI (`dynamic_csi`): `raw_plus_latent` as the main non-raw model,
  with `raw` retained as the benchmark comparator.
- Permanent CSI (`permanent_csi`): `raw_plus_latent` as the primary non-raw
  challenger, with `raw` retained as the conservative/reporting baseline.

Priority 2, only if the first computation ticket has capacity after Priority 1:

- Permanent CSI `latent_raw` as an OOS-robustness sensitivity already discussed
  in existing model-suite evidence, but its diagnostic discovery must still use
  CV rows only.

Priority 3, defer unless explicitly assigned:

- `fund` ablation rows.
- Temporary `latent_raw` ablation rows.
- Sensitivity-grid C/M/T runs.

Within each in-scope `track` and `feature_set`, the first diagnostic table should
use the CV thresholds already present in `index_thresholds_by_crsp_universe.csv`
and/or `complete_threshold_metrics_long.csv`. The deck-visible threshold family
priority is `fpr3` first, then `fpr1`, `fpr5`, and `youden`, because final model
slides emphasize R@FPR3 while index construction keeps the full four-threshold
grid.

## Available Source Summary

Available sources:

- CV/out-of-fold prediction rows exist for `raw`, `fund`, `latent_raw`, and
  `raw_plus_latent` for both temporary and permanent CSI in `03_Data_Output/6_ModelSuite/**`.
- CV prediction parquet schema is sufficient for cohort membership:
  `fold_id`, `permno`, `year`, `y`, and `p_csi`.
- CV threshold tables exist for non-raw model-suite rows in
  `03_Data_Output/6_ModelSuite/derived_metrics/complete_threshold_metrics_long.csv`.
- Raw CV threshold metrics exist in
  `03_Data_Output/6_ModelSuite/raw/derived_metrics/raw_complete_threshold_metrics.csv`
  and in the preserved raw benchmark copy under
  `03_Data_Output/7_IndexConstructionValidation/raw_benchmark/raw_preservation_20260529/raw_threshold_metrics/`.
- Index-construction CV thresholds exist for every final index-suite model and
  track in each model's `index_thresholds_by_crsp_universe.csv`.
- Label-count and split summaries exist in descriptive-statistics outputs with
  CV/test/OOS split labels.
- Existing feature-family documentation and model-suite evidence describe the
  feature sets and transformations at a group level.

Missing or insufficient sources before computation:

- No inspected artifact provides a row-level feature matrix keyed by
  `permno`/`year` for the final feature sets inside the allowed output evidence.
- No inspected artifact provides precomputed FP-vs-TP feature summaries.
- No inspected artifact provides fold-specific feature summaries for only the CV
  false-positive and true-positive rows.
- No inspected artifact maps all final engineered feature names to stable
  display groups in a machine-readable table. Existing docs provide narrative
  feature-family evidence, but a computation ticket will need a deterministic
  feature group map or an explicit fallback grouping rule.
- Some raw prediction evidence is preserved in raw benchmark/archive paths rather
  than in the same current path shape as the non-raw model-suite outputs. Later
  computation should resolve the canonical raw source path before reading.

Recommended remediation for AE-FP-DIAG-002:

- First resolve canonical CV prediction source paths from this inventory.
- Locate the final row-level feature matrix for each in-scope feature set, or
  create a follow-up blocker if it only exists under protected input/code output
  paths not readable or writable by the computation ticket.
- Require the computation ticket to stop before feature comparison if it cannot
  join CV predictions to CV-only feature rows by `permno` and `year` without
  using test/OOS rows.
- Require every output table to carry `split_source = "cv"` or equivalent audit
  metadata.

## Worker Completion Report

status: completed

summary: Created a CV-only false-positive diagnostic design and source
inventory. The design defines FP/TP cohorts using only CV prediction rows and
CV-derived thresholds, names first-pass model/configuration scope, and lists
missing row-level feature artifacts that must be resolved before computation.

artifacts:

- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-001_CV_FP_Diagnostic_Design.md`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-001_source_inventory.csv`

findings:

- Blocking for computation, not for this planning ticket: row-level final feature
  matrices keyed by `permno` and `year` were not found in the inspected output
  evidence.
- The ticket envelope omits several canonical AEGIS ticket-contract fields; the
  dispatch message supplied non-goals and guardrails used for this run.

next_recommended_role: validator

changed_files:

- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-001_CV_FP_Diagnostic_Design.md`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-001_source_inventory.csv`
- `epics/AE-FP-DIAG/ledger.md`

verification:

- Read-only evidence inspection only; no cohorts computed and no protected
  output areas modified.
- `git status --short` and `git diff --name-only` were used as required ticket
  verification commands.
- AEGIS scope firewall passed for the three ticket-owned changed paths using a
  temporary Markdown frontmatter wrapper because the canonical scope tool does
  not parse the YAML ticket envelope directly.
- `git diff --check` passed for the ticket-owned changed paths.

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Adds one planning report and one source inventory, plus ledger
  audit entries for worker and validator routing.
- layer_touched: procedure
- layer_separation_preserved: true
