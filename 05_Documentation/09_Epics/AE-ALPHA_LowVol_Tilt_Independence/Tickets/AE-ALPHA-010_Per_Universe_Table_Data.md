---
epic: AE-ALPHA
ticket: AE-ALPHA-010
type: evidence_table_data
status: complete
allowed_areas:
  - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/
  - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/
must_not_touch:
  - 01_Code/
  - 02_Data_Input/
  - 06_Presentations/
  - 08_Writting/
  - 03_Data_Output/
scope:
  allowed_outputs:
    - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/**
    - 05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/**
  forbidden_outputs:
    - 01_Code/**
    - 02_Data_Input/**
    - 06_Presentations/**
    - 08_Writting/**
    - 03_Data_Output/**
scripts_run:
  - ticket-local R table generator only
forbidden_scripts_run: false
---

# AE-ALPHA-010 Per-Universe Table Data

Created table-ready Test and OOS data for risk-return and low-volatility quintile overlap across Total, Large, Mid, and Small universes. The generated data are derived from existing AE-ALPHA alpha-validation artifacts and do not rerun modelling or construction workflows.

## Outputs

- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_per_universe_risk_return_table_data.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_per_universe_overlap_table_data.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_validation_checks.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tables/AE-ALPHA-010_source_traceability.csv`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/AE-ALPHA_Risk_Return_and_Overlap_Summary.md`

## Caveats

- Existing overlap summary artifacts are full-sample only. Test and OOS overlap rows are computed from dated overlap detail rows using the established Test/OOS windows.
- These tables support comparison and interpretation only. They do not establish a causal alpha mechanism.
