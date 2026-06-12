# AE-TEMP-CSI-RECON-001 Reconciliation Report

Epic: AE-TEMP-CSI-RECON
Ticket: AE-TEMP-CSI-RECON-001
Date: 2026-06-12
Scope: evidence-only reconciliation of Draft presentation slide 6 and slide 8 temporary CSI counts.

## AEGIS Materials Loaded

- `C:\Users\Tristan Leiter\Documents\aegis-core\AEGIS.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\epic-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\ticket-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\contracts\swarm-contract.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\multi-master-dispatch.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\clean-commit.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\execution\runbooks\shared-orchestration-loop.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\master-planner\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\model-interpreter-worker\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\roles\ds-validator\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\ticket-scope-validation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\model-output-interpretation\SKILL.md`
- `C:\Users\Tristan Leiter\Documents\aegis-core\skills\procedures\clean-commit\SKILL.md`

No relevant AEGIS role or skill contract was missing.

## Reconciliation Conclusion

There is no direct contradiction between Draft slide 6 and slide 8 once the units are separated.

Slide 6 reports final model-ready temporary CSI response observations on the cleaned observable firm-year scaffold:

- `y = 1`: 8,517 final response rows
- `y = 0`: 171,269 final response rows
- `y = NA`: 8,674 unresolved rows retained in the scaffold but excluded from supervised metrics
- total scaffold rows: 188,460

Slide 8 reports a firm-level CRSP default-overlap diagnostic:

- default universe: 629 unique CRSP 572-574 bankruptcy-related firms
- confirmed-only detected firms: 151
- terminal-failure-inclusive detected firms: 545
- gross firm-detection increase: 394
- detection rate after terminal-failure inclusion: 86.65%

The apparent mismatch comes from comparing different units:

1. `8,517` is a final cleaned firm-year response-row count.
2. `545` is a unique default-firm detection count.
3. `8,369` in the slide-7 before table is a confirmed-CSI source/event-cell count, not the same final cleaned response-row unit as slide 6.
4. The valid same-scaffold comparison is 8,217 old confirmed-only final labels versus 8,517 current final labels, a net increase of 300 final response rows.

Therefore, `8,517 - 8,369 = 148` is a mixed-unit arithmetic difference and should not be interpreted as the terminal-failure label addition.

## Gross-to-Net Bridge

The terminal-failure addition starts as 2,075 terminal-failure event rows. These do not map one-for-one into final response observations:

- 1,471 event rows collapse because multiple terminal-failure event rows fall into already represented firm-year cells.
- 296 terminal-failure annual cells are already positive under the confirmed-CSI rule.
- 8 new terminal-failure annual cells are outside the final model-ready scaffold.
- 0 new terminal-failure cells are lost to an additional `NA`/unlabelled override once they are inside the final scaffold.
- 300 terminal-failure annual cells are added to final `y = 1` response rows.

This reconciles the same-unit label counts:

```text
  8,217 old confirmed-only final y=1 rows
+   300 terminal-failure additions that survive into the final scaffold
=  8,517 final temporary CSI y=1 rows
```

The firm-detection diagnostic has a separate bridge:

```text
  151 CRSP 572-574 firms detected by confirmed CSI only
+ 394 additional CRSP 572-574 firms detected by the terminal-failure-inclusive diagnostic
= 545 CRSP 572-574 firms detected by temporary CSI
```

## Slide Correctness

Slide 6 is correct for the final model-ready response-label scaffold. Its numbers match `overview_counts_cv_and_full.csv`, `overview_by_track_response.csv`, and `labels_base.rds`.

Slide 8 is correct as a firm-level CRSP 572-574 detection diagnostic. Its `629`, `545`, `84`, and `86.65%` values match `temporary_csi_crsp_default_overlap_summary.csv` and the corresponding temporary CSI bankruptcy-overlap methodology documentation.

The important caveat is wording/interpretation: slide 8 must not be read as saying that terminal failures add 394 final response rows. It says terminal-failure-inclusive temporary CSI detects 394 more unique CRSP 572-574 default firms than confirmed CSI alone.

## Sources Used

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/Draft/FinalPresentation_TristanLeiter_h11815352_Draft.Rnw`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_base.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/csi_events_base.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds`
- `03_Data_Output/1_Descriptive_Statistics/Necessary/temporary_csi/csi_revised_label_scaffold_stats/overview_counts_cv_and_full.csv`
- `03_Data_Output/1_Descriptive_Statistics/Necessary/temporary_csi/csi_response_stats/overview_by_track_response.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/F_bankruptcy_detection_by_grid.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/terminal_failure_additive_summary_events.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/terminal_failure_additive_summary_labels.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv`
- `05_Documentation/01_Methodology/03_Classification/Necessary/Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md`
- `05_Documentation/09_Epics/AE-PANEL_Labelled_Firm_Year_Panel/AE-PANEL-004_Temporary_CSI_Source_And_NA_Rule_Evidence.md`
- `01_Code/pipeline/05A_Dynamic_CSI_Label.R`
- `01_Code/pipeline/13b_Dynamic_CSI_Delisting_Detection_Revised_Temporary_CSI_572_574.R`

All source files were inspected read-only. No model, index, evaluation, sensitivity, presentation compile, Vast, or SSH operation was run.

## Commit State

No commit was created in this ticket because validator approval is blocking and has not yet been provided in this thread.
