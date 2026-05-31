# AE-PRES-FINAL-REV2-005 Outside-Sample Cases Evidence

## Scope

Clarified slide 32's explanation of the 84 CRSP 572--574 bankruptcy-related firms that remain outside the displayed labelled positive count after the terminal-failure route.

## Read-only evidence used

No data, model, index, or sensitivity scripts were run. No `03_Data_Output` artifacts were written.

Read-only sources:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/F_bankruptcy_detection_by_grid.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/F_bankruptcy_detection_firm_detail.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/G_revised_csi_event_counts_by_grid.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/terminal_failure_additive_summary_events.csv`
- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/terminal_failure_additive_summary_labels.csv`
- `05_Documentation/09_Epics/AE-PANEL_Labelled_Firm_Year_Panel/AE-PANEL-004_Temporary_CSI_Source_And_NA_Rule_Evidence.md`
- `05_Documentation/09_Epics/AE-PANEL_Labelled_Firm_Year_Panel/AE-PANEL-007_Final_Results_And_Update_List.md`

## Evidence summary

Slide 32 reports the baseline `C080_M020_T018` bankruptcy-detection comparison:

| Scenario | Bankrupting | Detected | Missed | Detection |
|---|---:|---:|---:|---:|
| CSI only | 629 | 151 | 478 | 24.0% |
| CSI + terminal failure | 629 | 545 | 84 | 86.65% |

The mapped local evidence establishes that temporary CSI keeps the original drawdown-trigger logic and adds terminal failure only as a terminal-failure route after a valid drawdown trigger. AE-PANEL evidence also records the accepted current rule: terminal-failure positives are included, censored triggers and unavailable future labels become `y=NA`, canonical artifacts retain `y=NA`, and supervised training/evaluation use labelled rows only.

The available local evidence does not provide a finer audited reason for each of the 84 remaining firms. Therefore the slide should not invent a more specific cause. The cautious conclusion is that the 84 are CRSP 572--574 firms not captured by a valid drawdown trigger within the terminal-failure timing window in the checked local evidence; they remain outside labelled positives and are not treated as known pipeline errors.

## Slide wording conclusion

Updated slide 32 note:

> The 84 are CRSP 572--574 firms not captured by a valid drawdown trigger within the terminal-failure timing window. They remain outside labelled positives, not known pipeline errors.
