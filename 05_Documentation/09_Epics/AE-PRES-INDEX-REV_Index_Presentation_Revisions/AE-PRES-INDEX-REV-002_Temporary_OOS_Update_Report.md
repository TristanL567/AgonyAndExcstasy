# AE-PRES-INDEX-REV-002 Temporary OOS Update Report

## Scope

Ticket `AE-PRES-INDEX-REV-002` revises the temporary-CSI OOS index-result block in the June final presentation. The edit is limited to the index-results section of:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

No data, code, input, cloud, model, index-construction, evaluation, sensitivity, or pipeline files were modified or regenerated.

## Changed Slides

The temporary OOS block now has two slides immediately after the existing test-set index check:

1. `Temporary CSI OOS Index Results at 10 bps`
2. `Temporary CSI OOS Diagnostic and Active Contribution`

The prior separate temporary OOS 0 bps, error-cost diagnostic, realized active attribution, and duplicate 10 bps result frames were consolidated into these two OOS slides. Permanent, test, transaction-cost robustness, turnover, and sensitivity content was not intentionally revised for this ticket.

## Source Files Used

Result slide:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/index_performance_gross_and_net_by_tc.csv`

Diagnostic/contribution slide:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_Main_Index_Attribution_Report.md`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`

Detailed row-level traceability is in `AE-PRES-INDEX-REV-002_source_traceability.csv`.

## Key Interpretation Added

The revised combined diagnostic slide explicitly avoids overclaiming direct event avoidance. It states that false-positive opportunity cost is the largest direct exclusion offset and that retained-stock reweighting plus geometric portfolio effects explain most of the OOS alpha, with Small Cap showing the clearest direct TP exclusion contribution.

## Notes For Validator

- Strategy rows are OOS temporary CSI and use `transaction_cost_bps=10`.
- Benchmark rows use the existing deck convention: unfiltered market-cap reference rows without strategy exclusion-cost overlay.
- Contribution rows use `track=temporary CSI`, `period=oos`, `transaction_cost_bps=10` from `AE-ATTRIB-001_config_level_attribution.csv`.
- `SLIDE_DATA_SOURCES.md` rows 21 and 22 were updated for the changed slides, and later source-map frame numbers were mechanically renumbered because the temporary OOS block now has two fewer frames.
