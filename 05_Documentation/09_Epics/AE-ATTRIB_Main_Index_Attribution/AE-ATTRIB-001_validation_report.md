# AE-ATTRIB-001 Validation Report

## Checks

| Check | Result | Evidence |
|---|---|---|
| Branch is Development | pass | Checked before execution. |
| Outputs limited to scoped folder | pass | All created files are under `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/`. |
| No slide edits | pass | No `06_Presentations/**` files were edited. |
| No data edits | pass | No `03_Data_Output/**` files were edited. |
| No protected code/input/cloud edits | pass | No `01_Code/**`, `02_Data_Input/**`, or `07_CloudComputing/**` files were edited. |
| No model/index/sensitivity/pipeline scripts run | pass | Only local CSV reading and evidence writing were performed. |
| Temporary and permanent CSI covered | pass | Tracks covered: permanent CSI, temporary CSI. |
| Models covered | pass | Models covered: fund, latent_raw, raw, raw_plus_latent. |
| Transaction costs covered | pass | Costs covered: 0, 5, 10, 20 bps. |
| Reconciliation checks pass | pass | 5120 of 5120 rows pass exactly within tolerance. |
| Missing configurations listed | pass | Missing configuration count: 0. |

## Missing Configurations

None found for the main `raw`, `fund`, `latent_raw`, and `raw_plus_latent` folders. Pilot and raw_overlay duplicate folders were intentionally excluded from the main-run attribution.

## Reconciliation Formula

`TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment = realized alpha`
