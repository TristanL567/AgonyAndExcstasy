# AE-ALPHA-007 Completion Report

status: completed

summary:
- Created `01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R`.
- Quantified CSI excluded-name and excluded benchmark-weight overlap with Q1-Q5 volatility quintiles.
- Quantified CSI retained portfolio exposure and active weight versus benchmark across Q1-Q5.
- Used existing CSI weights, CSI performance extract, low-volatility quintile assignments, and benchmark constituents only.
- Did not rerun CSI construction, rerun low-volatility construction/performance/tilt diagnostics, train models, create charts, stage, commit, push, or edit thesis/presentation files.

changed_files:
- `01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R`
- `05_Documentation/09_Epics/AE-ALPHA_LowVol_Tilt_Independence/Tickets/AE-ALPHA-007_Completion_Report.md`

generated_outputs:
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/csi_exclusion_quintile_overlap.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/csi_retained_quintile_exposure.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/csi_active_quintile_exposure.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/overlap_summary_by_strategy.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/overlap_diagnostics/overlap_summary_by_track_universe.{rds,csv}`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/overlap_diagnostics_report.md`
- `03_Data_Output/3_Modelling_Results/Necessary/alpha_validation/reports/overlap_diagnostics_run_status.csv`

row_counts:
- csi_exclusion_quintile_overlap: 6920
- csi_retained_quintile_exposure: 7040
- csi_active_quintile_exposure: 7040
- overlap_summary_by_strategy: 80
- overlap_summary_by_track_universe: 40

coverage_notes:
- excluded_assignment_name_coverage_median: 0.9619
- excluded_assignment_weight_coverage_median: 0.9808
- retained_assignment_weight_coverage_median: 0.9686
- benchmark_assignment_weight_coverage_median: 0.96813
- quintiles_in_exclusion: Q1, Q2, Q3, Q4, Q5
- quintiles_in_retained: Q1, Q2, Q3, Q4, Q5
- selected_strategy_rows: 16

headline_findings_neutral:
- dynamic_csi / large_cap / Q1: mean excluded-name share 0.004424; mean excluded benchmark-weight share 0.007146; mean retained CSI weight share 0.3046; mean active weight versus benchmark 0.01837.
- dynamic_csi / large_cap / Q5: mean excluded-name share 0.7167; mean excluded benchmark-weight share 0.66; mean retained CSI weight share 0.08921; mean active weight versus benchmark -0.03285.
- dynamic_csi / mid_cap / Q1: mean excluded-name share 0; mean excluded benchmark-weight share 0; mean retained CSI weight share 0.1992; mean active weight versus benchmark 0.003181.
- dynamic_csi / mid_cap / Q5: mean excluded-name share 0.9762; mean excluded benchmark-weight share 0.9752; mean retained CSI weight share 0.1723; mean active weight versus benchmark -0.01214.
- dynamic_csi / small_cap / Q1: mean excluded-name share 0.009287; mean excluded benchmark-weight share 0.01019; mean retained CSI weight share 0.2863; mean active weight versus benchmark 0.06338.
- dynamic_csi / small_cap / Q5: mean excluded-name share 0.5892; mean excluded benchmark-weight share 0.5625; mean retained CSI weight share 0.04309; mean active weight versus benchmark -0.1027.
- dynamic_csi / total_market / Q1: mean excluded-name share 0.01482; mean excluded benchmark-weight share 0.03549; mean retained CSI weight share 0.5572; mean active weight versus benchmark 0.0476.
- dynamic_csi / total_market / Q5: mean excluded-name share 0.4391; mean excluded benchmark-weight share 0.2221; mean retained CSI weight share 0.005411; mean active weight versus benchmark -0.01597.
- permanent_csi / large_cap / Q1: mean excluded-name share 0.01072; mean excluded benchmark-weight share 0.007762; mean retained CSI weight share 0.2905; mean active weight versus benchmark 0.004301.
- permanent_csi / large_cap / Q5: mean excluded-name share 0.7295; mean excluded benchmark-weight share 0.6802; mean retained CSI weight share 0.1142; mean active weight versus benchmark -0.00791.
- permanent_csi / mid_cap / Q1: mean excluded-name share 0.01646; mean excluded benchmark-weight share 0.02041; mean retained CSI weight share 0.2032; mean active weight versus benchmark 0.007109.
- permanent_csi / mid_cap / Q5: mean excluded-name share 0.7195; mean excluded benchmark-weight share 0.7027; mean retained CSI weight share 0.1644; mean active weight versus benchmark -0.02005.
- permanent_csi / small_cap / Q1: mean excluded-name share 0.01798; mean excluded benchmark-weight share 0.02816; mean retained CSI weight share 0.2333; mean active weight versus benchmark 0.01032.
- permanent_csi / small_cap / Q5: mean excluded-name share 0.6251; mean excluded benchmark-weight share 0.5752; mean retained CSI weight share 0.1256; mean active weight versus benchmark -0.02013.
- permanent_csi / total_market / Q1: mean excluded-name share 0.00782; mean excluded benchmark-weight share 0.04215; mean retained CSI weight share 0.5219; mean active weight versus benchmark 0.01228.
- permanent_csi / total_market / Q5: mean excluded-name share 0.6079; mean excluded benchmark-weight share 0.3125; mean retained CSI weight share 0.01485; mean active weight versus benchmark -0.00653.

verification:
- `Rscript -e "parse('01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R')"` completed successfully.
- `Rscript 01_Code/pipeline/11I_CSI_LowVol_Overlap_Diagnostics.R` completed successfully.
- Output checks confirmed nonzero exclusion and retained rows, Q1-Q5 representation, response-track columns, and universe columns.
- Run-status CSV records completion and no prohibited reruns or git actions.

known_caveats:
- Diagnostics are limited to selected headline/best strategies available from the existing alpha-validation performance extract.
- Q1-Q5 shares are computed over firms or weights with available low-volatility quintile assignments; coverage fields quantify assignment coverage.
- The requested AE-ALPHA-005 completion report was not present at the ticket path during worker inspection.

validator_result: approved

validator_notes:
- Script parse validation passed.
- Required overlap diagnostic outputs exist under the approved alpha-validation root.
- Run status is `completed`; row counts are nonzero for exclusion overlap, retained exposure, active exposure, and both summary tables.
- Q1-Q5 are represented in exclusion and retained exposure outputs.
- Summary tables include both response tracks (`dynamic_csi`, `permanent_csi`) and all four universes (`total_market`, `large_cap`, `mid_cap`, `small_cap`).
- Required exclusion, retained exposure, benchmark exposure, and active CSI-versus-benchmark columns are present.
- Run-status flags confirm no CSI construction rerun, low-volatility construction/performance/tilt rerun, model training, chart creation, thesis/presentation edit, staging, commit, or push.
- Report wording remains neutral and avoids final causal claims.
- Existing CSI and low-volatility outputs were used read-only for this ticket.

next_recommended_role: master
