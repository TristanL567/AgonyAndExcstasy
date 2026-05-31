# AE-PRES-FINAL-REV2-006 Feature Engineering Groups Evidence

## Scope

This evidence note supports the revised `Appendix A7: Feature Engineering Groups` slide in:

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`

Inspection was read-only for code and data-output paths. No model, data, index, or sensitivity pipeline was rerun.

## Read-Only Evidence Inspected

- `01_Code/pipeline/06B_FeatureEngineering.R`
- `01_Code/subfunctions/08B_Autoencoder.py`
- `05_Documentation/09_Epics/AE-PRES-JUNE_Final_Presentation_Update/AE-PRES-JUNE-003_Model_Result_Source_Map.md`
- `05_Documentation/09_Epics/AE-PRES-REV_Final_Presentation_Revisions/AE-PRES-REV-001_Model_Label_And_Source_Check.csv`
- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_evidence_sources.csv`

## Supported Slide Claims

| Slide group | Support found |
|---|---|
| Firm fundamentals | `06B_FeatureEngineering.R` constructs point-in-time accounting ratios and identifies numeric model features while excluding metadata columns from `feature_cols`. |
| Level and momentum | `06B_FeatureEngineering.R` creates YoY changes, acceleration, lagged expanding mean/volatility, peak deterioration, trough rise, consecutive decline counters, accounting momentum, and 3/5-year rolling mean/min/max/trend/autocorrelation. |
| Dispersion and price distress | `06B_FeatureEngineering.R` supports within-firm dispersion and distress summaries through `expvol_*`, `roll_sd_*`, `vol_12m`, `vol_60m`, `max_dd_12m`, `max_dd_60m`, and momentum columns. The inspected feature-engineering code does not support a claim that peer-universe cross-sectional rank features were engineered. |
| Macro and interactions | `06B_FeatureEngineering.R` adds macro levels to the feature set and selected interaction terms: leverage/rates, coverage/rates, debt/high-yield spreads, profitability/GDP growth, returns/VIX, and accruals/high-yield spreads. |
| Rank-style VAE scaling | `08B_Autoencoder.py` applies train-fitted median/zero imputation and a train-fitted `QuantileTransformer(output_distribution="uniform")` PIT step to continuous inputs, then reuses the fitted transform for test and OOS rows; binary recession remains binary. |
| Feature-set assembly | `AE-PRES-REV-001_Model_Label_And_Source_Check.csv` maps `fund`, `raw`, `latent_raw`, and `raw_plus_latent` to AG Base Dataset, AG Expanded Dataset, AG Latent Dataset (VAE), and AG Exp. Dataset + VAE. `06B_FeatureEngineering.R` builds `features_fund` by stripping price-direction features from `features_raw`, while `08B_Autoencoder.py` supports latent `z1..z24` plus reconstruction error. |
| Metadata excluded | `06B_FeatureEngineering.R` keeps labels, event dates, censoring fields, and diagnostics in ID/audit columns but excludes them from `feature_cols`. |

## Wording Constraint

The slide intentionally says dispersion summaries are within-firm/time-series and not peer-universe cross-sectional ranks, because the inspected local feature-engineering code did not support a peer cross-sectional rank-family claim.

## Extra Slide

No extra slide was added. The existing Appendix A7 slide was replaced with a compact, readable feature-group table.
