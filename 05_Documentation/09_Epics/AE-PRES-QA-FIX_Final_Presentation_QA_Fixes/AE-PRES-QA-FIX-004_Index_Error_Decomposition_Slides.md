# AE-PRES-QA-FIX-004 Index Error Decomposition Slides

## Scope

This ticket adds error-cost decomposition slides directly after the main index-performance comparison slides. It uses existing decomposition outputs only and does not run index construction or generate new output data.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `c009d77 AE-PRES-QA-FIX-003: show cv and test model results`

## Changes Made

Two slides were added to the June presentation source:

1. `Temporary CSI: Error-Cost Decomposition`
   - Inserted after `Index Results: Temporary CSI at 10 bps`.
   - Covers Total, Large, Mid, and Small universes.
   - Columns: FP cost, FN cost, TP gain, TN gain, Net.

2. `Permanent CSI: Error-Cost Decomposition`
   - Inserted after `Index Results: Permanent CSI at 10 bps`.
   - Covers Total, Large, Mid, and Small universes.
   - Columns: FP cost, FN cost, TP gain, TN gain, Net.

The prior combined `Error-Cost Decomposition` slide was removed to avoid duplication. `SLIDE_DATA_SOURCES.md` was renumbered and updated to keep one source-map row per frame.

## Source Evidence

The inserted tables use the existing AE-INDEX-SUITE decomposition outputs:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_fund/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_fund/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_latent_raw/error_cost_decomposition_by_crsp_universe.csv`

## Validation Summary

- Decomposition outputs were present, so no computation ticket was required.
- Presentation source now has 51 frames.
- `SLIDE_DATA_SOURCES.md` has 51 mapped rows.
- The new decomposition slides are frame 21 and frame 24.
- No `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, or `07_CloudComputing/**` files were modified.
- No index construction, pipeline, model, or sensitivity scripts were run.
