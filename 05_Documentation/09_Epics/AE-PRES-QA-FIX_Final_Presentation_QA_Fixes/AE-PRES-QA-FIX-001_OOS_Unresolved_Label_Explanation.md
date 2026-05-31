# AE-PRES-QA-FIX-001 OOS Unresolved Label Explanation

## Scope

This ticket updates Slide 6 of the June final presentation to explain why the temporary-CSI OOS split contains 8,674 `y=NA` rows.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `1112155 AE-PRES-QA-FIX: initialize epic workspace`

## Explanation Added

The 8,674 temporary-CSI OOS `y=NA` rows are unresolved labels, not dropped observations:

- 3,342 are observable censored dynamic-trigger labels.
- 5,332 are observable 2024 rows that would require unavailable 2025 event-year labels under the annual `event_year_minus_1` alignment.

These rows remain in the observable CRSP firm-year scaffold and canonical artifacts. They are excluded from supervised training, label-based evaluation, and prevalence denominators because they are not labelled rows.

## Files Updated

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

## Source Evidence

- `05_Documentation/09_Epics/AE-PANEL_Labelled_Firm_Year_Panel/AE-PANEL-004_Temporary_CSI_Source_And_NA_Rule_Evidence.md`
- `05_Documentation/09_Epics/AE-PANEL_Labelled_Firm_Year_Panel/AE-PANEL-007_Final_Results_And_Update_List.md`
- `03_Data_Output/1_Descriptive_Statistics/Necessary/temporary_csi/csi_revised_label_scaffold_stats/overview_counts_cv_and_full.csv`

## Scope Confirmation

No data, model, index, sensitivity, cloud, or pipeline scripts were run. No `01_Code/**`, `02_Data_Input/**`, `03_Data_Output/**`, or `07_CloudComputing/**` files were modified.
