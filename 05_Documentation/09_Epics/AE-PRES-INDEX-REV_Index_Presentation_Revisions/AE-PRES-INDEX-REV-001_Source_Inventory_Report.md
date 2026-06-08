# AE-PRES-INDEX-REV-001 Source Inventory Report

## Scope

Ticket `AE-PRES-INDEX-REV-001` inventories the current June deck index section and maps sources for planned OOS/test index-result and attribution slides. This ticket is readiness/source-inventory only. No presentation, data-output, code, input, or cloud files were edited.

Target deck files inspected:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

## AEGIS Materials Loaded

- `C:/Users/Tristan Leiter/Documents/aegis-core/AEGIS.md`
- `contracts/epic-contract.md`
- `contracts/ticket-contract.md`
- `contracts/swarm-contract.md`
- `execution/runbooks/multi-master-dispatch.md`
- `execution/runbooks/clean-commit.md`
- `skills/roles/master/SKILL.md`
- `skills/roles/chart-worker/SKILL.md`
- `skills/roles/model-interpreter-worker/SKILL.md`
- `skills/roles/ds-validator/SKILL.md`
- `skills/roles/code-validator/SKILL.md`
- `skills/procedures/ticket-scope-validation/SKILL.md`

No distinct `presentation-worker` or `source-map validation` skill file was present in the referenced AEGIS role/procedure folders; this inventory uses the closest applicable worker and blocking validator guidance.

## Current Index Section Inventory

The current June deck index section begins at `\section{E. Index Construction}` around line 886 of the Rnw. The main index-result section currently includes:

- methodology frames for score-to-weight and benchmark universes;
- a temporary CSI test-set result frame at 10 bps;
- temporary CSI OOS result frames at 0 bps and 10 bps;
- temporary CSI OOS error-cost and realized active attribution frames;
- a permanent CSI frame currently titled as test-set 0 bps but mapped in `SLIDE_DATA_SOURCES.md` to OOS 0 bps sources;
- permanent CSI OOS error-cost and realized active attribution frames;
- permanent CSI OOS 10 bps frame;
- transaction-cost robustness, turnover effect, threshold-family/turnover, and sensitivity frames.

The detailed frame inventory is in `AE-PRES-INDEX-REV-001_current_frame_inventory.csv`.

## Source Availability Summary

OOS temporary and permanent CSI result slides are source-ready. The core source is:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`

Model-level OOS performance files also exist for the currently used temporary and permanent model families under:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/fund/...`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/...`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/latent_raw/...`

OOS error-cost and realized contribution slides are source-ready. Error-cost decomposition files exist per model family as `error_cost_decomposition_by_crsp_universe.csv`; realized contribution and reconciliation are available in:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`

Test result slides are source-ready from the isolated test-set construction output:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`

Validation evidence in `AE-FP-DIAG-006_validation_checks.csv` confirms the isolated test performance output covers `period=test`, years 2016-2019, tracks `dynamic_csi` and `permanent_csi`, and transaction costs 0, 5, 10, and 20 bps.

## Test Attribution Gap Status

Test-period error-cost and realized contribution data exist in the main attribution/decomposition suite:

- `AE-ATTRIB-001_config_level_attribution.csv` has `period=test` rows for temporary CSI and permanent CSI at transaction costs 0, 5, 10, and 20 bps.
- The linked `source_decomposition_file` values point to model-level `error_cost_decomposition_by_crsp_universe.csv` files under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/...`.

However, no standalone test-only error-cost, attribution, contribution, or decomposition file exists under `03_Data_Output/9_TestIndexConstruction`. Therefore:

- Blocks D and H are `partial` in the required-source matrix.
- The slide can use existing main-suite `period=test` diagnostics with a caveat.
- If the intended revision requires diagnostics generated from the isolated AE-FP-DIAG-006 test-only output folder, a separate data-preparation ticket is required before slide edits.

## Planned Blocks A-L

All planned blocks A-L are represented in `AE-PRES-INDEX-REV-001_required_source_matrix.csv`.

High-level classification:

- A, B, E, F, I, J, K, L: source-ready from OOS index, attribution, robustness, turnover, threshold, and sensitivity artifacts.
- C and G: source-ready from isolated test-set result artifacts.
- D and H: available with caveat through main-suite `period=test` attribution/decomposition; missing standalone isolated test-only diagnostic artifacts.

## Proposed Slide Order

The proposed order is in `AE-PRES-INDEX-REV-001_proposed_slide_order.md`. It keeps methodology first, pairs each track's OOS result with contribution diagnostics, then pairs each track's test result with the caveated diagnostic view, and closes with robustness, turnover, threshold-family interpretation, and sensitivity.

## Handoff Notes

- Do not edit presentation files until the next slide-edit ticket.
- The next slide-edit ticket should correct the current permanent CSI 0 bps frame title/source mismatch.
- For test diagnostic slides, decide before editing whether the caveated existing attribution source is acceptable or whether a data-preparation ticket must create standalone test-only diagnostic/contribution artifacts.
