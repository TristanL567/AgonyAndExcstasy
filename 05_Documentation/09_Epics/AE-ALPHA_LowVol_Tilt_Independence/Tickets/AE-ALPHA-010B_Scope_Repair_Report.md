---
epic: AE-ALPHA
ticket: AE-ALPHA-010B
type: scope_repair
status: complete
allowed_areas:
  - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/
must_not_touch:
  - 01_Code/
  - 02_Data_Input/
  - 03_Data_Output/
  - 06_Presentations/
  - 08_Writting/
forbidden_scripts_run: false
---

# AE-ALPHA-010B Scope Repair Report

## Repair Summary

AE-ALPHA-010 table content was preserved, but the table-ready CSV evidence was moved into the AE-ALPHA epic documentation tree so no committed evidence path lives under `03_Data_Output/**`.

Documentation-local table evidence now lives under:

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_per_universe_risk_return_table_data.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_per_universe_overlap_table_data.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_validation_checks.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_source_traceability.csv`

The prior local generated outputs under `03_Data_Output/**` may remain on disk as ignored working files, but they are not tracked by the repaired commit.

## Preserved Evidence

- Risk-return rows: 64.
- Overlap rows: 80.
- Coverage: Test and OOS x Total, Large, Mid, and Small.
- Summary markdown still contains the full per-universe risk-return and overlap tables.

## Validation

- Table validation checks pass in `Tables/AE-ALPHA-010_validation_checks.csv`.
- Scope validation is expected to pass with committed paths limited to `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**`.
- No model training, CSI index construction, low-volatility construction, evaluation, sensitivity, pipeline, chart, presentation, or thesis-writing scripts were run.
