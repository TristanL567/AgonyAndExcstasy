# AE-PRES-FINAL-REV2-001 XGB Result Visibility Audit

## Status

Completed. Local evidence shows that XGBoost/XGB exists as standalone main-run model diagnostics and as an AutoGluon candidate family, but not as a standalone final index-strategy result in the June deck evidence set. The deck should therefore keep the accepted AG feature-set labels and should not relabel aggregate AutoGluon or index results as XGB-specific results.

## Evidence Reviewed

- Ticket: `epics/AE-PRES-FINAL-REV2/tickets/AE-PRES-FINAL-REV2-001.yaml`
- Epic envelope: `epics/AE-PRES-FINAL-REV2/envelope.yaml`
- June deck source: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- June source map: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- Main standalone XGB diagnostics:
  - `03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/XGBoost/xgb_eval_table.csv`
  - `03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/XGBoost/xgb_eval_table.csv`
- Main AutoGluon evidence:
  - `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_family_winners.csv`
  - `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_Model_Suite_Comparison_Report.md`
  - `03_Data_Output/3_Modelling_Results/Necessary/*/AutoGluon/*/ag_leaderboard.csv`
- Index and sensitivity evidence:
  - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/full_grid_manifest.csv`
  - `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
  - `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_model_summary.csv`
  - `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_model_metric_ranking.csv`

No model, index, or sensitivity scripts were run. No `03_Data_Output/**` files were modified.

## Findings

### Main temporary/permanent runs

Standalone XGB-specific model diagnostics do exist for both response tracks:

- Temporary CSI: `temporary_csi/XGBoost/xgb_eval_table.csv` contains XGB rows for `raw`, `fund`, `raw_plus_latent`, and `latent_raw` across `cv_expanding_window`, `train_insample`, `test`, and `oos`.
- Permanent CSI: `permanent_csi/XGBoost/xgb_eval_table.csv` contains XGB rows for the same four feature sets and splits.

These are model-diagnostic results, not the final AutoGluon ensemble presentation rows and not downstream index-strategy results.

### AutoGluon ensemble/model-family evidence

AutoGluon leaderboards include `XGBoost` as a candidate family where optional-library models were available. However, `AE-MODEL-SUITE-007_model_family_winners.csv` shows the top model for every final feature-set/track run is `WeightedEnsemble_L2` with best family `WeightedEnsemble`.

The June deck's model-result slides are therefore correctly labelled as AG feature-set/ensemble results rather than XGB-only results.

### Final index grid

The final non-raw index grid manifest contains only these model keys:

- `raw`
- `fund`
- `latent_raw`
- `raw_plus_latent`

`best_by_track_index_cost.csv` and the index performance files use those AG feature-set model keys and strategy rows. No `xgb` or `xgboost` model key appears in the final index grid, and no XGB-only strategy row is available to present as a final benchmark-relative result.

### Temporary sensitivity grid

The presentation-ready sensitivity summary represents 27 C/M/T configurations: 24 complete or reused and 3 `blocked_partial`. The metric files have columns for C/M/T, split, AP, AUC, Brier, recall-at-FPR, status, and source file. They do not contain a model-family, model-key, XGB, or AutoGluon candidate dimension.

The 24 completed/reused sensitivity runs are therefore temporary-CSI C/M/T aggregate model/index sensitivity evidence, not XGB-specific sensitivity evidence.

## Deck Action

A concise clarification was added to the model-family note in the June deck source:

> Standalone XGBoost diagnostics exist for the main model runs, but they are not relabelled here because the final index grid has no XGB-only strategy rows.

The source map was updated to point to this audit report for the affected model-family and index-grid rows.

## Completion Report

status: completed

summary: Audited local model, AutoGluon, index, and sensitivity evidence for XGB visibility. Main XGB diagnostics exist, but final deck-visible results are AG ensemble feature-set and index-strategy results, not standalone XGB-only strategy results.

artifacts:

- `05_Documentation/09_Epics/AE-PRES-FINAL-REV2_Final_Presentation_Revisions/AE-PRES-FINAL-REV2-001_XGB_Result_Visibility_Audit.md`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- `epics/AE-PRES-FINAL-REV2/ledger.md`

findings:

- Standalone XGB model diagnostics exist for both temporary and permanent main runs.
- AutoGluon leaderboards include XGBoost candidates, but all final feature-set/track winners are `WeightedEnsemble_L2`.
- The final index grid has no XGB-only model key or strategy row.
- The 24 completed/reused temporary sensitivity runs have no model-family or XGB-specific dimension.

next_recommended_role: validator

changed_files:

- `05_Documentation/09_Epics/AE-PRES-FINAL-REV2_Final_Presentation_Revisions/AE-PRES-FINAL-REV2-001_XGB_Result_Visibility_Audit.md`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- `epics/AE-PRES-FINAL-REV2/ledger.md`

verification:

- Local read-only evidence was inspected with `rg`, `Get-ChildItem`, and `Import-Csv`.
- `git status --short` was run. It shows the ticket-owned June deck/source-map and ledger edits, plus known unrelated dirty paths: deleted old `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw` and untracked `07_CloudComputing/Validation/AE-VALIDATE/`.
- `git diff --name-only` was run. It includes the known unrelated old-deck deletion; scoped diff review was therefore also run against only the ticket-owned paths.
- `git diff --check` was run for the ticket-owned tracked paths and passed.
- `aegis-core/tools/validate_ticket_scope.py` was attempted with the YAML ticket envelope, but the tool expects markdown frontmatter and returned `ticket is missing YAML frontmatter opening delimiter`; manual path-scope validation was used instead.
- No model, index, sensitivity, or data-regeneration scripts were run.

validator_result:

- status: approved
- role: ds-validator
- scope: Ticket-owned changes are limited to the allowed documentation, June deck/source-map, and epic ledger paths. No `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, or `07_CloudComputing/**` paths were modified by this ticket.
- evidence: The report distinguishes standalone XGB main-run diagnostics from AutoGluon ensemble/candidate evidence and from final index/sensitivity outputs. It does not relabel AG aggregate results as XGB-specific.
- residual_risk: The PDF was not recompiled because ticket 008 owns final compile/visual QA; this ticket changed only a concise text clarification.

human_readability:

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Adds a scoped audit report and one deck/source-map clarification explaining why XGB diagnostics are not shown as XGB-only final deck results.
- layer_touched: meta
- layer_separation_preserved: true
