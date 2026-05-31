# AE-PRES-QA-FIX-003 Slide 10 CV/Test Model Results Check

## Scope

This ticket updates Slide 10, `Robustness II: Sensitivity Results and Limits`, so the table uses CV and test model metrics rather than OOS model metrics.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `7755097 AE-PRES-QA-FIX-002: investigate crsp bankruptcy reentry`

## Change Made

Slide 10 previously displayed OOS AP, OOS AUC, R@FPR3, and 11C total-market alpha for the selected C/M/T configurations. It now displays:

- `CV AP`
- `CV AUC`
- `CV FPR3`
- `Test AP`
- `Test AUC`
- `Test FPR3`

The OOS/index-alpha interpretation remains in the later index and robustness sections.

## Slide 10 Values

| Objective | Config | CV AP | CV AUC | CV FPR3 | Test AP | Test AUC | Test FPR3 |
|---|---|---:|---:|---:|---:|---:|---:|
| Composite | `C090_M000_T012` | 0.442 | 0.916 | 0.370 | 0.438 | 0.917 | 0.347 |
| AP winner | `C060_M000_T012` | 0.473 | 0.825 | 0.171 | 0.476 | 0.859 | 0.173 |
| 11C TM | `C090_M020_T018` | 0.198 | 0.897 | 0.279 | 0.209 | 0.906 | 0.271 |
| Baseline | `C080_M020_T018` | 0.203 | 0.862 | 0.230 | 0.199 | 0.877 | 0.200 |

## Source Evidence

- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_model_summary.csv`
- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/temporary_presentation_key_findings.csv`

## Validation

- Slide 10 table columns are CV/test only.
- OOS metric columns were removed from the Slide 10 table.
- `SLIDE_DATA_SOURCES.md` row 10 was updated.
- No model, index, data, or sensitivity computations were run.
- No `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, or `07_CloudComputing/**` files were modified.
