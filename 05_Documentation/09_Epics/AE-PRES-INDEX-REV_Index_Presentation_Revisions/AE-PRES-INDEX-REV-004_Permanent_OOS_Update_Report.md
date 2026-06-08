# AE-PRES-INDEX-REV-004 Permanent OOS Update Report

## Scope

Ticket `AE-PRES-INDEX-REV-004` revises the Permanent CSI OOS index-result block in the June final presentation. The edit is limited to:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- ticket evidence under `05_Documentation/09_Epics/AE-PRES-INDEX-REV_Index_Presentation_Revisions/`
- `epics/AE-PRES-INDEX-REV/ledger.md`

No data, code, input, cloud, model, index-construction, evaluation, sensitivity, or pipeline files were modified or regenerated.

## Changed Slides

The prior Permanent CSI OOS block contained separate 0 bps result, error-cost diagnostic, realized active attribution, and 10 bps result slides. It now has the required two-slide OOS 10 bps block:

1. `Permanent CSI OOS Index Results at 10 bps`
2. `Permanent CSI OOS Diagnostic and Active Contribution`

The new diagnostic slide combines the accepted attribution formula and the error-cost diagnostic interpretation into one readable slide.

## Source Files Used

Result slide:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/index_performance_gross_and_net_by_tc.csv`

Diagnostic/contribution slide:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_Main_Index_Attribution_Report.md`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/error_cost_decomposition_by_crsp_universe.csv`

Detailed row-level traceability is in `AE-PRES-INDEX-REV-004_source_traceability.csv`.

## Key Interpretation Added

The combined diagnostic slide explicitly avoids causal overclaiming. It states that Permanent CSI alpha is not mainly direct TP event-avoidance gain. Because permanent positives are rare, realized alpha is mostly retained-stock reweighting plus geometric portfolio effects, with FP exclusion cost as the main direct offset where exclusions are too broad.

## Notes For Validator

- Strategy rows are Permanent CSI, `period=oos`, and `transaction_cost_bps=10`.
- Result-slide strategy rows use 10 bps net performance; benchmark rows use the deck's unfiltered market-cap reference convention.
- Contribution rows use `track=permanent CSI`, `period=oos`, `transaction_cost_bps=10` from `AE-ATTRIB-001_config_level_attribution.csv`.
- `SLIDE_DATA_SOURCES.md` rows 24 and 25 were updated for the changed slides, and later source-map frame numbers were mechanically renumbered down by two because four prior permanent slides were consolidated into two.
