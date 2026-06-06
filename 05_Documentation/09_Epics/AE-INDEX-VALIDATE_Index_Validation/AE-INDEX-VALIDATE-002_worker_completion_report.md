# AE-INDEX-VALIDATE-002 Worker Completion Report

## Ticket

- Epic: `AE-INDEX-VALIDATE`
- Ticket: `AE-INDEX-VALIDATE-002`
- Role: model/index interpretation worker
- Branch: `Development`
- Status: complete, pending validator review

## Summary

Diagnosed selected OOS best-strategy rows from `AE-INDEX-VALIDATE-001` to compare excluded false positives against retained true negatives and the retained strategy portfolio.

Main finding: false positives underperform retained true negatives in 6 of 8 selected rows, especially all permanent CSI rows, but they underperform the retained portfolio in only 1 of 8 selected rows. The evidence is compatible with a broader quality-screen interpretation, but it is not a pure event-avoidance story and does not support causal claims.

## Artifacts Created

- `05_Documentation/09_Epics/AE-INDEX-VALIDATE_Index_Validation/AE-INDEX-VALIDATE-002_Excluded_Firm_Return_Diagnostic.md`
- `05_Documentation/09_Epics/AE-INDEX-VALIDATE_Index_Validation/AE-INDEX-VALIDATE-002_excluded_vs_retained_summary.csv`
- `05_Documentation/09_Epics/AE-INDEX-VALIDATE_Index_Validation/AE-INDEX-VALIDATE-002_worker_completion_report.md`

## Evidence Used

- `05_Documentation/09_Epics/AE-INDEX-VALIDATE_Index_Validation/AE-INDEX-VALIDATE-001_selected_strategy_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_fn_tn_diagnostics.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_realized_attribution_summary.csv`
- Source decomposition files referenced by the selected strategy attribution CSV.
- `01_Code/pipeline/11C_IndexConstruction_Revised.R` read only to confirm decomposition field construction.

## Scope Compliance

Allowed write areas used:

- `05_Documentation/09_Epics/AE-INDEX-VALIDATE_Index_Validation/**`
- `epics/AE-INDEX-VALIDATE/**`

No files were written under `03_Data_Output/11_IndexValidation/**`; no full derived output was needed.

Must-not-touch areas were not modified:

- `01_Code/**`
- `02_Data_Input/**`
- `06_Presentations/**`
- `07_CloudComputing/**`
- `C:/Users/Tristan Leiter/Documents/aegis-core/**`

## Verification

- Confirmed ticket dependency from `epics/AE-INDEX-VALIDATE/ledger.md`: `AE-INDEX-VALIDATE-001` has `validator_approved`.
- Confirmed selected OOS rows cover temporary CSI and permanent CSI for `large_cap`, `mid_cap`, `small_cap`, and `total_market`.
- Joined each selected row to its listed source decomposition file by period, universe, model, threshold method, lockout years, exclusion rule, and strategy ID.
- Did not run model training, model evaluation, index construction reruns, sensitivity scripts, pipeline regeneration, or presentation compile.
- Did not stage, commit, or push.

## Human Readability

The diagnostic report separates temporary and permanent CSI results, includes universe-level tables, and answers the required interpretive questions directly. It explicitly distinguishes non-CSI false-positive label status from realized economic underperformance and states limitations on the derived return proxy.

## Next Recommended Role

validator
