# AE-SENS-PRES-002 Index Grid Coverage Audit

## Scope

This ticket audits whether local temporary-CSI sensitivity and index outputs already cover the desired index-construction robustness grid:

- lockouts: 1, 2, 3, 5 years
- thresholds: `youden`, `fpr1`, `fpr3`, `fpr5`
- transaction costs: 0, 5, 10, 20 bps
- universes: total market, large cap, mid cap, small cap
- benchmark comparison
- temporary CSI only

This was a read-only audit of data outputs. The only files created are scoped evidence files under `05_Documentation/09_Epics/AE-SENS-PRES_Sensitivity_Analysis_Presentation/`.

No model training, sensitivity scripts, index construction, code edits, presentation edits, SSH, Vast.ai access, or `03_Data_Output/**` writes were performed.

## Branch And HEAD

- Branch: `Development`
- HEAD at audit time: `bdc1d30`

## Data Locations Inspected

- `03_Data_Output/5_SensitivityAnalysis/`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/`
- `07_CloudComputing/Validation/AE-SENS/`
- `05_Documentation/09_Epics/AE-SENS-PRES_Sensitivity_Analysis_Presentation/`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

## Expected Grid Definition

The base desired temporary-CSI robustness grid has:

`4 lockouts x 4 thresholds x 4 transaction costs x 4 universes = 256 combinations`

This base count is before adding model-family dimensions or CMT sensitivity-configuration dimensions.

The required grid is written to `AE-SENS-PRES-002_required_grid.csv`.

## Observed Coverage Summary

| Coverage class | Count | Meaning |
|---|---:|---|
| `present` | 48 | Present directly in the AE-SENS CMT sensitivity 11C outputs. |
| `present_in_index_suite_not_sensitivity_grid` | 208 | Present locally in AE-INDEX-SUITE full-grid outputs, but not natively in the CMT sensitivity grid. |
| `missing` | 0 | No base grid combinations are missing if AE-INDEX-SUITE is allowed as a source. |

Observed coverage is written to `AE-SENS-PRES-002_observed_grid_coverage.csv`.

## Sensitivity CMT-Grid Coverage

The AE-SENS temporary CMT outputs contain 11C performance rows for:

- thresholds: `youden`, `fpr1`, `fpr3`
- lockouts: 1, 2, 3, 5 years
- universes: total market, large cap, mid cap, small cap
- benchmark comparison through benchmark return and difference-versus-benchmark columns
- implicit no-cost performance only

The sensitivity CMT grid does not natively contain:

- `fpr5`
- transaction-cost overlays at 5, 10, or 20 bps
- turnover outputs needed to derive those cost overlays from the retained local sensitivity files

The sensitivity CMT grid therefore supports selected temporary-CSI C/M/T robustness claims, but it is not by itself the full desired index-construction robustness grid.

## AE-INDEX-SUITE Coverage

The AE-INDEX-SUITE full-grid outputs under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/` do contain the desired temporary-CSI grid.

The manifest `comparison/full_grid_manifest.csv` confirms dynamic/temporary CSI rows with:

- threshold methods: `fpr1|fpr3|fpr5|youden`
- transaction costs: `0|5|10|20`
- indices: `large_cap|mid_cap|small_cap|total_market`
- complete strategy grid
- populated turnover

The raw temporary performance source `raw/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised/index_performance_gross_and_net_by_tc.csv` was used to verify the 256 base combinations with benchmark deltas and net transaction-cost performance. Equivalent full-grid outputs also exist for the other AE-INDEX-SUITE model families.

## Missing Or Blocked Summary

No base grid combinations are missing locally when AE-INDEX-SUITE is included as a source.

However, three CMT sensitivity configurations remain blocked partial in the AE-SENS grid:

- `C080_M000_T012`
- `C080_M000_T018`
- `C060_M020_T028`

These blocked CMT runs affect completeness of the CMT sensitivity-config dimension. They do not prevent presenting the full temporary-CSI index robustness grid from AE-INDEX-SUITE, because that grid is a separate model-family/index-suite output family.

Missing or non-native rows are written to `AE-SENS-PRES-002_missing_or_blocked_grid.csv`.

## Clear Answer

Do we already have the full temporary-CSI index robustness grid?

Yes, locally, through AE-INDEX-SUITE outputs.

No, not natively inside the AE-SENS temporary CMT sensitivity grid.

The distinction matters: AE-SENS answers C/M/T sensitivity robustness; AE-INDEX-SUITE answers full threshold/lockout/transaction-cost/index robustness. They should not be collapsed into one source family in presentation work.

## Recommendation For AE-SENS-PRES-003

AE-SENS-PRES-003 should require no computation and no rerun if its goal is presentation preparation.

Recommended next step:

- Use local summarization/aggregation only.
- Build presentation-ready sensitivity tables from `03_Data_Output/5_SensitivityAnalysis/**`.
- Build full index robustness tables from `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`.
- State explicitly that `fpr5` and transaction-cost overlays come from AE-INDEX-SUITE, not the AE-SENS CMT sensitivity grid.
- Preserve the blocker caveat for the three blocked CMT sensitivity configs.

An isolated rerun should be required only if the next ticket explicitly needs every CMT sensitivity configuration to have `fpr5` and transaction-cost overlays inside the sensitivity output family itself.

## Evidence Files

- `AE-SENS-PRES-002_required_grid.csv`
- `AE-SENS-PRES-002_observed_grid_coverage.csv`
- `AE-SENS-PRES-002_missing_or_blocked_grid.csv`
- `AE-SENS-PRES-002_source_file_map.csv`
- `AE-SENS-PRES-002_validation_checks.csv`
