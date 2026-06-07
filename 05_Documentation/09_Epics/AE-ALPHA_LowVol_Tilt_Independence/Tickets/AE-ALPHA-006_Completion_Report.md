# AE-ALPHA-006 Completion Report

status: completed

summary:
- Created `01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R`.
- Produced observable characteristic and sector diagnostics for benchmark, Q1, Q5, and selected CSI headline/best strategies.
- Used no-look-ahead alignment by matching holding year Y to feature year Y-1.
- Did not rerun CSI construction, rerun low-volatility construction, train models, create charts, stage, commit, push, or edit thesis/presentation files.

changed_files:
- `01_Code/pipeline/11H_Characteristic_Tilt_Diagnostics.R`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-006_Completion_Report.md`

generated_outputs:
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/characteristic_field_manifest.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/portfolio_characteristic_summary.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/portfolio_characteristic_differences.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/sector_weight_summary.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/tilt_diagnostics/sector_active_weight_summary.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/characteristic_tilt_diagnostics_report.md`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/tilt_diagnostics_run_status.csv`

row_counts:
- characteristic_field_manifest: 30
- portfolio_characteristic_summary: 115776
- portfolio_characteristic_differences: 269568
- sector_weight_summary: 42958
- sector_active_weight_summary: 42958

fields_included:
- volatility: vol_12m, vol_60m
- size: log_mkvalt, log_at, security_mktcap
- sector: siccd
- profitability_quality: roa, roe, roic, gross_margin, ebitda_margin, ocf_margin
- leverage_solvency: leverage, net_debt_ebitda, interest_cov, current_ratio, quick_ratio
- altman_z: altman_z, altman_z1, altman_z2, altman_z3, altman_z4, altman_z5
- market_value_deterioration: peak_drop_log_mkvalt, consec_decline_log_mkvalt, yoy_log_mkvalt
- liquidity: liquidity_dollar_volume, liquidity_share_turnover

fields_missing:
- volatility: trailing_volatility
- sector: sich

coverage_notes:
- benchmark / altman_z: median weight coverage 0.958, minimum 0
- Q1 / altman_z: median weight coverage 0.9597, minimum 0
- CSI headline/best / altman_z: median weight coverage 0.9441, minimum 0.5982
- Q5 / altman_z: median weight coverage 0.9827, minimum 0
- benchmark / market_value_deterioration: median weight coverage 0.9319, minimum 0
- Q1 / market_value_deterioration: median weight coverage 0.9185, minimum 0
- CSI headline/best / market_value_deterioration: median weight coverage 0.9067, minimum 0.7163
- Q5 / market_value_deterioration: median weight coverage 0.9805, minimum 0
- benchmark / leverage_solvency: median weight coverage 0.875, minimum 0.7117
- Q1 / leverage_solvency: median weight coverage 0.8914, minimum 0.3681
- CSI headline/best / leverage_solvency: median weight coverage 0.8793, minimum 0.6134
- Q5 / leverage_solvency: median weight coverage 0.9614, minimum 0.4983
- benchmark / profitability_quality: median weight coverage 0.9919, minimum 0.8637
- Q1 / profitability_quality: median weight coverage 0.9894, minimum 0.6979
- CSI headline/best / profitability_quality: median weight coverage 0.9855, minimum 0.786
- Q5 / profitability_quality: median weight coverage 0.9939, minimum 0.7803
- benchmark / liquidity: median weight coverage 1, minimum 0.9983
- Q1 / liquidity: median weight coverage 1, minimum 1
- CSI headline/best / liquidity: median weight coverage 0.9961, minimum 0.8816
- Q5 / liquidity: median weight coverage 1, minimum 0.9898
- benchmark / size: median weight coverage 0.9949, minimum 0
- Q1 / size: median weight coverage 0.9932, minimum 0
- CSI headline/best / size: median weight coverage 0.9885, minimum 0.7704
- Q5 / size: median weight coverage 0.9982, minimum 0
- benchmark / volatility: median weight coverage 1, minimum 0.9972
- Q1 / volatility: median weight coverage 1, minimum 0.9993
- CSI headline/best / volatility: median weight coverage 0.9858, minimum 0.8235
- Q5 / volatility: median weight coverage 1, minimum 0.9352

headline_findings_neutral:
- CSI headline/best versus benchmark / altman_z: median weighted-mean difference 0.004868.
- CSI headline/best versus Q5 / altman_z: median weighted-mean difference 0.01698.
- CSI headline/best versus Q1 / altman_z: median weighted-mean difference 0.07101.
- CSI headline/best versus benchmark / leverage_solvency: median weighted-mean difference -0.002281.
- CSI headline/best versus Q5 / leverage_solvency: median weighted-mean difference -0.2462.
- CSI headline/best versus Q1 / leverage_solvency: median weighted-mean difference 0.3267.
- CSI headline/best versus benchmark / liquidity: median weighted-mean difference -0.1157.
- CSI headline/best versus Q5 / liquidity: median weighted-mean difference -2.181.
- CSI headline/best versus Q1 / liquidity: median weighted-mean difference 1.055.
- CSI headline/best versus benchmark / market_value_deterioration: median weighted-mean difference -0.005127.
- CSI headline/best versus Q5 / market_value_deterioration: median weighted-mean difference -0.01386.
- CSI headline/best versus Q1 / market_value_deterioration: median weighted-mean difference 0.03962.
- CSI headline/best versus benchmark / profitability_quality: median weighted-mean difference 0.008103.
- CSI headline/best versus Q5 / profitability_quality: median weighted-mean difference 0.1382.
- CSI headline/best versus Q1 / profitability_quality: median weighted-mean difference -0.01116.
- CSI headline/best versus benchmark / size: median weighted-mean difference 0.01133.
- CSI headline/best versus Q5 / size: median weighted-mean difference 1.46.
- CSI headline/best versus Q1 / size: median weighted-mean difference -0.3829.
- CSI headline/best versus benchmark / volatility: median weighted-mean difference -0.002067.
- CSI headline/best versus Q5 / volatility: median weighted-mean difference -0.08061.
- CSI headline/best versus Q1 / volatility: median weighted-mean difference 0.02787.

verification:
- Worker ran parse and execution checks after implementation; see final worker envelope for exact command results.

known_caveats:
- The requested AE-ALPHA-005 completion report was not present at the expected path during worker inspection.
- CSI diagnostics are limited to selected headline/best strategies available from the existing alpha-validation performance extract.
- Liquidity is a prior-year monthly proxy based on available CRSP `vol`, `shrout`, and price fields.

validator_result: approved

validator_notes:
- Script parse validation passed.
- Required tilt diagnostic outputs exist under the approved alpha-validation root.
- Run status is `completed`; row counts are nonzero for characteristic summaries, differences, sector weights, and sector active weights.
- Field manifest records 28 included fields and 2 missing fields (`trailing_volatility`, `sich`) without failing the ticket.
- Portfolio groups include benchmark, Q1, Q5, and CSI headline/best.
- Diagnostic families include volatility, size, sector, profitability/quality, leverage/solvency, Altman Z, market-value deterioration, and liquidity proxy where available.
- Benchmark/Q1/Q5 annual-feature coverage is populated after the corrected no-look-ahead feature alignment.
- Differences include benchmark, Q1, and Q5 comparison bases, with finite CSI headline/best comparisons.
- Sector diagnostics are present and populated.
- Report wording remains diagnostic and avoids final causal claims.
- No staging, commit, push, thesis edit, or presentation edit was performed for this ticket.

next_recommended_role: master
