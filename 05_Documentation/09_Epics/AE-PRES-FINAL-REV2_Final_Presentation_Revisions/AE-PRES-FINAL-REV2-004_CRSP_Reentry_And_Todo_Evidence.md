# AE-PRES-FINAL-REV2-004 CRSP Reentry And To-Do Evidence

## Scope

Updated the June final presentation to add the requested CRSP bankruptcy reentry clarification and a narrow To-Do slide limited to index-construction future tasks.

## Read-only evidence check

No data, model, index, or sensitivity artifacts were regenerated. The following existing local artifacts were read only:

- `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/F_bankruptcy_detection_firm_detail.csv`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds`
- `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds`
- `02_Data_Input/01_CRSP/Necessary/universe.rds`

Read-only checks found:

| Check | Result |
|---|---:|
| CRSP 572-574 bankruptcy-related firms checked | 629 |
| Annual sample rows after the bankruptcy delisting year | 0 |
| CRSP-like index constituent rows after the bankruptcy delisting date | 0 |
| Specific reentry CRSP code present in the checked universe metadata | No |

The checked bankruptcy-detail artifact contains CRSP delisting codes 573 and 574 within the 572-574 bankruptcy-related range. It does not provide a separate reentry code. The deck wording therefore says there is no specific reentry CRSP code in the checked evidence, not that CRSP has no such concept anywhere outside the local evidence reviewed here.

## Slide updates

- Slide 29 is now `CRSP Bankruptcy Reentry Check` and states that no checked CRSP 572-574 firms reentered the annual sample or CRSP-like index after the relevant bankruptcy delisting evidence.
- Slide 29 also states that no specific reentry CRSP code appears in the checked evidence.
- Added `To-Do: Index Construction`, limited to low-volatility and quality index-construction approaches.
- No broader future-work items were added to the To-Do slide.

## Validation

- Verified the Rnw source contains the CRSP reentry wording and narrow To-Do items.
- Rebuilt the June PDF from the `.Rnw` source.
- Verified the source map rows for slides 29 and 30 reflect the new CRSP reentry and To-Do slides.
