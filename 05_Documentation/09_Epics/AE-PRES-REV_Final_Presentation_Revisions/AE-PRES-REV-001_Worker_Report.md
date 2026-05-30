# AE-PRES-REV-001 Worker Report

## Summary

Revised the June final presentation modelling section to use presentation-ready model labels and compact main model tables. The main Modelling II and Modelling III tables now show only `Model`, `CV-AP`, `CV-AUC`, `CV-FPR3`, `Test-AP`, `Test-AUC`, and `Test-FPR3`. OOS metrics, R@FPR1, R@FPR5, Brier, and full split tables remain in Appendix A10 and Appendix A11.

## Labels Used

- `AG Expanded Dataset`
- `AG Base Dataset`
- `AG Latent Dataset (VAE)`
- `AG Exp. Dataset + VAE`

No `XGB` model-source prefix was used because no standalone XGBoost-specific presentation row was source-confirmed.

## Files Changed

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-001_Changed_Frames.csv`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-001_Model_Label_And_Source_Check.csv`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-001_Table_Column_Check.csv`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-001_Validation_Report.md`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-001_Worker_Report.md`

## Verification

Static checks confirmed the requested main-table headers, revised AG labels, appendix metric coverage, and source-map updates. The full deck was not compiled, and no data/model/index/sensitivity/pipeline scripts were run.

## Follow-Up

Route to validator for blocking review. If approved, the master can proceed to scoped commit/push outside this worker pass.
